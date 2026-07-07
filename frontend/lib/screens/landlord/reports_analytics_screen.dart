import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class ReportsAnalyticsScreen extends ConsumerStatefulWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  ConsumerState<ReportsAnalyticsScreen> createState() => _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends ConsumerState<ReportsAnalyticsScreen> {
  String _selectedFilter = 'Financial'; // 'Financial', 'Occupancy', 'Maintenance'

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(landlordProvider);
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Reports & Analytics', style: TextStyle(fontWeight: FontWeight.w700)),
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
            Text(
              'Portfolio Performance',
              style: TextStyle(fontSize: w * 0.05, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Review your portfolio performance across key metrics.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),

            SizedBox(height: h * 0.025),

            // Tab Filters: Financial, Occupancy, Maintenance
            Row(
              children: ['Financial', 'Occupancy', 'Maintenance'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: w * 0.03,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: h * 0.03),

            // Occupancy Rate Card
            Container(
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
                      const Text('Occupancy Rate', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text('${(state.occupancyRate * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: state.occupancyRate,
                      minHeight: 12,
                      color: AppColors.primary,
                      backgroundColor: AppColors.scaffoldBg,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.02),

            // Repair cost stats
            Container(
              padding: EdgeInsets.all(w * 0.05),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Avg Repair Cost', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text('\$210', style: TextStyle(fontSize: w * 0.08, fontWeight: FontWeight.w800, color: AppColors.secondary)),
                  const SizedBox(height: 10),
                  // Mock Graph Representation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [40, 60, 30, 80, 50, 90, 70].map((hVal) {
                      return Container(
                        width: w * 0.08,
                        height: hVal.toDouble(),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: hVal == 90 ? 1 : 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.03),

            // Export Actions
            Text(
              'Export Performance Data',
              style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            SizedBox(height: h * 0.015),
            Row(
              children: [
                _buildExportButton(Icons.picture_as_pdf_rounded, 'PDF', w),
                SizedBox(width: w * 0.03),
                _buildExportButton(Icons.grid_on_rounded, 'Excel', w),
                SizedBox(width: w * 0.03),
                _buildExportButton(Icons.description_rounded, 'CSV', w),
              ],
            ),

            SizedBox(height: h * 0.035),

            // Property breakdown table
            Text(
              'Property Breakdown',
              style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            SizedBox(height: h * 0.015),
            Container(
              padding: EdgeInsets.all(w * 0.04),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildBreakdownRow('Sunset Apartments', '\$12,450', '92%', w),
                  const Divider(color: AppColors.border, height: 24),
                  _buildBreakdownRow('Maple Residency', '\$9,380', '100%', w),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(IconData icon, String label, double w) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String name, String rev, String occ, double w) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 2),
            Text('Occupancy: $occ', style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
          ],
        ),
        Text(rev, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.green)),
      ],
    );
  }
}
