import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_input_field.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_primary_button.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _resetToken = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _resetToken = args;
    }
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final pass = _passCtrl.text.trim();
    final confirm = _confirmPassCtrl.text.trim();
    
    if (pass.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }
    
    if (pass.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters');
      return;
    }
    
    if (pass != confirm) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await ApiClient().dio.post(
        '/auth/reset-password',
        data: {
          'resetToken': _resetToken,
          'newPassword': pass,
        },
      );
      
      if (res.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successfully! Please login.'),
            backgroundColor: AppColors.success,
          ),
        );
        // Navigate back to login screen
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Failed to reset password. Token may be expired.');
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
                'New Password',
                style: TextStyle(
                  fontSize: w * 0.065,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: h * 0.015),
              Text(
                'Enter your new password below.',
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
                'New Password',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: h * 0.008),
              TLInputField(
                controller: _passCtrl,
                hint: '••••••••••••',
                prefixIcon: Icons.lock_outline_rounded,
                obscure: _obscurePassword,
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 18,
                    color: AppColors.textHint,
                  ),
                ),
              ),
              
              SizedBox(height: h * 0.02),
              
              const Text(
                'Confirm New Password',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: h * 0.008),
              TLInputField(
                controller: _confirmPassCtrl,
                hint: '••••••••••••',
                prefixIcon: Icons.lock_outline_rounded,
                obscure: _obscureConfirmPassword,
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  child: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 18,
                    color: AppColors.textHint,
                  ),
                ),
              ),
              
              const Spacer(),
              
              TLPrimaryButton(
                label: 'Reset Password',
                isLoading: _isLoading,
                onTap: _resetPassword,
              ),
              SizedBox(height: h * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
