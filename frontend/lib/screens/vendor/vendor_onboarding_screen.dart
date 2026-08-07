import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_primary_button.dart';
import 'package:tenant_and_landlord_application/provider/vendor_provider.dart';
import 'package:tenant_and_landlord_application/provider/vendor_state.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';

class VendorOnboardingScreen extends ConsumerStatefulWidget {
  const VendorOnboardingScreen({super.key});

  @override
  ConsumerState<VendorOnboardingScreen> createState() =>
      _VendorOnboardingScreenState();
}

class _VendorOnboardingScreenState
    extends ConsumerState<VendorOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _businessNameController = TextEditingController(
    text: 'Apex Plumbing Solutions LLC',
  );
  final _taxIdController = TextEditingController(text: 'XX-XXX8941');
  String _serviceCategory = 'Plumbing';

  final _phoneController = TextEditingController(text: '(555) 345-0900');
  final _emailController = TextEditingController(
    text: 'contact@apexplumbing.com',
  );
  final _addressController = TextEditingController(text: '809 Elm Street');
  final _cityController = TextEditingController(text: 'Seattle');
  final _stateController = TextEditingController(text: 'WA');
  final _zipController = TextEditingController(text: '98101');

  final _bankNameController = TextEditingController(text: 'Chase Bank');
  final _routingController = TextEditingController(text: '123456789');
  final _accountController = TextEditingController(text: '••••••••8901');

  bool _agreeToTerms = true;

  final String _tradeLicenseStatus = 'Verified';
  final String _insuranceStatus = 'Verified';
  final String _w9Status = 'Signed';

  bool _isLoading = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _taxIdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _bankNameController.dispose();
    _routingController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/role_selection'),
        ),
        title: const Text(
          'Vendor Onboarding',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    fontSize: w * 0.065,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: h * 0.008),
                Text(
                  'Provide your professional details to begin receiving job invitations and receiving payments.',
                  style: TextStyle(
                    fontSize: w * 0.035,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: h * 0.025),

                // Card 1: Business Information
                _buildCardContainer(
                  title: 'Business Information',
                  icon: Icons.business_center_rounded,
                  width: w,
                  children: [
                    _buildFieldLabel('Business Name', w),
                    SizedBox(height: h * 0.008),
                    _buildInputField(
                      controller: _businessNameController,
                      hint: 'e.g., Apex Plumbing Solutions LLC',
                    ),
                    SizedBox(height: h * 0.018),
                    _buildFieldLabel('Tax ID / EIN', w),
                    SizedBox(height: h * 0.008),
                    _buildInputField(
                      controller: _taxIdController,
                      hint: 'e.g., 12-3456789',
                    ),
                    SizedBox(height: h * 0.018),
                    _buildFieldLabel('Service Category', w),
                    SizedBox(height: h * 0.008),
                    _buildDropdownField(
                      hint: 'Select Category',
                      value: _serviceCategory,
                      items: const [
                        'Plumbing',
                        'Electrical',
                        'HVAC',
                        'General',
                      ],
                      onChanged: (val) {
                        setState(() {
                          _serviceCategory = val;
                        });
                      },
                      w: w,
                    ),
                  ],
                ),
                SizedBox(height: h * 0.02),

                // Card 2: Contact Information
                _buildCardContainer(
                  title: 'Contact Information',
                  icon: Icons.contact_mail_rounded,
                  width: w,
                  children: [
                    _buildFieldLabel('Business Phone', w),
                    SizedBox(height: h * 0.008),
                    _buildInputField(
                      controller: _phoneController,
                      hint: '+1 (555) 000-0000',
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: h * 0.018),
                    _buildFieldLabel('Business Email', w),
                    SizedBox(height: h * 0.008),
                    _buildInputField(
                      controller: _emailController,
                      hint: 'vendor@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: h * 0.018),
                    _buildFieldLabel('Street Address', w),
                    SizedBox(height: h * 0.008),
                    _buildInputField(
                      controller: _addressController,
                      hint: '123 Main St',
                    ),
                    SizedBox(height: h * 0.018),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('City', w),
                              SizedBox(height: h * 0.008),
                              _buildInputField(
                                controller: _cityController,
                                hint: 'City',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: w * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('State', w),
                              SizedBox(height: h * 0.008),
                              _buildInputField(
                                controller: _stateController,
                                hint: 'State',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: w * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('ZIP', w),
                              SizedBox(height: h * 0.008),
                              _buildInputField(
                                controller: _zipController,
                                hint: 'ZIP',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: h * 0.02),



                // Action Buttons
                TLPrimaryButton(
                  label: 'Submit Application',
                  isLoading: _isLoading,
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isLoading = true);
                      try {
                        // 1. Update Profile
                        final profilePayload = {
                          'display_name': _businessNameController.text.trim(),
                          'phone': _phoneController.text.trim(),
                          'current_address': {
                            'address_line1': _addressController.text.trim(),
                            'city': _cityController.text.trim(),
                            'state': _stateController.text.trim(),
                            'zip': _zipController.text.trim(),
                          },
                        };

                        try {
                          await ApiClient().dio.put(
                            ApiConstants.updateProfile,
                            data: profilePayload,
                          );
                        } catch (e) {
                          debugPrint('[VendorOnboarding] updateProfile error: $e');
                        }

                        // 2. Submit onboarding step 5 if available
                        try {
                          await ApiClient().dio.post(
                            '/users/me/onboarding/5',
                            data: {'step': 5, 'data': {}},
                          );
                        } catch (e) {
                          debugPrint('[VendorOnboarding] onboarding/5 error: $e');
                        }

                        final newProfile = VendorProfile(
                          businessName: _businessNameController.text,
                          taxId: _taxIdController.text,
                          serviceCategory: _serviceCategory,
                          phone: _phoneController.text,
                          email: _emailController.text,
                          address: _addressController.text,
                          city: _cityController.text,
                          state: _stateController.text,
                          zip: _zipController.text,
                          tradeLicenseStatus: _tradeLicenseStatus,
                          proofOfInsuranceStatus: _insuranceStatus,
                          w9FormStatus: _w9Status,
                          bankName: _bankNameController.text,
                          routingNumber: _routingController.text,
                          accountNumber: _accountController.text,
                          isOnboarded: true,
                        );

                        await ref
                            .read(vendorProvider.notifier)
                            .submitOnboarding(newProfile);

                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(
                          context,
                          '/account_status',
                        );
                      } catch (e) {
                        debugPrint('[VendorOnboarding] Submission error: $e');
                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(
                          context,
                          '/account_status',
                        );
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    }
                  },
                ),
                SizedBox(height: h * 0.012),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      await ApiClient().clearToken();
                      if (!context.mounted) return;
                      Navigator.pushReplacementNamed(
                        context,
                        '/role_selection',
                      );
                    },
                    child: Text(
                      'Cancel and Exit',
                      style: TextStyle(
                        fontSize: w * 0.038,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: h * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContainer({
    required String title,
    required IconData icon,
    required double width,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(width * 0.045),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.secondary, size: width * 0.05),
              SizedBox(width: width * 0.02),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: width * 0.033,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.border, height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text, double w) {
    return Text(
      text,
      style: TextStyle(
        fontSize: w * 0.035,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    required double w,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.015),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(fontSize: w * 0.035, color: AppColors.textHint),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textHint,
            size: w * 0.055,
          ),
          style: TextStyle(fontSize: w * 0.035, color: AppColors.textPrimary),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ),
    );
  }

  }
