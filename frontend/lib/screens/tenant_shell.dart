import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/screens/home_dashboard_screen.dart';
import 'package:tenant_and_landlord_application/screens/profile_screen.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_bottom_navigation_bar.dart';

import 'package:tenant_and_landlord_application/screens/tenant/tenant_dashboard_screen.dart';
import 'package:tenant_and_landlord_application/screens/tenant/tenant_pay_rent_screen.dart';
import 'package:tenant_and_landlord_application/screens/tenant/tenant_create_ticket_screen.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tenant_and_landlord_application/screens/tenant/tenant_saved_properties_screen.dart';

/// Main shell that wraps the 5 primary tenant tabs:
/// Home | Search | Payments | Chat | Profile
class TenantShell extends StatefulWidget {
  /// Pass an initial tab index (0-4) to deep-link to a specific tab.
  final int initialIndex;

  const TenantShell({super.key, this.initialIndex = 0});

  @override
  State<TenantShell> createState() => _TenantShellState();
}

class _TenantShellState extends State<TenantShell> {
  late int _currentIndex;
  bool _isGuest = false;
  bool _isLoading = true;

  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _checkGuestStatus();

    _statusTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!mounted || _isGuest) return;
      try {
        final res = await ApiClient().dio.get('/auth/me');
        if (res.statusCode == 200 && mounted) {
          final data = res.data['data'];
          if (data['kyc_status'] == 'suspended' || data['is_active'] == false) {
            _statusTimer?.cancel();
            Navigator.pushNamedAndRemoveUntil(context, '/account_suspended', (r) => false);
          }
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkGuestStatus() async {
    final token = await const FlutterSecureStorage().read(key: 'auth_token');
    if (mounted) {
      setState(() {
        _isGuest = token == null || token.isEmpty;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tenantItems = const [
      (Icons.home_rounded, Icons.home_outlined, 'Home'),
      (Icons.search_rounded, Icons.search_outlined, 'Search'),
      (Icons.payment_rounded, Icons.payment_outlined, 'Pay Rent'),
      (Icons.build_rounded, Icons.build_outlined, 'Tickets'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
    ];

    final guestItems = const [
      (Icons.search_rounded, Icons.search_outlined, 'Explore'),
      (Icons.favorite_rounded, Icons.favorite_border_rounded, 'Saved'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Login'),
    ];

    final tenantPages = const [
      TenantDashboardScreen(),
      HomeDashboardScreen(), 
      TenantPayRentScreen(),
      TenantCreateTicketScreen(),
      ProfileScreen(),
    ];

    final guestPages = const [
      HomeDashboardScreen(),
      TenantSavedPropertiesScreen(),
      ProfileScreen(),
    ];

    final currentItems = _isGuest ? guestItems : tenantItems;
    final currentPages = _isGuest ? guestPages : tenantPages;

    final safeIndex = _currentIndex < currentItems.length ? _currentIndex : 0;

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: currentPages),
      bottomNavigationBar: TLBottomNav(
        selectedIndex: safeIndex,
        items: currentItems,
        onTap: (index) {
          if (_isGuest && index == 2) {
            // Prompt login directly if clicking Login/Profile tab
            Navigator.pushNamed(context, '/login', arguments: {'role': 'Tenant'});
            return;
          }
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
