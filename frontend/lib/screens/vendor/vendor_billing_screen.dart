import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/vendor_provider.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_appbar.dart';
import 'package:tenant_and_landlord_application/provider/vendor_state.dart';
class VendorBillingScreen extends ConsumerWidget {
  const VendorBillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vendorProvider);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: TLAppBar(
        title: 'Billing & Payments',
        leading: Icon(
          Icons.menu_rounded,
          size: w * 0.065,
          color: AppColors.textPrimary,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Earnings Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(pad),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL EARNINGS',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: w * 0.028,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${state.earnings.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: w * 0.08,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_upward_rounded, color: Colors.greenAccent, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '+18% from last month',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: w * 0.028,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: h * 0.02),

              // Pending / Completed Row
              Row(
                children: [
                  Expanded(
                    child: _buildSplitCard(
                      label: 'Pending Payouts',
                      value: '\$${state.pendingPayments.toStringAsFixed(0)}',
                      icon: Icons.hourglass_empty_rounded,
                      color: Colors.orange,
                      width: w,
                    ),
                  ),
                  SizedBox(width: w * 0.04),
                  Expanded(
                    child: _buildSplitCard(
                      label: 'Completed Payouts',
                      value: '\$${state.completedPayments.toStringAsFixed(0)}',
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xFF2E7D32),
                      width: w,
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.025),

              // Quick Actions
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: w * 0.042,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: h * 0.012),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: 'Deposit Earnings',
                      icon: Icons.account_balance_wallet_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payout requested. Transferred in 2-3 business days.')),
                        );
                      },
                      w: w,
                    ),
                  ),
                  SizedBox(width: w * 0.03),
                  Expanded(
                    child: _buildActionButton(
                      label: 'Stats & Info',
                      icon: Icons.bar_chart_rounded,
                      onTap: () {
                        Navigator.pushNamed(context, '/vendor_performance');
                      },
                      w: w,
                    ),
                  ),
                  SizedBox(width: w * 0.03),
                  Expanded(
                    child: _buildActionButton(
                      label: 'Bank Details',
                      icon: Icons.payment_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Direct Deposit: ${state.profile.bankName.isEmpty ? "Chase Bank" : state.profile.bankName}')),
                        );
                      },
                      w: w,
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.025),

              // Payment History List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment History',
                    style: TextStyle(
                      fontSize: w * 0.042,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: w * 0.032,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.012),
              
              if (state.payments.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(pad),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'No invoices found.',
                      style: TextStyle(
                        fontSize: w * 0.035,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: state.payments.map((p) {
                    return _buildPaymentRow(p, w, h);
                  }).toList(),
                ),
              SizedBox(height: h * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required double width,
  }) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: width * 0.04),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: width * 0.028,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: width * 0.052,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required double w,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: w * 0.04, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.secondary, size: w * 0.055),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: w * 0.028,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(VendorPayment p, double w, double h) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_downward_rounded, color: Color(0xFF2E7D32), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.jobTitle,
                  style: TextStyle(
                    fontSize: w * 0.035,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${p.invoiceNumber} • ${p.date}',
                  style: TextStyle(
                    fontSize: w * 0.028,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+\$${p.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: w * 0.038,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  p.status,
                  style: TextStyle(
                    color: const Color(0xFF2E7D32),
                    fontSize: w * 0.024,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
