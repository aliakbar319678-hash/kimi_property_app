import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';
import 'package:tenant_and_landlord_application/provider/auth_provider.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_input_field.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(registerProvider.notifier).setLoginMode(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerProvider);
    final notif = ref.read(registerProvider.notifier);
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.06;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header Area ─────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: pad,
                vertical: h * 0.025,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.white,
                          size: w * 0.05,
                        ),
                      ),
                      SizedBox(width: w * 0.03),
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: w * 0.048,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: h * 0.02),
                  Text(
                    'WELCOME BACK',
                    style: TextStyle(
                      fontSize: w * 0.038,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: h * 0.008),
                  Text(
                    'Sign in to access your smart rental ecosystem\nand manage everything in one place.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: w * 0.033,
                      color: AppColors.white.withValues(alpha: 0.65),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── Form Area ───────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(pad, h * 0.03, pad, h * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.errorMessage != null) ...[
                        Container(
                          padding: EdgeInsets.all(w * 0.03),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                              SizedBox(width: w * 0.02),
                              Expanded(
                                child: Text(
                                  state.errorMessage!,
                                  style: TextStyle(color: Colors.redAccent, fontSize: w * 0.032),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: h * 0.018),
                      ],

                      // Email / Username Field
                      Text(
                        'Email or Username',
                        style: TextStyle(
                          fontSize: w * 0.036,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: h * 0.008),
                      TLInputField(
                        key: const ValueKey('login_email_field'),
                        hint: 'alex@example.com or alex123',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: notif.updateEmail,
                        errorText: state.emailError,
                      ),

                      SizedBox(height: h * 0.018),

                      // Password Field
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: w * 0.036,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: h * 0.008),
                      TLInputField(
                        key: const ValueKey('login_password_field'),
                        hint: '••••••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscure: state.obscurePassword,
                        onChanged: notif.updatePassword,
                        errorText: state.passwordError,
                        suffixIcon: GestureDetector(
                          onTap: notif.toggleObscure,
                          child: Icon(
                            state.obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.025),

                      // Submit Login Button
                      TLPrimaryButton(
                        label: 'Sign In',
                        isLoading: state.isLoading,
                        trailing: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.white,
                          size: 18,
                        ),
                        onTap: () async {
                          final success = await notif.submit();
                          if (!context.mounted) return;

                          final freshState = ref.read(registerProvider);
                          if (success) {
                            final role = freshState.selectedRole.toLowerCase();
                            String kycStatus = 'unverified';

                            try {
                              final response = await ApiClient().dio.get(ApiConstants.me);
                              if (response.statusCode == 200) {
                                kycStatus = response.data['data']['kyc_status'] ?? 'unverified';
                              }
                            } catch (_) {}

                            if (!context.mounted) return;
                            if (kycStatus == 'reviewing') {
                              Navigator.pushNamedAndRemoveUntil(context, '/landlord_pending_approval', (r) => false);
                            } else if (kycStatus == 'rejected') {
                              Navigator.pushNamedAndRemoveUntil(context, '/verification_rejected', (r) => false);
                            } else if (kycStatus == 'verified' || kycStatus == 'approved') {
                              if (role == 'vendor') {
                                Navigator.pushNamedAndRemoveUntil(context, '/vendor_home', (r) => false);
                              } else {
                                Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
                              }
                            } else {
                              if (role == 'landlord' || role == 'property_manager') {
                                Navigator.pushNamedAndRemoveUntil(context, '/landlord_onboarding', (r) => false);
                              } else if (role == 'vendor') {
                                Navigator.pushNamedAndRemoveUntil(context, '/vendor_onboarding', (r) => false);
                              } else {
                                Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    freshState.errorMessage ??
                                        'Sign in failed'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                      ),

                      SizedBox(height: h * 0.025),

                      // Don't have an account? Sign Up
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/register');
                          },
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: w * 0.034,
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                const TextSpan(text: "Don't have an account? "),
                                TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: w * 0.034,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.02),

                      // Explore as Guest
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                          child: Text(
                            'Explore Properties as Guest',
                            style: TextStyle(
                              fontSize: w * 0.035,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
