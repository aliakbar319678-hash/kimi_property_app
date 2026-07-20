import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/payment_maintenance_provider.dart';
import 'package:tenant_and_landlord_application/provider/tenant_lease_provider.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_bottom_navigation_bar.dart';

class RequestTrackingScreen extends ConsumerWidget {
  const RequestTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(requestTrackingProvider);
    final workOrdersAsync = ref.watch(tenantWorkOrdersProvider);
    final workOrders = workOrdersAsync.asData?.value ?? [];
    final openCount = workOrders.where((wo) {
      final s = (wo['status'] ?? '').toString().toLowerCase();
      return s == 'open' || s == 'request' || s == 'assigned' || s == 'in-progress';
    }).length;
    final now = DateTime.now();
    final thisMonthCount = workOrders.where((wo) {
      final created = wo['created_at']?.toString() ?? '';
      try {
        final d = DateTime.parse(created);
        return d.month == now.month && d.year == now.year;
      } catch (_) {
        return false;
      }
    }).length;
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
                  CircleAvatar(
                    radius: w * 0.048,
                    backgroundImage: const NetworkImage(
                      'https://i.pravatar.cc/100?img=3',
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
                      'My Requests',
                      style: TextStyle(
                        fontSize: w * 0.07,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: h * 0.005),
                    Text(
                      'Track the progress of your maintenance and service requests.',
                      style: TextStyle(
                        fontSize: w * 0.033,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: h * 0.02),

                    // In Progress request
                    Container(
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
                      padding: EdgeInsets.all(pad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Leak - In\nProgress',
                                style: TextStyle(
                                  fontSize: w * 0.045,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  height: 1.2,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.025,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'URGENT',
                                  style: TextStyle(
                                    fontSize: w * 0.028,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.red,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: h * 0.006),
                          Text(
                            'Request ID: #MT-8291 • Submitted Oct 24, 2023',
                            style: TextStyle(
                              fontSize: w * 0.029,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: h * 0.006),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'View Details >',
                              style: TextStyle(
                                fontSize: w * 0.033,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                          SizedBox(height: h * 0.02),

                          // Progress stepper
                          _ProgressStepper(
                            steps: const [
                              ('Requested', 'Oct 24, 09:15 AM', true),
                              ('Assigned', 'Oct 24, 11:30 AM', true),
                              ('Completed', 'Estimated: Today', false),
                            ],
                            w: w,
                          ),

                          SizedBox(height: h * 0.018),

                          // Technician card
                          Container(
                            padding: EdgeInsets.all(w * 0.035),
                            decoration: BoxDecoration(
                              color: AppColors.inputBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: w * 0.07,
                                  backgroundImage: const NetworkImage(
                                    'https://i.pravatar.cc/100?img=12',
                                  ),
                                ),
                                SizedBox(width: w * 0.03),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Brian Henderson assigned to your request',
                                        style: TextStyle(
                                          fontSize: w * 0.033,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '"I\'m on my way to check the bathroom sink leak. Should be there in about 20 minutes."',
                                        style: TextStyle(
                                          fontSize: w * 0.03,
                                          color: AppColors.textSecondary,
                                          height: 1.4,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.018),

                    // Summary dark card + New Request
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.all(pad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Summary',
                            style: TextStyle(
                              fontSize: w * 0.03,
                              color: AppColors.white.withValues(alpha: 0.6),
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: h * 0.012),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Open Requests',
                                style: TextStyle(
                                  fontSize: w * 0.036,
                                  color: AppColors.white,
                                ),
                              ),
                              Text(
                                '$openCount',
                                style: TextStyle(
                                  fontSize: w * 0.036,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: h * 0.008),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'This Month',
                                style: TextStyle(
                                  fontSize: w * 0.036,
                                  color: AppColors.white,
                                ),
                              ),
                              Text(
                                '$thisMonthCount',
                                style: TextStyle(
                                  fontSize: w * 0.036,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: h * 0.02),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/maintenance_request',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                  vertical: h * 0.016,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'New Request',
                                style: TextStyle(
                                  fontSize: w * 0.038,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.018),

                    // Support Articles
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.04),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(pad * 0.9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Support Articles',
                            style: TextStyle(
                              fontSize: w * 0.036,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: h * 0.012),
                          _ArticleRow('How to handle emergency leaks', w),
                          SizedBox(height: h * 0.01),
                          _ArticleRow('AC maintenance tips', w),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.02),

                    // Completed request
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
                      padding: EdgeInsets.all(pad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'AC Issue -\nCompleted',
                                style: TextStyle(
                                  fontSize: w * 0.045,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  height: 1.2,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.025,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.inputBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'ROUTINE',
                                  style: TextStyle(
                                    fontSize: w * 0.028,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: h * 0.006),
                          Text(
                            'Request ID: #MT-7952 • Completed Oct 12, 2023',
                            style: TextStyle(
                              fontSize: w * 0.029,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: h * 0.006),
                          Row(
                            children: [
                              Icon(
                                Icons.history_rounded,
                                size: w * 0.035,
                                color: AppColors.textHint,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'View History',
                                style: TextStyle(
                                  fontSize: w * 0.031,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: h * 0.018),

                          _ProgressStepper(
                            steps: const [
                              ('Requested', '', true),
                              ('Assigned', '', true),
                              ('Completed', 'Oct 12, 04:00 PM', true),
                            ],
                            w: w,
                            allDone: true,
                          ),

                          SizedBox(height: h * 0.018),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: const Color(0xFFF39C12),
                                size: w * 0.05,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'You rated this service\n5/5 stars',
                                style: TextStyle(
                                  fontSize: w * 0.03,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  'View\nInvoice',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: w * 0.031,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
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
      bottomNavigationBar: const TLBottomNav(selectedIndex: 3),
    );
  }
}

class _ProgressStepper extends StatelessWidget {
  final List<(String, String, bool)> steps;
  final double w;
  final bool allDone;

  const _ProgressStepper({
    required this.steps,
    required this.w,
    this.allDone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final isLast = i == steps.length - 1;
        final isDone = step.$3;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: w * 0.1,
                      height: w * 0.1,
                      decoration: BoxDecoration(
                        color: isDone ? AppColors.secondary : AppColors.inputBg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDone
                              ? AppColors.secondary
                              : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        allDone || isDone
                            ? Icons.check_rounded
                            : Icons.person_outline_rounded,
                        size: w * 0.045,
                        color: isDone ? AppColors.white : AppColors.textHint,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      step.$1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: w * 0.028,
                        fontWeight: FontWeight.w600,
                        color: isDone
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                    ),
                    if (step.$2.isNotEmpty)
                      Text(
                        step.$2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: w * 0.025,
                          color: AppColors.textHint,
                        ),
                      ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: EdgeInsets.only(bottom: w * 0.12),
                    color: isDone ? AppColors.secondary : AppColors.border,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _ArticleRow extends StatelessWidget {
  final String text;
  final double w;
  const _ArticleRow(this.text, this.w);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.menu_book_outlined,
          size: w * 0.04,
          color: AppColors.secondary,
        ),
        SizedBox(width: w * 0.025),
        Text(
          text,
          style: TextStyle(
            fontSize: w * 0.033,
            color: AppColors.secondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
