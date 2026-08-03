import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_user_avatar.dart';
import 'package:tenant_and_landlord_application/provider/payment_maintenance_provider.dart';
import 'package:tenant_and_landlord_application/provider/tenant_lease_provider.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(paymentHistoryProvider);
    final leaseAsync = ref.watch(tenantLeaseProvider);
    final financeAsync = ref.watch(tenantFinanceProvider);
    final lease = leaseAsync.asData?.value ?? TenantLeaseData.empty();
    final finance = financeAsync.asData?.value ?? {};
    final totalPaidRaw = finance['total_collected'] ?? finance['totalCollected'] ?? 0;
    final totalPaid = totalPaidRaw is num ? totalPaidRaw.toDouble() : double.tryParse(totalPaidRaw.toString()) ?? 0.0;
    final totalPaidDisplay = totalPaid > 0
        ? '\$${totalPaid.toStringAsFixed(2)}'
        : '\$0.00';
    final rentDisplay = lease.rentAmount > 0
        ? '\$${lease.rentAmount.toStringAsFixed(2)}'
        : '\$—';
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
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
                  TLUserAvatar(radius: w * 0.048),
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
                      'Payment History',
                      style: TextStyle(
                        fontSize: w * 0.07,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: h * 0.005),
                    Text(
                      'Review and manage your past rental transactions.',
                      style: TextStyle(
                        fontSize: w * 0.033,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: h * 0.02),

                    // Total paid card
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/lease_summary'),
                      child: Container(
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
                            Text(
                              'TOTAL PAID (YEAR TO DATE)',
                              style: TextStyle(
                                fontSize: w * 0.028,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: h * 0.008),
                            Text(
                              totalPaidDisplay,
                              style: TextStyle(
                                fontSize: w * 0.1,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: h * 0.01),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: w * 0.04,
                                  color: AppColors.secondary,
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'All payments processed successfully via ACH Transfer.',
                                    style: TextStyle(
                                      fontSize: w * 0.031,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.018),

                    // Next payment dark card
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/pay_rent'),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(pad * 1.1),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.wallet_outlined,
                              size: w * 0.1,
                              color: AppColors.white.withValues(alpha: 0.5),
                            ),
                            SizedBox(height: h * 0.008),
                            Text(
                              'Next Payment Due',
                              style: TextStyle(
                                fontSize: w * 0.033,
                                color: AppColors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              'July 1, 2024',
                              style: TextStyle(
                                fontSize: w * 0.06,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                            Text(
                              'Amount: $rentDisplay',
                              style: TextStyle(
                                fontSize: w * 0.033,
                                color: AppColors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.025),

                    // Payment rows
                    if (finance['recentActivity'] != null && finance['recentActivity'] is List && (finance['recentActivity'] as List).isNotEmpty)
                      ...(finance['recentActivity'] as List).map((p) {
                        final amt = p['amount_paid'] ?? p['amount_due'] ?? 0;
                        final isLate = p['status'] == 'late';
                        return Padding(
                          padding: EdgeInsets.only(bottom: h * 0.015),
                          child: _PaymentRow(
                            month: 'Rent Payment',
                            date: p['created_at'] != null ? 'Paid on ${p['created_at'].toString().split('T')[0]}' : 'Unknown date',
                            amount: '\$${double.parse(amt.toString()).toStringAsFixed(2)}',
                            status: (p['status'] ?? 'paid').toString().toUpperCase(),
                            isLate: isLate,
                            iconColor: isLate ? const Color(0xFFE74C3C) : AppColors.secondary,
                            iconBg: isLate ? const Color(0xFFE74C3C).withValues(alpha: 0.1) : AppColors.secondary.withValues(alpha: 0.1),
                            w: w,
                            h: h,
                          ),
                        );
                      })
                    else
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No recent transactions.'),
                      ),

                    SizedBox(height: h * 0.025),

                    // Support card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(pad),
                      decoration: BoxDecoration(
                        color: AppColors.inputBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Questions about a transaction?',
                            style: TextStyle(
                              fontSize: w * 0.04,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: h * 0.008),
                          Text(
                            'Our support team is here to help you with any billing discrepancies or payment issues.',
                            style: TextStyle(
                              fontSize: w * 0.032,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: h * 0.012),
                          GestureDetector(
                            onTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Billing Support...'))); },
                            child: Text(
                              'Contact Billing Support →',
                              style: TextStyle(
                                fontSize: w * 0.034,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
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
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String month, date, amount, status;
  final bool isLate;
  final Color iconColor, iconBg;
  final double w, h;

  const _PaymentRow({
    required this.month,
    required this.date,
    required this.amount,
    required this.status,
    required this.isLate,
    required this.iconColor,
    required this.iconBg,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: w * 0.12,
            height: w * 0.12,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(
              isLate
                  ? Icons.warning_amber_rounded
                  : Icons.calendar_today_outlined,
              size: w * 0.055,
              color: iconColor,
            ),
          ),
          SizedBox(width: w * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: TextStyle(
                    fontSize: w * 0.038,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: w * 0.029,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: h * 0.008),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.w700,
                    color: isLate
                        ? const Color(0xFFE74C3C)
                        : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.025,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isLate
                        ? const Color(0xFFE74C3C).withValues(alpha: 0.1)
                        : const Color(0xFF27AE60).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLate
                            ? Icons.error_outline_rounded
                            : Icons.check_circle_outline_rounded,
                        size: w * 0.032,
                        color: isLate
                            ? const Color(0xFFE74C3C)
                            : const Color(0xFF27AE60),
                      ),
                      SizedBox(width: 3),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: w * 0.028,
                          fontWeight: FontWeight.w600,
                          color: isLate
                              ? const Color(0xFFE74C3C)
                              : const Color(0xFF27AE60),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading Statement...'))); },
            icon: Icon(
              Icons.download_outlined,
              size: w * 0.038,
              color: AppColors.secondary,
            ),
            label: Text(
              'Download\nReceipt',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: w * 0.028, color: AppColors.secondary),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.025,
                vertical: h * 0.01,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
