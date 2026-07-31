import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/screens_provider.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_user_avatar.dart';


class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProfileProvider);
    final state = ref.watch(profileProvider);
    final notif = ref.read(profileProvider.notifier);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ───────────────────────────
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
                  Row(
                    children: [
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
                    ],
                  ),
                  const Spacer(),
                  TLUserAvatar(radius: w * 0.048),
                ],
              ),
            ),

            Expanded(
              child: userState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(pad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title + Edit button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Profile',
                                style: TextStyle(
                                  fontSize: w * 0.07,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    await ApiClient().dio.put(
                                      '/users/me/profile',
                                      data: {
                                        'smartAlerts': state.smartAlerts,
                                        'emailReceipts': state.emailReceipts,
                                        'language': state.language,
                                      },
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile settings saved!')));
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
                                    }
                                  }
                                },
                                icon: Icon(
                                  Icons.save_outlined,
                                  size: w * 0.04,
                                  color: AppColors.white,
                                ),
                                label: Text(
                                  'Save Profile',
                                  style: TextStyle(
                                    fontSize: w * 0.034,
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: w * 0.04,
                                    vertical: h * 0.012,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: h * 0.02),

                          // ── Personal Info card ────────
                          _SectionCard(
                            icon: Icons.person_outline_rounded,
                            iconBg: AppColors.secondary.withValues(alpha: 0.12),
                            iconColor: AppColors.secondary,
                            title: 'Personal Info',
                            hasLeftBorder: true,
                            w: w,
                            h: h,
                            child: Column(
                              children: [
                                _InfoRow(
                                  label: 'Full Name',
                                  value: userState.displayName.isNotEmpty ? userState.displayName : 'Not Provided',
                                  w: w,
                                  h: h,
                                ),
                                _InfoRow(
                                  label: 'Email Address',
                                  value: userState.email.isNotEmpty ? userState.email : 'Not Provided',
                                  w: w,
                                  h: h,
                                ),
                                _InfoRow(
                                  label: 'Phone Number',
                                  value: userState.phone.isNotEmpty ? userState.phone : 'Not Provided',
                                  w: w,
                                  h: h,
                                ),
                                _InfoRow(
                                  label: 'Date of Birth',
                                  value: userState.dateOfBirth.isNotEmpty ? userState.dateOfBirth : 'Not Provided',
                                  w: w,
                                  h: h,
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),

                    SizedBox(height: h * 0.018),

                    // ── Preferences card ──────────
                    _SectionCard(
                      icon: Icons.settings_outlined,
                      iconBg: AppColors.inputBg,
                      iconColor: AppColors.textSecondary,
                      title: 'Preferences',
                      w: w,
                      h: h,
                      child: Column(
                        children: [
                          _ToggleRow(
                            icon: Icons.notifications_outlined,
                            label: 'Smart Alerts',
                            value: state.smartAlerts,
                            onChanged: (_) => notif.toggleSmartAlerts(),
                            w: w,
                            h: h,
                          ),
                          Divider(height: 1, color: AppColors.border),
                          _ToggleRow(
                            icon: Icons.mail_outline_rounded,
                            label: 'Email Receipts',
                            value: state.emailReceipts,
                            onChanged: (_) => notif.toggleEmailReceipts(),
                            w: w,
                            h: h,
                          ),
                          Divider(height: 1, color: AppColors.border),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: h * 0.014),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.language_rounded,
                                  size: w * 0.045,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: w * 0.03),
                                Text(
                                  'Language',
                                  style: TextStyle(
                                    fontSize: w * 0.036,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  state.language,
                                  style: TextStyle(
                                    fontSize: w * 0.036,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1, color: AppColors.border),
                          GestureDetector(
                            onTap: () async {
                              await ApiClient().clearToken();
                              if (context.mounted) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/role_selection',
                                  (route) => false,
                                );
                              }
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: h * 0.014),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.logout_rounded,
                                    size: w * 0.045,
                                    color: AppColors.error,
                                  ),
                                  SizedBox(width: w * 0.03),
                                  Text(
                                    'Switch Portal / Logout',
                                    style: TextStyle(
                                      fontSize: w * 0.036,
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: w * 0.05,
                                    color: AppColors.error,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.018),

                    // ── Documents card ────────────
                    _SectionCard(
                      icon: Icons.folder_outlined,
                      iconBg: AppColors.secondary.withValues(alpha: 0.12),
                      iconColor: AppColors.secondary,
                      title: 'Documents',
                      w: w,
                      h: h,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/tenant_lease'),
                            behavior: HitTestBehavior.opaque,
                            child: _DocumentRow(
                              icon: Icons.description_outlined,
                              title: 'My Lease Agreement',
                              subtitle: 'Active',
                              trailing: Icons.chevron_right_rounded,
                              w: w,
                              h: h,
                            ),
                          ),
                          Divider(height: 1, color: AppColors.border),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/tenant_pay_rent'),
                            behavior: HitTestBehavior.opaque,
                            child: _DocumentRow(
                              icon: Icons.receipt_outlined,
                              title: 'Payment History',
                              subtitle: 'View recent payments',
                              trailing: Icons.chevron_right_rounded,
                              w: w,
                              h: h,
                            ),
                          ),
                          Divider(height: 1, color: AppColors.border),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/tenant_saved_properties'),
                            behavior: HitTestBehavior.opaque,
                            child: _DocumentRow(
                              icon: Icons.favorite_border_rounded,
                              title: 'Saved Properties',
                              subtitle: 'Keep track of homes you like',
                              trailing: Icons.chevron_right_rounded,
                              w: w,
                              h: h,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.018),

                    // ── Memos card ────────────────
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
                      child: Row(
                        children: [
                          Container(
                            width: w * 0.11,
                            height: w * 0.11,
                            decoration: BoxDecoration(
                              color: AppColors.inputBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.note_outlined,
                              size: w * 0.055,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: w * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Memos',
                                  style: TextStyle(
                                    fontSize: w * 0.038,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Tenant notes, requests,\ncomplaints, and follow-ups',
                                  style: TextStyle(
                                    fontSize: w * 0.03,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Memo Editor...'))); },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.secondary,
                              side: const BorderSide(
                                color: AppColors.secondary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: w * 0.03,
                                vertical: h * 0.008,
                              ),
                            ),
                            child: Text(
                              '+ Add Memo',
                              style: TextStyle(
                                fontSize: w * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.03),

                    // ── Logout Button ──────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () async {
                          await ApiClient().clearToken();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(context, '/role_selection', (route) => false);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Log Out',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
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

// ── Section card wrapper ──────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final Widget child;
  final bool hasLeftBorder;
  final double w;
  final double h;

  const _SectionCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.child,
    required this.w,
    required this.h,
    this.hasLeftBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: hasLeftBorder
            ? Border(left: BorderSide(color: AppColors.secondary, width: 3))
            : null,
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      padding: EdgeInsets.all(w * 0.045),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: w * 0.1,
                height: w * 0.1,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: w * 0.05, color: iconColor),
              ),
              SizedBox(width: w * 0.03),
              Text(
                title,
                style: TextStyle(
                  fontSize: w * 0.042,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.015),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final double w;
  final double h;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.w,
    required this.h,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: w * 0.03, color: AppColors.textSecondary),
        ),
        SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: w * 0.036,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        if (!isLast) ...[SizedBox(height: h * 0.012)],
      ],
    );
  }
}



class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final double w;
  final double h;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: h * 0.014),
      child: Row(
        children: [
          Icon(icon, size: w * 0.045, color: AppColors.textSecondary),
          SizedBox(width: w * 0.03),
          Text(
            label,
            style: TextStyle(fontSize: w * 0.036, color: AppColors.textPrimary),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.secondary,
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: AppColors.border,
          ),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final IconData trailing;
  final double w;
  final double h;

  const _DocumentRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: h * 0.014),
      child: Row(
        children: [
          Icon(icon, size: w * 0.05, color: AppColors.textSecondary),
          SizedBox(width: w * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: w * 0.036,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: w * 0.028,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(trailing, size: w * 0.055, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
