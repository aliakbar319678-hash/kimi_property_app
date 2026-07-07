import 'package:flutter_riverpod/legacy.dart';
import 'payment_maintenance_state.dart';

// ── Lease Summary ─────────────────────────────
class LeaseSummaryNotifier extends StateNotifier<LeaseSummaryState> {
  LeaseSummaryNotifier() : super(const LeaseSummaryState());

  Future<void> downloadLease() async {
    state = state.copyWith(isDownloading: true);
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isDownloading: false);
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

  Future<void> payNow() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isLoading: false);
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

  Future<void> submit() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isLoading: false);
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
