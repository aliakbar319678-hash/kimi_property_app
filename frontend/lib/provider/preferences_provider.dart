import 'package:flutter_riverpod/legacy.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:dio/dio.dart';

class PreferencesState {
  final bool hasPets;
  final bool needsParking;
  final String insurance;
  final String utilities;
  final String specialNeeds;
  final bool isLoading;
  final String? errorMessage;
  final int lastSubmittedStep;
  final Map<String, String> fieldErrors;

  const PreferencesState({
    this.hasPets = false,
    this.needsParking = false,
    this.insurance = '',
    this.utilities = '',
    this.specialNeeds = '',
    this.isLoading = false,
    this.errorMessage,
    this.lastSubmittedStep = 3,
    this.fieldErrors = const <String, String>{},
  });

  PreferencesState copyWith({
    bool? hasPets,
    bool? needsParking,
    String? insurance,
    String? utilities,
    String? specialNeeds,
    bool? isLoading,
    String? errorMessage,
    int? lastSubmittedStep,
    Map<String, String>? fieldErrors,
  }) {
    return PreferencesState(
      hasPets: hasPets ?? this.hasPets,
      needsParking: needsParking ?? this.needsParking,
      insurance: insurance ?? this.insurance,
      utilities: utilities ?? this.utilities,
      specialNeeds: specialNeeds ?? this.specialNeeds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSubmittedStep: lastSubmittedStep ?? this.lastSubmittedStep,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}

class PreferencesNotifier extends StateNotifier<PreferencesState> {
  PreferencesNotifier() : super(const PreferencesState());

  Map<String, String> _clearError(String field) {
    final errors = Map<String, String>.from(state.fieldErrors);
    errors.remove(field);
    return errors;
  }

  void togglePets(bool v) => state = state.copyWith(hasPets: v);
  void toggleParking(bool v) => state = state.copyWith(needsParking: v);
  void updateInsurance(String v) =>
      state = state.copyWith(insurance: v, fieldErrors: _clearError('insurance'));
  void updateUtilities(String v) =>
      state = state.copyWith(utilities: v, fieldErrors: _clearError('utilities'));
  void updateSpecialNeeds(String v) => state = state.copyWith(specialNeeds: v);

  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (state.insurance.trim().isEmpty) {
      errors['insurance'] = 'Insurance provider is required (enter "None" if not applicable)';
    }
    if (state.utilities.trim().isEmpty) {
      errors['utilities'] = 'Utilities provider is required (enter "None" if not applicable)';
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
      // Submit step 4 (Preferences) only if not already done
      if (state.lastSubmittedStep < 4) {
        final response4 = await ApiClient().dio.post(
          '/users/me/onboarding/4',
          data: {
            'step': 4,
            'data': {
              'preferences': {
                'hasPets': state.hasPets,
                'needsParking': state.needsParking,
                'insurance': state.insurance.trim(),
                'utilities': state.utilities.trim(),
                'specialNeeds': state.specialNeeds.trim(),
              },
            },
          },
        );
        if (response4.statusCode != 200 && response4.data['success'] != true) {
          final msg = response4.data['message'] ?? 'Failed to save preferences';
          state = state.copyWith(isLoading: false, errorMessage: msg);
          return false;
        }
        state = state.copyWith(lastSubmittedStep: 4);
      }

      // Submit step 5 (Complete onboarding) only if not already done
      if (state.lastSubmittedStep < 5) {
        await ApiClient().dio.post(
          '/users/me/onboarding/5',
          data: {
            'step': 5,
            'data': {},
          },
        );
        state = state.copyWith(lastSubmittedStep: 5);
      }

      state = state.copyWith(isLoading: false);
      return true;
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

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, PreferencesState>(
      (ref) => PreferencesNotifier(),
    );
