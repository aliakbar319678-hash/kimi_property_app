import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class TLBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onTap;

  const TLBottomNav({super.key, required this.selectedIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    final items = [
      (Icons.home_rounded, Icons.home_outlined, 'Home'),
      (Icons.search_rounded, Icons.search_outlined, 'Search'),
      (Icons.payment_rounded, Icons.payment_outlined, 'Payments'),
      (Icons.chat_bubble_rounded, Icons.chat_bubble_outline_rounded, 'Chat'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
    ];

    return Container(
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
          final isSelected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onTap?.call(i),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? items[i].$1 : items[i].$2,
                  size: w * 0.058,
                  color: isSelected ? AppColors.secondary : AppColors.textHint,
                ),
                SizedBox(height: 3),
                Text(
                  items[i].$3,
                  style: TextStyle(
                    fontSize: w * 0.027,
                    color: isSelected ? AppColors.primary : AppColors.textHint,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
