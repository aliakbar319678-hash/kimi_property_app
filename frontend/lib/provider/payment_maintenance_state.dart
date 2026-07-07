import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_maintenance_state.freezed.dart';

// ── Pay Rent ──────────────────────────────────
enum PaymentMethod { bankACH, eTransfer, creditCard }

@freezed
abstract class PayRentState with _$PayRentState {
  const factory PayRentState({
    @Default(PaymentMethod.bankACH) PaymentMethod selectedMethod,
    @Default(false) bool isLoading,
  }) = _PayRentState;
}

// ── Lease Summary ─────────────────────────────
@freezed
abstract class LeaseSummaryState with _$LeaseSummaryState {
  const factory LeaseSummaryState({@Default(false) bool isDownloading}) =
      _LeaseSummaryState;
}

// ── Payment History ───────────────────────────
@freezed
abstract class PaymentHistoryState with _$PaymentHistoryState {
  const factory PaymentHistoryState({@Default(false) bool isLoading}) =
      _PaymentHistoryState;
}

// ── Maintenance Request ───────────────────────
@freezed
abstract class MaintenanceRequestState with _$MaintenanceRequestState {
  const factory MaintenanceRequestState({
    String? issueType,
    @Default('') String description,
    @Default(false) bool isEmergency,
    @Default(false) bool hasPhoto,
    @Default(false) bool isLoading,
  }) = _MaintenanceRequestState;
}

// ── Request Tracking ──────────────────────────
@freezed
abstract class RequestTrackingState with _$RequestTrackingState {
  const factory RequestTrackingState({@Default(false) bool isLoading}) =
      _RequestTrackingState;
}
