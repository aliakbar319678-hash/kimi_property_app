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


                  // Premium Tickets stats cards row
                  Row(
                    children: [
                      _buildTicketStatCard(
                        state.maintenanceEmergency.toString(),
                        'Emergency',
                        AppColors.error,
                        Icons.warning_amber_rounded,
                        w,
                      ),
                      SizedBox(width: w * 0.03),
                      _buildTicketStatCard(
                        state.maintenanceInProgress.toString(),
                        'In-Progress',
                        const Color(0xFF0284C7),
                        Icons.engineering_rounded,
                        w,
                      ),
                      SizedBox(width: w * 0.03),
                      _buildTicketStatCard(
                        state.maintenanceCompleted.toString(),
                        'Completed',
                        const Color(0xFF16A34A),
                        Icons.verified_rounded,
                        w,
                      ),
                    ],
                  ),

                  SizedBox(height: h * 0.025),

                  // Filtering Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'In-Progress', 'Open', 'Completed'].map((tab) {
                        final isSelected = _selectedTab == tab;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = tab),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                  width: 1.2,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Text(
                                tab,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: h * 0.02),

                  // Work Orders List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredOrders.length,
                    separatorBuilder: (_, _) => SizedBox(height: h * 0.016),
                    itemBuilder: (context, idx) {
                      final order = filteredOrders[idx];
                      Color priorityColor;
                      switch (order.priority.toLowerCase()) {
                        case 'emergency':
                          priorityColor = AppColors.error;
                          break;
                        case 'high':
                          priorityColor = const Color(0xFFEA580C);
                          break;
                        default:
                          priorityColor = const Color(0xFF2563EB);
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
                            border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: priorityColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.flag_rounded, size: 12, color: priorityColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${order.priority} Priority',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: priorityColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildStatusBadge(order.status),
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
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${order.propertyName} • ${order.unitName}',
                                      style: TextStyle(
                                        fontSize: w * 0.03,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (order.vendorName != null && order.vendorName!.isNotEmpty) ...[
                                const Divider(height: 20, color: AppColors.border),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.08),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.engineering_rounded, size: 14, color: AppColors.primary),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          order.vendorName!,
                                          style: TextStyle(
                                            fontSize: w * 0.032,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (order.bidAmount != null && order.bidAmount! > 0)
                                      Text(
                                        '\$${order.bidAmount!.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: w * 0.035,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF16A34A),
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

            // Floating + Create Work Order Button
            Positioned(
              bottom: 20,
              left: pad,
              right: pad,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/landlord_create_work_order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    minimumSize: Size(double.infinity, w * 0.13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.add_rounded, size: 22),
                  label: const Text(
                    'Create Work Order',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    IconData icon;

    switch (status.toLowerCase().replaceAll('-', '_')) {
      case 'completed':
        bg = const Color(0xFF16A34A).withValues(alpha: 0.12);
        text = const Color(0xFF16A34A);
        icon = Icons.check_circle_rounded;
        break;
      case 'in_progress':
      case 'in-progress':
        bg = const Color(0xFF0284C7).withValues(alpha: 0.12);
        text = const Color(0xFF0284C7);
        icon = Icons.engineering_rounded;
        break;
      case 'assigned':
      case 'scheduled':
        bg = const Color(0xFFD97706).withValues(alpha: 0.12);
        text = const Color(0xFFD97706);
        icon = Icons.schedule_rounded;
        break;
      default: // request / open
        bg = const Color(0xFF2563EB).withValues(alpha: 0.12);
        text = const Color(0xFF2563EB);
        icon = Icons.pending_actions_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: text,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketStatCard(
    String count,
    String label,
    Color color,
    IconData icon,
    double w,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: w * 0.05,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
