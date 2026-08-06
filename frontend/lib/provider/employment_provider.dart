import 'package:flutter_riverpod/legacy.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class EmploymentState {
  final String companyName;
  final String annualSalary;
  final String employmentLength;
  final String otherIncome;
  final String? uploadedFileName;
  final String? uploadedFilePath;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, String> fieldErrors;
  final int lastSubmittedStep;

  const EmploymentState({
    this.companyName = '',
    this.annualSalary = '',
    this.employmentLength = '',
    this.otherIncome = '',
    this.uploadedFileName,
    this.uploadedFilePath,
    this.isLoading = false,
    this.errorMessage,
    this.fieldErrors = const <String, String>{},
    this.lastSubmittedStep = 1,
  });

  EmploymentState copyWith({
    String? companyName,
    String? annualSalary,
    String? employmentLength,
    String? otherIncome,
    String? uploadedFileName,
    String? uploadedFilePath,
    bool? isLoading,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    int? lastSubmittedStep,
  }) {
    return EmploymentState(
      companyName: companyName ?? this.companyName,
      annualSalary: annualSalary ?? this.annualSalary,
      employmentLength: employmentLength ?? this.employmentLength,
      otherIncome: otherIncome ?? this.otherIncome,
      uploadedFileName: uploadedFileName ?? this.uploadedFileName,
      uploadedFilePath: uploadedFilePath ?? this.uploadedFilePath,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      lastSubmittedStep: lastSubmittedStep ?? this.lastSubmittedStep,
    );
  }
}

class EmploymentNotifier extends StateNotifier<EmploymentState> {
  EmploymentNotifier() : super(const EmploymentState());

  Map<String, String> _clearError(String field) {
    final errors = Map<String, String>.from(state.fieldErrors);
    errors.remove(field);
    return errors;
  }

  void updateCompanyName(String v) =>
      state = state.copyWith(companyName: v, fieldErrors: _clearError('companyName'));
  void updateAnnualSalary(String v) =>
      state = state.copyWith(annualSalary: v, fieldErrors: _clearError('annualSalary'));
  void updateEmploymentLength(String v) =>
      state = state.copyWith(employmentLength: v, fieldErrors: _clearError('employmentLength'));
  void updateOtherIncome(String v) =>
      state = state.copyWith(otherIncome: v, fieldErrors: _clearError('otherIncome'));

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final errors = _clearError('uploadedFile');
        state = state.copyWith(
          uploadedFileName: file.name,
          uploadedFilePath: file.path ?? file.name,
          fieldErrors: errors,
        );
      }
    } catch (_) {
      // user cancelled or permission denied — do nothing
    }
  }

  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (state.companyName.trim().isEmpty) {
      errors['companyName'] = 'Company Name is required';
    }
    if (state.annualSalary.trim().isEmpty) {
      errors['annualSalary'] = 'Annual Salary is required';
    }
    if (state.employmentLength.trim().isEmpty) {
      errors['employmentLength'] = 'Employment Length is required';
    }
    if (state.otherIncome.trim().isEmpty) {
      errors['otherIncome'] = 'Other Income Sources is required (enter "None" if not applicable)';
    }
    if (state.uploadedFileName == null || state.uploadedFileName!.trim().isEmpty) {
      errors['uploadedFile'] = 'Please upload Proof of Income';
    }
    return errors;
  }

  Future<bool> next() async {
    final errors = _validate();
    if (errors.isNotEmpty) {
      state = state.copyWith(fieldErrors: errors);
      return false;
    }
    state = state.copyWith(isLoading: true, errorMessage: null, fieldErrors: {});
    try {
      // Only submit step 2 if not already submitted
      if (state.lastSubmittedStep < 2) {
        final response2 = await ApiClient().dio.post(
          '/users/me/onboarding/2',
          data: {
            'step': 2,
            'data': {
              'employment': {
                'company': state.companyName.trim(),
                'salary': state.annualSalary.trim(),
                'length': state.employmentLength,
                'otherIncome': state.otherIncome.trim(),
                'proof_url': state.uploadedFileName ?? '',
              },
            },
          },
        );
        if (response2.statusCode != 200 && response2.data['success'] != true) {
          final msg = response2.data['message'] ?? 'Failed to save employment data';
          state = state.copyWith(isLoading: false, errorMessage: msg);
          return false;
        }
        state = state.copyWith(lastSubmittedStep: 2);
      }

      // Only submit step 3 if not already submitted
      if (state.lastSubmittedStep < 3) {
        final String rawFileName = state.uploadedFileName ?? '';
        final String validUrl = rawFileName.startsWith('http')
            ? rawFileName
            : 'https://storage.app/uploads/$rawFileName';

        final docs = rawFileName.isNotEmpty
            ? [
                {
                  'type': 'proof_of_income',
                  'url': validUrl,
                }
              ]
            : [];

        await ApiClient().dio.post(
          '/users/me/onboarding/3',
          data: {
            'step': 3,
            'data': {
              'documents': docs,
            },
          },
        );
        state = state.copyWith(lastSubmittedStep: 3);
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      String msg = 'An unexpected error occurred';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map) {
          final err = data['message'] ?? data['error'];
          if (err is List) {
            msg = err.map((e) => e.toString()).join(', ');
          } else if (err != null) {
            msg = err.toString();
          }
        } else if (data is String && data.isNotEmpty) {
          msg = data;
        } else {
          msg = e.message ?? msg;
        }
      }
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    }
  }
}

final employmentProvider =
    StateNotifierProvider<EmploymentNotifier, EmploymentState>(
      (ref) => EmploymentNotifier(),
    );
