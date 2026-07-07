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
  }) = _Property;
}

@freezed
abstract class Unit with _$Unit {
  const factory Unit({
    required String id,
    required String name,
    required String status, // 'Occupied', 'Vacant', 'Maintenance'
    required String tenantName,
    required double rent,
    required List<String> amenities,
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
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String senderName,
    required String role, // 'Landlord', 'Vendor', 'Tenant'
    required String message,
    required String time,
  }) = _ChatMessage;
}

@freezed
abstract class LandlordState with _$LandlordState {
  const factory LandlordState({
    @Default([]) List<Property> properties,
    @Default([]) List<Unit> units,
    @Default([]) List<Tenant> tenants,
    @Default([]) List<WorkOrder> workOrders,
    @Default([]) List<Bid> bids,
    @Default([]) List<ChatMessage> chatMessages,
    @Default(24500.0) double totalCollected,
    @Default(3200.0) double totalOutstanding,
    @Default(0.94) double occupancyRate,
    @Default(false) bool isLoading,
  }) = _LandlordState;
}
