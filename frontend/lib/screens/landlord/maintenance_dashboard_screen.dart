import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class MaintenanceDashboardScreen extends ConsumerStatefulWidget {
  const MaintenanceDashboardScreen({super.key});

  @override
  ConsumerState<MaintenanceDashboardScreen> createState() =>
      _MaintenanceDashboardScreenState();
}

class _MaintenanceDashboardScreenState
    extends ConsumerState<MaintenanceDashboardScreen> {
  String _selectedTab = 'All'; // 'All', 'In-Progress', 'Open', 'Completed'

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(landlordProvider);
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.05;

    // Filter work orders based on tab
    final filteredOrders = state.workOrders.where((wo) {
      if (_selectedTab == 'In-Progress') {
        return wo.status == 'In-Progress' || wo.status == 'Assigned';
      } else if (_selectedTab == 'Open') {
        return wo.status == 'Request';
      } else if (_selectedTab == 'Completed') {
        return wo.status == 'Completed';
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: pad,
                vertical: h * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Maintenance',
                        style: TextStyle(
                          fontSize: w * 0.06,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  SizedBox(height: h * 0.02),


                  // Tickets stats cards row
                  Row(
                    children: [
                      _buildTicketStatCard(
                        state.maintenanceEmergency.toString(),
                        'Emergency',
                        AppColors.error,
                        w,
                      ),
                      SizedBox(width: w * 0.03),
                      _buildTicketStatCard(
                        state.maintenanceInProgress.toString(),
                        'In-Progress',
                        AppColors.secondary,
                        w,
                      ),
                      SizedBox(width: w * 0.03),
                      _buildTicketStatCard(state.maintenanceCompleted.toString(), 'Completed', Colors.green, w),
                    ],
                  ),


                  SizedBox(height: h * 0.03),

                  // Filtering Tabs
                  Row(
                    children: ['All', 'In-Progress', 'Open', 'Completed'].map((
                      tab,
                    ) {
                      final isSelected = _selectedTab == tab;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = tab),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              tab,
                              style: TextStyle(
                                fontSize: w * 0.028,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: h * 0.025),

                  // Work Orders List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredOrders.length,
                    separatorBuilder: (_, _) => SizedBox(height: h * 0.02),
                    itemBuilder: (context, idx) {
                      final order = filteredOrders[idx];
                      Color priorityColor;
                      switch (order.priority.toLowerCase()) {
                        case 'emergency':
                          priorityColor = AppColors.error;
                          break;
                        case 'high':
                          priorityColor = Colors.orange;
                          break;
                        default:
                          priorityColor = AppColors.secondary;
                      }

                      Color statusBg;
                      Color statusText;
                      switch (order.status.toLowerCase()) {
                        case 'completed':
                          statusBg = Colors.green.withValues(alpha: 0.12);
                          statusText = Colors.green;
                          break;
                        case 'in-progress':
                        case 'assigned':
                          statusBg = AppColors.secondary.withValues(alpha: 0.12);
                          statusText = AppColors.secondary;
                          break;
                        default:
                          statusBg = AppColors.textHint.withValues(alpha: 0.12);
                          statusText = AppColors.textSecondary;
                      }

                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/landlord_work_order_details',
                          arguments: order,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(w * 0.045),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: priorityColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      order.priority,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: priorityColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      order.status,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: statusText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: h * 0.015),
                              Text(
                                order.title,
                                style: TextStyle(
                                  fontSize: w * 0.042,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: h * 0.005),
                              Text(
                                '${order.propertyName} • ${order.unitName}',
                                style: TextStyle(
                                  fontSize: w * 0.03,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (order.vendorName != null) ...[
                                Divider(
                                  height: h * 0.025,
                                  color: AppColors.border,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.person_outline_rounded,
                                          size: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          order.vendorName!,
                                          style: TextStyle(
                                            fontSize: w * 0.03,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'SAR ${order.bidAmount?.toStringAsFixed(0) ?? ''}',
                                      style: TextStyle(
                                        fontSize: w * 0.032,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: h * 0.1),
                ],
              ),
            ),

            // Floating + Create Work Order Button at bottom
            Positioned(
              bottom: 20,
              left: pad,
              right: pad,
              child: ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/landlord_create_work_order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  minimumSize: Size(double.infinity, w * 0.13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text(
                  'Create Work Order',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketStatCard(
    String count,
    String label,
    Color color,
    double w,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: w * 0.05,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
