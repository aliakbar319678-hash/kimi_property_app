import 'package:flutter_riverpod/legacy.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:dio/dio.dart';

class BasicProfileState {
  final String fullLegalName;
  final String dateOfBirth;
  final String phoneNumber;
  final String emailAddress;
  final String residentialAddress;
  final String contactName;
  final String relationship;
  final String emergencyPhone;
  final bool isLoading;
  final String? errorMessage;
  // Field-level validation errors
  final Map<String, String> fieldErrors;

  const BasicProfileState({
    this.fullLegalName = '',
    this.dateOfBirth = '',
    this.phoneNumber = '',
    this.emailAddress = '',
    this.residentialAddress = '',
    this.contactName = '',
    this.relationship = '',
    this.emergencyPhone = '',
    this.isLoading = false,
    this.errorMessage,
    this.fieldErrors = const <String, String>{},
  });

  BasicProfileState copyWith({
    String? fullLegalName,
    String? dateOfBirth,
    String? phoneNumber,
    String? emailAddress,
    String? residentialAddress,
    String? contactName,
    String? relationship,
    String? emergencyPhone,
    bool? isLoading,
    String? errorMessage,
    Map<String, String>? fieldErrors,
  }) {
    return BasicProfileState(
      fullLegalName: fullLegalName ?? this.fullLegalName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      residentialAddress: residentialAddress ?? this.residentialAddress,
      contactName: contactName ?? this.contactName,
      relationship: relationship ?? this.relationship,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}

class BasicProfileNotifier extends StateNotifier<BasicProfileState> {
  BasicProfileNotifier() : super(const BasicProfileState());

  void updateFullLegalName(String v) =>
      state = state.copyWith(fullLegalName: v, fieldErrors: _clearError('fullLegalName'));
  void updateDateOfBirth(String v) =>
      state = state.copyWith(dateOfBirth: v, fieldErrors: _clearError('dateOfBirth'));
  void updatePhoneNumber(String v) =>
      state = state.copyWith(phoneNumber: v, fieldErrors: _clearError('phoneNumber'));
  void updateEmailAddress(String v) =>
      state = state.copyWith(emailAddress: v, fieldErrors: _clearError('emailAddress'));
  void updateResidentialAddress(String v) =>
      state = state.copyWith(residentialAddress: v, fieldErrors: _clearError('residentialAddress'));
  void updateContactName(String v) =>
      state = state.copyWith(contactName: v, fieldErrors: _clearError('contactName'));
  void updateRelationship(String v) =>
      state = state.copyWith(relationship: v, fieldErrors: _clearError('relationship'));
  void updateEmergencyPhone(String v) =>
      state = state.copyWith(emergencyPhone: v, fieldErrors: _clearError('emergencyPhone'));

  Map<String, String> _clearError(String field) {
    final errors = Map<String, String>.from(state.fieldErrors);
    errors.remove(field);
    return errors;
  }

  /// Validates all required fields. Returns a map of field -> error message.
  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (state.fullLegalName.trim().isEmpty) {
      errors['fullLegalName'] = 'Full Legal Name is required';
    }
    if (state.dateOfBirth.trim().isEmpty) {
      errors['dateOfBirth'] = 'Date of Birth is required';
    } else if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(state.dateOfBirth.trim())) {
      errors['dateOfBirth'] = 'Enter date as mm/dd/yyyy';
    }
    if (state.phoneNumber.trim().isEmpty) {
      errors['phoneNumber'] = 'Phone Number is required';
    }
    if (state.residentialAddress.trim().isEmpty) {
      errors['residentialAddress'] = 'Residential Address is required';
    }
    if (state.contactName.trim().isEmpty) {
      errors['contactName'] = 'Emergency Contact Name is required';
    }
    if (state.relationship.trim().isEmpty) {
      errors['relationship'] = 'Relationship is required';
    }
    if (state.emergencyPhone.trim().isEmpty) {
      errors['emergencyPhone'] = 'Emergency Phone is required';
    }
    return errors;
  }

  Future<bool> saveAsDraft() async {
    final errors = _validate();
    if (errors.isNotEmpty) {
      state = state.copyWith(fieldErrors: errors);
      return false;
    }
    return await _submit();
  }

  Future<bool> next() async {
    final errors = _validate();
    if (errors.isNotEmpty) {
      state = state.copyWith(fieldErrors: errors);
      return false;
    }
    return await _submit();
  }

  Future<bool> _submit() async {
    state = state.copyWith(isLoading: true, errorMessage: null, fieldErrors: {});
    try {
      final response = await ApiClient().dio.post(
        '/users/me/onboarding/1',
        data: {
          'step': 1,
          'data': {
            'legalName': state.fullLegalName.trim(),
            'dob': state.dateOfBirth.trim(),
            'phone': state.phoneNumber.trim(),
            'address': {
              'streetAddress': state.residentialAddress.trim(),
            },
            'emergencyContact': {
              'name': state.contactName.trim(),
              'relationship': state.relationship,
              'phone': state.emergencyPhone.trim(),
            },
          },
        },
      );
      state = state.copyWith(isLoading: false);
      return response.statusCode == 200 || response.data['success'] == true;
    } catch (e) {
      String msg = 'An unexpected error occurred';
      if (e is DioException) {
        final data = e.response?.data;
        msg = (data is Map ? data['message'] ?? data['error'] : null) ??
            e.message ??
            msg;
      }
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    }
  }
}

final basicProfileProvider =
    StateNotifierProvider<BasicProfileNotifier, BasicProfileState>(
      (ref) => BasicProfileNotifier(),
    );
