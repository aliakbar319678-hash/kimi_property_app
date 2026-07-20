import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(landlordProvider.notifier).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(landlordProvider);
    final landlordNotifier = ref.read(landlordProvider.notifier);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: pad, vertical: h * 0.015),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_rounded, size: w * 0.06, color: AppColors.textPrimary),
                  ),
                  SizedBox(width: w * 0.03),
                  Row(
                    children: [
                      Icon(Icons.apartment_rounded, size: w * 0.048, color: AppColors.primary),
                      SizedBox(width: w * 0.015),
                      Text('T&L', style: TextStyle(fontSize: w * 0.046, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ],
                  ),
                  const Spacer(),
                  if (state.unreadNotifications > 0)
                    TextButton(
                      onPressed: () => landlordNotifier.markAllNotificationsRead(),
                      child: const Text('Mark All Read'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notifications', style: TextStyle(fontSize: w * 0.07, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    SizedBox(height: h * 0.006),
                    Text('Stay updated with your latest lease agreements, payment reminders, and maintenance requests in real-time.', style: TextStyle(fontSize: w * 0.033, color: AppColors.textSecondary, height: 1.5)),
                    SizedBox(height: h * 0.025),
                    if (state.notifications.isEmpty)
                      const Center(child: Text('No notifications yet.'))
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.notifications.length,
                        separatorBuilder: (_, __) => SizedBox(height: h * 0.02),
                        itemBuilder: (context, index) {
                          final notif = state.notifications[index];
                          final isUnread = !notif.isRead;
                          IconData iconData = Icons.notifications_rounded;
                          if (notif.type == 'maintenance') iconData = Icons.build_circle_rounded;
                          if (notif.type == 'lease') iconData = Icons.description_rounded;
                          if (notif.type == 'finance') iconData = Icons.receipt_long_rounded;

                          DateTime parsedDate;
                          try {
                            parsedDate = DateTime.parse(notif.createdAt);
                          } catch (_) {
                            parsedDate = DateTime.now();
                          }
                          return Container(
                            decoration: BoxDecoration(
                              color: isUnread ? AppColors.white : AppColors.scaffoldBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border(left: BorderSide(color: isUnread ? AppColors.secondary : Colors.grey.shade400, width: 3)),
                              boxShadow: isUnread ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 10)] : [],
                            ),
                            padding: EdgeInsets.all(pad),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: w * 0.11, height: w * 0.11,
                                      decoration: BoxDecoration(color: isUnread ? AppColors.secondary.withValues(alpha: 0.12) : Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                                      child: Icon(iconData, size: w * 0.055, color: isUnread ? AppColors.secondary : Colors.grey.shade600),
                                    ),
                                    SizedBox(width: w * 0.03),
                                    Expanded(
                                      child: Text(notif.title, style: TextStyle(fontSize: w * 0.042, fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600, color: AppColors.textPrimary, height: 1.3)),
                                    ),
                                    if (isUnread)
                                      IconButton(
                                        onPressed: () => landlordNotifier.markNotificationRead(notif.id),
                                        icon: const Icon(Icons.check_circle_outline, color: AppColors.secondary),
                                        tooltip: 'Mark as read',
                                      )
                                  ],
                                ),
                                SizedBox(height: h * 0.012),
                                Text(notif.body, style: TextStyle(fontSize: w * 0.033, color: AppColors.textSecondary, height: 1.5)),
                                SizedBox(height: h * 0.01),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_rounded, size: w * 0.035, color: AppColors.textHint),
                                    const SizedBox(width: 4),
                                    Text(timeago.format(parsedDate), style: TextStyle(fontSize: w * 0.028, color: AppColors.textHint)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
