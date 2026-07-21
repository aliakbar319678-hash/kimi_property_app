import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/provider/landlord_state.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class WorkOrderDetailsScreen extends ConsumerStatefulWidget {
  const WorkOrderDetailsScreen({super.key});

  @override
  ConsumerState<WorkOrderDetailsScreen> createState() => _WorkOrderDetailsScreenState();
}

class _WorkOrderDetailsScreenState extends ConsumerState<WorkOrderDetailsScreen> {
  WorkOrder? _order;
  bool _isLoading = true;
  String? _error;

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
              children: stages.map((stage) {
                final isCurrent = updatedOrder.status.toLowerCase() == stage.toLowerCase();
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isCurrent ? AppColors.secondary : AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isCurrent ? AppColors.secondary : AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        stage,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isCurrent ? AppColors.white : AppColors.textSecondary,
                        ),
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
              '${updatedOrder.propertyName} â€¢ ${updatedOrder.unitName}',
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
              Row(
                children: updatedOrder.photos.map((photoUrl) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      photoUrl,
                      width: w * 0.22,
                      height: w * 0.22,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
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
                              updatedOrder.vendorName ?? 'No Vendor Assigned',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            if (updatedOrder.vendorName != null) ...[
                              const SizedBox(height: 2),
                              const Row(
                                children: [
                                  Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                  SizedBox(width: 2),
                                  Text('4.8 (126 jobs)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
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
                  if (updatedOrder.vendorName == null) ...[
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
                  if (updatedOrder.status == 'Completed') ...[
                    const Divider(height: 20),
                    _buildTimelineItem('Work order marked as completed', 'Just now', false),
                  ],
                ],
              ),
            ),

            SizedBox(height: h * 0.05),

            // Bottom Buttons: Reassign, Mark Completed
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
                    onPressed: updatedOrder.status == 'Completed'
                        ? null
                        : () {
                            notifier.updateWorkOrderStatus(updatedOrder.id, 'Completed');
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, w * 0.13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Mark Completed', style: TextStyle(fontWeight: FontWeight.w600)),
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
}
