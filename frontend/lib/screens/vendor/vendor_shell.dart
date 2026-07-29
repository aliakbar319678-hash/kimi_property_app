import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/vendor_provider.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_work_orders_screen.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_my_bids_screen.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_billing_screen.dart';
import 'package:tenant_and_landlord_application/screens/profile_screen.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_bottom_navigation_bar.dart';

class VendorShell extends ConsumerStatefulWidget {
  final int initialIndex;

  const VendorShell({super.key, this.initialIndex = 0});

  @override
  ConsumerState<VendorShell> createState() => VendorShellState();
}

class VendorShellState extends ConsumerState<VendorShell> {
  late int _currentIndex;
  Timer? _timer;

  final List<Widget> _pages = const [
    VendorWorkOrdersScreen(),
    VendorMyBidsScreen(),
    VendorBillingScreen(),
    ProfileScreen(),
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

  @override
  Widget build(BuildContext context) {
    final vendorItems = const [
      (Icons.assignment_rounded, Icons.assignment_outlined, 'Work Orders'),
      (Icons.gavel_rounded, Icons.gavel_outlined, 'Bids'),
      (Icons.account_balance_wallet_rounded, Icons.account_balance_wallet_outlined, 'Earnings'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: TLBottomNav(
        selectedIndex: _currentIndex,
        items: vendorItems,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
