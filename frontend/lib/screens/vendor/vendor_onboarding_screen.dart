import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_primary_button.dart';
import 'package:tenant_and_landlord_application/provider/vendor_provider.dart';
import 'package:tenant_and_landlord_application/provider/vendor_state.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_map_picker.dart';

class VendorOnboardingScreen extends ConsumerStatefulWidget {
  const VendorOnboardingScreen({super.key});

  @override
  ConsumerState<VendorOnboardingScreen> createState() =>
      _VendorOnboardingScreenState();
}

class _VendorOnboardingScreenState
    extends ConsumerState<VendorOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  // All controllers start EMPTY — no fake data
  final _businessNameController = TextEditingController();
  final _taxIdController = TextEditingController();
  String _serviceCategory = 'Plumbing';

  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  // Document state
  File? _tradeLicenseFile;
  File? _insuranceFile;
  String? _tradeLicenseUrl;
  String? _insuranceUrl;
  bool _uploadingTradeLicense = false;
  bool _uploadingInsurance = false;

  bool _isLoading = false;
  bool _isFetchingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// Load real email/phone from backend to pre-fill the form
  Future<void> _loadUserProfile() async {
    try {
      final res = await ApiClient().dio.get(ApiConstants.me);
      if (res.statusCode == 200 && mounted) {
        final data = res.data['data'] as Map<String, dynamic>? ?? {};
        final email = data['email']?.toString() ?? '';
        final phone = data['phone']?.toString() ?? '';
        final displayName = data['display_name']?.toString() ?? '';
        setState(() {
          if (email.isNotEmpty) _emailController.text = email;
          if (phone.isNotEmpty) _phoneController.text = phone;
          if (displayName.isNotEmpty) _businessNameController.text = displayName;
          _isFetchingProfile = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isFetchingProfile = false);
    }
  }

  /// Upload a file to the backend KYC endpoint and return the URL
  Future<String?> _uploadDocument(File file, String docType) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });
      final resp = await ApiClient().dio.post(
        ApiConstants.uploadsKycDocument(docType),
        data: formData,
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return resp.data['data']?['url']?.toString();
      }
    } catch (e) {
      debugPrint('[VendorOnboarding] Upload error ($docType): $e');
    }
    return null;
  }

  Future<void> _pickTradeLicense() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    setState(() {
      _tradeLicenseFile = file;
      _uploadingTradeLicense = true;
      _tradeLicenseUrl = null;
    });
    final url = await _uploadDocument(file, 'trade_license');
    if (mounted) {
      setState(() {
        _tradeLicenseUrl = url;
        _uploadingTradeLicense = false;
      });
    }
  }

  Future<void> _pickInsurance() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    setState(() {
      _insuranceFile = file;
      _uploadingInsurance = true;
      _insuranceUrl = null;
    });
    final url = await _uploadDocument(file, 'proof_of_insurance');
    if (mounted) {
      setState(() {
        _insuranceUrl = url;
        _uploadingInsurance = false;
      });
    }
  }

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    if (_isFetchingProfile) {
      return const Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

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
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/role_selection');
            }
          },
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
                  'Provide your professional details to begin receiving job invitations and payments.',
                  style: TextStyle(
                    fontSize: w * 0.035,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: h * 0.025),

                // ── Card 1: Business Information ──────────────────────────
                _buildCardContainer(
                  title: 'Business Information',
                  icon: Icons.business_center_rounded,
                  width: w,
                  children: [
                    _buildFieldLabel('Business / Company Name', w),
                    SizedBox(height: h * 0.008),
                    _buildInputField(
                      controller: _businessNameController,
                      hint: 'e.g., Apex Plumbing Solutions LLC',
                    ),
                    SizedBox(height: h * 0.018),
                    _buildFieldLabel('Tax ID / EIN (optional)', w),
                    SizedBox(height: h * 0.008),
                    _buildInputField(
                      controller: _taxIdController,
                      hint: 'e.g., 12-3456789',
                      required: false,
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
                        'Carpentry',
                        'Painting',
                        'Cleaning',
                        'Landscaping',
                        'Security',
                        'Other',
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

                // ── Card 2: Contact Information ───────────────────────────
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFieldLabel('Street Address', w),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.map_rounded, size: 18, color: AppColors.primary),
                          label: const Text('Pick on Map', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                          onPressed: () async {
                            final addressData = await Navigator.push<Map<String, String>>(
                              context,
                              MaterialPageRoute(builder: (_) => const TLMapPicker()),
                            );
                            if (addressData != null) {
                              setState(() {
                                _addressController.text = addressData['street'] ?? '';
                                _cityController.text = addressData['city'] ?? '';
                                _stateController.text = addressData['state'] ?? '';
                                _zipController.text = addressData['postal'] ?? '';
                              });
                            }
                          },
                        ),
                      ],
                    ),
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

                // ── Card 3: Documents Upload ──────────────────────────────
                _buildCardContainer(
                  title: 'Verification Documents',
                  icon: Icons.verified_user_rounded,
                  width: w,
                  children: [
                    Text(
                      'Upload your trade license and proof of insurance to get verified faster. These are optional but recommended.',
                      style: TextStyle(
                        fontSize: w * 0.032,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: h * 0.018),

                    // Trade License
                    _buildDocumentUploadTile(
                      label: 'Trade License',
                      icon: Icons.card_membership_rounded,
                      file: _tradeLicenseFile,
                      uploadedUrl: _tradeLicenseUrl,
                      isUploading: _uploadingTradeLicense,
                      onTap: _pickTradeLicense,
                      w: w,
                      h: h,
                    ),
                    SizedBox(height: h * 0.015),

                    // Proof of Insurance
                    _buildDocumentUploadTile(
                      label: 'Proof of Insurance',
                      icon: Icons.security_rounded,
                      file: _insuranceFile,
                      uploadedUrl: _insuranceUrl,
                      isUploading: _uploadingInsurance,
                      onTap: _pickInsurance,
                      w: w,
                      h: h,
                    ),
                  ],
                ),
                SizedBox(height: h * 0.025),

                // ── Submit Button ─────────────────────────────────────────
                TLPrimaryButton(
                  label: 'Submit Application',
                  isLoading: _isLoading,
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isLoading = true);
                      try {
                        final newProfile = VendorProfile(
                          businessName: _businessNameController.text.trim(),
                          taxId: _taxIdController.text.trim(),
                          serviceCategory: _serviceCategory,
                          phone: _phoneController.text.trim(),
                          email: _emailController.text.trim(),
                          address: _addressController.text.trim(),
                          city: _cityController.text.trim(),
                          state: _stateController.text.trim(),
                          zip: _zipController.text.trim(),
                          isOnboarded: true,
                        );

                        await ref
                            .read(vendorProvider.notifier)
                            .submitOnboarding(
                              newProfile,
                              tradeLicenseUrl: _tradeLicenseUrl,
                              insuranceUrl: _insuranceUrl,
                            );

                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(
                          context,
                          '/account_status',
                        );
                      } catch (e) {
                        debugPrint('[VendorOnboarding] Submission error: $e');
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Submission failed. Please try again.\n${e.toString()}',
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
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

  // ── Document Upload Tile ──────────────────────────────────────────────────
  Widget _buildDocumentUploadTile({
    required String label,
    required IconData icon,
    required File? file,
    required String? uploadedUrl,
    required bool isUploading,
    required VoidCallback onTap,
    required double w,
    required double h,
  }) {
    final bool isUploaded = uploadedUrl != null && uploadedUrl.isNotEmpty;

    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.04,
          vertical: h * 0.016,
        ),
        decoration: BoxDecoration(
          color: isUploaded
              ? AppColors.success.withValues(alpha: 0.06)
              : AppColors.inputBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUploaded
                ? AppColors.success.withValues(alpha: 0.4)
                : AppColors.border,
            width: isUploaded ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(w * 0.025),
              decoration: BoxDecoration(
                color: isUploaded
                    ? AppColors.success.withValues(alpha: 0.12)
                    : AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUploaded ? Icons.check_circle_rounded : icon,
                color: isUploaded ? AppColors.success : AppColors.primary,
                size: w * 0.05,
              ),
            ),
            SizedBox(width: w * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: w * 0.036,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    isUploading
                        ? 'Uploading...'
                        : isUploaded
                            ? 'Uploaded successfully ✓'
                            : file != null
                                ? 'Upload failed — tap to retry'
                                : 'Tap to upload (optional)',
                    style: TextStyle(
                      fontSize: w * 0.03,
                      color: isUploaded
                          ? AppColors.success
                          : isUploading
                              ? AppColors.secondary
                              : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isUploading)
              SizedBox(
                width: w * 0.05,
                height: w * 0.05,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.secondary,
                ),
              )
            else
              Icon(
                isUploaded
                    ? Icons.check_rounded
                    : Icons.upload_file_rounded,
                color: isUploaded ? AppColors.success : AppColors.textHint,
                size: w * 0.05,
              ),
          ],
        ),
      ),
    );
  }

  // ── Shared builders ───────────────────────────────────────────────────────

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
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      validator: required
          ? (val) {
              if (val == null || val.trim().isEmpty) {
                return 'This field is required';
              }
              return null;
            }
          : null,
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
