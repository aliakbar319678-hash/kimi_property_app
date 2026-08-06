import 'package:flutter_riverpod/legacy.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:dio/dio.dart';

class BasicProfileState {
  final String fullLegalName;
  final String dateOfBirth;
  final String phoneNumber;
  final String emailAddress;
  final String streetAddress;
  final String city;
  final String stateProvince;
  final String postalCode;
  final String country;
  final String contactName;
  final String relationship;
  final String emergencyPhone;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  const BasicProfileState({
    this.fullLegalName = '',
    this.dateOfBirth = '',
    this.phoneNumber = '',
    this.emailAddress = '',
    this.streetAddress = '',
    this.city = '',
    this.stateProvince = '',
    this.postalCode = '',
    this.country = 'Pakistan',
    this.contactName = '',
    this.relationship = '',
    this.emergencyPhone = '',
    this.isLoading = false,
    this.errorMessage,
    this.fieldErrors = const <String, String>{},
  });

  String get fullAddress {
    final parts = [streetAddress, city, stateProvince, postalCode, country]
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  String get residentialAddress => fullAddress;

  BasicProfileState copyWith({
    String? fullLegalName,
    String? dateOfBirth,
    String? phoneNumber,
    String? emailAddress,
    String? streetAddress,
    String? city,
    String? stateProvince,
    String? postalCode,
    String? country,
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
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      stateProvince: stateProvince ?? this.stateProvince,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
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
  BasicProfileNotifier() : super(const BasicProfileState()) {
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final res = await ApiClient().dio.get('/auth/me');
      if (res.statusCode == 200) {
        final data = res.data['data'];
        if (data != null) {
          final String first = data['first_name']?.toString() ?? '';
          final String last = data['last_name']?.toString() ?? '';
          final String fullName = '$first $last'.trim();
          
          state = state.copyWith(
            fullLegalName: state.fullLegalName.isEmpty ? fullName : state.fullLegalName,
            phoneNumber: state.phoneNumber.isEmpty ? (data['phone']?.toString() ?? '') : state.phoneNumber,
            emailAddress: state.emailAddress.isEmpty ? (data['email']?.toString() ?? '') : state.emailAddress,
          );
        }
      }
    } catch (_) {}
  }

  void updateFullLegalName(String v) =>
      state = state.copyWith(fullLegalName: v, fieldErrors: _clearError('fullLegalName'));
  void updateDateOfBirth(String v) =>
      state = state.copyWith(dateOfBirth: v, fieldErrors: _clearError('dateOfBirth'));
  void updatePhoneNumber(String v) =>
      state = state.copyWith(phoneNumber: v, fieldErrors: _clearError('phoneNumber'));
  void updateEmailAddress(String v) =>
      state = state.copyWith(emailAddress: v, fieldErrors: _clearError('emailAddress'));
  void updateResidentialAddress(String v) =>
      state = state.copyWith(streetAddress: v, fieldErrors: _clearError('streetAddress'));
  void updateStreetAddress(String v) =>
      state = state.copyWith(streetAddress: v, fieldErrors: _clearError('streetAddress'));
  void updateCity(String v) =>
      state = state.copyWith(city: v, fieldErrors: _clearError('city'));
  void updateStateProvince(String v) =>
      state = state.copyWith(stateProvince: v, fieldErrors: _clearError('stateProvince'));
  void updatePostalCode(String v) =>
      state = state.copyWith(postalCode: v, fieldErrors: _clearError('postalCode'));
  void updateCountry(String v) =>
      state = state.copyWith(country: v, fieldErrors: _clearError('country'));
  void updateContactName(String v) =>
      state = state.copyWith(contactName: v, fieldErrors: _clearError('contactName'));
  void updateRelationship(String v) =>
      state = state.copyWith(relationship: v, fieldErrors: _clearError('relationship'));
  void updateEmergencyPhone(String v) =>
      state = state.copyWith(emergencyPhone: v, fieldErrors: _clearError('emergencyPhone'));

  void updateFullAddress({
    required String street,
    required String city,
    required String stateProv,
    required String postal,
    required String countryName,
  }) {
    state = state.copyWith(
      streetAddress: street,
      city: city,
      stateProvince: stateProv,
      postalCode: postal,
      country: countryName,
      fieldErrors: Map<String, String>.from(state.fieldErrors)
        ..remove('streetAddress')
        ..remove('city')
        ..remove('stateProvince')
        ..remove('postalCode')
        ..remove('country'),
    );
  }

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
      errors['dateOfBirth'] = 'Enter date as dd/mm/yyyy';
    }
    if (state.phoneNumber.trim().isEmpty) {
      errors['phoneNumber'] = 'Phone Number is required';
    } else if (state.phoneNumber.replaceAll(RegExp(r'\D'), '').length < 10) {
      errors['phoneNumber'] = 'Please enter a valid complete phone number';
    }
    
    if (state.streetAddress.trim().isEmpty) {
      errors['streetAddress'] = 'Street Address is required';
    }
    if (state.city.trim().isEmpty) {
      errors['city'] = 'City is required';
    }

    if (state.contactName.trim().isEmpty) {
      errors['contactName'] = 'Emergency Contact Name is required';
    }
    if (state.relationship.trim().isEmpty) {
      errors['relationship'] = 'Relationship is required';
    }
    
    if (state.emergencyPhone.trim().isEmpty) {
      errors['emergencyPhone'] = 'Emergency Phone is required';
    } else if (state.emergencyPhone.replaceAll(RegExp(r'\D'), '').length < 10) {
      errors['emergencyPhone'] = 'Please enter a valid complete phone number';
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
      final response = await ApiClient().dio.put(
        '/users/me/profile',
        data: {
          'legal_first_name': state.fullLegalName.trim(),
          'date_of_birth': () {
            final parts = state.dateOfBirth.trim().split('/');
            if (parts.length == 3) {
              return '${parts[2]}-${parts[1]}-${parts[0]}'; // YYYY-MM-DD
            }
            return state.dateOfBirth.trim();
          }(),
          'phone': state.phoneNumber.trim(),
          'current_address': {
            'street': state.streetAddress.trim(),
            'city': state.city.trim(),
            'state': state.stateProvince.trim(),
            'postal_code': state.postalCode.trim(),
            'country': state.country.trim(),
            'full_address': state.fullAddress,
          },
          'emergency_contact': {
            'name': state.contactName.trim(),
            'relationship': state.relationship,
            'phone': state.emergencyPhone.trim(),
          },
        },
      );
      state = state.copyWith(isLoading: false);
      return response.statusCode == 200 || response.data['success'] == true;
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

final basicProfileProvider =
    StateNotifierProvider<BasicProfileNotifier, BasicProfileState>(
      (ref) => BasicProfileNotifier(),
    );
