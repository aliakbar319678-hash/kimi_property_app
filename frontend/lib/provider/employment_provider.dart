import 'package:flutter_riverpod/legacy.dart';

class EmploymentState {
  final String companyName;
  final String annualSalary;
  final String employmentLength;
  final String otherIncome;
  final String? uploadedFileName;
  final bool isLoading;

  const EmploymentState({
    this.companyName = '',
    this.annualSalary = '',
    this.employmentLength = 'Less than 1 year',
    this.otherIncome = '',
    this.uploadedFileName,
    this.isLoading = false,
  });

  EmploymentState copyWith({
    String? companyName,
    String? annualSalary,
    String? employmentLength,
    String? otherIncome,
    String? uploadedFileName,
    bool? isLoading,
  }) {
    return EmploymentState(
      companyName: companyName ?? this.companyName,
      annualSalary: annualSalary ?? this.annualSalary,
      employmentLength: employmentLength ?? this.employmentLength,
      otherIncome: otherIncome ?? this.otherIncome,
      uploadedFileName: uploadedFileName ?? this.uploadedFileName,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class EmploymentNotifier extends StateNotifier<EmploymentState> {
  EmploymentNotifier() : super(const EmploymentState());

  void updateCompanyName(String v) => state = state.copyWith(companyName: v);
  void updateAnnualSalary(String v) => state = state.copyWith(annualSalary: v);
  void updateEmploymentLength(String v) =>
      state = state.copyWith(employmentLength: v);
  void updateOtherIncome(String v) => state = state.copyWith(otherIncome: v);
  void updateFileName(String v) => state = state.copyWith(uploadedFileName: v);

  Future<void> next() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1)); // Mock API
    state = state.copyWith(isLoading: false);
  }
}

final employmentProvider =
    StateNotifierProvider<EmploymentNotifier, EmploymentState>(
      (ref) => EmploymentNotifier(),
    );
