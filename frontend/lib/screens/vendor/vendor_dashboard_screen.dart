import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/vendor_state.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/vendor_provider.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_find_jobs_screen.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_appbar.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_mock_map.dart';

class VendorDashboardScreen extends ConsumerWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vendorProvider);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    // Filter active jobs vs completed
    final activeWorkOrders = state.activeJobs
        .where((j) => j.status != 'Completed')
        .toList();
    final completedWorkOrders = state.activeJobs
        .where((j) => j.status == 'Completed')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: TLAppBar(
        title: 'T&L Vendor System',
        leading: Icon(
          Icons.menu_rounded,
          size: w * 0.065,
          color: AppColors.textPrimary,
        ),
        trailing: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Active',
                    style: TextStyle(
                      color: const Color(0xFF2E7D32),
                      fontSize: w * 0.026,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: w * 0.03),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.white,
                    title: const Text('Exit Vendor Portal', style: TextStyle(fontWeight: FontWeight.bold)),
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
              child: CircleAvatar(
                radius: w * 0.045,
                backgroundImage: const NetworkImage(
                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80',
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Text
              Text(
                'Good morning, ${state.profile.businessName.isEmpty ? 'Mike' : state.profile.businessName.split(' ')[0]}',
                style: TextStyle(
                  fontSize: w * 0.06,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Here is your schedule for today.',
                style: TextStyle(
                  fontSize: w * 0.035,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const VendorFindJobsScreen())
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: w * 0.045, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Go to VendorHub (Find Jobs & Bid)',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Browse open jobs, submit bids & check status',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.secondary,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: h * 0.025),

              // Metrics Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: 'ACTIVE JOBS',
                      value: activeWorkOrders.length.toString(),
                      icon: Icons.run_circle_rounded,
                      color: AppColors.secondary,
                      width: w,
                    ),
                  ),
                  SizedBox(width: w * 0.04),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'COMPLETED JOBS',
                      value: (state.jobsCount + completedWorkOrders.length)
                          .toString(),
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xFF2E7D32),
                      width: w,
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.025),

              // Today's Schedule Section
              Text(
                "Today's Schedule",
                style: TextStyle(
                  fontSize: w * 0.042,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: h * 0.012),
              if (activeWorkOrders.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(w * 0.06),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'No jobs scheduled for today.',
                      style: TextStyle(
                        fontSize: w * 0.035,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: activeWorkOrders.map((wo) {
                    return _buildScheduleItem(wo, w, context);
                  }).toList(),
                ),
              SizedBox(height: h * 0.025),

              // Performance Panel Card
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/vendor_performance');
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(pad),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Performance Summary',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: w * 0.032,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: h * 0.005),
                            Row(
                              children: [
                                Text(
                                  state.rating.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: w * 0.075,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: w * 0.065,
                                ),
                              ],
                            ),
                            SizedBox(height: h * 0.008),
                            Text(
                              'On-Time Rate: ${state.onTimeRate.toStringAsFixed(0)}% • Resp: ${state.responseTime}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: w * 0.03,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.secondary,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: h * 0.025),

              // Job Locations Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Job Locations",
                    style: TextStyle(
                      fontSize: w * 0.042,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    "Active Maps",
                    style: TextStyle(
                      fontSize: w * 0.032,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.012),
              Container(
                height: w * 0.45,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: const TLMockMap(showZoomControls: false),
                ),
              ),
              SizedBox(height: h * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required double width,
  }) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: width * 0.026,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, color: color, size: width * 0.05),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: width * 0.065,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(
    VendorWorkOrder wo,
    double w,
    BuildContext context,
  ) {
    Color priorityColor;
    switch (wo.priority) {
      case 'Emergency':
        priorityColor = AppColors.error;
        break;
      case 'High':
        priorityColor = Colors.orange;
        break;
      case 'Medium':
        priorityColor = AppColors.secondary;
        break;
      default:
        priorityColor = Colors.grey;
    }

    final isInProgress = wo.status == 'In-Progress';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/vendor_work_order_details',
          arguments: wo.id,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(w * 0.04),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: isInProgress
              ? Border.all(color: AppColors.secondary, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Timeline Dot indicator
            Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(width: 2, height: 40, color: AppColors.border),
              ],
            ),
            const SizedBox(width: 12),
            // Schedule Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        wo.timeSlot,
                        style: TextStyle(
                          fontSize: w * 0.032,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          wo.priority,
                          style: TextStyle(
                            color: priorityColor,
                            fontSize: w * 0.026,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wo.title,
                    style: TextStyle(
                      fontSize: w * 0.038,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${wo.propertyName} • ${wo.unitName}',
                    style: TextStyle(
                      fontSize: w * 0.03,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: w * 0.065,
            ),
          ],
        ),
      ),
    );
  }
}
