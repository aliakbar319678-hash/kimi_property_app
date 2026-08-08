import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_primary_button.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.06;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/role_selection', (r) => false),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: h * 0.025),

                // ── Logo ─────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.apartment_rounded,
                      size: w * 0.06,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: w * 0.02),
                    Text(
                      'T&L',
                      style: TextStyle(
                        fontSize: w * 0.055,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: h * 0.025),

                // ── Hero Image with overlay badge ─────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Hero image
                      Container(
                        width: double.infinity,
                        height: h * 0.36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800&q=80',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Verified badge — bottom left
                      Positioned(
                        bottom: 14,
                        left: 14,
                        right: 14,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: w * 0.04,
                            vertical: h * 0.015,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: w * 0.1,
                                height: w * 0.1,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.key_rounded,
                                  color: AppColors.secondary,
                                  size: w * 0.05,
                                ),
                              ),
                              SizedBox(width: w * 0.03),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Verified Listings',
                                    style: TextStyle(
                                      fontSize: w * 0.038,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '2,400+ Homes Available',
                                    style: TextStyle(
                                      fontSize: w * 0.032,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: h * 0.035),

                // ── Headline ─────────────────────────────
                Text(
                  'Find Your Perfect\nHome Easily',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: w * 0.075,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),

                SizedBox(height: h * 0.015),

                // ── Subtitle ─────────────────────────────
                Text(
                  'Connecting modern tenants with premium\nproperties through a seamless, digital-first\nmanagement experience.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: w * 0.037,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),

                SizedBox(height: h * 0.04),

                // ── Login Button ─────────────────────────
                TLPrimaryButton(
                  label: 'Login',
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),

                SizedBox(height: h * 0.015),

                // ── Sign Up Button ───────────────────────
                TLPrimaryButton(
                  label: 'Sign Up',
                  outlined: true,
                  onTap: () {
                    Navigator.pushNamed(context, '/register');
                  },
                ),

                // ── Guest Button ─────────────────────────
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  icon: const Icon(Icons.travel_explore_rounded, color: AppColors.textSecondary, size: 20),
                  label: const Text(
                    'Explore Properties as Guest',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                SizedBox(height: h * 0.04),

                // ── Footer ───────────────────────────────
                Text(
                  '© 2024 T&L. All rights reserved.',
                  style: TextStyle(
                    fontSize: w * 0.029,
                    color: AppColors.textHint,
                  ),
                ),
                SizedBox(height: h * 0.008),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _FooterLink('Privacy Policy'),
                    _dot(w),
                    _FooterLink('Terms of Service'),
                    _dot(w),
                    _FooterLink('Contact Support'),
                  ],
                ),
                SizedBox(height: h * 0.025),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dot(double w) => Padding(
    padding: EdgeInsets.symmetric(horizontal: w * 0.02),
    child: const Text('·', style: TextStyle(color: AppColors.textHint)),
  );
}

class _FooterLink extends StatelessWidget {
  final String text;
  const _FooterLink(this.text);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening $text...')),
        );
      },
      child: Text(
        text,
        style: TextStyle(fontSize: w * 0.029, color: AppColors.textHint),
      ),
    );
  }
}
