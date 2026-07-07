import 'package:flutter_riverpod/legacy.dart';

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
    );
  }
}

class BasicProfileNotifier extends StateNotifier<BasicProfileState> {
  BasicProfileNotifier() : super(const BasicProfileState());

  void updateFullLegalName(String v) =>
      state = state.copyWith(fullLegalName: v);
  void updateDateOfBirth(String v) => state = state.copyWith(dateOfBirth: v);
  void updatePhoneNumber(String v) => state = state.copyWith(phoneNumber: v);
  void updateEmailAddress(String v) => state = state.copyWith(emailAddress: v);
  void updateResidentialAddress(String v) =>
      state = state.copyWith(residentialAddress: v);
  void updateContactName(String v) => state = state.copyWith(contactName: v);
  void updateRelationship(String v) => state = state.copyWith(relationship: v);
  void updateEmergencyPhone(String v) =>
      state = state.copyWith(emergencyPhone: v);

  Future<void> saveAsDraft() async {
    // Save draft logic here
  }

  Future<void> next() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1)); // Mock API
    state = state.copyWith(isLoading: false);
  }
}

final basicProfileProvider =
    StateNotifierProvider<BasicProfileNotifier, BasicProfileState>(
      (ref) => BasicProfileNotifier(),
    );
