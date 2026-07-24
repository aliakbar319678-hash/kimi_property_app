import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/api_constants.dart';

// ── Tenant Lease Data ─────────────────────────────────────────────────────
// A simple model to hold the tenant's active lease details
class TenantLeaseData {
  final String leaseId;
  final String propertyName;
  final String unitName;
  final double rentAmount;
  final double securityDeposit;
  final String startDate;
  final String endDate;
  final String status;
  final String dueDayOfMonth; // e.g. "1st"

  const TenantLeaseData({
    required this.leaseId,
    required this.propertyName,
    required this.unitName,
    required this.rentAmount,
    required this.securityDeposit,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.dueDayOfMonth,
  });

  factory TenantLeaseData.empty() => const TenantLeaseData(
        leaseId: '',
        propertyName: 'Your Property',
        unitName: 'Your Unit',
        rentAmount: 0,
        securityDeposit: 0,
        startDate: '',
        endDate: '',
        status: 'active',
        dueDayOfMonth: '1st',
      );

  factory TenantLeaseData.fromJson(Map<String, dynamic> m) {
    final rentRaw = m['rent_amount'] ?? m['rentAmount'] ?? 0;
    final rent = rentRaw is num ? rentRaw.toDouble() : double.tryParse(rentRaw.toString()) ?? 0.0;
    final depRaw = m['security_deposit'] ?? m['securityDeposit'] ?? 0;
    final deposit = depRaw is num ? depRaw.toDouble() : double.tryParse(depRaw.toString()) ?? 0.0;
    final prop = m['property'] as Map<String, dynamic>? ?? {};
    final unit = m['unit'] as Map<String, dynamic>? ?? {};

    return TenantLeaseData(
      leaseId: m['id']?.toString() ?? '',
      propertyName:
          prop['name']?.toString() ?? m['property_name']?.toString() ?? 'Property',
      unitName:
          unit['unit_number']?.toString() ?? m['unit_name']?.toString() ?? m['unit_number']?.toString() ?? 'Unit',
      rentAmount: rent,
      securityDeposit: deposit,
      startDate:
          m['start_date']?.toString() ?? m['startDate']?.toString() ?? '',
      endDate: m['end_date']?.toString() ?? m['endDate']?.toString() ?? '',
      status: m['status']?.toString() ?? 'active',
      dueDayOfMonth: '1st', // Most leases are due the 1st
    );
  }
}

/// Fetches the tenant's active lease from /tenant/active-lease
final tenantLeaseProvider = FutureProvider<TenantLeaseData>((ref) async {
  try {
    final resp = await ApiClient().dio.get(ApiConstants.tenantActiveLease);
    final data = resp.data['data'];

    if (data != null && data['id'] != null) {
      return TenantLeaseData.fromJson(data);
    }
    return TenantLeaseData.empty();
  } on DioException catch (e) {
    if (e.response?.statusCode == 403 || e.response?.statusCode == 404) {
      return TenantLeaseData.empty();
    }
    rethrow;
  }
});

/// Fetches lease dashboard stats using /leases/dashboard
final leaseDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final resp = await ApiClient().dio.get(ApiConstants.leasesDashboard);
    final data = resp.data['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is List && data.isNotEmpty) return data.first as Map<String, dynamic>;
    return {};
  } on DioException {
    return {};
  }
});

/// Fetches tenant payment history from /finance/dashboard
final tenantFinanceProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final resp = await ApiClient().dio.get(ApiConstants.financeDashboard);
    final data = resp.data['data'];
    if (data is Map<String, dynamic>) return data;
    return {};
  } on DioException {
    return {};
  }
});

/// Fetches tenant's work orders / maintenance requests from /maintenance/work-orders
final tenantWorkOrdersProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final resp = await ApiClient().dio.get(ApiConstants.workOrders);
    final data = resp.data['data'];
    if (data is List) {
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  } on DioException {
    return [];
  }
});
