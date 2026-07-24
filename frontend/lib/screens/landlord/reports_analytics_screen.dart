import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/provider/landlord_state.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class ReportsAnalyticsScreen extends ConsumerStatefulWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  ConsumerState<ReportsAnalyticsScreen> createState() => _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends ConsumerState<ReportsAnalyticsScreen> {
  String _selectedFilter = 'Financial'; // 'Financial', 'Property', 'Tenant', 'Export'
  
  // For export filters
  DateTime? _startDate;
  DateTime? _endDate;

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

            // Tab Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Financial', 'Property', 'Tenant', 'Export'].map((filter) {
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
            ),

            SizedBox(height: h * 0.03),

            // Render based on selected tab
            if (_selectedFilter == 'Financial') _buildFinancialTab(state, w, h),
            if (_selectedFilter == 'Property') _buildPropertyTab(state, w, h),
            if (_selectedFilter == 'Tenant') _buildTenantTab(state, w, h),
            if (_selectedFilter == 'Export') _buildExportTab(state, w, h),
          ],
        ),
      ),
    );
  }

  // --- A) Financial Reports Tab ---
  Widget _buildFinancialTab(LandlordState state, double w, double h) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Income vs Expenses
        Container(
          padding: EdgeInsets.all(w * 0.05),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Income vs Expenses (YTD)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatBlock('Total Income', '\$${state.totalCollected.toStringAsFixed(0)}', Colors.green, w),
                  _buildStatBlock('Total Expenses', '\$12,450', AppColors.error, w), // Mock Expense
                  _buildStatBlock('Net Profit', '\$${(state.totalCollected - 12450).toStringAsFixed(0)}', AppColors.primary, w),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Monthly Revenue Trend', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              // Mock Line/Bar Chart for Revenue
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildChartBar('Jan', 40, AppColors.primary, w),
                  _buildChartBar('Feb', 50, AppColors.primary, w),
                  _buildChartBar('Mar', 45, AppColors.primary, w),
                  _buildChartBar('Apr', 60, AppColors.primary, w),
                  _buildChartBar('May', 75, AppColors.primary, w),
                  _buildChartBar('Jun', 80, AppColors.primary, w),
                  _buildChartBar('Jul', 85, AppColors.primary, w),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- B) Property Performance Tab ---
  Widget _buildPropertyTab(LandlordState state, double w, double h) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        // Revenue per Unit Table
        Container(
          padding: EdgeInsets.all(w * 0.04),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Revenue per Unit', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 16),
              if (state.properties.isEmpty)
                const Text('No properties available.', style: TextStyle(color: AppColors.textSecondary))
              else
                ...state.properties.map((p) {
                  final occ = '${(p.occupancyRate * 100).toInt()}% Occupied';
                  final rev = '\$${p.monthlyRent.toStringAsFixed(0)}/mo';
                  return Column(
                    children: [
                      _buildBreakdownRow(p.name, rev, occ, w),
                      const Divider(color: AppColors.border, height: 24),
                    ],
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  // --- C) Tenant Behavior Tab ---
  Widget _buildTenantTab(LandlordState state, double w, double h) {
    final onTimePct = state.rentCollectionPercent * 100; 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(w * 0.05),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tenant Payment Behavior', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: w * 0.2,
                        height: w * 0.2,
                        child: CircularProgressIndicator(
                          value: state.rentCollectionPercent,
                          strokeWidth: 8,
                          color: Colors.green,
                          backgroundColor: AppColors.scaffoldBg,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text('${onTimePct.toInt()}%', style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  SizedBox(width: w * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('On-Time Payments', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('${onTimePct.toInt()}% of tenants pay their rent on or before the due date.', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: h * 0.02),
        // Lease Renewals
        Container(
          padding: EdgeInsets.all(w * 0.05),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Lease Renewal Metrics', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatBlock('Upcoming Renewals', '4', AppColors.primary, w),
                  _buildStatBlock('Historical Rate', '78%', Colors.green, w),
                  _buildStatBlock('Churn Rate', '22%', AppColors.error, w),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- D) Custom Report Export Tab ---
  Widget _buildExportTab(LandlordState state, double w, double h) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(w * 0.05),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Custom Report Builder', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 16),
              const Text('Select Date Range', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
                        if (date != null) setState(() => _startDate = date);
                      },
                      icon: const Icon(Icons.calendar_today_rounded, size: 16),
                      label: Text(_startDate != null ? '${_startDate!.month}/${_startDate!.day}/${_startDate!.year}' : 'Start Date', style: const TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('to', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
                        if (date != null) setState(() => _endDate = date);
                      },
                      icon: const Icon(Icons.calendar_today_rounded, size: 16),
                      label: Text(_endDate != null ? '${_endDate!.month}/${_endDate!.day}/${_endDate!.year}' : 'End Date', style: const TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Export Format', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildExportButton(Icons.picture_as_pdf_rounded, 'PDF Report', w),
                  SizedBox(width: w * 0.03),
                  _buildExportButton(Icons.grid_on_rounded, 'Excel Data', w),
                  SizedBox(width: w * 0.03),
                  _buildExportButton(Icons.description_rounded, 'CSV Data', w),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Helpers ---
  Widget _buildStatBlock(String label, String value, Color color, double w) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(fontSize: w * 0.05, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildChartBar(String label, double heightVal, Color color, double w) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: w * 0.08,
          height: heightVal,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildExportButton(IconData icon, String label, double w) {
    return Expanded(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading $label...')));
        },
        borderRadius: BorderRadius.circular(14),
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
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textPrimary)),
            ],
          ),
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
            Text(occ, style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
          ],
        ),
        Text(rev, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.green)),
      ],
    );
  }
}
