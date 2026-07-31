import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/auth_provider.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_input_field.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_primary_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final routeName = ModalRoute.of(context)?.settings.name;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (routeName == '/login') {
            ref.read(registerProvider.notifier).setLoginMode(true);
          } else if (routeName == '/register') {
            ref.read(registerProvider.notifier).setLoginMode(false);
          }
        }
      });
      _isInitialized = true;
    }
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
            // ── Top area (dark bg) ────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: pad,
                vertical: h * 0.025,
              ),
              child: Column(
                children: [
                  // Back arrow + title
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
                        state.isLogin ? 'Sign In' : 'Create Account',
                        style: TextStyle(
                          fontSize: w * 0.048,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: h * 0.022),

                  // JOIN T&L subtitle
                  Text(
                    state.isLogin ? 'WELCOME BACK' : 'JOIN T&L',
                    style: TextStyle(
                      fontSize: w * 0.038,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                      letterSpacing: 1.5,
                    ),
                  ),

                  SizedBox(height: h * 0.008),

                  Text(
                    state.isLogin
                        ? 'Sign in to access your smart rental ecosystem\nand manage everything in one place.'
                        : 'Access your smart rental ecosystem and\nmanage everything in one place.',
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

            // ── White card (scrollable form) ──────────
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
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.errorMessage!,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: h * 0.018),
                      ],



                      if (!state.isLogin) ...[
                        _FieldLabel('Full Name', w),
                        SizedBox(height: h * 0.008),
                        TLInputField(
                          key: const ValueKey('register_full_name'),
                          hint: 'Alex Thompson',
                          prefixIcon: Icons.person_outline_rounded,
                          onChanged: notif.updateFullName,
                          errorText: state.fullNameError,
                        ),
                        SizedBox(height: h * 0.018),

                        if (state.selectedRole == 'tenant') ...[
                          _FieldLabel('Username', w),
                          SizedBox(height: h * 0.008),
                          TLInputField(
                            key: const ValueKey('register_username'),
                            hint: 'alex123',
                            prefixIcon: Icons.account_circle_outlined,
                            onChanged: notif.updateUsername,
                            errorText: state.usernameError,
                          ),
                          SizedBox(height: h * 0.018),
                        ],
                      ],

                      // Email
                      _FieldLabel('Email', w),
                      SizedBox(height: h * 0.008),
                      TLInputField(
                        key: ValueKey(state.isLogin ? 'login_email' : 'register_email'),
                        hint: 'alex@example.com',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: notif.updateEmail,
                        errorText: state.emailError,
                      ),

                      SizedBox(height: h * 0.018),

                      // Phone (Only show in register)
                      if (!state.isLogin) ...[
                        _FieldLabel('Phone Number', w),
                        SizedBox(height: h * 0.008),
                        TLInputField(
                          key: const ValueKey('register_phone'),
                          hint: '+1 (555) 000-0000',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          onChanged: notif.updatePhone,
                          errorText: state.phoneError,
                        ),
                        SizedBox(height: h * 0.018),
                      ],

                      // Password
                      _FieldLabel('Password', w),
                      SizedBox(height: h * 0.008),
                      TLInputField(
                        key: ValueKey(state.isLogin ? 'login_password' : 'register_password'),
                        hint: '••••••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscure: state.obscurePassword,
                        onChanged: notif.updatePassword,
                        errorText: state.passwordError,
                        helperText: state.isLogin
                            ? null
                            : 'Must be at least 8 characters with one special symbol.',
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

                      SizedBox(height: h * 0.022),

                      // Terms checkbox (Only show in register)
                      if (!state.isLogin) ...[
                        GestureDetector(
                          onTap: notif.toggleTerms,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: w * 0.05,
                                height: w * 0.05,
                                decoration: BoxDecoration(
                                  color: state.agreeToTerms
                                      ? AppColors.primary
                                      : AppColors.white,
                                  border: Border.all(
                                    color: state.agreeToTerms
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: state.agreeToTerms
                                    ? Icon(
                                        Icons.check_rounded,
                                        color: AppColors.white,
                                        size: w * 0.033,
                                      )
                                    : null,
                              ),
                              SizedBox(width: w * 0.03),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: w * 0.033,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                    children: [
                                      const TextSpan(text: 'I agree to the '),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          color: AppColors.secondary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: w * 0.033,
                                        ),
                                      ),
                                      const TextSpan(text: '\nand '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          color: AppColors.secondary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: w * 0.033,
                                        ),
                                      ),
                                      const TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: h * 0.03),
                      ],

                      // Continue button
                      TLPrimaryButton(
                        label: state.isLogin ? 'Sign In' : 'Continue',
                        isLoading: state.isLoading,
                        trailing: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.white,
                          size: 18,
                        ),
                        onTap: () async {
                          if (!state.isLogin && !state.agreeToTerms) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('You must agree to the terms to continue'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          final success = await notif.submit();
                          if (!context.mounted) return;

                          // Read fresh state after async to get the role set by the API
                          final freshState = ref.read(registerProvider);

                          if (success) {
                            if (freshState.isLogin) {
                              // Route user to role-specific home
                              if (freshState.selectedRole == 'landlord') {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/landlord_home', (r) => false);
                              } else if (freshState.selectedRole == 'vendor') {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/vendor_home', (r) => false);
                              } else {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/home', (r) => false);
                              }
                            } else {
                              // Registration succeeded -> auto-login succeeded -> go to home
                              if (freshState.selectedRole == 'landlord') {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/landlord_home', (r) => false);
                              } else if (freshState.selectedRole == 'vendor') {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/vendor_home', (r) => false);
                              } else {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/home', (r) => false);
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    freshState.errorMessage ??
                                        'Authentication failed'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                      ),

                      SizedBox(height: h * 0.025),

                      // Sign In / Sign Up link toggle
                      Center(
                        child: GestureDetector(
                          onTap: notif.toggleMode,
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: w * 0.034,
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                TextSpan(
                                  text: state.isLogin
                                      ? "Don't have an account? "
                                      : 'Already have an account? ',
                                ),
                                TextSpan(
                                  text: state.isLogin ? 'Sign Up' : 'Sign In',
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
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                          child: const Text(
                            'Explore Properties as Guest',
                            style: TextStyle(
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

class _FieldLabel extends StatelessWidget {
  final String text;
  final double w;
  const _FieldLabel(this.text, this.w);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: w * 0.036,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }
}
