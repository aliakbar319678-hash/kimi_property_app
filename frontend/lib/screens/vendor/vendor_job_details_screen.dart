import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/vendor_provider.dart';
import 'package:tenant_and_landlord_application/provider/vendor_state.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_appbar.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_mock_map.dart';

class VendorJobDetailsScreen extends ConsumerWidget {
  const VendorJobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobId = ModalRoute.of(context)!.settings.arguments as String? ?? 'job_find_1';
    final state = ref.watch(vendorProvider);

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    // Find job details in available jobs
    final job = state.availableJobs.firstWhere(
      (j) => j.id == jobId,
      orElse: () => const VendorWorkOrder(
        id: '',
        title: 'Job Details',
        description: '',
        propertyName: '',
        unitName: '',
        tenantName: '',
        priority: 'Low',
        status: 'Request',
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
        appBar: TLAppBar(title: 'Details'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Job details not found or bid already submitted.',
                style: TextStyle(fontSize: w * 0.038, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
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

    String budgetRange = '\$300 - \$400';
    if (job.id == 'job_find_2') budgetRange = '\$150 - \$250';
    if (job.id == 'job_find_3') budgetRange = '\$800 - \$1,200';
    if (job.id == 'job_find_4') budgetRange = '\$200 - \$300';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: TLAppBar(
        title: 'Job Details',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Card
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
                                budgetRange,
                                style: TextStyle(
                                  fontSize: w * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: h * 0.015),
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
                            'Posted by ${job.propertyName} Administration',
                            style: TextStyle(
                              fontSize: w * 0.03,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Divider(color: AppColors.border, height: 24),
                          Text(
                            'Job Description',
                            style: TextStyle(
                              fontSize: w * 0.035,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: h * 0.008),
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

                    // Gallery Card
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
                            'Evidence Gallery',
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
                                        'https://images.unsplash.com/photo-1542013936693-8848e574047a?w=200&q=80'),
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
                                        'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=200&q=80'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: h * 0.02),

                    // Schedule preferences card
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
                            'Schedule Preference',
                            style: TextStyle(
                              fontSize: w * 0.035,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Divider(color: AppColors.border, height: 20),
                          Row(
                            children: [
                              Icon(Icons.calendar_month_rounded, color: AppColors.secondary, size: w * 0.05),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Preferred Service Slot',
                                      style: TextStyle(
                                        fontSize: w * 0.032,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${job.date} • ${job.timeSlot}',
                                      style: TextStyle(
                                        fontSize: w * 0.028,
                                        color: AppColors.textSecondary,
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

                    // Location Preview Card
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
                            'Estimated Location',
                            style: TextStyle(
                              fontSize: w * 0.035,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Divider(color: AppColors.border, height: 20),
                          Container(
                            height: w * 0.35,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: TLMockMap(
                                showZoomControls: false,
                                latitude: job.latitude,
                                longitude: job.longitude,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Exact address will be revealed after the bid is accepted.',
                            style: TextStyle(
                              fontSize: w * 0.028,
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: h * 0.04),
                  ],
                ),
              ),
            ),
            
            // Bottom Action bar
            Container(
              padding: EdgeInsets.all(pad),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/vendor_submit_bid',
                    arguments: job.id,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, w * 0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Submit Bid',
                  style: TextStyle(
                    fontSize: w * 0.038,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
