import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class FinancialOverviewScreen extends ConsumerWidget {
  const FinancialOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(landlordProvider);
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'Financial Overview',
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
            // Financial Metrics Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(w * 0.05),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL COLLECTED',
                    style: TextStyle(
                      fontSize: w * 0.03,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${state.totalCollected.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: w * 0.08,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const Divider(height: 30, color: AppColors.border),
                  Text(
                    'OUTSTANDING',
                    style: TextStyle(
                      fontSize: w * 0.03,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${state.totalOutstanding.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: w * 0.07,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.025),

            // Export button
            ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                minimumSize: Size(double.infinity, w * 0.13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.download_rounded, size: 20),
              label: const Text(
                'Export Reports',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            SizedBox(height: h * 0.035),

            // Rent Payment Status progress bars
            Text(
              'Rent Status',
              style: TextStyle(
                fontSize: w * 0.042,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: h * 0.015),
            Container(
              padding: EdgeInsets.all(w * 0.05),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildProgressBar(
                    'Collected',
                    '80%',
                    '\$24,500',
                    Colors.green,
                    w,
                  ),
                  const SizedBox(height: 16),
                  _buildProgressBar(
                    'Outstanding',
                    '12%',
                    '\$3,200',
                    AppColors.error,
                    w,
                  ),
                  const SizedBox(height: 16),
                  _buildProgressBar(
                    'Late Payments',
                    '8%',
                    '\$1,800',
                    Colors.orange,
                    w,
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.035),

            // Recent activity timeline list
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: w * 0.042,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: h * 0.015),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final name = idx == 0 ? 'John Smith' : 'Sarah Jenkins';
                final amount = idx == 0 ? '+\$1,200' : 'Late Rent';
                final date = idx == 0 ? 'May 19, 2026' : 'May 15, 2026';
                final isLate = idx == 1;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isLate
                                  ? AppColors.error.withValues(alpha: 0.1)
                                  : Colors.green.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isLate
                                  ? Icons.warning_amber_rounded
                                  : Icons.check_rounded,
                              color: isLate ? AppColors.error : Colors.green,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                date,
                                style: const TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        amount,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: isLate ? AppColors.error : Colors.green,
                        ),
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

  Widget _buildProgressBar(
    String label,
    String percent,
    String amount,
    Color color,
    double w,
  ) {
    final val = double.parse(percent.replaceAll('%', '')) / 100.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            Text(
              '$percent ($amount)',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: val,
            minHeight: 8,
            color: color,
            backgroundColor: AppColors.scaffoldBg,
          ),
        ),
      ],
    );
  }
}
