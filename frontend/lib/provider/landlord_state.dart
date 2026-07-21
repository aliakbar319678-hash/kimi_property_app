import 'package:freezed_annotation/freezed_annotation.dart';

part 'landlord_state.freezed.dart';

@freezed
abstract class Property with _$Property {
  const factory Property({
    required String id,
    required String name,
    required String address,
    required double occupancyRate,
    required String imageUrl,
    required int totalUnits,
    required int occupiedUnits,
    required int vacantUnits,
    required double monthlyRent,
    // Extra backend fields
    @Default('apartment') String type,
    @Default([]) List<String> amenities,
    @Default('') String description,
    @Default('active') String status,
    // Approval workflow fields
    @Default('pending') String verificationStatus, // 'pending' | 'approved' | 'rejected' | 'needs_revision' | 'resubmitted' | 'permanently_rejected'
    @Default(null) String? rejectionReason,
    @Default(0) int resubmissionCount,
    @Default([]) List<dynamic> requestedDocuments,
    @Default(false) bool isPermanentlyRejected,
    @Default([]) List<dynamic> revisionHistory,
    // Extra dynamic fields
    @Default({}) Map<String, dynamic> metadata,
  }) = _Property;
}

@freezed
abstract class Unit with _$Unit {
  const factory Unit({
    required String id,
    required String name,
    required String status, // 'occupied', 'vacant', 'maintenance', 'reserved'
    required String tenantName,
    required double rent,
    required List<String> amenities,
    // Extra backend fields
    @Default(0) int bedrooms,
    @Default(0) int bathrooms,
    @Default(0) int squareFeet,
    @Default(0.0) double depositAmount,
    @Default('') String availableDate,
    @Default('') String propertyId,
  }) = _Unit;
}

@freezed
abstract class Tenant with _$Tenant {
  const factory Tenant({
    required String id,
    required String name,
    required String unitName,
    required String contact,
    required String email,
    required String emergencyContactName,
    required String emergencyContactPhone,
    required List<String> memos,
    required double balance,
    required String status, // 'Active', 'Late Payment'
    required String dateJoined,
    // Extra lease-linked fields
    @Default('') String propertyName,
    @Default('') String leaseEndDate,
    @Default(0.0) double rentAmount,
    @Default('') String avatarUrl,
  }) = _Tenant;
}

@freezed
abstract class WorkOrder with _$WorkOrder {
  const factory WorkOrder({
    required String id,
    required String title,
    required String description,
    required String propertyName,
    required String unitName,
    required String tenantName,
    required String priority, // 'Low', 'Medium', 'High', 'Emergency'
    required String status, // 'Request', 'Assigned', 'In-Progress', 'Completed'
    required List<String> photos,
    required String
    category, // 'Plumbing', 'Electrical', 'HVAC', 'General Repair', etc.
    required String date,
    required String timeSlot,
    required String accessInstructions,
    String? vendorName,
    String? vendorPhone,
    double? bidAmount,
  }) = _WorkOrder;
}

@freezed
abstract class Bid with _$Bid {
  const factory Bid({
    required String id,
    required String vendorName,
    required double rating,
    required int totalJobs,
    required double price,
    required String time,
    required String avatarUrl,
  }) = _Bid;
}

@freezed
abstract class VendorProfile with _$VendorProfile {
  const factory VendorProfile({
    required String id,
    required String displayName,
    required String email,
    required double avgRating,
  }) = _VendorProfile;
}

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String senderName,
    required String role, // 'Landlord', 'Vendor', 'Tenant'
    required String message,
    required String time,
  }) = _ChatMessage;
}

/// A single lease record from the backend.
@freezed
abstract class Lease with _$Lease {
  const factory Lease({
    required String id,
    required String unitName,
    required String tenantName,
    required String propertyName,
    required double rentAmount,
    required String startDate,
    required String endDate,
    required String status, // 'active', 'expired', 'pending'
    @Default(0) int daysLeft,
  }) = _Lease;
}

/// Represents an urgent alert item shown on the dashboard home page.
@freezed
abstract class UrgentAlert with _$UrgentAlert {
  const factory UrgentAlert({
    required String id,
    required String title,
    required String description,
    required String type, // 'maintenance' | 'lease'
    String? priority,
  }) = _UrgentAlert;
}

@freezed
abstract class NotificationItem with _$NotificationItem {
  const factory NotificationItem({
    required String id,
    required String title,
    required String body,
    required String type,
    required bool isRead,
    required String createdAt,
  }) = _NotificationItem;
}

@freezed
abstract class LandlordState with _$LandlordState {
  const factory LandlordState({
    // ── Profile ────────────────────────────────────────────────
    @Default('') String userName,
    @Default('') String userAvatarUrl,

    // ── Core Lists ─────────────────────────────────────────────
    @Default([]) List<Property> properties,
    @Default([]) List<Unit> units,
    @Default([]) List<Tenant> tenants,
    @Default([]) List<WorkOrder> workOrders,
    @Default([]) List<Bid> bids,
    @Default([]) List<VendorProfile> vendors,
    @Default([]) List<ChatMessage> chatMessages,
    @Default([]) List<Lease> leases,

    // ── Finance ────────────────────────────────────────────────
    @Default(0.0) double totalCollected,
    @Default(0.0) double totalOutstanding,
    @Default(0.0) double occupancyRate,
    @Default(0.0) double rentCollectionPercent, // 0.0 to 1.0

    // ── Maintenance Summary ────────────────────────────────────
    @Default(0) int maintenanceEmergency,
    @Default(0) int maintenanceInProgress,
    @Default(0) int maintenanceCompleted,

    // ── Lease Summary ─────────────────────────────────────────
    @Default(0) int activeLeaseCount,
    @Default(0) int expiringLeaseCount,

    // ── Urgent Alerts (home dashboard) ────────────────────────
    @Default([]) List<UrgentAlert> urgentAlerts,

    // ── Notifications ─────────────────────────────────────────
    @Default([]) List<NotificationItem> notifications,
    @Default(0) int unreadNotifications,

    // ── Loading ────────────────────────────────────────────────
    @Default(false) bool isLoading,
    @Default(false) bool isTenantsLoading,
    @Default(false) bool isLeasesLoading,
    @Default(false) bool isUnitsLoading,
    @Default(false) bool isBidsLoading,

    // ── Error ──────────────────────────────────────────────────
    @Default('') String errorMessage,
  }) = _LandlordState;
}
