import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class SearchFilterState {
  final RangeValues rentRange;
  final String bedrooms;
  final String bathrooms;
  final double searchRadius;
  final bool petsAllowed;
  final List<String> amenities;

  const SearchFilterState({
    this.rentRange = const RangeValues(1200, 4500),
    this.bedrooms = '2+',
    this.bathrooms = '2+',
    this.searchRadius = 15.0,
    this.petsAllowed = true,
    this.amenities = const ['AC', 'Laundry', 'Parking'],
  });

  SearchFilterState copyWith({
    RangeValues? rentRange,
    String? bedrooms,
    String? bathrooms,
    double? searchRadius,
    bool? petsAllowed,
    List<String>? amenities,
  }) {
    return SearchFilterState(
      rentRange: rentRange ?? this.rentRange,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      searchRadius: searchRadius ?? this.searchRadius,
      petsAllowed: petsAllowed ?? this.petsAllowed,
      amenities: amenities ?? this.amenities,
    );
  }
}

class SearchFilterNotifier extends StateNotifier<SearchFilterState> {
  SearchFilterNotifier() : super(const SearchFilterState());

  void updateRentRange(RangeValues range) => state = state.copyWith(rentRange: range);
  
  void selectBedrooms(String val) => state = state.copyWith(bedrooms: val);
  
  void selectBathrooms(String val) => state = state.copyWith(bathrooms: val);
  
  void updateRadius(double val) => state = state.copyWith(searchRadius: val);
  
  void togglePets(bool val) => state = state.copyWith(petsAllowed: val);

  void toggleAmenity(String amenity) {
    final list = List<String>.from(state.amenities);
    if (list.contains(amenity)) {
      list.remove(amenity);
    } else {
      list.add(amenity);
    }
    state = state.copyWith(amenities: list);
  }

  void resetFilters() {
    state = const SearchFilterState();
  }
}

final searchFilterProvider = StateNotifierProvider<SearchFilterNotifier, SearchFilterState>(
  (ref) => SearchFilterNotifier(),
);
