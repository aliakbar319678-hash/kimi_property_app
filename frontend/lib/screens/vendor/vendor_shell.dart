import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/vendor_provider.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_dashboard_screen.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_work_orders_screen.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_find_jobs_screen.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_my_bids_screen.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_billing_screen.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_gps_checkin_screen.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_performance_screen.dart';
import 'package:tenant_and_landlord_application/screens/profile_screen.dart';

class VendorShell extends ConsumerStatefulWidget {
  final int initialIndex;

  const VendorShell({super.key, this.initialIndex = 0});

  @override
  ConsumerState<VendorShell> createState() => VendorShellState();
}

class VendorShellState extends ConsumerState<VendorShell> {
  late int _currentIndex;
  bool _isBiddingMode = false;
  Timer? _timer;

  final List<Widget> _pages = const [
    VendorDashboardScreen(), // 0
    VendorWorkOrdersScreen(), // 1
    VendorGpsCheckinScreen(), // 2
    VendorPerformanceScreen(), // 3
    VendorBillingScreen(), // 4
    VendorFindJobsScreen(), // 5
    VendorMyBidsScreen(), // 6
    ProfileScreen(), // 7
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    
    // Start global ticking timer for GPS Check-in Duration
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final state = ref.read(vendorProvider);
      if (state.checkedIn) {
        ref.read(vendorProvider.notifier).tickTimer();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void setBiddingMode(bool value, {int initialTab = 0}) {
    setState(() {
      _isBiddingMode = value;
      _currentIndex = initialTab;
    });
  }

  int get _indexedStackIndex {
    if (!_isBiddingMode) {
      return _currentIndex;
    } else {
      if (_currentIndex == 0) return 0;
      if (_currentIndex == 1) return 5;
      if (_currentIndex == 2) return 6;
      if (_currentIndex == 3) return 7;
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    final activeItems = [
      (Icons.dashboard_rounded, Icons.dashboard_outlined, 'Home'),
      (Icons.assignment_rounded, Icons.assignment_outlined, 'Jobs'),
      (Icons.location_on_rounded, Icons.location_on_outlined, 'GPS Checkin'),
      (Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Performance'),
      (Icons.account_balance_wallet_rounded, Icons.account_balance_wallet_outlined, 'Billing'),
    ];

    final biddingItems = [
      (Icons.home_rounded, Icons.home_outlined, 'Home'),
      (Icons.search_rounded, Icons.search_outlined, 'Find Jobs'),
      (Icons.gavel_rounded, Icons.gavel_outlined, 'My Bids'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
    ];

    final items = _isBiddingMode ? biddingItems : activeItems;

    return Scaffold(
      body: IndexedStack(
        index: _indexedStackIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: w * 0.18,
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final isSelected = i == _currentIndex;
            return GestureDetector(
              onTap: () {
                if (_isBiddingMode && i == 0) {
                  setBiddingMode(false, initialTab: 0);
                } else {
                  setState(() => _currentIndex = i);
                }
              },
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSelected ? items[i].$1 : items[i].$2,
                      size: w * 0.058,
                      color: isSelected ? AppColors.secondary : AppColors.textHint,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items[i].$3,
                      style: TextStyle(
                        fontSize: w * 0.025,
                        color: isSelected ? AppColors.secondary : AppColors.textHint,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
