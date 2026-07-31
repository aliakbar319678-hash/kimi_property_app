import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String addressLine1;
  final String city;
  final String stateProvince;
  final String zipCode;
  final String country;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.addressLine1,
    required this.city,
    required this.stateProvince,
    required this.zipCode,
    required this.country,
  });
}

class LocationPickerDialog extends StatefulWidget {
  final double initialLat;
  final double initialLng;

  const LocationPickerDialog({
    super.key,
    this.initialLat = 31.5204, // Default
    this.initialLng = 74.3587,
  });

  static Future<LocationResult?> show(
    BuildContext context, {
    double initialLat = 31.5204,
    double initialLng = 74.3587,
  }) {
    return showDialog<LocationResult>(
      context: context,
      builder: (ctx) => LocationPickerDialog(
        initialLat: initialLat,
        initialLng: initialLng,
      ),
    );
  }

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  late LatLng _selectedLocation;
  final TextEditingController _searchCtrl = TextEditingController();
  final MapController _mapController = MapController();
  bool _isLoading = false;
  Timer? _debounce;
  List<Map<String, dynamic>> _suggestions = [];
  bool _isSearchingSuggestions = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(widget.initialLat, widget.initialLng);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    setState(() => _isSearchingSuggestions = true);
    try {
      final response = await Dio().get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': 1,
          'limit': 5,
        },
        options: Options(headers: {'User-Agent': 'TenantLandlordApp/1.0'}),
      );
      if (response.statusCode == 200) {
        final data = response.data as List;
        setState(() {
          _suggestions = data.map((e) => e as Map<String, dynamic>).toList();
        });
      }
    } catch (e) {
      setState(() => _suggestions = []);
    } finally {
      if (mounted) setState(() => _isSearchingSuggestions = false);
    }
  }

  void _onSuggestionSelected(Map<String, dynamic> suggestion) {
    FocusScope.of(context).unfocus();
    _searchCtrl.text = suggestion['display_name'] ?? '';
    final lat = double.tryParse(suggestion['lat'].toString()) ?? 0.0;
    final lon = double.tryParse(suggestion['lon'].toString()) ?? 0.0;
    
    final newLatLng = LatLng(lat, lon);
    setState(() {
      _suggestions = [];
      _selectedLocation = newLatLng;
    });
    _mapController.move(newLatLng, 15);
  }

  Future<void> _searchLocation() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      List<geo.Location> locations = await geo.Geocoding().locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final newLatLng = LatLng(loc.latitude, loc.longitude);
        setState(() {
          _selectedLocation = newLatLng;
        });
        _mapController.move(newLatLng, 15);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location not found')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error finding location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      } 

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final newLatLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = newLatLng;
      });
      _mapController.move(newLatLng, 15);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmSelection() async {
    setState(() => _isLoading = true);
    String addressLine1 = '';
    String city = '';
    String stateProvince = '';
    String zipCode = '';
    String country = '';

    try {
      List<geo.Placemark> placemarks = await geo.Geocoding().placemarkFromCoordinates(
        _selectedLocation.latitude,
        _selectedLocation.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        addressLine1 = [place.street, place.subLocality, place.thoroughfare].where((s) => s != null && s.isNotEmpty).join(', ');
        city = place.locality ?? place.subAdministrativeArea ?? '';
        stateProvince = place.administrativeArea ?? '';
        zipCode = place.postalCode ?? '';
        country = place.isoCountryCode ?? place.country ?? '';
      }
    } catch (e) {
      // Ignore geocoding error
    }

    if (mounted) {
      Navigator.pop(
        context,
        LocationResult(
          latitude: _selectedLocation.latitude,
          longitude: _selectedLocation.longitude,
          addressLine1: addressLine1,
          city: city,
          stateProvince: stateProvince,
          zipCode: zipCode,
          country: country,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: w,
        constraints: const BoxConstraints(maxHeight: 600),
        color: AppColors.white,
        child: Column(
          children: [
            // Dialog Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: AppColors.primary, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Select Location',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search Bar & Interactive Map Container (Stacked for Overlay)
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: _onSearchChanged,
                                decoration: InputDecoration(
                                  hintText: 'Search city or address...',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                                ),
                                onSubmitted: (_) => _searchLocation(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                              child: IconButton(
                                icon: const Icon(Icons.search_rounded, color: Colors.white),
                                onPressed: _searchLocation,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Interactive Map Container
                      Expanded(
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: _selectedLocation,
                                initialZoom: 14,
                                onTap: (tapPosition, point) => _onMapTapped(point),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.tenant_and_landlord_app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: _selectedLocation,
                                      width: 60,
                                      height: 60,
                                      child: const Icon(Icons.location_on, color: Colors.red, size: 50),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Positioned(
                              bottom: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.touch_app_rounded, color: Colors.white, size: 14),
                                    SizedBox(width: 6),
                                    Text(
                                      'Tap map to move pin',
                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: FloatingActionButton(
                                mini: true,
                                backgroundColor: Colors.white,
                                onPressed: _getCurrentLocation,
                                child: const Icon(Icons.my_location_rounded, color: AppColors.primary),
                              ),
                            ),
                            if (_isLoading)
                              Container(
                                color: Colors.white.withValues(alpha: 0.6),
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Suggestions Dropdown Overlay
                  if (_suggestions.isNotEmpty || _isSearchingSuggestions)
                    Positioned(
                      top: 68,
                      left: 16,
                      right: 16,
                      child: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 250),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: _isSearchingSuggestions
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: _suggestions.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final suggestion = _suggestions[index];
                                    return ListTile(
                                      leading: const Icon(Icons.location_on_outlined, color: AppColors.textSecondary),
                                      title: Text(
                                        suggestion['display_name'] ?? '',
                                        style: const TextStyle(fontSize: 13),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onTap: () => _onSuggestionSelected(suggestion),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Confirm Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _confirmSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  label: const Text('Confirm Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

