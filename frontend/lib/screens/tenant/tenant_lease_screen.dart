import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/tenant_lease_provider.dart';

class TenantLeaseScreen extends ConsumerWidget {
  const TenantLeaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final leaseAsync = ref.watch(tenantLeaseProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(title: const Text('My Lease')),
      body: SafeArea(
        child: leaseAsync.when(
          data: (lease) {
            if (lease.leaseId.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No active lease found.',
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lease.propertyName, style: AppTextStyles.headlineMedium),
                        const SizedBox(height: 4),
                        Text('Unit ${lease.unitName}', style: const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        _buildDetailRow('Start Date', lease.startDate.isNotEmpty ? lease.startDate.split('T').first : 'N/A'),
                        _buildDetailRow('End Date', lease.endDate.isNotEmpty ? lease.endDate.split('T').first : 'N/A'),
                        _buildDetailRow('Monthly Rent', '\$${lease.rentAmount.toStringAsFixed(2)}'),
                        _buildDetailRow('Deposit Amount', '\$${lease.securityDeposit.toStringAsFixed(2)}'),
                        _buildDetailRow('Status', lease.status.toUpperCase()),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              lease.status.toLowerCase() == 'active' ? Icons.verified : Icons.info,
                              color: lease.status.toLowerCase() == 'active' ? Colors.green : Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              lease.status.toLowerCase() == 'active' ? 'Lease Active' : 'Lease Pending/Expired',
                              style: TextStyle(
                                color: lease.status.toLowerCase() == 'active' ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text('Documents', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 20),
                  _buildDocTile('Lease_Agreement_${lease.leaseId.substring(0, 5)}.pdf', 'Generated dynamically'),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocTile(String title, String size) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: AppColors.error, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelMedium, overflow: TextOverflow.ellipsis),
                Text(size, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.download, color: AppColors.secondary),
        ],
      ),
    );
  }
}
