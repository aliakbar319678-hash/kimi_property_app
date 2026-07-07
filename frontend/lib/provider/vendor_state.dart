import 'package:freezed_annotation/freezed_annotation.dart';

part 'vendor_state.freezed.dart';

@freezed
abstract class VendorProfile with _$VendorProfile {
  const factory VendorProfile({
    @Default('') String businessName,
    @Default('') String taxId,
    @Default('Plumbing') String serviceCategory,
    @Default('') String phone,
    @Default('') String email,
    @Default('') String address,
    @Default('') String city,
    @Default('') String state,
    @Default('') String zip,
    @Default('Upload') String tradeLicenseStatus,
    @Default('Upload') String proofOfInsuranceStatus,
    @Default('Upload') String w9FormStatus,
    @Default('') String bankName,
    @Default('') String routingNumber,
    @Default('') String accountNumber,
    @Default(false) bool isOnboarded,
  }) = _VendorProfile;
}

@freezed
abstract class VendorWorkOrder with _$VendorWorkOrder {
  const factory VendorWorkOrder({
    required String id,
    required String title,
    required String description,
    required String propertyName,
    required String unitName,
    required String tenantName,
    required String priority, // 'Low', 'Medium', 'High', 'Emergency'
    required String status, // 'Assigned', 'In-Progress', 'Completed'
    required String category, // 'Plumbing', 'Electrical', 'HVAC', 'General'
    required String date,
    required String timeSlot,
    required String accessInstructions,
    required String address,
    @Default(47.6062) double latitude,
    @Default(-122.3321) double longitude,
    required double bidAmount,
    @Default(0) int durationOnSite, // in seconds
    String? checkInTime,
  }) = _VendorWorkOrder;
}

@freezed
abstract class VendorBid with _$VendorBid {
  const factory VendorBid({
    required String id,
    required String title,
    required String category,
    required String description,
    required String address,
    required double price,
    required String status, // 'Pending', 'Accepted', 'Rejected'
    required String dateSubmitted,
    @Default([]) List<String> scopeChecklist,
    @Default('') String landlordMessage,
  }) = _VendorBid;
}

@freezed
abstract class VendorPayment with _$VendorPayment {
  const factory VendorPayment({
    required String id,
    required String invoiceNumber,
    required double amount,
    required String date,
    required String status, // 'Pending', 'Paid'
    required String jobTitle,
  }) = _VendorPayment;
}

@freezed
abstract class VendorState with _$VendorState {
  const factory VendorState({
    @Default(VendorProfile()) VendorProfile profile,
    @Default([]) List<VendorWorkOrder> activeJobs,
    @Default([]) List<VendorWorkOrder> availableJobs,
    @Default([]) List<VendorBid> bids,
    @Default([]) List<VendorPayment> payments,
    @Default(8540.0) double earnings,
    @Default(1348.0) double pendingPayments,
    @Default(7208.0) double completedPayments,
    @Default(4.8) double rating,
    @Default(248) int jobsCount,
    @Default(96.0) double onTimeRate,
    @Default("18 Mins") String responseTime,
    @Default(false) bool checkedIn,
    String? checkedInJobId,
    @Default(0) int elapsedSeconds,
    @Default(false) bool isLoading,
  }) = _VendorState;
}
