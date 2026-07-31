import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class TenantPayRentScreen extends StatelessWidget {
  const TenantPayRentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(title: const Text('Pay Rent')),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(),
              const SizedBox(height: 30),
              const Text('Payment Method', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 20),
              _buildPaymentMethodSelector(context),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _showPaymentSuccessDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Pay Now', style: AppTextStyles.buttonText),
              ),
              const SizedBox(height: 40),
              const Text('Recent History', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 20),
              _buildHistoryList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Due', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 8),
          const Text('\$2,550.00', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const Divider(height: 30),
          _buildRow('Base Rent', '\$2,450.00'),
          const SizedBox(height: 8),
          _buildRow('Utilities', '\$100.00'),
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

  Widget _buildPaymentMethodSelector(BuildContext context) {
    return Column(
      children: [
        _paymentTile(Icons.credit_card, 'Credit/Debit Card', '**** 1234'),
        const SizedBox(height: 12),
        _paymentTile(Icons.account_balance, 'Bank Transfer', 'Add Bank Account'),
        const SizedBox(height: 12),
        _paymentTile(Icons.apple, 'Apple/Google Pay', 'Setup Digital Wallet'),
      ],
    );
  }

  Widget _paymentTile(IconData icon, String title, String subtitle) {
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
          Icon(icon, color: AppColors.primary),
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
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textHint),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
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
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.green),
            ),
            title: const Text('Rent Payment - Sep 2024', style: AppTextStyles.labelMedium, overflow: TextOverflow.ellipsis),
            subtitle: const Text('Sep 1, 2024', style: AppTextStyles.bodySmall),
            trailing: const Icon(Icons.download, color: AppColors.secondary),
          ),
        );
      },
    );
  }

  void _showPaymentSuccessDialog(BuildContext context) {
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
              const Text(
                'Your payment of \$2,550.00 has been processed successfully.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context); // Go back if possible
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
