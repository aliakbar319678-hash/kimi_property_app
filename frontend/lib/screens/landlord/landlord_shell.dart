import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/screens/landlord/portfolio_dashboard_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/property_portfolio_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/tenant_directory_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/maintenance_dashboard_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/landlord_profile_screen.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class LandlordShell extends StatefulWidget {
  final int initialIndex;

  const LandlordShell({super.key, this.initialIndex = 0});

  @override
  State<LandlordShell> createState() => _LandlordShellState();
}

class _LandlordShellState extends State<LandlordShell> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    PortfolioDashboardScreen(),
    PropertyPortfolioScreen(),
    TenantDirectoryScreen(),
    MaintenanceDashboardScreen(),
    LandlordProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textHint,
        selectedFontSize: 10.0,
        unselectedFontSize: 9.0,
        elevation: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.apartment_outlined), activeIcon: Icon(Icons.apartment_rounded), label: 'Properties'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline_rounded), activeIcon: Icon(Icons.people_rounded), label: 'Tenants'),
          BottomNavigationBarItem(icon: Icon(Icons.build_outlined), activeIcon: Icon(Icons.build_rounded), label: 'Maintenance'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
