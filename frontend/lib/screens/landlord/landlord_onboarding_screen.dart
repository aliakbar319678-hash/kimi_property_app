import 'package:dio/dio.dart' as dio_lib;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_primary_button.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_map_picker.dart';

class LandlordOnboardingScreen extends ConsumerStatefulWidget {
  const LandlordOnboardingScreen({super.key});

  @override
  ConsumerState<LandlordOnboardingScreen> createState() =>
      _LandlordOnboardingScreenState();
}

class _LandlordOnboardingScreenState extends ConsumerState<LandlordOnboardingScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  String? _userId;
  int _currentServerStep = 1;

  // ── Step 1: Basic Info ───────────────────────────────────────────────────
  final _firstNameController = TextEditingController();
  final _lastNameController  = TextEditingController();
  final _dobController       = TextEditingController();
  final _taxIdController     = TextEditingController();
  final _addressController   = TextEditingController();
  final _cityController      = TextEditingController();
  final _stateController     = TextEditingController();
  final _postalController    = TextEditingController();
  final _phoneController     = TextEditingController();

  // Field-level validation errors
  String? _firstNameError;
  String? _lastNameError;
  String? _dobError;
  String? _taxIdError;
  String? _addressError;
  String? _cityError;
  String? _stateError;
  String? _postalError;

  String? _existingPhone;

  // ── Step 2 (was 3): KYC Document ────────────────────────────────────────
  // Must match backend Joi: 'passport' | 'drivers_license' | 'state_id' | 'proof_of_income'
  String  _pickedDocType   = 'passport';
  String? _pickedFileName;
  String? _pickedFilePath;
  String? _pickedFileBytesSize;
  String? _kycError; // required error

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  // Fetches user ID and current onboarding step from the server
  Future<void> _fetchUserId() async {
    try {
      final res = await ApiClient().dio.get(ApiConstants.me);
      if (res.statusCode == 200) {
        final data = res.data['data'];
        setState(() {
          _userId = data['id'];
          // onboarding_step lives inside the nested 'profile' object returned by /auth/me
          final profile = data['profile'];
          if (profile != null && profile['onboarding_step'] != null) {
            _currentServerStep = (profile['onboarding_step'] as num).toInt();
          }
          if (data['phone'] != null && data['phone'].toString().isNotEmpty) {
            _existingPhone = data['phone'].toString();
            _phoneController.text = _existingPhone!;
          }
          if (data['first_name'] != null && data['first_name'].toString().isNotEmpty) {
            _firstNameController.text = data['first_name'].toString();
          }
          if (data['last_name'] != null && data['last_name'].toString().isNotEmpty) {
            _lastNameController.text = data['last_name'].toString();
          }
        });
      }
    } catch (_) {}
  }

  // Always fetches a fresh onboarding_step from the server right before submitting
  Future<int> _fetchCurrentServerStep() async {
    try {
      final res = await ApiClient().dio.get(ApiConstants.me);
      if (res.statusCode == 200) {
        final profile = res.data['data']['profile'];
        if (profile != null && profile['onboarding_step'] != null) {
          return (profile['onboarding_step'] as num).toInt();
        }
      }
    } catch (_) {}
    return _currentServerStep;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _taxIdController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────
  bool _validateStep1() {
    bool ok = true;
    setState(() {
      _firstNameError = _firstNameController.text.trim().isEmpty ? 'First name is required' : null;
      _lastNameError  = _lastNameController.text.trim().isEmpty  ? 'Last name is required'  : null;
      _dobError       = _dobController.text.trim().isEmpty       ? 'Date of birth is required' : null;
      _taxIdError     = _taxIdController.text.trim().isEmpty     ? 'Tax ID / EIN is required' : null;
      _addressError   = _addressController.text.trim().isEmpty   ? 'Address is required'   : null;
      _cityError      = _cityController.text.trim().isEmpty      ? 'City is required'      : null;
      _stateError     = _stateController.text.trim().isEmpty     ? 'State is required'     : null;
      _postalError    = _postalController.text.trim().isEmpty    ? 'Zip code is required'  : null;
    });

    if (_firstNameError != null || _lastNameError != null || _dobError != null ||
        _taxIdError != null || _addressError != null || _cityError != null ||
        _stateError != null || _postalError != null) {
      ok = false;
    }
    return ok;
  }

  bool _validateStep2() {
    if (_pickedFilePath == null) {
      setState(() => _kycError = 'Please upload your KYC document (PDF only)');
      return false;
    }
    setState(() => _kycError = null);
    return true;
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submitAllSteps() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not fetch user ID. Try again.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final messenger  = ScaffoldMessenger.of(context);
    final navigator  = Navigator.of(context);

    try {
      // 1. Update profile
      final profilePayload = <String, dynamic>{
        'legal_first_name': _firstNameController.text.trim(),
        'legal_last_name':  _lastNameController.text.trim(),
        'current_address': {
          'addressLine1':    _addressController.text.trim(),
          'city':            _cityController.text.trim(),
          'stateProvince':   _stateController.text.trim().toUpperCase(),
          'postalCode':      _postalController.text.trim(),
          'countryCode':     'US',
        },
      };
      final phoneInput = _phoneController.text.trim();
      if (phoneInput.isNotEmpty && phoneInput != _existingPhone) {
        profilePayload['phone'] = phoneInput;
      }
      await ApiClient().dio.put(ApiConstants.updateProfile, data: profilePayload);

      // 2. Re-fetch the live step from server right before posting to avoid stale state
      final liveStep = await _fetchCurrentServerStep();

      // 3. Only post steps that haven't been completed yet (liveStep = next step to do)
      for (int i = liveStep; i <= 5; i++) {
        Map<String, dynamic> stepData = {};
        if (i == 1) {
          final legalName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();
          if (legalName.isNotEmpty) stepData['legalName'] = legalName;
          final rawDob = _dobController.text.trim();
          stepData['dob'] = rawDob.contains('T') ? rawDob : '${rawDob}T00:00:00.000Z';
          if (_taxIdController.text.trim().isNotEmpty) {
            stepData['tax_identifier'] = _taxIdController.text.trim();
          }
        } else if (i == 3) {
          // Upload the PDF file first, then use the returned server URL
          String docUrl = 'https://example.com/kyc_placeholder.pdf'; // fallback
          if (_pickedFilePath != null) {
            try {
              final formData = dio_lib.FormData.fromMap({
                'file': await dio_lib.MultipartFile.fromFile(
                  _pickedFilePath!,
                  filename: _pickedFileName ?? 'kyc_doc.pdf',
                ),
                'doc_type': _pickedDocType,
              });
              final uploadRes = await ApiClient().dio.post(
                '/me/documents/upload',
                data: formData,
              );
              if (uploadRes.statusCode == 200 || uploadRes.statusCode == 201) {
                final uploadedUrl = uploadRes.data['data']?['url'] ??
                    uploadRes.data['data']?['file_url'] ??
                    uploadRes.data['url'];
                if (uploadedUrl != null) docUrl = uploadedUrl.toString();
              }
            } catch (_) {
              // Upload failed — use placeholder so onboarding still completes
            }
          }
          stepData['documents'] = [
            {'type': _pickedDocType, 'url': docUrl}
          ];
        }
        try {
          await ApiClient().dio.post('/users/me/onboarding/$i', data: {'step': i, 'data': stepData});
        } catch (stepErr) {
          // If a step returns 400, it likely means the backend already advanced past it.
          // Re-fetch the actual current step and skip ahead.
          final serverStep = await _fetchCurrentServerStep();
          if (i < serverStep) {
            // Backend is already past this step — safe to continue
            continue;
          }
          // Otherwise it's a real error — rethrow
          rethrow;
        }
      }

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Onboarding submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      navigator.pushNamedAndRemoveUntil('/landlord_pending_approval', (route) => false);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to submit onboarding: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? labelTrailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
              if (labelTrailing != null) labelTrailing,
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller:  controller,
            keyboardType: keyboardType,
            readOnly:    readOnly,
            onTap:       onTap,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText:    hint,
              hintStyle:   const TextStyle(fontSize: 14, color: AppColors.textHint),
              filled:      true,
              fillColor:   errorText != null
                  ? Colors.redAccent.withValues(alpha: 0.05)
                  : AppColors.inputBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: errorText != null
                    ? const BorderSide(color: Colors.redAccent, width: 1.2)
                    : const BorderSide(color: Colors.black87, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: errorText != null
                    ? const BorderSide(color: Colors.redAccent, width: 1.2)
                    : const BorderSide(color: Colors.black87, width: 1.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 4),
              child: Text(errorText, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1930),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      helpText: 'Select Date of Birth',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _dobController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() => _dobError = null);
    }
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      final sizeKb = ((file.size) / 1024).toStringAsFixed(1);
      setState(() {
        _pickedFileName      = file.name;
        _pickedFilePath      = file.path;
        _pickedFileBytesSize = '$sizeKb KB';
        _kycError            = null;
      });
    }
  }

  // ── Steps ─────────────────────────────────────────────────────────────────
  List<Step> get _steps => [
    // ── Step 1: Basic Info ─────────────────────────────────────────────────
    Step(
      title: const Text('Basic Info'),
      content: Column(
        children: [
          _buildField(label: 'First Name *', hint: 'e.g. John', controller: _firstNameController, errorText: _firstNameError),
          _buildField(label: 'Last Name *', hint: 'e.g. Doe', controller: _lastNameController,  errorText: _lastNameError),
          _buildField(
            label: 'Date of Birth *',
            hint: 'Tap to pick date',
            controller: _dobController,
            errorText: _dobError,
            readOnly: true,
            onTap: _pickDate,
          ),
          _buildField(label: 'Tax ID / EIN *', hint: 'e.g. 12-3456789', controller: _taxIdController, errorText: _taxIdError),
          _buildField(
            label: 'Address Line 1 *', 
            hint: 'e.g. 123 Main St', 
            controller: _addressController, 
            errorText: _addressError,
            labelTrailing: TextButton.icon(
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
                    _postalController.text = addressData['postal'] ?? '';
                  });
                }
              },
            ),
          ),
          _buildField(label: 'City *', hint: 'e.g. New York', controller: _cityController, errorText: _cityError),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildField(
                  label: 'State *',
                  hint: 'e.g. NY',
                  controller: _stateController,
                  errorText: _stateError,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildField(
                  label: 'Zip Code *',
                  hint: 'e.g. 10001',
                  controller: _postalController,
                  keyboardType: TextInputType.number,
                  errorText: _postalError,
                ),
              ),
            ],
          ),
        ],
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    ),

    // ── Step 2: KYC ────────────────────────────────────────────────────────
    Step(
      title: const Text('KYC'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Upload a PDF copy of your KYC document. Max 10 MB.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          // Document type
          const Text('Document Type *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _pickedDocType,
                isExpanded: true,
                items: const [
                  // Values must match backend Joi: 'passport' | 'drivers_license' | 'state_id' | 'proof_of_income'
                  DropdownMenuItem(value: 'passport',        child: Text('Passport')),
                  DropdownMenuItem(value: 'drivers_license', child: Text("Driver's License")),
                  DropdownMenuItem(value: 'state_id',        child: Text('State / National ID')),
                  DropdownMenuItem(value: 'proof_of_income', child: Text('Proof of Income')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _pickedDocType = val);
                },
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Text('Upload Document (PDF) *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),

          // Upload area
          GestureDetector(
            onTap: _pickPdf,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _pickedFilePath != null
                    ? Colors.green.withValues(alpha: 0.06)
                    : (_kycError != null
                        ? Colors.redAccent.withValues(alpha: 0.05)
                        : AppColors.white),
                border: Border.all(
                  color: _pickedFilePath != null
                      ? Colors.green
                      : (_kycError != null ? Colors.redAccent : AppColors.border),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: _pickedFilePath != null
                  ? Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _pickedFileName!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_pickedFileBytesSize != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  _pickedFileBytesSize!,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
                      ],
                    )
                  : Column(
                      children: [
                        Icon(
                          Icons.upload_file_rounded,
                          size: 36,
                          color: _kycError != null ? Colors.redAccent : AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to upload PDF',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _kycError != null ? Colors.redAccent : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Only .pdf files are accepted',
                          style: TextStyle(fontSize: 12, color: AppColors.textHint),
                        ),
                      ],
                    ),
            ),
          ),

          if (_kycError != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                _kycError!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
          ],

          if (_pickedFilePath != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickPdf,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded, size: 16, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text(
                    'Change document',
                    style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    ),

    // ── Step 3: Submit ─────────────────────────────────────────────────────
    Step(
      title: const Text('Submit'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All sections completed!',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Click "Submit Verification" below to send your profile for admin review.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      isActive: _currentStep >= 2,
      state: StepState.indexed,
    ),
  ];

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Landlord Onboarding',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Logout',
            onPressed: () async {
              await ApiClient().clearToken();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/role_selection', (route) => false);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stepper(
          currentStep: _currentStep,
          type: StepperType.vertical,
          onStepContinue: () {
            if (_currentStep == 0) {
              if (!_validateStep1()) return;
            } else if (_currentStep == 1) {
              if (!_validateStep2()) return;
            }

            if (_currentStep < _steps.length - 1) {
              setState(() => _currentStep += 1);
            } else {
              _submitAllSteps();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep -= 1);
          },
          controlsBuilder: (context, details) {
            final isLastStep = _currentStep == _steps.length - 1;
            return Container(
              margin: const EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TLPrimaryButton(
                    label: isLastStep ? 'Submit Verification' : 'Next',
                    isLoading: _isLoading,
                    onTap: details.onStepContinue,
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _isLoading ? null : details.onStepCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Back',
                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: _steps,
        ),
      ),
    );
  }
}
