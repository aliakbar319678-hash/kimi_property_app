import 'package:flutter_riverpod/legacy.dart';
import 'package:dio/dio.dart';
import 'screens_state.dart';
import '../core/api_client.dart';
import '../core/api_constants.dart';

// ── Notifications ─────────────────────────────
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier() : super(const NotificationsState()) {
    loadNotifications();
  }

  void selectFilter(NotifFilter f) => state = state.copyWith(selectedFilter: f);

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final resp = await ApiClient().dio.get(ApiConstants.notifications);
      final data = resp.data;
      final List<dynamic> items = (data['data'] ?? data['notifications'] ?? []) as List<dynamic>;
      final notifications = items.map((n) {
        final m = n as Map<String, dynamic>;
        return NotificationItem(
          id: m['id']?.toString() ?? '',
          title: m['title']?.toString() ?? 'Notification',
          message: m['message']?.toString() ?? m['body']?.toString() ?? '',
          type: m['type']?.toString() ?? 'general',
          createdAt: m['created_at']?.toString() ?? m['createdAt']?.toString() ?? '',
          isRead: m['is_read'] == true || m['isRead'] == true,
        );
      }).toList();
      state = state.copyWith(notifications: notifications, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _errMsg(e));
    }
  }

  Future<void> markRead(String id) async {
    try {
      await ApiClient().dio.put('${ApiConstants.notifications}/$id/read');
      final updated = state.notifications
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList();
      state = state.copyWith(notifications: updated);
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await ApiClient().dio.put(ApiConstants.notificationsReadAll);
      final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
      state = state.copyWith(notifications: updated);
    } catch (_) {}
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>(
      (ref) => NotificationsNotifier(),
    );

// ── Chat List ─────────────────────────────────
class ChatListNotifier extends StateNotifier<ChatListState> {
  ChatListNotifier() : super(const ChatListState()) {
    loadRooms();
  }

  void updateSearch(String v) => state = state.copyWith(searchQuery: v);

  Future<void> loadRooms() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final resp = await ApiClient().dio.get(ApiConstants.chatRooms);
      final List<dynamic> raw = (resp.data['data'] ?? []) as List<dynamic>;
      final rooms = raw.map((r) {
        final m = r as Map<String, dynamic>;
        return ChatRoom(
          id: m['id']?.toString() ?? '',
          title: m['title']?.toString() ?? m['name']?.toString() ?? 'Chat',
          lastMessage: m['last_message']?.toString() ?? '',
          lastMessageAt: m['last_message_at']?.toString() ?? m['updated_at']?.toString() ?? '',
          unreadCount: (m['unread_count'] ?? 0) as int,
        );
      }).toList();
      state = state.copyWith(rooms: rooms, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _errMsg(e));
    }
  }
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

  Future<void> loadMessages(String roomId) async {
    state = state.copyWith(isLoading: true, currentRoomId: roomId);
    try {
      final resp = await ApiClient().dio.get(
        '${ApiConstants.chatRooms}/$roomId/messages',
      );
      final List<dynamic> raw = (resp.data['data'] ?? []) as List<dynamic>;

      // Get current user id from token
      final meResp = await ApiClient().dio.get(ApiConstants.me);
      final myId = meResp.data['data']?['id']?.toString() ?? '';

      final messages = raw.map((msg) {
        final m = msg as Map<String, dynamic>;
        final senderId = m['sender_id']?.toString() ?? '';
        return ChatMessageItem(
          id: m['id']?.toString() ?? '',
          senderId: senderId,
          senderName: m['sender_name']?.toString() ?? 'User',
          content: m['content']?.toString() ?? '',
          createdAt: m['created_at']?.toString() ?? '',
          isMe: senderId == myId,
        );
      }).toList();
      state = state.copyWith(messages: messages, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> sendMessage(String roomId) async {
    final text = state.typedMessage.trim();
    if (text.isEmpty) return;
    clearMessage();
    try {
      final resp = await ApiClient().dio.post(
        '${ApiConstants.chatRooms}/$roomId/messages',
        data: {'content': text},
      );
      final m = resp.data['data'] as Map<String, dynamic>? ?? {};
      final meResp = await ApiClient().dio.get(ApiConstants.me);
      final myId = meResp.data['data']?['id']?.toString() ?? '';
      final newMsg = ChatMessageItem(
        id: m['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: myId,
        senderName: 'You',
        content: text,
        createdAt: DateTime.now().toIso8601String(),
        isMe: true,
      );
      state = state.copyWith(messages: [...state.messages, newMsg]);
    } catch (_) {}
  }
}

final chatDetailProvider =
    StateNotifierProvider<ChatDetailNotifier, ChatDetailState>(
      (ref) => ChatDetailNotifier(),
    );

// ── User Profile ──────────────────────────────
class UserProfileNotifier extends StateNotifier<UserProfileState> {
  UserProfileNotifier() : super(const UserProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final resp = await ApiClient().dio.get(ApiConstants.userProfile);
      final d = resp.data['data'] as Map<String, dynamic>;

      // Parse employment_data JSON field
      final empData = d['employment_data'];
      String employer = '';
      String position = '';
      String empType = '';
      String income = '';
      if (empData is Map) {
        employer = empData['employer']?.toString() ?? empData['company']?.toString() ?? '';
        position = empData['position']?.toString() ?? empData['title']?.toString() ?? '';
        empType = empData['employment_type']?.toString() ?? empData['type']?.toString() ?? '';
        income = empData['annual_income']?.toString() ?? empData['income']?.toString() ?? '';
      }

      // Parse address
      final addrData = d['current_address'];
      String addr = '';
      if (addrData is Map) {
        addr = [addrData['street'], addrData['city'], addrData['state']]
            .where((s) => s != null && s.toString().isNotEmpty)
            .join(', ');
      } else if (addrData is String) {
        addr = addrData;
      }

      // Roles
      final rolesRaw = d['roles'];
      List<String> roles = [];
      if (rolesRaw is List) {
        roles = rolesRaw.map((r) => r.toString()).toList();
      }

      state = state.copyWith(
        id: d['id']?.toString() ?? '',
        displayName: d['display_name']?.toString() ??
            '${d['legal_first_name'] ?? ''} ${d['legal_last_name'] ?? ''}'.trim(),
        email: d['email']?.toString() ?? '',
        phone: d['phone']?.toString() ?? '',
        avatarUrl: d['avatar_url']?.toString() ?? '',
        kycStatus: d['kyc_status']?.toString() ?? '',
        roles: roles,
        employer: employer,
        position: position,
        employmentType: empType,
        annualIncome: income,
        currentAddress: addr,
        dateOfBirth: d['date_of_birth']?.toString() ?? '',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _errMsg(e));
    }
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>(
      (ref) => UserProfileNotifier(),
    );

// ── Profile Settings ──────────────────────────
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

// ── Helpers ───────────────────────────────────
String _errMsg(Object e) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map) return (data['error'] ?? data['message'] ?? e.message ?? e.toString()).toString();
    if (e.type == DioExceptionType.connectionError) return 'Cannot connect to server.';
    if (e.type == DioExceptionType.connectionTimeout) return 'Connection timed out.';
  }
  return e.toString();
}
