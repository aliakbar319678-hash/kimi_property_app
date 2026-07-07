import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';

class PortfolioDashboardScreen extends ConsumerWidget {
  const PortfolioDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(landlordProvider);
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: pad, vertical: h * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Welcome Header ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppColors.white,
                              title: const Text('Exit Landlord Portal', style: TextStyle(fontWeight: FontWeight.bold)),
                              content: const Text('Do you want to logout and switch to another portal?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(context); // Close dialog
                                    await ApiClient().clearToken();
                                    if (context.mounted) {
                                      Navigator.pushNamedAndRemoveUntil(context, '/role_selection', (route) => false);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                  child: const Text('Exit', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          width: w * 0.12,
                          height: w * 0.12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.secondary,
                              width: 2,
                            ),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&q=80',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: w * 0.03),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back,',
                            style: TextStyle(
                              fontSize: w * 0.032,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'John',
                            style: TextStyle(
                              fontSize: w * 0.05,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/notifications'),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Badge(
                        label: Text('2'),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: h * 0.025),

              // ── Portfolio Overview Card ─────────────────────────────────
              Text(
                'Portfolio Overview',
                style: TextStyle(
                  fontSize: w * 0.045,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: h * 0.012),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(w * 0.05),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Properties',
                              style: TextStyle(
                                fontSize: w * 0.032,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: h * 0.005),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '12',
                                  style: TextStyle(
                                    fontSize: w * 0.075,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(width: w * 0.015),
                                Text(
                                  '▲ 8.4%',
                                  style: TextStyle(
                                    fontSize: w * 0.03,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Occupancy Progress Indicator
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: w * 0.16,
                              height: w * 0.16,
                              child: CircularProgressIndicator(
                                value: state.occupancyRate,
                                strokeWidth: 8,
                                color: AppColors.primary,
                                backgroundColor: AppColors.scaffoldBg,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Text(
                              '${(state.occupancyRate * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: w * 0.035,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(height: h * 0.03, color: AppColors.border),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Rent Collected',
                              style: TextStyle(
                                fontSize: w * 0.032,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: h * 0.005),
                            Text(
                              '\$${state.totalCollected.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: w * 0.055,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Outstanding: \$${state.totalOutstanding.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: w * 0.03,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.02),

              // Quick Buttons (+ Add Lease, - Post Expense)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/landlord_lease_management',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text(
                        'Add Lease',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(width: w * 0.04),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/landlord_financial_overview',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.show_chart_rounded, size: 20),
                      label: const Text(
                        'Finances',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: h * 0.03),

              // ── Rent Status Circular Chart Card ─────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(w * 0.05),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: w * 0.22,
                          height: w * 0.22,
                          child: const CircularProgressIndicator(
                            value: 0.80,
                            strokeWidth: 10,
                            color: AppColors.secondary,
                            backgroundColor: AppColors.border,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Text(
                          '80%',
                          style: TextStyle(
                            fontSize: w * 0.05,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: w * 0.06),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rent Collection',
                            style: TextStyle(
                              fontSize: w * 0.04,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: h * 0.005),
                          Text(
                            '80% of rent has been collected for May.',
                            style: TextStyle(
                              fontSize: w * 0.032,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: h * 0.012),
                          Text(
                            'View Details →',
                            style: TextStyle(
                              fontSize: w * 0.032,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.03),

              // ── Urgent Alerts ───────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Urgent Alerts',
                    style: TextStyle(
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: w * 0.032,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.012),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2,
                separatorBuilder: (_, _) => SizedBox(height: h * 0.012),
                itemBuilder: (context, index) {
                  final alertTitle = index == 0
                      ? 'Water Leak Reported'
                      : 'Lease Expiring Soon';
                  final alertDesc = index == 0
                      ? 'Sunset Heights Apts • Unit 402 • High Priority'
                      : 'Sarah Jenkins • Maple Residency • 14 days left';
                  final alertIcon = index == 0
                      ? Icons.water_drop_rounded
                      : Icons.calendar_today_rounded;
                  final alertColor = index == 0
                      ? AppColors.error
                      : AppColors.secondary;

                  return GestureDetector(
                    onTap: () {
                      if (index == 0) {
                        Navigator.pushNamed(context, '/landlord_work_order_details');
                      } else {
                        Navigator.pushNamed(context, '/landlord_lease_management');
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(w * 0.04),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: alertColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(alertIcon, color: alertColor, size: 20),
                          ),
                          SizedBox(width: w * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alertTitle,
                                  style: TextStyle(
                                    fontSize: w * 0.036,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  alertDesc,
                                  style: TextStyle(
                                    fontSize: w * 0.03,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.textHint,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: h * 0.03),

              // ── Maintenance Summary ─────────────────────────────────────
              Text(
                'Maintenance Summary',
                style: TextStyle(
                  fontSize: w * 0.045,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: h * 0.012),
              Row(
                children: [
                  _buildSummaryCard('6', 'Emergency', AppColors.error, w, h),
                  SizedBox(width: w * 0.03),
                  _buildSummaryCard(
                    '3',
                    'In Progress',
                    AppColors.secondary,
                    w,
                    h,
                  ),
                  SizedBox(width: w * 0.03),
                  _buildSummaryCard('12', 'Completed', Colors.green, w, h),
                ],
              ),

              SizedBox(height: h * 0.03),

              // ── Upcoming Activities ─────────────────────────────────────
              Text(
                'Upcoming Activities',
                style: TextStyle(
                  fontSize: w * 0.045,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: h * 0.015),
              Container(
                padding: EdgeInsets.all(w * 0.04),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '26',
                            style: TextStyle(
                              fontSize: w * 0.045,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'MAY',
                            style: TextStyle(
                              fontSize: w * 0.024,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: w * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vendor Payment Due',
                            style: TextStyle(
                              fontSize: w * 0.036,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Mike Plumbing • SAR 350 • Kitchen repair',
                            style: TextStyle(
                              fontSize: w * 0.03,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: h * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String count,
    String label,
    Color color,
    double w,
    double h,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: h * 0.02),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: w * 0.065,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            SizedBox(height: h * 0.005),
            Text(
              label,
              style: TextStyle(
                fontSize: w * 0.028,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
