import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/screens_provider.dart';
import 'package:tenant_and_landlord_application/provider/screens_state.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';


class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    final notif = ref.read(notificationsProvider.notifier);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ───────────────────────────
            Container(
              color: AppColors.white,
              padding: EdgeInsets.symmetric(
                horizontal: pad,
                vertical: h * 0.015,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: w * 0.06,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: w * 0.03),
                  Row(
                    children: [
                      Icon(
                        Icons.apartment_rounded,
                        size: w * 0.048,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: w * 0.015),
                      Text(
                        'T&L',
                        style: TextStyle(
                          fontSize: w * 0.046,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: w * 0.048,
                    backgroundImage: const NetworkImage(
                      'https://i.pravatar.cc/100?img=5',
                    ),
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
                    // ── Title ────────────────────
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: w * 0.07,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: h * 0.006),
                    Text(
                      'Stay updated with your latest lease agreements, payment reminders, and maintenance requests in real-time.',
                      style: TextStyle(
                        fontSize: w * 0.033,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: h * 0.025),

                    // ── Rent Due card ─────────────
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border(
                          left: BorderSide(
                            color: AppColors.secondary,
                            width: 3,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(pad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: w * 0.11,
                                height: w * 0.11,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.receipt_long_outlined,
                                  size: w * 0.055,
                                  color: AppColors.secondary,
                                ),
                              ),
                              SizedBox(width: w * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rent Due\nReminder',
                                      style: TextStyle(
                                        fontSize: w * 0.042,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.025,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'URGENT',
                                  style: TextStyle(
                                    fontSize: w * 0.028,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.red,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              SizedBox(width: w * 0.02),
                              Icon(
                                Icons.more_vert_rounded,
                                size: w * 0.05,
                                color: AppColors.textHint,
                              ),
                            ],
                          ),
                          SizedBox(height: h * 0.012),
                          Text(
                            'Your monthly rent payment for Apartment 4B is due in 3 days. Please ensure funds are available in your connected account.',
                            style: TextStyle(
                              fontSize: w * 0.033,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: h * 0.01),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: w * 0.035,
                                color: AppColors.textHint,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '2 hours ago',
                                style: TextStyle(
                                  fontSize: w * 0.03,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: h * 0.015),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pushNamed(context, '/pay_rent'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: h * 0.014,
                                    ),
                                  ),
                                  child: Text(
                                    'Pay Now',
                                    style: TextStyle(
                                      fontSize: w * 0.036,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: w * 0.03),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pushNamed(context, '/payment_history'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textPrimary,
                                    side: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: h * 0.014,
                                    ),
                                  ),
                                  child: Text(
                                    'View Invoice',
                                    style: TextStyle(
                                      fontSize: w * 0.036,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.02),

                    // ── Unread alerts dark card ───
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(pad * 1.1),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UNREAD ALERTS',
                            style: TextStyle(
                              fontSize: w * 0.03,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white.withValues(alpha: 0.6),
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: h * 0.006),
                          Text(
                            '03',
                            style: TextStyle(
                              fontSize: w * 0.14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: h * 0.006),
                          Text(
                            'You have unresolved maintenance updates waiting for your approval.',
                            style: TextStyle(
                              fontSize: w * 0.033,
                              color: AppColors.white.withValues(alpha: 0.65),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.02),

                    // ── Quick Filters ─────────────
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: EdgeInsets.all(pad * 0.9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Filters',
                            style: TextStyle(
                              fontSize: w * 0.036,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: h * 0.012),
                          Wrap(
                            spacing: w * 0.025,
                            runSpacing: h * 0.008,
                            children: [
                              _FilterChip(
                                label: 'All',
                                selected:
                                    state.selectedFilter == NotifFilter.all,
                                onTap: () =>
                                    notif.selectFilter(NotifFilter.all),
                                w: w,
                              ),
                              _FilterChip(
                                label: 'Payments',
                                selected:
                                    state.selectedFilter ==
                                    NotifFilter.payments,
                                onTap: () =>
                                    notif.selectFilter(NotifFilter.payments),
                                w: w,
                              ),
                              _FilterChip(
                                label: 'Maintenance',
                                selected:
                                    state.selectedFilter ==
                                    NotifFilter.maintenance,
                                onTap: () =>
                                    notif.selectFilter(NotifFilter.maintenance),
                                w: w,
                              ),
                              _FilterChip(
                                label: 'Lease',
                                selected:
                                    state.selectedFilter == NotifFilter.lease,
                                onTap: () =>
                                    notif.selectFilter(NotifFilter.lease),
                                w: w,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.02),

                    // ── Maintenance Update ────────
                    _NotifRow(
                      icon: Icons.build_outlined,
                      iconColor: const Color(0xFFE67E22),
                      iconBg: const Color(0xFFFEF3E2),
                      title: 'Maintenance Update',
                      body:
                          'The ticket #4421 regarding the HVAC system has been updated. A technician is scheduled for tomorrow at 10:00 AM.',
                      time: 'Yesterday, 4:30 PM',
                      actionLabel: 'Track Status',
                      onAction: () => Navigator.pushNamed(context, '/request_tracking'),
                      w: w,
                      h: h,
                    ),

                    SizedBox(height: h * 0.015),

                    // ── Lease Expiring ────────────
                    _NotifRow(
                      icon: Icons.calendar_today_outlined,
                      iconColor: AppColors.secondary,
                      iconBg: AppColors.secondary.withValues(alpha: 0.1),
                      title: 'Lease Expiring Alert',
                      body:
                          'Your lease agreement for the current term expires in 60 days. Early renewal offers are now available in your portal.',
                      time: 'Oct 12, 2023',
                      actionLabel: 'Review Terms',
                      onAction: () => Navigator.pushNamed(context, '/lease_summary'),
                      w: w,
                      h: h,
                    ),

                    SizedBox(height: h * 0.02),

                    // ── Promo dark card ───────────
                    Container(
                      width: double.infinity,
                      height: h * 0.18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1486325212027-8081e485255e?w=800&q=80',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.85),
                              AppColors.primary.withValues(alpha: 0.4),
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                        ),
                        padding: EdgeInsets.all(pad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Upgrade Your Living\nExperience',
                              style: TextStyle(
                                fontSize: w * 0.048,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: h * 0.006),
                            Text(
                              'Explore larger units available in your building before they hit the public market.',
                              style: TextStyle(
                                fontSize: w * 0.031,
                                color: AppColors.white.withValues(alpha: 0.8),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.03),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double w;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.w,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.02),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secondary.withValues(alpha: 0.15)
              : AppColors.inputBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.secondary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: w * 0.033,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.secondary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _NotifRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String body;
  final String time;
  final String actionLabel;
  final VoidCallback? onAction;
  final double w;
  final double h;

  const _NotifRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.body,
    required this.time,
    required this.actionLabel,
    this.onAction,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      padding: EdgeInsets.all(w * 0.04),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: w * 0.11,
            height: w * 0.11,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: w * 0.052, color: iconColor),
          ),
          SizedBox(width: w * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: w * 0.038,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: h * 0.006),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: w * 0.031,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: h * 0.008),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: w * 0.029,
                        color: AppColors.textHint,
                      ),
                    ),
                    GestureDetector(
                      onTap: onAction,
                      child: Text(
                        actionLabel,
                        style: TextStyle(
                          fontSize: w * 0.031,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
