import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_primary_button.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';

class LandlordPendingApprovalScreen extends StatefulWidget {
  const LandlordPendingApprovalScreen({super.key});

  @override
  State<LandlordPendingApprovalScreen> createState() =>
      _LandlordPendingApprovalScreenState();
}

class _LandlordPendingApprovalScreenState
    extends State<LandlordPendingApprovalScreen> {
  bool _isChecking = false;

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final res = await ApiClient().dio.get(ApiConstants.me);
      if (res.statusCode == 200) {
        final kycStatus = res.data['data']['kyc_status'] ?? 'pending';
        if (kycStatus == 'verified' || kycStatus == 'approved') {
          navigator.pushNamedAndRemoveUntil(
              '/verification_success', (route) => false);
          return;
        } else if (kycStatus == 'rejected') {
          navigator.pushNamedAndRemoveUntil(
              '/verification_rejected', (route) => false);
          return;
        } else {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Your account is still pending approval.'),
            ),
          );
        }
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to check status: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _logout() async {
    await ApiClient().clearToken();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                Icons.hourglass_empty_rounded,
                size: w * 0.25,
                color: AppColors.primary,
              ),
              SizedBox(height: h * 0.04),
              Text(
                'Verification Pending',
                style: TextStyle(
                  fontSize: w * 0.065,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: h * 0.02),
              Text(
                'Your documents have been submitted and are currently being reviewed by our Admin team. This usually takes 1-2 business days.',
                style: TextStyle(
                  fontSize: w * 0.04,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: h * 0.06),
              TLPrimaryButton(
                label: 'Check Status',
                isLoading: _isChecking,
                onTap: _checkStatus,
              ),
              SizedBox(height: h * 0.02),
              TextButton(
                onPressed: _logout,
                child: Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: w * 0.04,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
