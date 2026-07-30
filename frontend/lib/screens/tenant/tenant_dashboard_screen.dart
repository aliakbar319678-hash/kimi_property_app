import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_user_avatar.dart';
import 'package:tenant_and_landlord_application/provider/tenant_lease_provider.dart';
import 'package:intl/intl.dart';

class TenantDashboardScreen extends ConsumerWidget {
  const TenantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final leaseAsync = ref.watch(tenantLeaseProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('My Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: TLUserAvatar(radius: 18),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Welcome back!', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 20),
              leaseAsync.when(
                data: (lease) {
                  if (lease.leaseId.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.info_outline, size: 40, color: AppColors.textHint),
                          SizedBox(height: 12),
                          Text(
                            'No Active Lease Found',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'When you sign a lease, it will appear here.',
                            style: TextStyle(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  return _buildActiveLeaseCard(lease);
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(
                    'Failed to load active lease details: $err',
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text('Quick Actions', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildActionCard(context, Icons.payment, 'Pay Rent', '/tenant_pay_rent'),
                  _buildActionCard(context, Icons.build, 'Report Issue', '/tenant_create_ticket'),
                  _buildActionCard(context, Icons.description, 'My Lease', '/tenant_lease'),
                  _buildActionCard(context, Icons.favorite, 'Saved Homes', '/tenant_saved_properties'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveLeaseCard(TenantLeaseData lease) {
    String formattedDueDate = 'TBD';
    try {
      if (lease.startDate.isNotEmpty) {
        final startDt = DateTime.tryParse(lease.startDate);
        if (startDt != null) {
          final now = DateTime.now();
          final nextDue = DateTime(now.year, now.month, 1);
          formattedDueDate = DateFormat('MMM dd, yyyy').format(
            nextDue.isBefore(now) ? DateTime(now.year, now.month + 1, 1) : nextDue,
          );
        }
      }
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
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
              Expanded(
                child: Text(
                  '${lease.propertyName} - Unit ${lease.unitName}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  lease.status.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Next Rent Due: $formattedDueDate',
            style: const TextStyle(color: AppColors.white, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${lease.rentAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
