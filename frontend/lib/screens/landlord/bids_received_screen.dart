import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/provider/landlord_state.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class BidsReceivedScreen extends ConsumerStatefulWidget {
  const BidsReceivedScreen({super.key});

  @override
  ConsumerState<BidsReceivedScreen> createState() => _BidsReceivedScreenState();
}

class _BidsReceivedScreenState extends ConsumerState<BidsReceivedScreen> {
  WorkOrder? _order;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_order == null) {
      final order = ModalRoute.of(context)?.settings.arguments as WorkOrder?;
      if (order != null) {
        _order = order;
        Future.microtask(() {
          ref.read(landlordProvider.notifier).fetchBidsForWorkOrder(order.id);
        });
      } else {
        _order = ref.read(landlordProvider).workOrders.firstOrNull;
        if (_order != null) {
          Future.microtask(() {
            ref.read(landlordProvider.notifier).fetchBidsForWorkOrder(_order!.id);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(landlordProvider);
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.05;

    final order = _order;
    if (order == null) {
      return const Scaffold(body: Center(child: Text('No work order provided')));
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'Job Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
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
            // Job Details Overview Header Box
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(w * 0.05),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.title,
                        style: TextStyle(
                          fontSize: w * 0.045,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'OPEN FOR BIDS',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${order.propertyName}, ${order.unitName}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tenant: ${order.tenantName}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.border),
                  const Text(
                    'BUDGET RANGE',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textHint,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'SAR 200 - SAR 500',
                    style: TextStyle(
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.035),

            // Bids received header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bids Received (${state.bids.length})',
                  style: TextStyle(
                    fontSize: w * 0.042,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Sort by: Highest Rated',
                  style: TextStyle(
                    fontSize: w * 0.028,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            SizedBox(height: h * 0.015),

            // Bids Card List
            if (state.isBidsLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ))
            else if (state.bids.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No bids yet.'),
              ))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.bids.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, idx) {
                  final bid = state.bids[idx];

                  return Container(
                  padding: EdgeInsets.all(w * 0.045),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: w * 0.12,
                            height: w * 0.12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(bid.avatarUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bid.vendorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${bid.rating} (${bid.totalJobs} jobs)',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Available to fix this immediately. I carry all standard sink parts.',
                                  style: TextStyle(
                                    fontSize: w * 0.028,
                                    color: AppColors.textHint,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'SAR ${bid.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: w * 0.045,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bid.time,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: AppColors.border),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/landlord_job_chat',
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Chat',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/landlord_confirm_assignment',
                                  arguments: {'order': order, 'bid': bid},
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Assign Job',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
