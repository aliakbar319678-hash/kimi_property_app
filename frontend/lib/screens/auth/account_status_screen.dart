import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';
import 'package:tenant_and_landlord_application/screens/tenant_kyc_upload_screen.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

/// Displays the user's KYC verification journey in a beautiful timeline UI.
/// Replaces the plain LandlordPendingApprovalScreen.
class AccountStatusScreen extends StatefulWidget {
  const AccountStatusScreen({super.key});

  @override
  State<AccountStatusScreen> createState() => _AccountStatusScreenState();
}

class _AccountStatusScreenState extends State<AccountStatusScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String _kycStatus = 'reviewing';
  String _userRole = 'tenant';
  String? _rejectionReason;
  String _displayName = '';
  String _email = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadStatus();
    // Fast polling (every 4 seconds) to detect admin approval/rejection instantly
    _pollTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _loadStatus(silent: true);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStatus({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get(ApiConstants.me);
      if (res.statusCode == 200 && mounted) {
        final data = res.data['data'];
        final status = data['kyc_status'] ?? 'reviewing';
        final prevStatus = _kycStatus;

        // Determine user role for navigation decisions
        String role = 'tenant';
        final List roles = data['roles'] ?? [];
        if (roles.isNotEmpty) {
          final primaryRoleObj = roles.firstWhere(
            (r) => r['is_primary'] == true,
            orElse: () => roles.first,
          );
          role = primaryRoleObj['role'] ?? 'tenant';
        }

        setState(() {
          _kycStatus = status;
          _userRole = role;
          _rejectionReason = data['rejection_reason'];
          _displayName = data['display_name'] ?? data['email'] ?? 'User';
          _email = data['email'] ?? '';
          _isLoading = false;
        });
        // Notify user when status changed while waiting
        if (silent && prevStatus != status && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Your account status updated to: ${status.toUpperCase()}'),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        // If approved or verified, auto-navigate after 1.5s
        if (status == 'verified' || status == 'approved') {
          _pollTimer?.cancel();
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            if (role == 'landlord' || role == 'property_manager') {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/landlord_home', (r) => false);
            } else if (role == 'vendor') {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/vendor_home', (r) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (r) => false);
            }
          }
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await ApiClient().clearToken();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // ── Top App Bar ──────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: h * 0.22,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0B1F3A), Color(0xFF1A3A5C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: w * 0.06, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: AppColors.secondary
                                        .withValues(alpha: 0.2),
                                    child: Text(
                                      _displayName.isNotEmpty
                                          ? _displayName[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: w * 0.03),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _displayName,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: w * 0.042,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _email,
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.6),
                                            fontSize: w * 0.031,
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: h * 0.02),
                              // Status badge
                              _StatusBadge(status: _kycStatus, w: w),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(w * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: h * 0.01),

                        // ── Status Timeline ──────────────────────────────
                        Text(
                          'Verification Progress',
                          style: TextStyle(
                            fontSize: w * 0.042,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: h * 0.02),
                        _VerificationTimeline(
                            status: _kycStatus,
                            pulseAnimation: _pulseAnimation),
                        SizedBox(height: h * 0.025),

                        // ── Info / Reason Card ───────────────────────────
                        _StatusInfoCard(
                          status: _kycStatus,
                          rejectionReason: _rejectionReason,
                          w: w,
                        ),

                        SizedBox(height: h * 0.03),

                        // ── Action Buttons ───────────────────────────────
                        if (_kycStatus == 'rejected') ...[
                          _ActionButton(
                            label: _userRole == 'vendor'
                                ? 'Resubmit Application'
                                : 'Resubmit Documents',
                            icon: _userRole == 'vendor'
                                ? Icons.business_center_rounded
                                : Icons.upload_file_rounded,
                            color: AppColors.primary,
                            onTap: () {
                              if (_userRole == 'vendor') {
                                // Vendor goes back to their onboarding form
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/vendor_onboarding',
                                );
                              } else {
                                // Tenant / Landlord uploads KYC documents
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TenantKycUploadScreen(
                                      rejectionReason: _rejectionReason,
                                      isResubmission: true,
                                    ),
                                  ),
                                ).then((_) => _loadStatus(silent: false));
                              }
                            },
                          ),
                          SizedBox(height: h * 0.015),
                        ],

                        // ── Contact Support — only for rejected/suspended users ──
                        if (_kycStatus == 'rejected' || _kycStatus == 'suspended') ...[  
                          _ActionButton(
                            label: 'Contact Support',
                            icon: Icons.headset_mic_rounded,
                            color: AppColors.secondary,
                            onTap: () => Navigator.pushNamed(
                                context, '/support_chat'),
                          ),
                        ],

                        SizedBox(height: h * 0.015),

                        // ── Log Out ──────────────────────────────────────
                        Center(
                          child: TextButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout_rounded,
                                size: 18, color: AppColors.textSecondary),
                            label: const Text(
                              'Log Out',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
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
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  final double w;
  const _StatusBadge({required this.status, required this.w});

  @override
  Widget build(BuildContext context) {
    final info = _statusInfo(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: info['color'] as Color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info['icon'] as IconData, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            info['label'] as String,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: w * 0.033,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Verification Timeline ─────────────────────────────────────────────────────
class _VerificationTimeline extends StatelessWidget {
  final String status;
  final Animation<double> pulseAnimation;
  const _VerificationTimeline(
      {required this.status, required this.pulseAnimation});

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps(status);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(steps.length, (i) {
          final step = steps[i];
          final isLast = i == steps.length - 1;
          final isActive = step['state'] == 'active';

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon column
              Column(
                children: [
                  isActive
                      ? ScaleTransition(
                          scale: pulseAnimation,
                          child: _stepDot(step['state'] as String,
                              step['icon'] as IconData),
                        )
                      : _stepDot(
                          step['state'] as String, step['icon'] as IconData),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: step['state'] == 'done'
                          ? AppColors.success.withValues(alpha: 0.5)
                          : AppColors.border,
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: step['state'] == 'pending'
                              ? AppColors.textHint
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        step['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: step['state'] == 'pending'
                              ? AppColors.textHint
                              : AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _stepDot(String state, IconData icon) {
    Color bg;
    Color iconColor;
    switch (state) {
      case 'done':
        bg = AppColors.success;
        iconColor = Colors.white;
        break;
      case 'active':
        bg = AppColors.secondary;
        iconColor = Colors.white;
        break;
      case 'error':
        bg = AppColors.error;
        iconColor = Colors.white;
        break;
      default:
        bg = AppColors.border;
        iconColor = AppColors.textHint;
    }
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: state == 'active'
            ? [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Icon(icon, color: iconColor, size: 18),
    );
  }

  List<Map<String, dynamic>> _buildSteps(String status) {
    // Step states: 'done', 'active', 'pending', 'error'
    final isApproved = status == 'verified' || status == 'approved';
    final isRejected = status == 'rejected';
    final isSuspended = status == 'suspended';
    final isReviewing = status == 'reviewing' || status == 'in_review';

    return [
      {
        'title': 'Documents Submitted',
        'subtitle': 'Your KYC documents have been uploaded successfully.',
        'icon': Icons.task_alt_rounded,
        'state': 'done',
      },
      {
        'title': 'Identity Verification',
        'subtitle': 'We are verifying your identity and documents.',
        'icon': Icons.manage_search_rounded,
        'state': isApproved || isRejected || isSuspended
            ? (isApproved ? 'done' : 'error')
            : (isReviewing ? 'active' : 'pending'),
      },
      {
        'title': isRejected
            ? 'Verification Rejected'
            : isSuspended
                ? 'Account Suspended'
                : 'Admin Approval',
        'subtitle': isRejected
            ? 'Please review the reason and resubmit.'
            : isSuspended
                ? 'Your account has been suspended. Contact support.'
                : isApproved
                    ? 'Your account is fully verified!'
                    : 'Awaiting final admin decision.',
        'icon': isRejected
            ? Icons.cancel_rounded
            : isSuspended
                ? Icons.block_rounded
                : isApproved
                    ? Icons.verified_rounded
                    : Icons.pending_actions_rounded,
        'state': isApproved
            ? 'done'
            : isRejected || isSuspended
                ? 'error'
                : 'pending',
      },
    ];
  }
}

// ── Status Info Card ──────────────────────────────────────────────────────────
class _StatusInfoCard extends StatelessWidget {
  final String status;
  final String? rejectionReason;
  final double w;
  const _StatusInfoCard(
      {required this.status,
      required this.rejectionReason,
      required this.w});

  @override
  Widget build(BuildContext context) {
    final info = _statusInfo(status);
    final color = info['color'] as Color;
    final msg = info['message'] as String;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(info['icon'] as IconData, color: color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  info['label'] as String,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            msg,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (rejectionReason != null && rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Reason:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rejectionReason!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

// ── Shared status metadata helper ─────────────────────────────────────────────
Map<String, dynamic> _statusInfo(String status) {
  switch (status) {
    case 'reviewing':
    case 'in_review':
      return {
        'label': 'Under Review',
        'icon': Icons.hourglass_top_rounded,
        'color': const Color(0xFF4DB2E6),
        'message':
            'Your documents are currently being reviewed by our admin team. This usually takes 1–2 business days. We\'ll notify you once a decision is made.',
      };
    case 'verified':
    case 'approved':
      return {
        'label': 'Verified ✓',
        'icon': Icons.verified_rounded,
        'color': const Color(0xFF2ECC71),
        'message':
            'Congratulations! Your account is fully verified. You now have full access to all platform features.',
      };
    case 'rejected':
      return {
        'label': 'Rejected',
        'icon': Icons.cancel_rounded,
        'color': const Color(0xFFE74C3C),
        'message':
            'Your verification was rejected. Please review the reason below, fix the issue, and resubmit your documents.',
      };
    case 'suspended':
      return {
        'label': 'Suspended',
        'icon': Icons.block_rounded,
        'color': const Color(0xFF8B0000),
        'message':
            'Your account has been suspended by the admin. Please contact support immediately to resolve this issue and provide any required documentation.',
      };
    default:
      return {
        'label': 'Pending',
        'icon': Icons.schedule_rounded,
        'color': const Color(0xFFF39C12),
        'message':
            'Your submission is pending. Our team will begin the review process shortly.',
      };
  }
}
