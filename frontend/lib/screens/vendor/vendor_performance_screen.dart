import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/vendor_provider.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_appbar.dart';

class VendorPerformanceScreen extends ConsumerWidget {
  const VendorPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vendorProvider);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    // Monthly completed jobs data for chart
    final chartData = [
      ('Jan', 14, 0.55),
      ('Feb', 18, 0.70),
      ('Mar', 12, 0.48),
      ('Apr', 22, 0.88),
      ('May', 25, 1.0),
    ];

    // Reviews list
    final reviews = [
      (
        'Sarah Jenkins',
        'Tenant at Sunset Heights Apts',
        'Technician was extremely polite and cleaned up completely after fixing the kitchen leak. On time and very professional!',
        4.9
      ),
      (
        'David Miller',
        'Landlord (Green Valley)',
        'Apex Plumbing did an outstanding job replacing the water valves. Quick response and transparent pricing. Recommending to all my properties.',
        5.0
      ),
      (
        'Michael Chang',
        'Tenant at Sunset Heights Apts',
        'AC is working perfectly now. They came within the schedule slot and finished the work in under an hour. Great service!',
        4.7
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: TLAppBar(
        title: 'Vendor Performance',
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              )
            : Icon(
                Icons.menu_rounded,
                size: w * 0.065,
                color: AppColors.textPrimary,
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Rating Summary Header Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(pad),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'YOUR PERFORMANCE RATING',
                      style: TextStyle(
                        fontSize: w * 0.028,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.rating.toString(),
                          style: TextStyle(
                            fontSize: w * 0.11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star_rounded, color: Colors.amber, size: w * 0.1),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Excellent Status • Top 5% in Seattle Area',
                      style: TextStyle(
                        fontSize: w * 0.034,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starRating = index + 1;
                        if (starRating <= state.rating.floor()) {
                          return const Icon(Icons.star_rounded, color: Colors.amber, size: 24);
                        } else if (starRating - 1 < state.rating && starRating > state.rating) {
                          return const Icon(Icons.star_half_rounded, color: Colors.amber, size: 24);
                        } else {
                          return const Icon(Icons.star_outline_rounded, color: Colors.amber, size: 24);
                        }
                      }),
                    ),
                  ],
                ),
              ),
              SizedBox(height: h * 0.02),

              // 2. Performance Metrics Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      label: 'Jobs Completed',
                      value: state.jobsCount.toString(),
                      icon: Icons.done_all_rounded,
                      color: AppColors.secondary,
                      w: w,
                    ),
                  ),
                  SizedBox(width: w * 0.04),
                  Expanded(
                    child: _buildMetricItem(
                      label: 'On-Time Arrival',
                      value: '${state.onTimeRate.toStringAsFixed(0)}%',
                      icon: Icons.timer_rounded,
                      color: const Color(0xFF2E7D32),
                      w: w,
                    ),
                  ),
                ],
              ),
              SizedBox(height: w * 0.04),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      label: 'Average Response',
                      value: state.responseTime,
                      icon: Icons.chat_bubble_outline_rounded,
                      color: Colors.blueAccent,
                      w: w,
                    ),
                  ),
                  SizedBox(width: w * 0.04),
                  Expanded(
                    child: _buildMetricItem(
                      label: 'Re-Hire Rate',
                      value: '92%',
                      icon: Icons.thumb_up_alt_rounded,
                      color: Colors.purple,
                      w: w,
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.025),

              // 3. Completed Jobs Chart Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(pad),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completed Jobs (Last 5 Months)',
                      style: TextStyle(
                        fontSize: w * 0.038,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Divider(color: AppColors.border, height: 24),
                    SizedBox(
                      height: w * 0.45,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: chartData.map((data) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                data.$2.toString(),
                                style: TextStyle(
                                  fontSize: w * 0.028,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: w * 0.08,
                                height: (w * 0.3) * data.$3,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data.$1,
                                style: TextStyle(
                                  fontSize: w * 0.028,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: h * 0.025),

              // 4. Manager & Tenant Feedback Section
              Text(
                'Manager & Tenant Feedback',
                style: TextStyle(
                  fontSize: w * 0.042,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: h * 0.012),
              
              Column(
                children: reviews.map((rev) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(pad),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.015),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rev.$1,
                                  style: TextStyle(
                                    fontSize: w * 0.034,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  rev.$2,
                                  style: TextStyle(
                                    fontSize: w * 0.028,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                                  const SizedBox(width: 2),
                                  Text(
                                    rev.$4.toString(),
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: w * 0.026,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: AppColors.border, height: 16),
                        Text(
                          '"${rev.$3}"',
                          style: TextStyle(
                            fontSize: w * 0.032,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: h * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required double w,
  }) {
    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: w * 0.05),
              Text(
                value,
                style: TextStyle(
                  fontSize: w * 0.045,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: w * 0.028,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
