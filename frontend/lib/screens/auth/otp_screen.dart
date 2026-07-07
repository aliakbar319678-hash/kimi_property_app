import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/auth_provider.dart';
import 'package:tenant_and_landlord_application/provider/auth_state.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_primary_button.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (final n in _focusNodes) {
      n.dispose();
    }
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String val) {
    ref.read(otpProvider.notifier).updateDigit(index, val);
    if (val.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (val.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<OtpState>(otpProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      if (next.isVerified && !(previous?.isVerified ?? false)) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/basic_profile');
      }
    });

    final state = ref.watch(otpProvider);
    final notif = ref.read(otpProvider.notifier);
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.06),
            child: Column(
              children: [
                SizedBox(height: h * 0.06),

                // ── Lock icon ────────────────────────────
                Container(
                  width: w * 0.22,
                  height: w * 0.22,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.white,
                          size: w * 0.1,
                        ),
                        Positioned(
                          bottom: w * 0.03,
                          right: w * 0.03,
                          child: Container(
                            width: w * 0.06,
                            height: w * 0.06,
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              color: AppColors.white,
                              size: w * 0.035,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: h * 0.03),

                // ── Title ────────────────────────────────
                Text(
                  'Verify Your Account',
                  style: TextStyle(
                    fontSize: w * 0.07,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),

                SizedBox(height: h * 0.01),

                Text(
                  'Enter Code Sent to Email',
                  style: TextStyle(
                    fontSize: w * 0.038,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: h * 0.045),

                // ── White card ───────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(w * 0.06),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // ── OTP boxes ─────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          4,
                          (i) => _OtpBox(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            onChanged: (v) => _onChanged(i, v),
                            w: w,
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.03),

                      // ── Verify button ─────────────────
                      TLPrimaryButton(
                        label: 'Verify',
                        isLoading: state.isLoading,
                        onTap: () async {
                          await notif.verify();
                        },
                      ),

                      SizedBox(height: h * 0.022),

                      // ── Resend ────────────────────────
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: w * 0.035,
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            const TextSpan(text: "Didn't receive the code? "),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () async {
                                  for (final c in _controllers) {
                                    c.clear();
                                  }
                                  _focusNodes[0].requestFocus();
                                  await notif.resend();
                                  if (context.mounted && ref.read(otpProvider).errorMessage == null) {
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Verification code resent successfully!'),
                                        backgroundColor: Colors.blue,
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  'Resend\nCode',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: w * 0.035,
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: h * 0.05),

                // ── Back to Login ────────────────────────
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        size: w * 0.04,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: w * 0.015),
                      Text(
                        'Back to Login',
                        style: TextStyle(
                          fontSize: w * 0.037,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: h * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final double w;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.w,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: w * 0.17,
      height: w * 0.17,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: w * 0.06,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.inputBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
