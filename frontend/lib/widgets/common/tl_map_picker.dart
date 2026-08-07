import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

/// Returns a Map<String, String> with keys:
///   street, city, state, postal, country, fullAddress
class TLMapPicker extends StatefulWidget {
  const TLMapPicker({super.key});

  @override
  State<TLMapPicker> createState() => _TLMapPickerState();
}

class _TLMapPickerState extends State<TLMapPicker> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng _center = const LatLng(30.3753, 69.3451); // Pakistan default
  LatLng? _selectedLocation;
  Map<String, String>? _addressData; // structured address
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _goToCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _goToCurrentLocation({bool autoConfirm = false}) async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _isLoading = false);
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.scaffoldBg,
              title: const Text('Location Services Disabled', style: TextStyle(color: AppColors.textPrimary)),
              content: const Text('Please enable location services to find your current location.', style: TextStyle(color: AppColors.textSecondary)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Geolocator.openLocationSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _isLoading = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final latLng = LatLng(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _selectedLocation = latLng;
          _center = latLng;
        });
        _mapController.move(latLng, 16.0);
        await _reverseGeocode(latLng);
        if (autoConfirm && mounted && _addressData != null) {
          Navigator.pop(context, _addressData);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _reverseGeocode(LatLng latLng) async {
    setState(() => _isLoading = true);
    try {
      final placemarks = await Geocoding()
          .placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty && mounted) {
        final pm = placemarks.first;

        // Build street: prefer street, fallback to name
        final street = (pm.street != null && pm.street!.isNotEmpty)
            ? pm.street!
            : (pm.name ?? '');

        final city = pm.locality ?? pm.subAdministrativeArea ?? '';
        final state = pm.administrativeArea ?? '';
        final postal = pm.postalCode ?? '';
        final country = pm.country ?? '';

        // Build a human-readable full address
        final parts = [
          if (street.isNotEmpty) street,
          if (city.isNotEmpty) city,
          if (state.isNotEmpty) state,
          if (postal.isNotEmpty) postal,
          if (country.isNotEmpty) country,
        ].where((e) => e.isNotEmpty).toList();

        setState(() {
          _addressData = {
            'street': street,
            'city': city,
            'state': state,
            'postal': postal,
            'country': country,
            'fullAddress': parts.join(', '),
          };
        });
      }
    } catch (_) {
      if (mounted) setState(() => _addressData = null);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isSearching = true);
    try {
      final locations =
          await Geocoding().locationFromAddress(query.trim());
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final latLng = LatLng(loc.latitude, loc.longitude);
        setState(() {
          _selectedLocation = latLng;
          _center = latLng;
        });
        _mapController.move(latLng, 15.0);
        await _reverseGeocode(latLng);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Location not found. Try a different search.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Location',
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 13.0,
              onTap: (tapPosition, point) async {
                setState(() {
                  _selectedLocation = point;
                  _addressData = null;
                });
                await _reverseGeocode(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.example.tenant_and_landlord_application',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 48,
                      height: 48,
                      child: const Icon(Icons.location_pin,
                          color: AppColors.primary, size: 48),
                    ),
                  ],
                ),
            ],
          ),

          // ── Search Bar ───────────────────────────────────
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                controller: _searchController,
                onSubmitted: _searchAddress,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search for an address...',
                  hintStyle: const TextStyle(
                      color: AppColors.textHint, fontSize: 14),
                  prefixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.search_rounded,
                          color: AppColors.primary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.textHint, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // ── Current Location Button (inside map, above bottom card) ───
          Positioned(
            right: 16,
            bottom: h * 0.28 + 16, // always above the bottom panel
            child: FloatingActionButton.small(
              heroTag: 'myLocation',
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 4,
              onPressed: () => _goToCurrentLocation(autoConfirm: true),
              child: const Icon(Icons.my_location_rounded),
            ),
          ),

          // ── Bottom Card ──────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child:
                          Center(child: CircularProgressIndicator()),
                    )
                  else if (_addressData != null) ...[
                    const Text(
                      'Selected Address',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _addressData!['fullAddress'] ?? '',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        // Return the structured Map, not just a string
                        onPressed: () =>
                            Navigator.pop(context, _addressData),
                        icon: const Icon(Icons.check_circle_rounded,
                            size: 18),
                        label: const Text('Confirm Location',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: const [
                          Icon(Icons.touch_app_rounded,
                              color: AppColors.textHint),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tap anywhere on the map to select a location',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
