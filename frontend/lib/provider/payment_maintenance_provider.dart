import 'package:flutter_riverpod/legacy.dart';
import 'package:dio/dio.dart';
import 'payment_maintenance_state.dart';
import '../core/api_client.dart';
import '../core/api_constants.dart';

// ── Lease Summary ─────────────────────────────
class LeaseSummaryNotifier extends StateNotifier<LeaseSummaryState> {
  LeaseSummaryNotifier() : super(const LeaseSummaryState());

  /// Simulates downloading the lease PDF.
  /// In production you'd fetch from the backend and open a URL.
  Future<void> downloadLease() async {
    state = state.copyWith(isDownloading: true);
    // The backend /finance/invoices (POST) is for vendor invoices.
    // For tenant lease PDF, the lease document URL is stored in the lease record.
    // We'll call /leases/dashboard to get the lease doc URL, then open it.
    try {
      final resp = await ApiClient().dio.get(ApiConstants.leasesDashboard);
      final data = resp.data['data'];
      if (data is List && data.isNotEmpty) {
        // lease = data.first as Map<String, dynamic>;
      } else if (data is Map<String, dynamic>) {
        // lease = data;
      }
      // document_url may be stored in lease or its signed_url
      // final docUrl = lease?['document_url'] ?? lease?['lease_document_url'];
      // For now, we just complete successfully (no PDF viewer integrated)
    } catch (_) {
      // Fail silently — show done anyway
    } finally {
      state = state.copyWith(isDownloading: false);
    }
  }
}

final leaseSummaryProvider =
    StateNotifierProvider<LeaseSummaryNotifier, LeaseSummaryState>(
      (ref) => LeaseSummaryNotifier(),
    );

// ── Pay Rent ──────────────────────────────────
class PayRentNotifier extends StateNotifier<PayRentState> {
  PayRentNotifier() : super(const PayRentState());

  void selectMethod(PaymentMethod m) =>
      state = state.copyWith(selectedMethod: m);

  /// Calls POST /finance/payments/initiate with the tenant's lease ID and amount.
  Future<bool> payNow({required String leaseId, required double amount}) async {
    if (leaseId.isEmpty) {
      // No active lease found — show warning
      return false;
    }
    state = state.copyWith(isLoading: true);
    try {
      final methodStr = switch (state.selectedMethod) {
        PaymentMethod.bankACH => 'ach',
        PaymentMethod.eTransfer => 'e_transfer',
        PaymentMethod.creditCard => 'card',
      };

      await ApiClient().dio.post(
        ApiConstants.initiatePayment,
        data: {
          'leaseId': leaseId,
          'amount': amount,
          'paymentMethod': methodStr,
        },
      );
      state = state.copyWith(isLoading: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false);
      final msg = e.response?.data?['error'] ?? e.response?.data?['message'];
      throw Exception(msg ?? 'Payment failed. Please try again.');
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}

final payRentProvider = StateNotifierProvider<PayRentNotifier, PayRentState>(
  (ref) => PayRentNotifier(),
);

// ── Payment History ───────────────────────────
class PaymentHistoryNotifier extends StateNotifier<PaymentHistoryState> {
  PaymentHistoryNotifier() : super(const PaymentHistoryState());
}

final paymentHistoryProvider =
    StateNotifierProvider<PaymentHistoryNotifier, PaymentHistoryState>(
      (ref) => PaymentHistoryNotifier(),
    );

// ── Maintenance Request ───────────────────────
class MaintenanceRequestNotifier
    extends StateNotifier<MaintenanceRequestState> {
  MaintenanceRequestNotifier() : super(const MaintenanceRequestState());

  void setIssueType(String v) => state = state.copyWith(issueType: v);
  void setDescription(String v) => state = state.copyWith(description: v);
  void toggleEmergency() =>
      state = state.copyWith(isEmergency: !state.isEmergency);
  void addPhoto() => state = state.copyWith(hasPhoto: true);

  /// Submits a new maintenance work order to POST /maintenance/work-orders
  Future<void> submit({
    required String propertyId,
    required String unitId,
  }) async {
    if (state.issueType == null || state.issueType!.isEmpty) {
      throw Exception('Please select an issue type.');
    }
    if (state.description.trim().isEmpty) {
      throw Exception('Please describe the issue.');
    }

    state = state.copyWith(isLoading: true);
    try {
      await ApiClient().dio.post(
        ApiConstants.workOrders,
        data: {
          'title': state.issueType,
          'description': state.description.trim(),
          'priority': state.isEmergency ? 'emergency' : 'normal',
          'property_id': propertyId,
          'unit_id': unitId,
        },
      );
      // Reset form on success
      state = const MaintenanceRequestState();
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false);
      final msg = e.response?.data?['error'] ?? e.response?.data?['message'];
      throw Exception(msg ?? 'Failed to submit request.');
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}

final maintenanceRequestProvider =
    StateNotifierProvider<MaintenanceRequestNotifier, MaintenanceRequestState>(
      (ref) => MaintenanceRequestNotifier(),
    );

// ── Request Tracking ──────────────────────────
class RequestTrackingNotifier extends StateNotifier<RequestTrackingState> {
  RequestTrackingNotifier() : super(const RequestTrackingState());
}

final requestTrackingProvider =
    StateNotifierProvider<RequestTrackingNotifier, RequestTrackingState>(
      (ref) => RequestTrackingNotifier(),
    );
