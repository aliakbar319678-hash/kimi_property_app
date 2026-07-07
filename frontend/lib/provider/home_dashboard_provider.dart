import 'package:flutter_riverpod/legacy.dart';

class HomeDashboardState {
  final String selectedFilter;

  const HomeDashboardState({this.selectedFilter = 'Price'});

  HomeDashboardState copyWith({String? selectedFilter}) {
    return HomeDashboardState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class HomeDashboardNotifier extends StateNotifier<HomeDashboardState> {
  HomeDashboardNotifier() : super(const HomeDashboardState());

  void selectFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}

final homeDashboardProvider =
    StateNotifierProvider<HomeDashboardNotifier, HomeDashboardState>(
      (ref) => HomeDashboardNotifier(),
    );
