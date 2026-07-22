import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/utils/api_client.dart';
import 'package:tenant_and_landlord_application/provider/landlord_state.dart';

class TenantPropertyState {
  final List<Property> properties;
  final bool isLoading;
  final String error;

  TenantPropertyState({this.properties = const [], this.isLoading = false, this.error = ''});
}

class TenantPropertyNotifier extends StateNotifier<TenantPropertyState> {
  TenantPropertyNotifier() : super(TenantPropertyState()) {
    fetchVacantProperties();
  }

  Future<void> fetchVacantProperties() async {
    state = TenantPropertyState(isLoading: true, properties: state.properties);
    try {
      final res = await ApiClient().dio.get('/properties/vacant');
      final data = res.data['data'] as List;
      final props = data.map((e) => _mapProperty(e)).toList();
      state = TenantPropertyState(properties: props, isLoading: false);
    } catch (e) {
      state = TenantPropertyState(error: e.toString(), isLoading: false, properties: state.properties);
    }
  }

  Property _mapProperty(dynamic m) {
    String imageUrl = 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&q=80';
    if (m['images'] != null && (m['images'] as List).isNotEmpty) {
      imageUrl = m['images'][0].toString();
    }
    
    int beds = 1;
    int baths = 1;
    int sqft = 800;
    
    final units = m['units'] as List?;
    if (units != null && units.isNotEmpty) {
      final firstUnit = units.first;
      beds = firstUnit['bedrooms'] ?? beds;
      baths = firstUnit['bathrooms'] ?? baths;
      sqft = firstUnit['square_feet'] ?? sqft;
    }

    return Property(
      id: m['id']?.toString() ?? '',
      name: m['name'] ?? m['title'] ?? 'Unknown Property',
      address: m['address'] ?? '',
      occupancyRate: 0.0,
      imageUrl: imageUrl,
      totalUnits: 1,
      occupiedUnits: 0,
      vacantUnits: 1,
      monthlyRent: ((m['price'] ?? m['rent_amount'] ?? m['monthly_rent'] ?? 0) as num).toDouble(),
      type: m['type'] ?? 'apartment',
      description: m['description'] ?? '',
      status: m['status'] ?? 'available',
      metadata: {
        'beds': beds,
        'baths': baths,
        'sqft': sqft,
      },
    );
  }
}

final tenantPropertyProvider = StateNotifierProvider<TenantPropertyNotifier, TenantPropertyState>(
  (ref) => TenantPropertyNotifier(),
);
