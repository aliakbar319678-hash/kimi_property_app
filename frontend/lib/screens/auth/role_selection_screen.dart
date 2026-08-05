import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_primary_button.dart';
import 'package:tenant_and_landlord_application/provider/auth_provider.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String? _selectedRole; // 'tenant', 'landlord', or 'vendor'
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await ApiClient().getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final response = await ApiClient().dio.get(ApiConstants.me);
        if (response.statusCode == 200) {
          final data = response.data['data'];
          final List roles = data['roles'] ?? [];
          String role = 'tenant';
          String kycStatus = 'unverified';
          if (roles.isNotEmpty) {
            final primaryRoleObj = roles.firstWhere(
              (r) => r['is_primary'] == true,
              orElse: () => roles.first,
            );
            role = primaryRoleObj['role'] ?? 'tenant';
          }
          kycStatus = data['kyc_status'] ?? 'unverified';

          if (mounted) {
            if (role == 'landlord' || role == 'property_manager') {
              if (kycStatus == 'verified' || kycStatus == 'approved') {
                Navigator.pushReplacementNamed(context, '/verification_success');
              } else if (kycStatus == 'rejected') {
                Navigator.pushReplacementNamed(context, '/verification_rejected');
              } else if (kycStatus == 'reviewing') {
                Navigator.pushReplacementNamed(context, '/landlord_pending_approval');
              } else {
                Navigator.pushReplacementNamed(context, '/landlord_onboarding');
              }
            } else if (role == 'vendor') {
              Navigator.pushReplacementNamed(context, '/vendor_home');
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          }
        }
      } catch (e) {
        // Token invalid or network error, stop loading
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.06;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: h * 0.02),

              // Back Button (hidden if root screen)
              if (Navigator.canPop(context)) ...[
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: w * 0.1,
                    height: w * 0.1,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: h * 0.02),
              ] else ...[
                SizedBox(height: h * 0.04),
              ],

              // Header text
              Text(
                'Choose your Portal',
                style: TextStyle(
                  fontSize: w * 0.075,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: h * 0.01),
              Text(
                'Select the portal that fits your needs. You can switch portals later in settings.',
                style: TextStyle(
                  fontSize: w * 0.037,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              SizedBox(height: h * 0.03),

              // Role Cards
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Tenant Card
                      _buildRoleCard(
                        role: 'tenant',
                        title: 'Tenant Portal',
                        desc:
                            'Browse property listings, pay rent online, submit maintenance requests, and chat with your landlord.',
                        icon: Icons.key_rounded,
                        width: w,
                        height: h,
                      ),
                      SizedBox(height: h * 0.015),
                      // Landlord Card
                      _buildRoleCard(
                        role: 'landlord',
                        title: 'Landlord Portal',
                        desc:
                            'List properties, manage occupancy, track lease agreements, receive rent, and coordinate vendor bids.',
                        icon: Icons.apartment_rounded,
                        width: w,
                        height: h,
                      ),
                      SizedBox(height: h * 0.015),
                      // Vendor Card
                      _buildRoleCard(
                        role: 'vendor',
                        title: 'Vendor Portal',
                        desc:
                            'Onboard your service business, bid on open work orders, track job timelines on-site, and manage payouts.',
                        icon: Icons.build_rounded,
                        width: w,
                        height: h,
                      ),
                      SizedBox(height: h * 0.02),
                    ],
                  ),
                ),
              ),

              // Continue Button
              TLPrimaryButton(
                label: 'Continue',
                onTap: _selectedRole != null
                    ? () {
                        ref.read(registerProvider.notifier).updateSelectedRole(_selectedRole!);
                        Navigator.pushNamed(context, '/welcome');
                      }
                    : null,
              ),

              SizedBox(height: h * 0.02),

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

              SizedBox(height: h * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String desc,
    required IconData icon,
    required double width,
    required double height,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.05,
          vertical: height * 0.02,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.secondary.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(width * 0.03),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.secondary.withValues(alpha: 0.15)
                    : AppColors.scaffoldBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.secondary
                    : AppColors.textSecondary,
                size: width * 0.065,
              ),
            ),
            SizedBox(width: width * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.secondary,
                          size: width * 0.05,
                        ),
                    ],
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: width * 0.032,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
