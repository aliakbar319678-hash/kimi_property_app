import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/payment_maintenance_provider.dart';
import 'package:tenant_and_landlord_application/provider/payment_maintenance_state.dart';
import 'package:tenant_and_landlord_application/provider/tenant_lease_provider.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_bottom_navigation_bar.dart';

class PayRentScreen extends ConsumerWidget {
  const PayRentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(payRentProvider);
    final notif = ref.read(payRentProvider.notifier);
    final leaseAsync = ref.watch(tenantLeaseProvider);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    // Extract lease data once available
    final lease = leaseAsync.asData?.value ?? TenantLeaseData.empty();
    final rentAmount = lease.rentAmount;
    final rentDisplay = rentAmount > 0
        ? '\$${rentAmount.toStringAsFixed(0)}'
        : '\$—';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Container(
              color: AppColors.white,
              padding: EdgeInsets.symmetric(
                horizontal: pad,
                vertical: h * 0.015,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.menu_rounded,
                    size: w * 0.06,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(width: w * 0.03),
                  Icon(
                    Icons.apartment_rounded,
                    size: w * 0.048,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: w * 0.015),
                  Text(
                    'T&L',
                    style: TextStyle(
                      fontSize: w * 0.046,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: w * 0.048,
                    backgroundImage: const NetworkImage(
                      'https://i.pravatar.cc/100?img=8',
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pay Rent',
                      style: TextStyle(
                        fontSize: w * 0.07,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: h * 0.005),
                    Text(
                      'Manage your monthly rent payment securely.',
                      style: TextStyle(
                        fontSize: w * 0.033,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: h * 0.02),

                    // Amount card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(pad),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border(
                          left: BorderSide(
                            color: AppColors.secondary,
                            width: 3,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'AMOUNT DUE',
                                style: TextStyle(
                                  fontSize: w * 0.028,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                  letterSpacing: 1,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.03,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Monthly Rent',
                                  style: TextStyle(
                                    fontSize: w * 0.028,
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: h * 0.008),
                          Text(
                            rentDisplay,
                            style: TextStyle(
                              fontSize: w * 0.14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: h * 0.008),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: w * 0.038,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Due Date: June 1',
                                style: TextStyle(
                                  fontSize: w * 0.034,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Divider(color: AppColors.border, height: h * 0.03),
                          _AmountRow(
                            'Base Rent',
                            rentAmount > 0 ? '\$${rentAmount.toStringAsFixed(2)}' : '\$—',
                            w,
                            isBold: false,
                          ),
                          SizedBox(height: h * 0.008),
                          _AmountRow(
                            'Utilities (Fixed)',
                            '\$0.00',
                            w,
                            isBold: false,
                          ),
                          Divider(color: AppColors.border, height: h * 0.025),
                          _AmountRow(
                            'Total Payable',
                            rentAmount > 0 ? '\$${rentAmount.toStringAsFixed(2)}' : '\$—',
                            w,
                            isBold: true,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.018),

                    // Promo card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(pad),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Modern Living @ Heights',
                                  style: TextStyle(
                                    fontSize: w * 0.038,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Your lease is in good standing. Making on-time payments helps build your internal tenant credit score.',
                                  style: TextStyle(
                                    fontSize: w * 0.029,
                                    color: AppColors.white.withValues(alpha: 0.7),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.apartment_rounded,
                            size: w * 0.15,
                            color: AppColors.white.withValues(alpha: 0.15),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.025),

                    Text(
                      'Select Payment Method',
                      style: TextStyle(
                        fontSize: w * 0.042,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: h * 0.015),

                    // Payment methods
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _PaymentMethodTile(
                            icon: Icons.account_balance_outlined,
                            title: 'Bank Account (ACH)',
                            subtitle:
                                'Direct transfer from your checking account. No fees.',
                            method: PaymentMethod.bankACH,
                            selected: state.selectedMethod,
                            onTap: () =>
                                notif.selectMethod(PaymentMethod.bankACH),
                            w: w,
                            h: h,
                          ),
                          Divider(
                            height: 1,
                            color: AppColors.border,
                            indent: w * 0.15,
                          ),
                          _PaymentMethodTile(
                            icon: Icons.swap_horiz_rounded,
                            title: 'E-Transfer',
                            subtitle:
                                'Send via secure email portal. 24-48 hours processing.',
                            method: PaymentMethod.eTransfer,
                            selected: state.selectedMethod,
                            onTap: () =>
                                notif.selectMethod(PaymentMethod.eTransfer),
                            w: w,
                            h: h,
                          ),
                          Divider(
                            height: 1,
                            color: AppColors.border,
                            indent: w * 0.15,
                          ),
                          _PaymentMethodTile(
                            icon: Icons.credit_card_outlined,
                            title: 'Credit or Debit Card',
                            subtitle:
                                '2.9% processing fee applies. Instant confirmation.',
                            method: PaymentMethod.creditCard,
                            selected: state.selectedMethod,
                            onTap: () =>
                                notif.selectMethod(PaymentMethod.creditCard),
                            w: w,
                            h: h,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.025),

                    // Pay Now button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                         onPressed: state.isLoading
                             ? null
                             : () async {
                                 try {
                                   final success = await notif.payNow(
                                     leaseId: lease.leaseId,
                                     amount: lease.rentAmount,
                                   );
                                   if (success && context.mounted) {
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       const SnackBar(
                                         content: Text('Payment submitted successfully!'),
                                         backgroundColor: Colors.green,
                                       ),
                                     );
                                   } else if (!success && context.mounted) {
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       const SnackBar(
                                         content: Text('No active lease found. Cannot process payment.'),
                                         backgroundColor: AppColors.error,
                                       ),
                                     );
                                   }
                                 } catch (e) {
                                   if (context.mounted) {
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       SnackBar(
                                         content: Text(e.toString().replaceFirst('Exception: ', '')),
                                         backgroundColor: AppColors.error,
                                       ),
                                     );
                                   }
                                 }
                               },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: h * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: state.isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Pay Now',
                                    style: TextStyle(
                                      fontSize: w * 0.042,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: AppColors.white,
                                    size: w * 0.045,
                                  ),
                                ],
                              ),
                      ),
                    ),

                    SizedBox(height: h * 0.01),
                    Text(
                      'By clicking Pay Now, you authorize T&L to initiate a payment of $rentDisplay.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: w * 0.029,
                        color: AppColors.textHint,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: h * 0.025),

                    // Security badges
                    ...[
                      (Icons.security_outlined, '256-bit SSL Secure'),
                      (Icons.verified_outlined, 'Verified Payments'),
                      (Icons.shield_outlined, 'Data Protected'),
                    ].map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: h * 0.012),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.$1,
                              size: w * 0.04,
                              color: AppColors.textHint,
                            ),
                            SizedBox(width: w * 0.02),
                            Text(
                              item.$2,
                              style: TextStyle(
                                fontSize: w * 0.032,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.03),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const TLBottomNav(selectedIndex: 2),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final double w;
  final bool isBold;
  const _AmountRow(this.label, this.value, this.w, {required this.isBold});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: w * 0.035,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: w * 0.035,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final PaymentMethod method;
  final PaymentMethod selected;
  final VoidCallback onTap;
  final double w, h;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.method,
    required this.selected,
    required this.onTap,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = method == selected;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(w * 0.04),
        child: Row(
          children: [
            Container(
              width: w * 0.07,
              height: w * 0.07,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.secondary : AppColors.border,
                  width: isSelected ? 2.5 : 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: w * 0.035,
                        height: w * 0.035,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: w * 0.03),
            Container(
              width: w * 0.1,
              height: w * 0.1,
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: w * 0.05, color: AppColors.secondary),
            ),
            SizedBox(width: w * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: w * 0.036,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: w * 0.029,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.secondary,
                size: w * 0.055,
              ),
          ],
        ),
      ),
    );
  }
}
