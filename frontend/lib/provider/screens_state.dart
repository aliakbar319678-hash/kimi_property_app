import 'package:freezed_annotation/freezed_annotation.dart';

part 'screens_state.freezed.dart';

// ── Notification Filter ───────────────────────
enum NotifFilter { all, payments, maintenance, lease }

// ── Notification Item ─────────────────────────
@freezed
abstract class NotificationItem with _$NotificationItem {
  const factory NotificationItem({
    required String id,
    required String title,
    required String message,
    required String type,
    required String createdAt,
    @Default(false) bool isRead,
  }) = _NotificationItem;
}

@freezed
abstract class NotificationsState with _$NotificationsState {
  const factory NotificationsState({
    @Default(NotifFilter.all) NotifFilter selectedFilter,
    @Default([]) List<NotificationItem> notifications,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _NotificationsState;
}

// ── Chat Room ─────────────────────────────────
@freezed
abstract class ChatRoom with _$ChatRoom {
  const factory ChatRoom({
    required String id,
    required String title,
    @Default('') String lastMessage,
    @Default('') String lastMessageAt,
    @Default(0) int unreadCount,
  }) = _ChatRoom;
}

// ── Chat Message ──────────────────────────────
@freezed
abstract class ChatMessageItem with _$ChatMessageItem {
  const factory ChatMessageItem({
    required String id,
    required String senderId,
    required String senderName,
    required String content,
    required String createdAt,
    @Default(false) bool isMe,
  }) = _ChatMessageItem;
}

// ── Chat List ─────────────────────────────────
@freezed
abstract class ChatListState with _$ChatListState {
  const factory ChatListState({
    @Default('') String searchQuery,
    @Default([]) List<ChatRoom> rooms,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _ChatListState;
}

// ── Chat Detail ───────────────────────────────
@freezed
abstract class ChatDetailState with _$ChatDetailState {
  const factory ChatDetailState({
    @Default('') String typedMessage,
    @Default(false) bool isTyping,
    @Default([]) List<ChatMessageItem> messages,
    @Default(false) bool isLoading,
    String? currentRoomId,
  }) = _ChatDetailState;
}

// ── User Profile ──────────────────────────────
@freezed
abstract class UserProfileState with _$UserProfileState {
  const factory UserProfileState({
    @Default('') String id,
    @Default('') String displayName,
    @Default('') String email,
    @Default('') String phone,
    @Default('') String avatarUrl,
    @Default('') String kycStatus,
    @Default([]) List<String> roles,
    @Default(false) bool isLoading,
    String? errorMessage,
    // Employment from user_profiles.employment_data JSON
    @Default('') String employer,
    @Default('') String position,
    @Default('') String employmentType,
    @Default('') String annualIncome,
    // Address from user_profiles.current_address JSON
    @Default('') String currentAddress,
    @Default('') String dateOfBirth,
  }) = _UserProfileState;
}

// ── Profile Settings ──────────────────────────
@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(true) bool smartAlerts,
    @Default(true) bool emailReceipts,
    @Default('English') String language,
    @Default(false) bool obscureIncome,
  }) = _ProfileState;
}
