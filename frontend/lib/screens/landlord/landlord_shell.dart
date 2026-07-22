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
    final w = MediaQuery.of(context).size.width;

    final items = [
      (Icons.home_rounded, Icons.home_outlined, 'Home'),
      (Icons.apartment_rounded, Icons.apartment_outlined, 'Properties'),
      (Icons.people_rounded, Icons.people_outline_rounded, 'Tenants'),
      (Icons.build_rounded, Icons.build_outlined, 'Maintenance'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
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
              onTap: () => setState(() => _currentIndex = i),
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        fontSize: w * 0.027,
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
