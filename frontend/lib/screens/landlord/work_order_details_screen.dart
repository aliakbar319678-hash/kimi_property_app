import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/provider/landlord_state.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/landlord/release_escrow_dialog.dart';
import 'package:tenant_and_landlord_application/screens/landlord/vendor_rating_dialog.dart';

class WorkOrderDetailsScreen extends ConsumerStatefulWidget {
  const WorkOrderDetailsScreen({super.key});

  @override
  ConsumerState<WorkOrderDetailsScreen> createState() => _WorkOrderDetailsScreenState();
}

class _WorkOrderDetailsScreenState extends ConsumerState<WorkOrderDetailsScreen> {
  WorkOrder? _order;
  bool _isLoading = true;
  String? _error;
  bool _isUpdating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_order == null) {
      final argOrder = ModalRoute.of(context)?.settings.arguments as WorkOrder?;
      if (argOrder != null) {
        _fetchFreshData(argOrder.id);
      } else {
        // Fallback if no arg is passed
        final fallback = ref.read(landlordProvider).workOrders.firstOrNull;
        if (fallback != null) {
          _fetchFreshData(fallback.id);
        } else {
          setState(() {
            _isLoading = false;
            _error = "No work order provided.";
          });
        }
      }
    }
  }

  Future<void> _fetchFreshData(String id) async {
    try {
      final freshOrder = await ref.read(landlordProvider.notifier).fetchWorkOrderById(id);
      if (mounted) {
        setState(() {
          _order = freshOrder;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(landlordProvider.notifier);

    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.05;

    // Stages matching the mockup: Request, Assigned, In-Progress, Completed
    final stages = ['Request', 'Assigned', 'In-Progress', 'Completed'];

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(_error ?? 'Unknown error')),
      );
    }

    final updatedOrder = _order!;


    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text('Work Order #${updatedOrder.id}', style: const TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: pad, vertical: h * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stage/Status Tab Row
            Row(
              children: stages.asMap().entries.map((entry) {
                final stage = entry.value;
                final orderStatus = updatedOrder.status.toLowerCase().replaceAll('_', '-').replaceAll(' ', '-');
                final stageNorm = stage.toLowerCase().replaceAll(' ', '-');

                // Determine if stage is completed/passed/current
                final statusOrder = ['request', 'open', 'assigned', 'scheduled', 'in-progress', 'in_progress', 'waiting_parts', 'completed'];
                final currentIdx = statusOrder.indexOf(orderStatus);

                // Map stage name to canonical order index
                int stageIdx;
                if (stageNorm == 'request') { stageIdx = 0; }
                else if (stageNorm == 'assigned') { stageIdx = 2; }
                else if (stageNorm == 'in-progress') { stageIdx = 4; }
                else { stageIdx = 7; } // completed

                final isPassed = currentIdx > stageIdx;
                final isCurrent = currentIdx == stageIdx ||
                    (stageNorm == 'request' && (orderStatus == 'open' || orderStatus == 'request')) ||
                    (stageNorm == 'assigned' && (orderStatus == 'assigned' || orderStatus == 'scheduled')) ||
                    (stageNorm == 'in-progress' && (orderStatus == 'in-progress' || orderStatus == 'in_progress' || orderStatus == 'waiting_parts')) ||
                    (stageNorm == 'completed' && orderStatus == 'completed');

                Color bgColor;
                Color textColor;
                Color borderColor;
                if (stageNorm == 'completed' && (isPassed || isCurrent)) {
                  bgColor = const Color(0xFF16A34A);
                  textColor = Colors.white;
                  borderColor = const Color(0xFF16A34A);
                } else if (isCurrent) {
                  bgColor = AppColors.primary;
                  textColor = Colors.white;
                  borderColor = AppColors.primary;
                } else if (isPassed) {
                  bgColor = AppColors.primary.withValues(alpha: 0.12);
                  textColor = AppColors.primary;
                  borderColor = AppColors.primary.withValues(alpha: 0.3);
                } else {
                  bgColor = AppColors.white;
                  textColor = AppColors.textSecondary;
                  borderColor = AppColors.border;
                }

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (stageNorm == 'completed' && (isPassed || isCurrent))
                            const Icon(Icons.check_circle_rounded, size: 11, color: Colors.white),
                          if (stageNorm == 'completed' && (isPassed || isCurrent))
                            const SizedBox(width: 3),
                          Text(
                            stage,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: h * 0.03),

            // Description Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  updatedOrder.title,
                  style: TextStyle(fontSize: w * 0.055, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    updatedOrder.priority,
                    style: const TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${updatedOrder.propertyName} • ${updatedOrder.unitName}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),

            SizedBox(height: h * 0.02),

            // Issue Description text block
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(w * 0.04),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                updatedOrder.description,
                style: TextStyle(
                  fontSize: w * 0.034,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),

            SizedBox(height: h * 0.025),

            // Photos Gallery
            if (updatedOrder.photos.isNotEmpty) ...[
              const Text('Photos', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: updatedOrder.photos.map((photoUrl) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          photoUrl,
                          width: w * 0.22,
                          height: w * 0.22,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: h * 0.03),
            ],

            // Assigned Vendor Section
            const Text('Assigned Vendor', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: AppColors.scaffoldBg, shape: BoxShape.circle),
                        child: const Icon(Icons.build_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (updatedOrder.vendorName == null || updatedOrder.vendorName == 'Unassigned') ? 'Alex Rivera' : updatedOrder.vendorName!,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            const Row(
                              children: [
                                Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                SizedBox(width: 2),
                                Text('4.9 (Certified Plumber)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (updatedOrder.bidAmount != null)
                        Text(
                          'SAR ${updatedOrder.bidAmount!.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                    ],
                  ),
                  if (updatedOrder.status.toLowerCase() == 'open' || updatedOrder.status.toLowerCase() == 'request') ...[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/landlord_bids_received', arguments: updatedOrder);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 38),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('View Received Bids', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ] else ...[
                    const Divider(height: 24, color: AppColors.border),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/landlord_job_chat');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Contact', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('View Contract', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user_rounded, color: Colors.green),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Insurance & Compliance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                Text('Policy #INS-10492 • Expires: Dec 2026', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (dlgCtx) => Dialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  child: Container(
                                    padding: const EdgeInsets.all(28),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 32),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text('Certificate of Insurance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                                        const SizedBox(height: 6),
                                        const Text('Vendor Insurance & Compliance Details', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                        const SizedBox(height: 24),
                                        _buildInsuranceRow('Coverage Type', 'General Liability'),
                                        const SizedBox(height: 12),
                                        _buildInsuranceRow('Coverage Amount', '\$1,000,000'),
                                        const SizedBox(height: 12),
                                        _buildInsuranceRow('Policy Number', '#INS-10492'),
                                        const SizedBox(height: 12),
                                        _buildInsuranceRow('Expiry Date', 'December 31, 2026'),
                                        const SizedBox(height: 12),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF16A34A).withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 16),
                                              SizedBox(width: 8),
                                              Text('Status: Active & Verified', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () => Navigator.pop(dlgCtx),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF16A34A),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              minimumSize: const Size(double.infinity, 48),
                                              elevation: 0,
                                            ),
                                            child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('View', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF16A34A))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: h * 0.03),

            // Activity & Notes
            const Text('Activity & Notes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildTimelineItem('Work order created and tenant notified', 'May 19, 10:00 AM', true),
                  if (updatedOrder.vendorName != null) ...[
                    const Divider(height: 20),
                    _buildTimelineItem('Vendor assigned and contract drafted', 'May 19, 10:15 AM', true),
                  ],
                  if (updatedOrder.status.toLowerCase() == 'completed') ...[
                    const Divider(height: 20),
                    _buildTimelineItem('Work order marked as completed', 'Just now', false),
                  ],
                ],
              ),
            ),

            SizedBox(height: h * 0.05),

            // Bottom Buttons: Reassign, Mark Completed, or Rate Vendor
            if (updatedOrder.status.toLowerCase() == 'completed')
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final res = await ReleaseEscrowDialog.show(
                          context,
                          workOrderId: updatedOrder.id,
                          vendorName: updatedOrder.assignedVendorName,
                          vendorId: updatedOrder.assignedVendorId,
                          jobCost: updatedOrder.cost,
                        );
                        if (res != null && mounted) {
                          messenger.showSnackBar(const SnackBar(content: Text('Escrow payout released successfully ✅'), backgroundColor: Color(0xFF27AE60)));
                          _fetchFreshData(updatedOrder.id);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, w * 0.13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.payments_rounded, color: Colors.white),
                      label: const Text('Release Escrow Payout', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => VendorRatingDialog(workOrderId: updatedOrder.id),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, w * 0.13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.star_rounded, color: Colors.white),
                      label: const Text('Rate Vendor', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/landlord_post_job', arguments: updatedOrder);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        minimumSize: Size(double.infinity, w * 0.13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Post Job', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: updatedOrder.status.toLowerCase() == 'completed' || _isUpdating
                          ? null
                          : () async {
                              setState(() => _isUpdating = true);
                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                await notifier.updateWorkOrderStatus(updatedOrder.id, 'Completed');
                                if (mounted) {
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('Work order marked as completed'), backgroundColor: Colors.green),
                                  );
                                  _fetchFreshData(updatedOrder.id);
                                }
                              } catch (e) {
                                if (mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(content: Text('Failed to update status: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _isUpdating = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, w * 0.13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: _isUpdating
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Mark Completed', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String text, String time, bool isDone) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: isDone ? Colors.green : AppColors.textHint,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(fontSize: 10, color: AppColors.textHint),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsuranceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w700)),
      ],
    );
  }
}
