import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/vendor_provider.dart';
import 'package:tenant_and_landlord_application/provider/vendor_state.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_appbar.dart';

class VendorWorkOrderDetailsScreen extends ConsumerWidget {
  const VendorWorkOrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobId = ModalRoute.of(context)!.settings.arguments as String? ?? 'job_act_1';
    final state = ref.watch(vendorProvider);
    final notifier = ref.read(vendorProvider.notifier);

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    // Find job details
    final job = state.activeJobs.firstWhere(
      (j) => j.id == jobId,
      orElse: () => const VendorWorkOrder(
        id: '',
        title: 'Work Order Not Found',
        description: '',
        propertyName: '',
        unitName: '',
        tenantName: '',
        priority: 'Low',
        status: 'Assigned',
        category: 'General',
        date: '',
        timeSlot: '',
        accessInstructions: '',
        address: '',
        bidAmount: 0.0,
      ),
    );

    if (job.id.isEmpty) {
      return Scaffold(
        appBar: TLAppBar(title: 'Error'),
        body: const Center(child: Text('Work order not found.')),
      );
    }

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

    final isAssigned = job.status == 'Assigned';
    final isInProgress = job.status == 'In-Progress';
    final isCompleted = job.status == 'Completed';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: TLAppBar(
        title: 'Issue Details',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main details card
              Container(
                width: double.infinity,
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
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                        Text(
                          'Job ID: #${job.id.substring(job.id.length - 4).toUpperCase()}',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: w * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: h * 0.012),
                    Text(
                      job.title,
                      style: TextStyle(
                        fontSize: w * 0.052,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: h * 0.005),
                    Text(
                      'Category: ${job.category}',
                      style: TextStyle(
                        fontSize: w * 0.032,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Divider(color: AppColors.border, height: 24),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: w * 0.035,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: h * 0.005),
                    Text(
                      job.description,
                      style: TextStyle(
                        fontSize: w * 0.032,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: h * 0.02),

              // Photos Card
              Container(
                width: double.infinity,
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
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reference Photos',
                      style: TextStyle(
                        fontSize: w * 0.035,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: h * 0.012),
                    Row(
                      children: [
                        Container(
                          width: w * 0.22,
                          height: w * 0.22,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                            image: const DecorationImage(
                              image: NetworkImage(
                                  'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=200&q=80'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: w * 0.03),
                        Container(
                          width: w * 0.22,
                          height: w * 0.22,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                            image: const DecorationImage(
                              image: NetworkImage(
                                  'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=200&q=80'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: w * 0.03),
                        Container(
                          width: w * 0.22,
                          height: w * 0.22,
                          decoration: BoxDecoration(
                            color: AppColors.inputBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined,
                                  color: AppColors.textHint, size: w * 0.06),
                              const SizedBox(height: 2),
                              Text(
                                'Add Photo',
                                style: TextStyle(
                                  fontSize: w * 0.026,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: h * 0.02),

              // Contact & Access instructions
              Container(
                width: double.infinity,
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
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact & Access Info',
                      style: TextStyle(
                        fontSize: w * 0.035,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Divider(color: AppColors.border, height: 20),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.secondary.withValues(alpha: 0.12),
                          child: Icon(Icons.person_rounded, color: AppColors.secondary, size: w * 0.045),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.tenantName,
                                style: TextStyle(
                                  fontSize: w * 0.034,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Tenant • ${job.propertyName}',
                                style: TextStyle(
                                  fontSize: w * 0.028,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.phone_rounded, color: AppColors.secondary),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Access Directions:',
                      style: TextStyle(
                        fontSize: w * 0.03,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.accessInstructions,
                      style: TextStyle(
                        fontSize: w * 0.03,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: h * 0.02),

              // GPS Check-in widget area
              if (!isCompleted)
                Container(
                  width: double.infinity,
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
                  padding: EdgeInsets.all(pad),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAssigned ? 'Scheduled Appointment' : 'On-Site Status',
                                style: TextStyle(
                                  fontSize: w * 0.03,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isAssigned 
                                    ? job.timeSlot 
                                    : 'Checked In since ${job.checkInTime ?? "N/A"}',
                                style: TextStyle(
                                  fontSize: w * 0.036,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          if (isInProgress)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _formatDuration(state.elapsedSeconds),
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: w * 0.028,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (isAssigned)
                        ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to GPS Check in
                            Navigator.pushNamed(
                              context,
                              '/vendor_gps_checkin',
                              arguments: job.id,
                            );
                          },
                          icon: const Icon(Icons.location_on_rounded),
                          label: const Text('Start GPS Check-In'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, w * 0.12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      if (isInProgress)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/vendor_gps_checkin',
                                    arguments: job.id,
                                  );
                                },
                                icon: const Icon(Icons.timer_rounded),
                                label: const Text('View Timer'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  minimumSize: Size(double.infinity, w * 0.12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Complete Job
                                  notifier.updateWorkOrderStatus(job.id, 'Completed');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Job completed successfully! Invoice sent.'),
                                      backgroundColor: Color(0xFF2E7D32),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.check_circle_rounded),
                                label: const Text('Complete Job'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(double.infinity, w * 0.12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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

              // Job Timeline Flow
              Container(
                width: double.infinity,
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
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Job Timeline',
                      style: TextStyle(
                        fontSize: w * 0.035,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Divider(color: AppColors.border, height: 20),
                    _buildTimelineNode(
                      title: 'Work Request Submitted',
                      subtitle: 'Landlord requested vendor proposals',
                      isCompleted: true,
                      isLast: false,
                      w: w,
                    ),
                    _buildTimelineNode(
                      title: 'Job Assigned to You',
                      subtitle: 'Bid accepted. Payout: \$${job.bidAmount.toStringAsFixed(0)}',
                      isCompleted: true,
                      isLast: false,
                      w: w,
                    ),
                    _buildTimelineNode(
                      title: 'Work In Progress',
                      subtitle: isInProgress 
                          ? 'Technician on site' 
                          : isCompleted 
                              ? 'Completed on site' 
                              : 'Pending check-in',
                      isCompleted: isInProgress || isCompleted,
                      isLast: false,
                      w: w,
                    ),
                    _buildTimelineNode(
                      title: 'Job Signed Off',
                      subtitle: isCompleted ? 'Invoice processed & archived' : 'Waiting for completion sign-off',
                      isCompleted: isCompleted,
                      isLast: true,
                      w: w,
                    ),
                  ],
                ),
              ),
              SizedBox(height: h * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildTimelineNode({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isLast,
    required double w,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.secondary : AppColors.inputBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? AppColors.secondary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 10)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 45,
                color: isCompleted ? AppColors.secondary : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: w * 0.034,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? AppColors.textPrimary : AppColors.textHint,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: w * 0.028,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
