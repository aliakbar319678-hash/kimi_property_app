import 'package:freezed_annotation/freezed_annotation.dart';

part 'screens_state.freezed.dart';

// ── Notification Filter ───────────────────────
enum NotifFilter { all, payments, maintenance, lease }

@freezed
abstract class NotificationsState with _$NotificationsState {
  const factory NotificationsState({
    @Default(NotifFilter.all) NotifFilter selectedFilter,
  }) = _NotificationsState;
}

// ── Chat List ─────────────────────────────────
@freezed
abstract class ChatListState with _$ChatListState {
  const factory ChatListState({@Default('') String searchQuery}) =
      _ChatListState;
}

// ── Chat Detail ───────────────────────────────
@freezed
abstract class ChatDetailState with _$ChatDetailState {
  const factory ChatDetailState({
    @Default('') String typedMessage,
    @Default(false) bool isTyping,
  }) = _ChatDetailState;
}

// ── Profile ───────────────────────────────────
@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(true) bool smartAlerts,
    @Default(true) bool emailReceipts,
    @Default('English') String language,
    @Default(false) bool obscureIncome,
  }) = _ProfileState;
}
