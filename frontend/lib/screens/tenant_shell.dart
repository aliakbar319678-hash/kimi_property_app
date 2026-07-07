import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/screens/chat_list_screen.dart';
import 'package:tenant_and_landlord_application/screens/home_dashboard_screen.dart';
import 'package:tenant_and_landlord_application/screens/payment_history_screen.dart';
import 'package:tenant_and_landlord_application/screens/profile_screen.dart';
import 'package:tenant_and_landlord_application/screens/search_screen.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_bottom_navigation_bar.dart';

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

  // Keep all pages alive while navigating between tabs
  final List<Widget> _pages = const [
    HomeDashboardScreen(),
    SearchScreen(),
    PaymentHistoryScreen(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: TLBottomNav(
        selectedIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
