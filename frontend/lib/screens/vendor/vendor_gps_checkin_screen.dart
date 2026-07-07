import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/vendor_provider.dart';
import 'package:tenant_and_landlord_application/provider/vendor_state.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_appbar.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_mock_map.dart';

class VendorGpsCheckinScreen extends ConsumerWidget {
  const VendorGpsCheckinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobId = ModalRoute.of(context)!.settings.arguments as String? ?? 'job_act_2';
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

    final isCurrentJobCheckedIn = state.checkedIn && state.checkedInJobId == job.id;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: TLAppBar(
        title: 'Job Site Verification',
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
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: Column(
            children: [
              // Top Property Label
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(w * 0.04),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.domain_rounded, color: AppColors.secondary, size: w * 0.05),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.propertyName,
                            style: TextStyle(
                              fontSize: w * 0.038,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            job.address,
                            style: TextStyle(
                              fontSize: w * 0.028,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isCurrentJobCheckedIn)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
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
                              'On Site',
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
              ),
              SizedBox(height: h * 0.02),

              // Timer Display Box
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: h * 0.025),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'TOTAL ON-SITE TIME',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: w * 0.028,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: h * 0.008),
                    Text(
                      isCurrentJobCheckedIn ? _formatDuration(state.elapsedSeconds) : '00:00:00',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: w * 0.1,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: h * 0.005),
                    Text(
                      isCurrentJobCheckedIn 
                          ? 'Timer actively recording' 
                          : 'Clock in when you arrive at the job site',
                      style: TextStyle(
                        color: isCurrentJobCheckedIn ? AppColors.secondary : Colors.white.withValues(alpha: 0.5),
                        fontSize: w * 0.028,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: h * 0.02),

              // Map Section
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: TLMockMap(
                      latitude: job.latitude,
                      longitude: job.longitude,
                    ),
                  ),
                ),
              ),
              SizedBox(height: h * 0.025),

              // Location Verification Banner
              Container(
                padding: EdgeInsets.all(w * 0.035),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA5D6A7)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.gps_fixed_rounded, color: Color(0xFF2E7D32), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'GPS location verified. You are within 10 meters of the project site.',
                        style: TextStyle(
                          color: const Color(0xFF2E7D32),
                          fontSize: w * 0.03,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: h * 0.025),

              // Action Buttons
              if (!isCurrentJobCheckedIn)
                ElevatedButton.icon(
                  onPressed: () {
                    notifier.clockIn(job.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Clocked in successfully at ${job.propertyName}.'),
                        backgroundColor: AppColors.secondary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Check In to Job Site'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, w * 0.13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: TextStyle(fontSize: w * 0.038, fontWeight: FontWeight.bold),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Pass Tour simulation
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tour verification logged.'),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          minimumSize: Size(double.infinity, w * 0.13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: TextStyle(fontSize: w * 0.038, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Log Patrol/Tour'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          notifier.clockOut();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Clocked out successfully.'),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Check Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, w * 0.13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: TextStyle(fontSize: w * 0.038, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: h * 0.02),
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
}
