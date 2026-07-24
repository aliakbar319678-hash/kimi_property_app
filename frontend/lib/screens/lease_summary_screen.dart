import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_user_avatar.dart';
import 'package:tenant_and_landlord_application/provider/payment_maintenance_provider.dart';
import 'package:tenant_and_landlord_application/provider/tenant_lease_provider.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_bottom_navigation_bar.dart';

class LeaseSummaryScreen extends ConsumerWidget {
  const LeaseSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leaseSummaryProvider);
    final leaseAsync = ref.watch(tenantLeaseProvider);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    final lease = leaseAsync.asData?.value ?? TenantLeaseData.empty();
    final propertyDisplay = lease.propertyName.isNotEmpty
        ? '${lease.propertyName}, ${lease.unitName}'
        : 'Your Property';
    final endDateDisplay = lease.endDate.isNotEmpty
        ? _formatDate(lease.endDate)
        : 'N/A';
    final depositDisplay = lease.securityDeposit > 0
        ? '\$${lease.securityDeposit.toStringAsFixed(0)}'
        : '\$—';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(w: w, h: h, pad: pad),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Lease Summary',
                      style: TextStyle(
                        fontSize: w * 0.07,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: h * 0.005),
                    Text(
                      'Active Agreement • $propertyDisplay',
                      style: TextStyle(
                        fontSize: w * 0.033,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: h * 0.02),

                    // Download button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Document download endpoint pending backend update'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: state.isDownloading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.download_outlined,
                                color: AppColors.white,
                                size: w * 0.045,
                              ),
                        label: Text(
                          'Download Lease',
                          style: TextStyle(
                            fontSize: w * 0.038,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: h * 0.018),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.02),

                    // Rent Schedule card
                    _InfoCard(
                      hasLeftBorder: true,
                      w: w,
                      h: h,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'RENT SCHEDULE',
                                style: TextStyle(
                                  fontSize: w * 0.028,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                  letterSpacing: 1,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.03,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Monthly Recurring',
                                  style: TextStyle(
                                    fontSize: w * 0.028,
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: h * 0.008),
                          Text(
                            'Rent Due',
                            style: TextStyle(
                              fontSize: w * 0.04,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: h * 0.008),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '1',
                                  style: TextStyle(
                                    fontSize: w * 0.15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                TextSpan(
                                  text: 'st',
                                  style: TextStyle(
                                    fontSize: w * 0.06,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                TextSpan(
                                  text: ' of every month',
                                  style: TextStyle(
                                    fontSize: w * 0.038,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(color: AppColors.border, height: h * 0.03),
                          Text(
                            'Next payment processed automatically on October 1st via Linked Bank Account.',
                            style: TextStyle(
                              fontSize: w * 0.032,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.018),

                    // Security Deposit
                    _InfoCard(
                      w: w,
                      h: h,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: w * 0.055,
                            color: AppColors.secondary,
                          ),
                          SizedBox(height: h * 0.01),
                          Text(
                            'Security Deposit',
                            style: TextStyle(
                              fontSize: w * 0.04,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: h * 0.008),
                          Text(
                            depositDisplay,
                            style: TextStyle(
                              fontSize: w * 0.08,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Held in Escrow Account',
                            style: TextStyle(
                              fontSize: w * 0.032,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.018),

                    // Lease Term
                    _InfoCard(
                      w: w,
                      h: h,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: w * 0.055,
                            color: AppColors.secondary,
                          ),
                          SizedBox(height: h * 0.01),
                          Text(
                            'Lease Term',
                            style: TextStyle(
                              fontSize: w * 0.04,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: h * 0.008),
                          Text(
                            '12 Months',
                            style: TextStyle(
                              fontSize: w * 0.08,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Expires $endDateDisplay',
                            style: TextStyle(
                              fontSize: w * 0.032,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.018),

                    // Utilities
                    _InfoCard(
                      w: w,
                      h: h,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Utilities Included',
                            style: TextStyle(
                              fontSize: w * 0.04,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: h * 0.015),
                          Row(
                            children: [
                              _UtilityChip(
                                icon: Icons.water_drop_outlined,
                                title: 'Water',
                                sub: 'Standard Usage',
                                w: w,
                              ),
                              SizedBox(width: w * 0.03),
                              _UtilityChip(
                                icon: Icons.delete_outline_rounded,
                                title: 'Trash',
                                sub: 'Weekly Pickup',
                                w: w,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.02),

                    // Property image card
                    Container(
                      height: h * 0.22,
                      width: double.infinity,
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
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        padding: EdgeInsets.all(pad),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              propertyDisplay,
                              style: TextStyle(
                                fontSize: w * 0.042,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                            Text(
                              lease.propertyName.isNotEmpty
                                  ? 'Managed by T&L Property Group'
                                  : 'Managed by Propertius Property Group',
                              style: TextStyle(
                                fontSize: w * 0.031,
                                color: AppColors.white.withValues(alpha: 0.8),
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
      bottomNavigationBar: const TLBottomNav(selectedIndex: 2),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  final bool hasLeftBorder;
  final double w;
  final double h;
  const _InfoCard({
    required this.child,
    this.hasLeftBorder = false,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.045),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: hasLeftBorder
            ? Border(left: BorderSide(color: AppColors.secondary, width: 3))
            : null,
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: child,
    );
  }
}

class _UtilityChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final double w;
  const _UtilityChip({
    required this.icon,
    required this.title,
    required this.sub,
    required this.w,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(w * 0.035),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: w * 0.055, color: AppColors.secondary),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: w * 0.034,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: w * 0.028,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────
String _formatDate(String iso) {
  try {
    final d = DateTime.parse(iso);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  } catch (_) {
    return iso;
  }
}

class _AppBar extends StatelessWidget {
  final double w, h, pad;
  const _AppBar({required this.w, required this.h, required this.pad});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: h * 0.015),
      child: Row(
        children: [
          Icon(
            Icons.menu_rounded,
            size: w * 0.06,
            color: AppColors.textPrimary,
          ),
          SizedBox(width: w * 0.03),
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
          const Spacer(),
          TLUserAvatar(radius: w * 0.048),
        ],
      ),
    );
  }
}
