import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/tenant_lease_provider.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';

class TenantPayRentScreen extends ConsumerStatefulWidget {
  const TenantPayRentScreen({super.key});

  @override
  ConsumerState<TenantPayRentScreen> createState() => _TenantPayRentScreenState();
}

class _TenantPayRentScreenState extends ConsumerState<TenantPayRentScreen> {
  bool _isPaying = false;
  String _selectedMethod = 'card';

  Future<void> _payRent(String leaseId, double amount) async {
    if (leaseId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot pay rent without an active lease.')),
      );
      return;
    }

    setState(() => _isPaying = true);
    try {
      final resp = await ApiClient().dio.post(
        ApiConstants.initiatePayment,
        data: {
          'leaseId': leaseId,
          'amount': amount,
          'paymentMethod': _selectedMethod,
        },
      );

      if (resp.data != null && resp.data['success'] == true) {
        if (mounted) {
          _showPaymentSuccessDialog(context, amount);
          ref.refresh(tenantFinanceProvider);
        }
      } else {
        throw Exception(resp.data?['error'] ?? 'Initiation failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final leaseAsync = ref.watch(tenantLeaseProvider);
    final financeAsync = ref.watch(tenantFinanceProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(title: const Text('Pay Rent')),
      body: SafeArea(
        child: leaseAsync.when(
          data: (lease) {
            if (lease.leaseId.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No active lease found. Rent payment is unavailable.',
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
                  _buildBalanceCard(lease.rentAmount),
                  const SizedBox(height: 30),
                  const Text('Payment Method', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 20),
                  _buildPaymentMethodSelector(),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isPaying ? null : () => _payRent(lease.leaseId, lease.rentAmount),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isPaying
                        ? const CircularProgressIndicator(color: AppColors.white)
                        : const Text('Pay Now', style: AppTextStyles.buttonText),
                  ),
                  const SizedBox(height: 40),
                  const Text('Recent History', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 20),
                  financeAsync.when(
                    data: (finance) {
                      final List<dynamic> transactions = finance['transactions'] ?? [];
                      if (transactions.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No recent transaction history.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        );
                      }
                      return _buildHistoryList(transactions);
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Text('History error: $err', style: const TextStyle(color: AppColors.error)),
                  ),
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

  Widget _buildBalanceCard(double rentAmount) {
    return Container(
      width: double.infinity,
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
          const Text('Total Due', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 8),
          Text(
            '\$${rentAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const Divider(height: 30),
          _buildRow('Base Rent', '\$${rentAmount.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      children: [
        _paymentTile(Icons.credit_card, 'Credit/Debit Card', 'Default Payment Method', 'card'),
        const SizedBox(height: 12),
        _paymentTile(Icons.account_balance, 'Bank Transfer', 'Direct ACH transfer', 'ach'),
      ],
    );
  }

  Widget _paymentTile(IconData icon, String title, String subtitle, String value) {
    final isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textHint),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelMedium, overflow: TextOverflow.ellipsis),
                  Text(subtitle, style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<dynamic> transactions) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index] as Map<String, dynamic>;
        final typeStr = tx['type']?.toString().toUpperCase() ?? 'PAYMENT';
        final statusStr = tx['status']?.toString().toUpperCase() ?? 'COMPLETED';
        final amount = (tx['amount'] ?? 0.0) is num
            ? (tx['amount'] as num).toDouble()
            : double.tryParse(tx['amount'].toString()) ?? 0.0;
        final dateStr = tx['created_at'] != null
            ? tx['created_at'].toString().split('T').first
            : 'Recent';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusStr == 'COMPLETED' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                statusStr == 'COMPLETED' ? Icons.check : Icons.access_time,
                color: statusStr == 'COMPLETED' ? Colors.green : Colors.orange,
              ),
            ),
            title: Text('$typeStr - $statusStr', style: AppTextStyles.labelMedium, overflow: TextOverflow.ellipsis),
            subtitle: Text(dateStr, style: AppTextStyles.bodySmall),
            trailing: Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  void _showPaymentSuccessDialog(BuildContext context, double amount) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
              ),
              const SizedBox(height: 20),
              const Text('Payment Successful!', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Your payment of \$${amount.toStringAsFixed(2)} has been processed successfully.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Done', style: AppTextStyles.buttonText),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
