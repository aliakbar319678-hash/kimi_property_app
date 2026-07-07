import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/vendor_provider.dart';
import 'package:tenant_and_landlord_application/provider/vendor_state.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_appbar.dart';

class VendorWorkOrdersScreen extends ConsumerStatefulWidget {
  const VendorWorkOrdersScreen({super.key});

  @override
  ConsumerState<VendorWorkOrdersScreen> createState() => _VendorWorkOrdersScreenState();
}

class _VendorWorkOrdersScreenState extends ConsumerState<VendorWorkOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vendorProvider);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    // Categorize jobs
    final activeJobs = state.activeJobs.where((j) => j.status != 'Completed').toList();
    final completedJobs = state.activeJobs.where((j) => j.status == 'Completed').toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const TLAppBar(
        subtitle: 'Work Orders',
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tab Header Row
            Container(
              color: AppColors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.secondary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textHint,
                labelStyle: TextStyle(
                  fontSize: w * 0.038,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: w * 0.038,
                  fontWeight: FontWeight.normal,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Active'),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            activeJobs.length.toString(),
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: w * 0.026,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Completed'),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            completedJobs.length.toString(),
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: w * 0.026,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Tab View Body
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Active Jobs List
                  activeJobs.isEmpty
                      ? _buildEmptyState('No active jobs assigned at the moment.', w)
                      : ListView.builder(
                          padding: EdgeInsets.all(pad),
                          itemCount: activeJobs.length,
                          itemBuilder: (context, index) {
                            return _buildJobCard(activeJobs[index], w, h, context);
                          },
                        ),

                  // Completed Jobs List
                  completedJobs.isEmpty
                      ? _buildEmptyState('No completed jobs in history.', w)
                      : ListView.builder(
                          padding: EdgeInsets.all(pad),
                          itemCount: completedJobs.length,
                          itemBuilder: (context, index) {
                            return _buildCompletedJobCard(completedJobs[index], w, h, context);
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String text, double w) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, color: AppColors.textHint, size: w * 0.15),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: w * 0.038,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(VendorWorkOrder job, double w, double h, BuildContext context) {
    Color priorityColor;
    switch (job.priority) {
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

    final isInProgress = job.status == 'In-Progress';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: isInProgress ? Border.all(color: AppColors.secondary, width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(w * 0.045),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title and Priority
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: TextStyle(
                    fontSize: w * 0.042,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job.priority,
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: w * 0.026,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.005),
          // Category and Location
          Text(
            '${job.category} • ${job.propertyName}',
            style: TextStyle(
              fontSize: w * 0.032,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Divider(color: AppColors.border, height: 24),
          // Time Slot & Address details
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: AppColors.textHint, size: w * 0.042),
              const SizedBox(width: 8),
              Text(
                '${job.date} • ${job.timeSlot}',
                style: TextStyle(
                  fontSize: w * 0.032,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.01),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppColors.textHint, size: w * 0.042),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  job.address,
                  style: TextStyle(
                    fontSize: w * 0.032,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.02),
          // Bottom CTA button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${job.bidAmount.toStringAsFixed(0)} Est. Payout',
                style: TextStyle(
                  fontSize: w * 0.038,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/vendor_work_order_details',
                    arguments: job.id,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isInProgress ? AppColors.secondary : AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        isInProgress ? 'In Progress' : 'View Details',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: w * 0.03,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.white, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedJobCard(VendorWorkOrder job, double w, double h, BuildContext context) {
    final minutes = job.durationOnSite ~/ 60;
    final hours = minutes / 60;
    final durationStr = hours >= 1 
        ? '${hours.toStringAsFixed(1)} hrs on-site' 
        : '$minutes mins on-site';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(w * 0.045),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: TextStyle(
                    fontSize: w * 0.038,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Completed',
                      style: TextStyle(
                        color: const Color(0xFF2E7D32),
                        fontSize: w * 0.026,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.005),
          Text(
            '${job.propertyName} • Completed on ${job.date}',
            style: TextStyle(
              fontSize: w * 0.03,
              color: AppColors.textSecondary,
            ),
          ),
          const Divider(color: AppColors.border, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    durationStr,
                    style: TextStyle(
                      fontSize: w * 0.03,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${job.bidAmount.toStringAsFixed(0)} Earned',
                    style: TextStyle(
                      fontSize: w * 0.038,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  // Direct to invoices or payments tab in the shell, or show dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invoice generated for \$${job.bidAmount.toStringAsFixed(0)}. Sent to ACH payouts.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long_rounded, size: 14),
                label: const Text('View Invoice'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  padding: EdgeInsets.zero,
                  textStyle: TextStyle(fontSize: w * 0.03, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
