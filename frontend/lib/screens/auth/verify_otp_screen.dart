import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_input_field.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_primary_button.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _otpCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String _email = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _email = args;
    }
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpCtrl.text.trim();
    if (otp.isEmpty) {
      setState(() => _error = 'Please enter the OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await ApiClient().dio.post(
        '/auth/verify-otp',
        data: {
          'email': _email,
          'otp': otp,
        },
      );
      
      if (res.statusCode == 200 && mounted) {
        final resetToken = res.data['data']['resetToken'];
        // Navigate to Reset Password screen
        Navigator.pushNamed(context, '/reset_password', arguments: resetToken);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Invalid or expired OTP. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.06;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: pad, vertical: h * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify OTP',
                style: TextStyle(
                  fontSize: w * 0.065,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: h * 0.015),
              Text(
                'We\'ve sent a 6-digit one-time password to:\n$_email',
                style: TextStyle(
                  fontSize: w * 0.035,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: h * 0.04),
              
              if (_error != null) ...[
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
                          _error!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: h * 0.02),
              ],

              const Text(
                'OTP Code',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: h * 0.008),
              TLInputField(
                controller: _otpCtrl,
                hint: '123456',
                prefixIcon: Icons.lock_clock_outlined,
                keyboardType: TextInputType.number,
              ),
              
              const Spacer(),
              
              TLPrimaryButton(
                label: 'Verify OTP',
                isLoading: _isLoading,
                onTap: _verifyOtp,
              ),
              SizedBox(height: h * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
