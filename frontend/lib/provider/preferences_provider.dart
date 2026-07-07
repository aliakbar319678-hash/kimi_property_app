import 'package:flutter_riverpod/legacy.dart';

class PreferencesState {
  final bool hasPets;
  final bool needsParking;
  final String insurance;
  final String utilities;
  final String specialNeeds;
  final bool isLoading;

  const PreferencesState({
    this.hasPets = false,
    this.needsParking = false,
    this.insurance = '',
    this.utilities = '',
    this.specialNeeds = '',
    this.isLoading = false,
  });

  PreferencesState copyWith({
    bool? hasPets,
    bool? needsParking,
    String? insurance,
    String? utilities,
    String? specialNeeds,
    bool? isLoading,
  }) {
    return PreferencesState(
      hasPets: hasPets ?? this.hasPets,
      needsParking: needsParking ?? this.needsParking,
      insurance: insurance ?? this.insurance,
      utilities: utilities ?? this.utilities,
      specialNeeds: specialNeeds ?? this.specialNeeds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PreferencesNotifier extends StateNotifier<PreferencesState> {
  PreferencesNotifier() : super(const PreferencesState());

  void togglePets(bool v) => state = state.copyWith(hasPets: v);
  void toggleParking(bool v) => state = state.copyWith(needsParking: v);
  void updateInsurance(String v) => state = state.copyWith(insurance: v);
  void updateUtilities(String v) => state = state.copyWith(utilities: v);
  void updateSpecialNeeds(String v) => state = state.copyWith(specialNeeds: v);

  Future<void> next() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1)); // Mock API
    state = state.copyWith(isLoading: false);
  }
}

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, PreferencesState>(
      (ref) => PreferencesNotifier(),
    );
