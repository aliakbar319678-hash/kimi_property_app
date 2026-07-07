import 'package:flutter_riverpod/legacy.dart';
import 'screens_state.dart';

// ── Notifications ─────────────────────────────
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier() : super(const NotificationsState());

  void selectFilter(NotifFilter f) => state = state.copyWith(selectedFilter: f);
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>(
      (ref) => NotificationsNotifier(),
    );

// ── Chat List ─────────────────────────────────
class ChatListNotifier extends StateNotifier<ChatListState> {
  ChatListNotifier() : super(const ChatListState());

  void updateSearch(String v) => state = state.copyWith(searchQuery: v);
}

final chatListProvider = StateNotifierProvider<ChatListNotifier, ChatListState>(
  (ref) => ChatListNotifier(),
);

// ── Chat Detail ───────────────────────────────
class ChatDetailNotifier extends StateNotifier<ChatDetailState> {
  ChatDetailNotifier() : super(const ChatDetailState());

  void updateMessage(String v) => state = state.copyWith(typedMessage: v);
  void setTyping(bool v) => state = state.copyWith(isTyping: v);
  void clearMessage() => state = state.copyWith(typedMessage: '');
}

final chatDetailProvider =
    StateNotifierProvider<ChatDetailNotifier, ChatDetailState>(
      (ref) => ChatDetailNotifier(),
    );

// ── Profile ───────────────────────────────────
class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState());

  void toggleSmartAlerts() =>
      state = state.copyWith(smartAlerts: !state.smartAlerts);
  void toggleEmailReceipts() =>
      state = state.copyWith(emailReceipts: !state.emailReceipts);
  void setLanguage(String v) => state = state.copyWith(language: v);
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);
