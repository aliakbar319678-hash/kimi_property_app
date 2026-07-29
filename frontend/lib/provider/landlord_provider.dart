import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'landlord_state.dart';
import '../core/api_client.dart';
import '../core/api_constants.dart';

double _safeDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is num) return val.toDouble();
  return double.tryParse(val.toString()) ?? 0.0;
}

class LandlordNotifier extends StateNotifier<LandlordState> {
  LandlordNotifier() : super(const LandlordState()) {
    _loadInitialData();
  }

  void _loadInitialData() {
    // Fire all real API calls concurrently – no more mock data
    loadProperties();
    loadUserProfile();
    loadWorkOrders();
    loadFinanceDashboard();
    loadUrgentAlerts();
    loadUnreadCount();
    loadTenants();
    loadLeases();
  }

  // ── 1. Load user profile (name + avatar) ─────────────────────────────────────
  Future<void> loadUserProfile() async {
    try {
      final resp = await ApiClient().dio.get(ApiConstants.userProfile);
      final data = resp.data['data'] as Map<String, dynamic>? ?? {};
      final firstName = data['legal_first_name']?.toString() ??
          data['display_name']?.toString() ??
          data['email']?.toString().split('@').first ??
          'Landlord';
      final avatarUrl = data['avatar_url']?.toString() ?? '';
      state = state.copyWith(userName: firstName, userAvatarUrl: avatarUrl);
    } catch (_) {
      // Keep empty defaults on failure
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await ApiClient().dio.put(ApiConstants.updateProfile, data: data);
      await loadUserProfile(); // refresh data
    } catch (e) {
      debugPrint('[LandlordProvider] updateProfile error: $e');
      rethrow;
    }
  }

  Future<void> uploadAvatar(List<int> bytes, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });
      await ApiClient().dio.post(ApiConstants.uploadsAvatar, data: formData);
      await loadUserProfile(); // refresh data
    } catch (e) {
      debugPrint('[LandlordProvider] uploadAvatar error: $e');
      rethrow;
    }
  }

  // ── 2. Load properties ───────────────────────────────────────────────────────
  Future<void> loadProperties() async {
    state = state.copyWith(isLoading: true);
    try {
      final resp = await ApiClient().dio.get(ApiConstants.properties);
      final List<dynamic> rawList = (resp.data['data'] ?? []) as List<dynamic>;
      final properties = rawList.map((item) {
        final m = item as Map<String, dynamic>;

        final address1 = m['address_line1']?.toString() ?? '';
        final city = m['city']?.toString() ?? '';
        final stateProv = m['state_province']?.toString() ?? '';
        final address =
            [address1, city, stateProv].where((s) => s.isNotEmpty).join(', ');

        final totalUnits = (m['total_units'] ?? 0) as int;
        final occupiedUnits = (m['occupied_units'] ?? 0) as int;
        final vacantUnits = (m['vacant_units'] ?? 0) as int;
        final occupancyRate = totalUnits > 0
            ? (occupiedUnits.toDouble() / totalUnits.toDouble())
            : 0.0;

        String imageUrl =
            'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&q=80';
        final rawImages = m['images'];
        if (rawImages is List && rawImages.isNotEmpty) {
          imageUrl = _parsePhotoUrl(rawImages[0]);
        } else if (rawImages is String && rawImages.isNotEmpty) {
          try {
            final parsed = jsonDecode(rawImages);
            if (parsed is List && parsed.isNotEmpty) {
              imageUrl = _parsePhotoUrl(parsed[0]);
            } else {
              imageUrl = _parsePhotoUrl(rawImages);
            }
          } catch (_) {
            imageUrl = _parsePhotoUrl(rawImages);
          }
        }

        // Parse amenities
        List<String> amenities = [];
        final rawAmenities = m['amenities'];
        if (rawAmenities is List) {
          amenities = rawAmenities.map((a) => a.toString()).toList();
        } else if (rawAmenities is String && rawAmenities.isNotEmpty) {
          try {
            final parsed = jsonDecode(rawAmenities);
            if (parsed is List) {
              amenities = parsed.map((a) => a.toString()).toList();
            }
          } catch (_) {}
        }

        Map<String, dynamic> metadata = {};
        if (m['metadata'] is Map) {
          metadata = m['metadata'] as Map<String, dynamic>;
        } else if (m['metadata'] is String && m['metadata'].toString().isNotEmpty) {
          try {
            metadata = jsonDecode(m['metadata']) as Map<String, dynamic>;
          } catch (_) {}
        }

        // Parse approval workflow lists
        List<dynamic> requestedDocs = [];
        if (m['requested_documents'] is List) {
          requestedDocs = m['requested_documents'];
        } else if (m['requested_documents'] is String && m['requested_documents'].toString().isNotEmpty) {
          try { requestedDocs = jsonDecode(m['requested_documents']) as List; } catch (_) {}
        }

        List<dynamic> revisionHist = [];
        if (m['revision_history'] is List) {
          revisionHist = m['revision_history'];
        } else if (m['revision_history'] is String && m['revision_history'].toString().isNotEmpty) {
          try { revisionHist = jsonDecode(m['revision_history']) as List; } catch (_) {}
        }

        return Property(
          id: m['id']?.toString() ?? '',
          name: m['name']?.toString() ?? 'Unnamed Property',
          address: address,
          occupancyRate: occupancyRate,
          imageUrl: imageUrl,
          totalUnits: totalUnits,
          occupiedUnits: occupiedUnits,
          vacantUnits: vacantUnits,
          monthlyRent: _safeDouble(m['monthly_rent'] ?? m['price']),
          type: m['type']?.toString() ?? 'apartment',
          amenities: amenities,
          description: m['description']?.toString() ?? '',
          status: m['status']?.toString() ?? 'active',
          verificationStatus: m['verification_status']?.toString() ?? 'pending',
          rejectionReason: m['rejection_reason']?.toString(),
          resubmissionCount: (m['resubmission_count'] ?? 0) as int,
          isPermanentlyRejected: m['is_permanently_rejected'] == true || m['is_permanently_rejected'] == 'true',
          requestedDocuments: requestedDocs,
          revisionHistory: revisionHist,
          metadata: metadata,
        );
      }).toList();

      int totalU = 0;
      int occupiedU = 0;
      for (final p in properties) {
        totalU += p.totalUnits;
        occupiedU += p.occupiedUnits;
      }
      final calculatedOccupancy = totalU > 0
          ? (occupiedU.toDouble() / totalU.toDouble())
          : 0.0;

      state = state.copyWith(
        properties: properties,
        occupancyRate: calculatedOccupancy,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('[LandlordProvider] loadProperties error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // ── 3. Load work orders → populate workOrders + maintenance summary ───────────
  Future<void> loadWorkOrders() async {
    try {
      final resp =
          await ApiClient().dio.get(ApiConstants.workOrders);
      final List<dynamic> rawList =
          (resp.data['data'] ?? []) as List<dynamic>;

      int emergency = 0;
      int inProgress = 0;
      int completed = 0;

      final orders = rawList.map((item) {
        final m = item as Map<String, dynamic>;
        final status = (m['status'] ?? '').toString().toLowerCase();
        final priority = (m['priority'] ?? '').toString().toLowerCase();

        if (priority == 'emergency' || status == 'emergency') emergency++;
        if (status == 'in_progress' || status == 'in-progress' || status == 'assigned') inProgress++;
        if (status == 'completed') completed++;

        // Parse photos
        List<String> photos = [];
        final rawPhotos = m['photos'];
        if (rawPhotos is List) {
          photos = rawPhotos.map((p) => _parsePhotoUrl(p)).toList();
        } else if (rawPhotos is String && rawPhotos.isNotEmpty) {
          try {
            final parsed = jsonDecode(rawPhotos);
            if (parsed is List) photos = parsed.map((p) => _parsePhotoUrl(p)).toList();
          } catch (_) {}
        }

        // Format date
        String formattedDate = '';
        try {
          final rawDate = m['created_at']?.toString() ?? m['date']?.toString() ?? '';
          if (rawDate.isNotEmpty) {
            final dt = DateTime.tryParse(rawDate);
            if (dt != null) formattedDate = DateFormat('MMM dd, yyyy').format(dt);
          }
        } catch (_) {}

        return WorkOrder(
          id: m['id']?.toString() ?? '',
          title: m['title']?.toString() ?? 'Work Order',
          description: m['description']?.toString() ?? '',
          propertyName: m['property_name']?.toString() ?? m['propertyName']?.toString() ?? '',
          unitName: m['unit_name']?.toString() ?? m['unitName']?.toString() ?? '',
          tenantName: m['tenant_name']?.toString() ?? m['tenantName']?.toString() ?? '',
          priority: _capitalize(m['priority']?.toString() ?? 'Medium'),
          status: _formatStatus(m['status']?.toString() ?? 'Request'),
          photos: photos,
          category: _capitalize(m['category']?.toString() ?? 'General'),
          date: formattedDate,
          timeSlot: m['time_slot']?.toString() ?? m['timeSlot']?.toString() ?? '',
          accessInstructions: m['access_instructions']?.toString() ?? m['accessInstructions']?.toString() ?? '',
          vendorName: m['vendor_name']?.toString() ?? m['vendorName']?.toString(),
          vendorPhone: m['vendor_phone']?.toString() ?? m['vendorPhone']?.toString(),
          bidAmount: m['bid_amount'] != null ? _safeDouble(m['bid_amount']) : null,
        );
      }).toList();

      state = state.copyWith(
        workOrders: orders,
        maintenanceEmergency: emergency,
        maintenanceInProgress: inProgress,
        maintenanceCompleted: completed,
      );
    } catch (e) {
      debugPrint('[LandlordProvider] loadWorkOrders error: $e');
    }
  }

  // ── 4. Load finance dashboard → totalCollected, outstanding, rent % ───────────
  Future<void> loadFinanceDashboard() async {
    try {
      final resp = await ApiClient().dio.get(ApiConstants.financeDashboard);
      final data = resp.data['data'] as Map<String, dynamic>? ?? {};

      final collectedMap = data['total_collected'] ?? data['totalCollected'] ?? {'amount': 0};
      final totalCollected = double.tryParse((collectedMap is Map ? collectedMap['amount'] : collectedMap).toString()) ?? 0.0;

      final outstandingMap = data['total_outstanding'] ?? data['totalOutstanding'] ?? {'amount': 0};
      final totalOutstanding = double.tryParse((outstandingMap is Map ? outstandingMap['amount'] : outstandingMap).toString()) ?? 0.0;

      final rentPercent = double.tryParse((data['rent_collection_percent'] ?? data['rentCollectionPercent'] ?? data['rentStatus']?['pct_paid'] ?? 0).toString()) ?? 0.0;

      // Backend may return 0–100 scale; normalise to 0.0–1.0
      final normalised = rentPercent > 1.0 ? rentPercent / 100.0 : rentPercent;

      state = state.copyWith(
        totalCollected: totalCollected,
        totalOutstanding: totalOutstanding,
        rentCollectionPercent: normalised.clamp(0.0, 1.0),
      );
    } catch (e) {
      debugPrint('[LandlordProvider] loadFinanceDashboard error: $e');
    }
  }

  // ── 5. Load urgent alerts (expiring leases + emergency work orders) ────────────
  Future<void> loadUrgentAlerts() async {
    final alerts = <UrgentAlert>[];
    try {
      // Expiring leases
      final leaseResp =
          await ApiClient().dio.get(ApiConstants.leasesExpiringSoon);
      final List<dynamic> leases =
          (leaseResp.data['data'] ?? []) as List<dynamic>;
      for (final l in leases.take(3)) {
        final m = l as Map<String, dynamic>;
        final tenantName = m['tenant_name']?.toString() ??
            m['tenantName']?.toString() ??
            'Tenant';
        final propName = m['property_name']?.toString() ??
            m['propertyName']?.toString() ??
            '';
        final endDate = m['end_date']?.toString() ?? m['endDate']?.toString() ?? '';
        String daysLeft = '';
        try {
          final dt = DateTime.tryParse(endDate);
          if (dt != null) {
            final diff = dt.difference(DateTime.now()).inDays;
            daysLeft = '$diff days left';
          }
        } catch (_) {}
        alerts.add(UrgentAlert(
          id: m['id']?.toString() ?? 'lease_${alerts.length}',
          title: 'Lease Expiring Soon',
          description:
              '$tenantName${propName.isNotEmpty ? " • $propName" : ""}${daysLeft.isNotEmpty ? " • $daysLeft" : ""}',
          type: 'lease',
        ));
      }
    } catch (_) {}

    try {
      // High-priority / emergency open work orders
      final woResp = await ApiClient().dio.get(ApiConstants.workOrders);
      final List<dynamic> orders =
          (woResp.data['data'] ?? []) as List<dynamic>;
      for (final o in orders) {
        final m = o as Map<String, dynamic>;
        final priority = (m['priority'] ?? '').toString().toLowerCase();
        final status = (m['status'] ?? '').toString().toLowerCase();
        if ((priority == 'emergency' || priority == 'high') &&
            status != 'completed' &&
            status != 'cancelled') {
          final propName = m['property_name']?.toString() ??
              m['propertyName']?.toString() ??
              '';
          final unitName =
              m['unit_name']?.toString() ?? m['unitName']?.toString() ?? '';
          alerts.add(UrgentAlert(
            id: m['id']?.toString() ?? 'wo_${alerts.length}',
            title: m['title']?.toString() ?? 'Maintenance Issue',
            description:
                '${propName.isNotEmpty ? propName : ""}${unitName.isNotEmpty ? " • $unitName" : ""} • ${_capitalize(priority)} Priority',
            type: 'maintenance',
            priority: priority,
          ));
          if (alerts.length >= 5) break;
        }
      }
    } catch (_) {}

    state = state.copyWith(urgentAlerts: alerts);
  }

  // ── 6. Load unread notification count ─────────────────────────────────────────
  Future<void> loadUnreadCount() async {
    try {
      final resp =
          await ApiClient().dio.get(ApiConstants.notificationsUnreadCount);
      final data = resp.data['data'];
      final count = data is int
          ? data
          : (data is Map ? (data['count'] ?? data['total'] ?? 0) as int : 0);
      state = state.copyWith(unreadNotifications: count);
    } catch (_) {
      // Keep 0 on failure
    }
  }

  // ── 7. Load tenants from leases dashboard ─────────────────────────────────────
  Future<void> loadTenants() async {
    state = state.copyWith(isTenantsLoading: true);
    try {
      final resp = await ApiClient().dio.get(ApiConstants.usersTenants);
      final List<dynamic> rawList = (resp.data['data'] ?? []) as List<dynamic>;

      final tenants = rawList.map((item) {
        final m = item as Map<String, dynamic>;
        final tenantData = m['tenant'] as Map<String, dynamic>? ?? {};

        // Determine payment status
        final status = (m['status'] ?? '').toString().toLowerCase();
        String paymentStatus = 'Active';
        if (status == 'overdue' || status == 'late') {
          paymentStatus = 'Late Payment';
        }

        // Format join date from start_date
        String dateJoined = '';
        try {
          final raw = m['start_date']?.toString() ?? '';
          final dt = DateTime.tryParse(raw);
          if (dt != null) dateJoined = DateFormat('MMM dd, yyyy').format(dt);
        } catch (_) {}

        // Lease end date
        String leaseEnd = '';
        try {
          final raw = m['end_date']?.toString() ?? '';
          final dt = DateTime.tryParse(raw);
          if (dt != null) leaseEnd = DateFormat('MMM dd, yyyy').format(dt);
        } catch (_) {}

        final rentAmt = _safeDouble(m['rent_amount'] ?? m['rentAmount']);
        final outstanding = _safeDouble(m['outstanding'] ?? m['balance']);

        final firstName = tenantData['legal_first_name']?.toString() ?? '';
        final lastName = tenantData['legal_last_name']?.toString() ?? '';
        final fullName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

        return Tenant(
          id: m['id']?.toString() ?? '',
          name: fullName.isNotEmpty
              ? fullName
              : (tenantData['email']?.toString().split('@').first ?? 'Tenant'),
          unitName: m['unit_name']?.toString() ?? m['unitName']?.toString() ?? 'N/A',
          contact: tenantData['phone']?.toString() ?? '',
          email: tenantData['email']?.toString() ?? '',
          emergencyContactName: '',
          emergencyContactPhone: '',
          memos: [],
          balance: outstanding,
          status: paymentStatus,
          dateJoined: dateJoined,
          propertyName: m['property_name']?.toString() ?? m['propertyName']?.toString() ?? '',
          leaseEndDate: leaseEnd,
          rentAmount: rentAmt,
          avatarUrl: tenantData['avatar_url']?.toString() ?? '',
        );
      }).toList();

      state = state.copyWith(tenants: tenants, isTenantsLoading: false);
    } catch (e) {
      debugPrint('[LandlordProvider] loadTenants error: $e');
      state = state.copyWith(isTenantsLoading: false);
    }
  }

  // ── 8. Load leases list from /leases/dashboard ────────────────────────────────
  Future<void> loadLeases() async {
    state = state.copyWith(isLeasesLoading: true);
    try {
      final resp = await ApiClient().dio.get(ApiConstants.leasesDashboard);
      final List<dynamic> rawList = (resp.data['data'] ?? []) as List<dynamic>;

      int activeCount = 0;
      int expiringCount = 0;

      final leases = rawList.map((item) {
        final m = item as Map<String, dynamic>;
        final tenantData = m['tenant'] as Map<String, dynamic>? ?? {};

        final status = (m['status'] ?? 'active').toString().toLowerCase();
        if (status == 'active') activeCount++;

        // Days left calculation
        int daysLeft = 0;
        String endDate = '';
        try {
          final raw = m['end_date']?.toString() ?? '';
          final dt = DateTime.tryParse(raw);
          if (dt != null) {
            daysLeft = dt.difference(DateTime.now()).inDays;
            endDate = DateFormat('MMM dd, yyyy').format(dt);
            if (daysLeft <= 60 && daysLeft > 0) expiringCount++;
          }
        } catch (_) {}

        String startDate = '';
        try {
          final raw = m['start_date']?.toString() ?? '';
          final dt = DateTime.tryParse(raw);
          if (dt != null) startDate = DateFormat('MMM dd, yyyy').format(dt);
        } catch (_) {}

        final firstName = tenantData['legal_first_name']?.toString() ?? '';
        final lastName = tenantData['legal_last_name']?.toString() ?? '';
        final fullName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

        return Lease(
          id: m['id']?.toString() ?? '',
          unitName: m['unit_name']?.toString() ?? m['unitName']?.toString() ?? 'N/A',
          tenantName: fullName.isNotEmpty
              ? fullName
              : (tenantData['email']?.toString().split('@').first ?? 'Tenant'),
          propertyName: m['property_name']?.toString() ?? m['propertyName']?.toString() ?? '',
          rentAmount: double.tryParse((m['rent_amount'] ?? m['rentAmount'] ?? 0).toString()) ?? 0.0,
          startDate: startDate,
          endDate: endDate,
          status: status,
          daysLeft: daysLeft,
        );
      }).toList();

      state = state.copyWith(
        leases: leases,
        activeLeaseCount: activeCount,
        expiringLeaseCount: expiringCount,
        isLeasesLoading: false,
      );
    } catch (e) {
      debugPrint('[LandlordProvider] loadLeases error: $e');
      state = state.copyWith(isLeasesLoading: false);
    }
  }

  // ── 9. Load units for a specific property ─────────────────────────────────────
  Future<void> loadUnits(String propertyId) async {
    state = state.copyWith(isUnitsLoading: true);
    try {
      final resp =
          await ApiClient().dio.get(ApiConstants.propertyUnits(propertyId));
      final List<dynamic> rawList = (resp.data['data'] ?? []) as List<dynamic>;

      final units = rawList.map((item) {
        final m = item as Map<String, dynamic>;

        // Try to get tenant name from embedded data
        String tenantName = '';
        final tenantData = m['tenant'] as Map<String, dynamic>?;
        if (tenantData != null) {
          final fn = tenantData['legal_first_name']?.toString() ?? '';
          final ln = tenantData['legal_last_name']?.toString() ?? '';
          tenantName = [fn, ln].where((s) => s.isNotEmpty).join(' ');
          if (tenantName.isEmpty) {
            tenantName = tenantData['email']?.toString().split('@').first ?? '';
          }
        }

        return Unit(
          id: m['id']?.toString() ?? '',
          name: m['unit_number']?.toString() ?? m['unitNumber']?.toString() ?? 'Unit',
          status: _capitalize(m['status']?.toString() ?? 'vacant'),
          tenantName: tenantName,
          rent: double.tryParse((m['rent_amount'] ?? m['rentAmount'] ?? m['price'] ?? 0).toString()) ?? 0.0,
          amenities: [],
          bedrooms: int.tryParse((m['bedrooms'] ?? 0).toString()) ?? 0,
          bathrooms: int.tryParse((m['bathrooms'] ?? 0).toString()) ?? 0,
          squareFeet: int.tryParse((m['square_feet'] ?? m['squareFeet'] ?? 0).toString()) ?? 0,
          depositAmount: double.tryParse((m['deposit_amount'] ?? m['depositAmount'] ?? 0).toString()) ?? 0.0,
          availableDate: m['available_date']?.toString() ?? m['availableDate']?.toString() ?? '',
          propertyId: propertyId,
        );
      }).toList();

      state = state.copyWith(units: units, isUnitsLoading: false);
    } catch (e) {
      debugPrint('[LandlordProvider] loadUnits error: $e');
      state = state.copyWith(isUnitsLoading: false);
      rethrow;
    }
  }

  // ── 9.5 Load Vendors ─────────────────────────────────────────────────────────
  Future<void> loadVendors() async {
    try {
      final resp = await ApiClient().dio.get(ApiConstants.vendorDirectory);
      final List<dynamic> rawList = (resp.data['data'] ?? []) as List<dynamic>;

      final vendors = rawList.map((item) {
        final m = item as Map<String, dynamic>;
        return VendorProfile(
          id: m['id']?.toString() ?? '',
          displayName: m['display_name']?.toString() ?? '',
          email: m['email']?.toString() ?? '',
          avgRating: _safeDouble(m['avg_rating']),
        );
      }).toList();

      state = state.copyWith(vendors: vendors);
    } catch (e) {
      debugPrint('[LandlordProvider] loadVendors error: $e');
    }
  }

  // ── 10. Load bids for a work order ────────────────────────────────────────────
  Future<void> loadBids(String workOrderId) async {
    state = state.copyWith(isBidsLoading: true);
    try {
      final resp =
          await ApiClient().dio.get(ApiConstants.workOrderBids(workOrderId));
      final List<dynamic> rawList = (resp.data['data'] ?? []) as List<dynamic>;

      final bids = rawList.map((item) {
        final m = item as Map<String, dynamic>;
        final vendorData = m['vendor'] as Map<String, dynamic>? ?? {};
        final vendorProfile = vendorData['profile'] as Map<String, dynamic>? ?? {};

        final fn = vendorProfile['legal_first_name']?.toString() ?? '';
        final ln = vendorProfile['legal_last_name']?.toString() ?? '';
        String vendorName = [fn, ln].where((s) => s.isNotEmpty).join(' ');
        if (vendorName.isEmpty) {
          vendorName = vendorData['email']?.toString().split('@').first ?? 'Vendor';
        }

        return Bid(
          id: m['id']?.toString() ?? '',
          vendorName: vendorName,
          rating: _safeDouble(m['rating'] ?? vendorData['rating'] ?? 4.0),
          totalJobs: int.tryParse(vendorData['total_jobs']?.toString() ?? '0') ?? 0,
          price: _safeDouble(m['amount']),
          time: m['estimated_hours'] != null
              ? '${m["estimated_hours"]}h est.'
              : (m['proposed_date']?.toString() ?? 'Flexible'),
          avatarUrl: vendorProfile['avatar_url']?.toString() ?? '',
        );
      }).toList();

      state = state.copyWith(bids: bids, isBidsLoading: false);
    } catch (e) {
      debugPrint('[LandlordProvider] loadBids error: $e');
      state = state.copyWith(isBidsLoading: false);
    }
  }

  // ── Create Property ───────────────────────────────────────────────────────────
  Future<String> createProperty({
    required String name,
    required String addressLine1,
    required String city,
    required String stateProvince,
    required String postalCode,
    String countryCode = 'US',
    required String type,
    String? description,
    List<String>? amenities,
    double? price,
    Map<String, dynamic>? metadata,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'addressLine1': addressLine1,
      'city': city,
      'stateProvince': stateProvince,
      'postalCode': postalCode,
      'countryCode': countryCode,
      'type': type,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (amenities != null && amenities.isNotEmpty) 'amenities': amenities,
      if (price != null) 'price': price,
      if (metadata != null) 'metadata': metadata,
    };
    final resp = await ApiClient().dio.post(ApiConstants.properties, data: payload);
    await loadProperties(); // Refresh the properties list
    final createdData = resp.data['data'] as Map<String, dynamic>? ?? {};
    return createdData['id']?.toString() ?? (state.properties.isNotEmpty ? state.properties.first.id : '');
  }

  // ── Upload Property Image ───────────────────────────────────────────────────
  Future<void> uploadPropertyImage(String propertyId, List<int> bytes, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });
      await ApiClient().dio.post(ApiConstants.uploadsPropertyImage(propertyId), data: formData);
      await loadProperties();
    } catch (e) {
      debugPrint('[LandlordProvider] uploadPropertyImage error: $e');
      rethrow;
    }
  }

  // ── Update Property ──────────────────────────────────────────────────────────
  Future<void> updateProperty(String propertyId, Map<String, dynamic> data) async {
    try {
      await ApiClient().dio.put(ApiConstants.property(propertyId), data: data);
      await loadProperties();
    } catch (e) {
      debugPrint('[LandlordProvider] updateProperty error: $e');
      rethrow;
    }
  }

  // ── Delete Property ──────────────────────────────────────────────────────────
  Future<void> deleteProperty(String propertyId) async {
    try {
      await ApiClient().dio.delete(ApiConstants.property(propertyId));
      await loadProperties();
    } catch (e) {
      debugPrint('[LandlordProvider] deleteProperty error: $e');
      rethrow;
    }
  }

  // ── Create Lease ─────────────────────────────────────────────────────────────
  Future<void> createLease({
    required String tenantId,
    required String unitId,
    required String propertyId,
    required String startDate,
    required String endDate,
    required double rentAmount,
    double securityDeposit = 0.0,
    String paymentSchedule = 'monthly',
    bool autoRenew = false,
  }) async {
    final payload = <String, dynamic>{
      'tenantId': tenantId,
      'unitId': unitId,
      'propertyId': propertyId,
      'startDate': startDate,
      'endDate': endDate,
      'rentAmount': rentAmount,
      'securityDeposit': securityDeposit,
      'paymentSchedule': paymentSchedule,
      'autoRenew': autoRenew,
    };
    await ApiClient().dio.post(ApiConstants.leases, data: payload);
    await loadLeases();
    await loadTenants();
  }

  // ── Renew Lease ──────────────────────────────────────────────────────────────
  Future<void> renewLease(String leaseId, String newEndDate) async {
    try {
      await ApiClient().dio.post(
        ApiConstants.leaseRenew(leaseId),
        data: {'newEndDate': newEndDate},
      );
      await loadLeases();
    } catch (e) {
      debugPrint('[LandlordProvider] renewLease error: $e');
      rethrow;
    }
  }

  // ── Update Lease Status ──────────────────────────────────────────────────────
  Future<void> updateLeaseStatus(String leaseId, String status) async {
    try {
      await ApiClient().dio.put(
        ApiConstants.leaseStatus(leaseId),
        data: {'status': status},
      );
      await loadLeases();
    } catch (e) {
      debugPrint('[LandlordProvider] updateLeaseStatus error: $e');
      rethrow;
    }
  }

  // ── Add Unit ─────────────────────────────────────────────────────────────────
  Future<void> addUnit(String propertyId, Unit unit) async {
    try {
      final payload = {
        'unitNumber': unit.name,
        'price': unit.rent,
        'status': unit.status.toLowerCase(),
        if (unit.bedrooms > 0) 'bedrooms': unit.bedrooms,
        if (unit.bathrooms > 0) 'bathrooms': unit.bathrooms,
        if (unit.squareFeet > 0) 'squareFeet': unit.squareFeet,
        if (unit.depositAmount > 0) 'depositAmount': unit.depositAmount,
      };
      await ApiClient().dio.post(
        ApiConstants.propertyUnits(propertyId),
        data: payload,
      );
      await loadUnits(propertyId);
      await loadProperties();
    } catch (e) {
      debugPrint('[LandlordProvider] addUnit error: $e');
      rethrow;
    }
  }

  // ── Update Unit ──────────────────────────────────────────────────────────────
  Future<void> updateUnit(String propertyId, String unitId, Map<String, dynamic> data) async {
    try {
      await ApiClient().dio.put(
        ApiConstants.propertyUnit(propertyId, unitId),
        data: data,
      );
      await loadUnits(propertyId);
      await loadProperties();
    } catch (e) {
      debugPrint('[LandlordProvider] updateUnit error: $e');
      rethrow;
    }
  }

  // ── Delete Unit ──────────────────────────────────────────────────────────────
  Future<void> deleteUnit(String propertyId, String unitId) async {
    try {
      await ApiClient().dio.delete(ApiConstants.propertyUnit(propertyId, unitId));
      await loadUnits(propertyId);
      await loadProperties();
    } catch (e) {
      debugPrint('[LandlordProvider] deleteUnit error: $e');
      rethrow;
    }
  }

  // ── Add Tenant Memo ──────────────────────────────────────────────────────────
  void addMemoToTenant(String tenantId, String memo) {
    final updatedTenants = state.tenants.map((t) {
      if (t.id == tenantId) {
        return t.copyWith(memos: [...t.memos, memo]);
      }
      return t;
    }).toList();
    state = state.copyWith(tenants: updatedTenants);
  }

  // ── Create Work Order ────────────────────────────────────────────────────────
  Future<String> createWorkOrder(WorkOrder order, {String? assignedVendorId, String? scheduledDate}) async {
    try {
      // Find property ID by matching name
      final properties = state.properties;
      final matchedProp = properties.isNotEmpty
          ? properties.firstWhere(
              (p) => p.name == order.propertyName,
              orElse: () => properties.first,
            )
          : null;

      if (matchedProp == null) {
        throw Exception('No property found. Please add a property first.');
      }

      // Find unit ID — units are loaded in state.units
      final units = state.units;
      final matchedUnit = units.isNotEmpty
          ? units.firstWhere(
              (u) => u.name == order.unitName,
              orElse: () => units.first,
            )
          : null;

      if (matchedUnit == null) {
        throw Exception('No unit found. Please add a unit to this property first.');
      }

      // Map display category names to backend enum values
      final categoryMap = {
        'general repair': 'general_repair',
        'plumbing': 'plumbing',
        'electrical': 'electrical',
        'hvac': 'hvac',
        'appliance': 'appliance',
        'painting': 'painting',
        'other': 'other',
      };
      final mappedCategory = categoryMap[order.category.toLowerCase()] ?? 'general_repair';

      final payload = {
        'propertyId': matchedProp.id,
        'unitId': matchedUnit.id,
        'title': order.title,
        'description': order.description,
        'priority': order.priority.toLowerCase(),
        'category': mappedCategory,
        'currency': 'USD',
        'accessInstructions': order.accessInstructions,
        'notifyTenant': true,
        'notifyVendor': true,
        if (assignedVendorId != null) 'assignedVendorId': assignedVendorId,
        if (scheduledDate != null) 'scheduledDate': scheduledDate,
      };

      final resp = await ApiClient().dio.post(ApiConstants.workOrders, data: payload);
      await loadWorkOrders();
      final createdData = resp.data['data'] as Map<String, dynamic>? ?? {};
      return createdData['id']?.toString() ?? '';
    } catch (e) {
      if (e is DioException) {
        debugPrint('[LandlordProvider] createWorkOrder response error data: ${e.response?.data}');
      }
      debugPrint('[LandlordProvider] createWorkOrder error: $e');
      rethrow;
    }
  }

  // ── Upload Work Order Photo ─────────────────────────────────────────────────
  Future<void> uploadWorkOrderPhoto(String workOrderId, List<int> bytes, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });
      await ApiClient().dio.post(ApiConstants.uploadsWorkOrderPhoto(workOrderId), data: formData);
      await loadWorkOrders();
    } catch (e) {
      debugPrint('[LandlordProvider] uploadWorkOrderPhoto error: $e');
      rethrow;
    }
  }

  // ── Assign Bid ───────────────────────────────────────────────────────────────
  Future<void> assignBidToWorkOrder(String orderId, Bid bid) async {
    try {
      await ApiClient().dio.post(ApiConstants.bidAccept(bid.id));
      await loadWorkOrders();
    } catch (e) {
      debugPrint('Error assigning bid: $e');
      rethrow;
    }
  }

  // ── Chat message sending ─────────────────────────────────────────────────────
  void sendMessage(String text) {
    final newMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderName: 'Landlord',
      role: 'Landlord',
      message: text,
      time: 'Just now',
    );
    state = state.copyWith(chatMessages: [...state.chatMessages, newMsg]);
  }

  // ── Update Work Order Status ─────────────────────────────────────────────────
  Future<void> updateWorkOrderStatus(String orderId, String newStatus) async {
    try {
      final payload = {'status': newStatus.toLowerCase()};
      await ApiClient().dio.put(
        ApiConstants.workOrderStatus(orderId),
        data: payload,
      );
      await loadWorkOrders();
    } catch (e) {
      debugPrint('Error updating work order status: $e');
      rethrow;
    }
  }

  // ── Notifications ──────────────────────────────────────────────────────────────
  Future<void> fetchNotifications() async {
    try {
      final resp = await ApiClient().dio.get(ApiConstants.notifications);
      final rawList = (resp.data['data'] ?? []) as List<dynamic>;
      final notifications = rawList.map((m) => NotificationItem(
        id: m['id'].toString(),
        title: m['title']?.toString() ?? 'Notification',
        body: m['body']?.toString() ?? '',
        type: m['type']?.toString() ?? 'system',
        isRead: m['is_read'] == true,
        createdAt: m['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      )).toList();
      
      final unreadCountResp = await ApiClient().dio.get(ApiConstants.notificationsUnreadCount);
      int unreadCount = 0;
      if (unreadCountResp.data['data'] is num) {
        unreadCount = (unreadCountResp.data['data'] as num).toInt();
      } else if (unreadCountResp.data['data'] is Map && unreadCountResp.data['data']['count'] != null) {
        unreadCount = int.tryParse(unreadCountResp.data['data']['count'].toString()) ?? 0;
      }
      
      state = state.copyWith(notifications: notifications, unreadNotifications: unreadCount);
    } catch (e) {
      debugPrint('[LandlordProvider] fetchNotifications error: $e');
    }
  }

  Future<void> markNotificationRead(String id) async {
    try {
      await ApiClient().dio.put(ApiConstants.notificationRead(id));
      await fetchNotifications();
    } catch (e) {
      debugPrint('[LandlordProvider] markNotificationRead error: $e');
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await ApiClient().dio.put(ApiConstants.notificationsReadAll);
      await fetchNotifications();
    } catch (e) {
      debugPrint('[LandlordProvider] markAllNotificationsRead error: $e');
    }
  }

  String _parsePhotoUrl(dynamic p) {
    String str = p.toString();
    String relativePath = str;
    
    if (str.startsWith('{')) {
      try {
        final decoded = jsonDecode(str);
        relativePath = decoded['key'] ?? str;
        if (decoded['url'] != null) {
          String url = decoded['url'];
          if (url.startsWith('http://localhost')) {
            url = url.replaceFirst('http://localhost:5000', ApiConstants.baseUrl.replaceAll('/api/v1', ''));
          }
          return url;
        }
      } catch (_) {
        final urlMatch = RegExp(r'url:\s*([^,}]+)').firstMatch(str);
        if (urlMatch != null && urlMatch.group(1) != null) {
          String url = urlMatch.group(1)!.trim();
          if (url.startsWith('http://localhost')) {
            url = url.replaceFirst('http://localhost:5000', ApiConstants.baseUrl.replaceAll('/api/v1', ''));
          }
          return url;
        }
        final keyMatch = RegExp(r'key:\s*([^,}]+)').firstMatch(str);
        if (keyMatch != null && keyMatch.group(1) != null) {
          relativePath = keyMatch.group(1)!.trim();
        }
      }
    }
    
    if (relativePath.startsWith('http')) {
       if (relativePath.startsWith('http://localhost')) {
         relativePath = relativePath.replaceFirst('http://localhost:5000', ApiConstants.baseUrl.replaceAll('/api/v1', ''));
       }
       return relativePath;
    }
    if (relativePath.startsWith('/')) relativePath = relativePath.substring(1);
    
    final base = ApiConstants.baseUrl.replaceAll('/api/v1', '');
    return '$base/$relativePath';
  }

  // ── Approval Workflow & Admin Actions ──────────────────────────────────────────
  Future<void> resubmitProperty(String propertyId) async {
    try {
      await ApiClient().dio.post('${ApiConstants.properties}/$propertyId/resubmit');
      await loadProperties(); // Refresh the list
    } catch (e) {
      debugPrint('[LandlordProvider] resubmitProperty error: $e');
      rethrow;
    }
  }

  Future<void> adminRequestRevision(String propertyId, String reason, List<String> requestedDocuments) async {
    try {
      await ApiClient().dio.post('/admin/properties/$propertyId/request-revision', data: {
        'reason': reason,
        'requestedDocuments': requestedDocuments,
      });
      await loadProperties();
    } catch (e) {
      debugPrint('[LandlordProvider] adminRequestRevision error: $e');
      if (e is DioException && e.response?.data != null) {
        throw e.response!.data['message'] ?? 'Server error';
      }
      throw 'Failed to request revision';
    }
  }

  Future<void> adminPermanentReject(String propertyId, String reason) async {
    try {
      await ApiClient().dio.post('/admin/properties/$propertyId/permanent-reject', data: {
        'reason': reason,
      });
      await loadProperties();
    } catch (e) {
      debugPrint('[LandlordProvider] adminPermanentReject error: $e');
      if (e is DioException && e.response?.data != null) {
        throw e.response!.data['message'] ?? 'Server error';
      }
      throw 'Failed to permanently reject property';
    }
  }

  Future<void> adminApproveProperty(String propertyId) async {
    try {
      await ApiClient().dio.post('/admin/properties/$propertyId/approve');
      await loadProperties();
    } catch (e) {
      debugPrint('[LandlordProvider] adminApproveProperty error: $e');
      if (e is DioException && e.response?.data != null) {
        throw e.response!.data['message'] ?? 'Server error';
      }
      throw 'Failed to approve property';
    }
  }

  // ── Work Order details & Bids ────────────────────────────────────────────────
  Future<WorkOrder> fetchWorkOrderById(String id) async {
    try {
      final resp = await ApiClient().dio.get(ApiConstants.workOrderById(id));
      final m = resp.data['data'] as Map<String, dynamic>;
      
      final w = WorkOrder(
        id: m['id']?.toString() ?? '',
        title: m['title']?.toString() ?? 'Work Order',
        description: m['description']?.toString() ?? '',
        propertyName: m['property_name']?.toString() ?? 'Property',
        unitName: m['unit_name']?.toString() ?? 'Unit',
        category: _capitalize(m['category']?.toString() ?? 'repair'),
        priority: _capitalize(m['priority']?.toString() ?? 'medium'),
        status: _formatStatus(m['status']?.toString() ?? 'request'),
        tenantName: m['tenant_name']?.toString() ?? m['tenantName']?.toString() ?? 'Tenant',
        photos: (m['photos'] as List<dynamic>?)?.map((p) => _parsePhotoUrl(p)).toList() ?? const [],
        date: m['created_at']?.toString() ?? '',
        timeSlot: 'Anytime',
        accessInstructions: 'N/A',
        vendorName: m['vendor_name']?.toString() ?? 'Unassigned',
      );
      
      return w;
    } catch (e) {
      debugPrint('[LandlordProvider] fetchWorkOrderById error: $e');
      rethrow;
    }
  }

  Future<void> fetchBidsForWorkOrder(String workOrderId) async {
    state = state.copyWith(isBidsLoading: true);
    try {
      // The bids are returned in the work order details endpoint (bids array)
      final resp = await ApiClient().dio.get(ApiConstants.workOrderById(workOrderId));
      final m = resp.data['data'] as Map<String, dynamic>;
      final rawBids = (m['bids'] ?? []) as List<dynamic>;
      
      final bids = rawBids.map((b) => Bid(
        id: b['id']?.toString() ?? '',
        vendorName: b['vendor_name']?.toString() ?? 'Vendor',
        avatarUrl: b['vendor_avatar']?.toString() ?? 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=50&q=80',
        price: _safeDouble(b['amount']),
        rating: 4.8, // backend doesn't provide rating yet
        totalJobs: 12,
        time: '${b['estimated_hours'] ?? 1} hours',
      )).toList();
      
      state = state.copyWith(bids: bids, isBidsLoading: false);
    } catch (e) {
      debugPrint('[LandlordProvider] fetchBidsForWorkOrder error: $e');
      state = state.copyWith(isBidsLoading: false);
    }
  }

  Future<void> acceptBid(String bidId) async {
    try {
      await ApiClient().dio.post('${ApiConstants.maintenanceBids}/$bidId/accept');
    } catch (e) {
      debugPrint('[LandlordProvider] acceptBid error: $e');
      rethrow;
    }
  }

  // ── Screening Application Review ─────────────────────────────────────────────

  /// GET /screening/applications/:id
  /// Returns the raw JSON map for a specific screening application record.
  Future<Map<String, dynamic>> fetchScreeningApplication(String id) async {
    final resp = await ApiClient().dio.get(ApiConstants.screeningApplication(id));
    final data = resp.data['data'];
    if (data == null) throw Exception('No screening application data returned');
    return data as Map<String, dynamic>;
  }

  /// GET /screening/applications/:id/credit-report
  Future<Map<String, dynamic>> fetchScreeningCreditReport(String id) async {
    final resp = await ApiClient().dio.get(ApiConstants.screeningCreditReport(id));
    final data = resp.data['data'];
    if (data == null) throw Exception('No credit report data returned');
    return data as Map<String, dynamic>;
  }

  /// GET /screening/applications/:id/background-check
  Future<Map<String, dynamic>> fetchScreeningBackgroundCheck(String id) async {
    final resp = await ApiClient().dio.get(ApiConstants.screeningBackgroundCheck(id));
    final data = resp.data['data'];
    if (data == null) throw Exception('No background check data returned');
    return data as Map<String, dynamic>;
  }

  /// POST /screening/applications/:id/decision  { decision: 'APPROVED' | 'REJECTED' | 'PENDING' }
  Future<void> postScreeningDecision(String id, String decision) async {
    await ApiClient().dio.post(
      ApiConstants.screeningDecision(id),
      data: {'decision': decision},
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String _formatStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'open':
      case 'request':
        return 'Request';
      case 'assigned':
        return 'Assigned';
      case 'in_progress':
      case 'in-progress':
        return 'In-Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return _capitalize(raw);
    }
  }
}

final landlordProvider = StateNotifierProvider<LandlordNotifier, LandlordState>(
  (ref) => LandlordNotifier(),
);
