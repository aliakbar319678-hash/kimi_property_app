import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';

class VerificationRejectedScreen extends StatefulWidget {
  const VerificationRejectedScreen({super.key});

  @override
  State<VerificationRejectedScreen> createState() => _VerificationRejectedScreenState();
}

class _VerificationRejectedScreenState extends State<VerificationRejectedScreen> {
  bool _isLoading = false;
  bool _isFetchingReason = true;
  String? _rejectionReason;

  @override
  void initState() {
    super.initState();
    _fetchRejectionReason();
  }

  /// Fetch the real admin-provided rejection reason from the server
  Future<void> _fetchRejectionReason() async {
    try {
      final res = await ApiClient().dio.get(ApiConstants.me);
      if (res.statusCode == 200) {
        final data = res.data['data'];
        final reason = data['rejection_reason'] as String?;
        if (mounted) {
          setState(() {
            _rejectionReason = (reason != null && reason.isNotEmpty) ? reason : null;
            _isFetchingReason = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isFetchingReason = false);
    }
  }

  Future<void> _handleResubmit() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get(ApiConstants.me);
      if (res.statusCode == 200) {
        final data = res.data['data'];
        final List roles = data['roles'] ?? [];
        String role = 'tenant';
        if (roles.isNotEmpty) {
          final primaryRoleObj = roles.firstWhere(
            (r) => r['is_primary'] == true,
            orElse: () => roles.first,
          );
          role = primaryRoleObj['role'] ?? 'tenant';
        }

        if (!mounted) return;
        if (role == 'vendor') {
          Navigator.pushReplacementNamed(context, '/vendor_onboarding');
        } else {
          Navigator.pushReplacementNamed(context, '/landlord_onboarding');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile')),
      );
      setState(() => _isLoading = false);
    }
  }

  /// Properly clear token and navigate to login
  Future<void> _handleLogout() async {
    await ApiClient().clearToken();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 100,
              ),
              const SizedBox(height: 32),
              const Text(
                'Verification Rejected',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your account verification was rejected by the Admin. Please review the reason below, fix the issue, and resubmit.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // ── Rejection Reason Box ───────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                ),
                child: _isFetchingReason
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline, color: AppColors.error, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _rejectionReason != null
                                    ? 'Rejection Reason:'
                                    : 'Note:',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _rejectionReason ??
                                'Ensure your legal name matches your ID exactly and the uploaded documents are clear and legible.',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.error,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 48),

              // ── Resubmit Button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleResubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Resubmit Documents',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/support_chat'),
                  icon: const Icon(Icons.headset_mic_rounded,
                      size: 20, color: AppColors.secondary),
                  label: const Text(
                    'Contact Support',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: AppColors.secondary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Log Out Button (properly clears tokens) ────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: _handleLogout,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
