import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class TLAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  const TLAppBar({
    super.key,
    this.showBack = false,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.05),
        child: Row(
          children: [
            // Leading widget (custom or default back button)
            if (leading != null)
              leading!
            else if (showBack)
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: w * 0.045,
                  color: AppColors.textPrimary,
                ),
              ),
            if (leading != null || showBack) SizedBox(width: w * 0.03),
            // Title and optional subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: w * 0.048,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  )
                else
                  Row(
                    children: [
                      Icon(
                        Icons.apartment_rounded,
                        size: w * 0.05,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: w * 0.015),
                      Text(
                        'T&L',
                        style: TextStyle(
                          fontSize: w * 0.048,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: w * 0.03,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            trailing ?? const SizedBox(),
          ],
        ),
      ),
    );
  }
}
