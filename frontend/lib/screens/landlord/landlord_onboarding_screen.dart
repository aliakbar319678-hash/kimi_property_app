import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_primary_button.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';

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

  // Step 1: Basic Info
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController(text: '1990-01-01');
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController(text: 'NY');
  final _postalController = TextEditingController(text: '10001');
  final _ssnController = TextEditingController(text: '1234');
  final _taxIdController = TextEditingController();

  String? _existingPhone;

  // Step 2: Employment
  final _employerController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _incomeController = TextEditingController();

  // Step 3: Documents
  String _pickedDocType = 'passport';
  String? _pickedFileName;
  String? _mockFileUrl;

  // Step 4: Preferences
  bool _emailNotif = true;
  bool _smsNotif = true;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    try {
      final res = await ApiClient().dio.get(ApiConstants.me);
      if (res.statusCode == 200) {
        final data = res.data['data'];
        setState(() {
          _userId = data['id'];
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

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalController.dispose();
    _ssnController.dispose();
    _taxIdController.dispose();
    _employerController.dispose();
    _jobTitleController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _submitAllSteps() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not fetch user ID. Try again.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      // 1. Update Profile (User Service)
      final Map<String, dynamic> profilePayload = {
        'legal_first_name': _firstNameController.text.trim(),
        'legal_last_name': _lastNameController.text.trim(),
        'current_address': {
          'addressLine1': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'stateProvince': _stateController.text.trim().toUpperCase(),
          'postalCode': _postalController.text.trim(),
          'countryCode': 'US',
        },
      };

      final phoneInput = _phoneController.text.trim();
      if (phoneInput.isNotEmpty && phoneInput != _existingPhone) {
        profilePayload['phone'] = phoneInput;
      }

      await ApiClient().dio.put(
        ApiConstants.updateProfile,
        data: profilePayload,
      );

      // Step 1 API
      final legalName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();
      final step1Data = <String, dynamic>{};

      if (legalName.isNotEmpty) {
        step1Data['legalName'] = legalName;
      }
      step1Data['dob'] = '1990-01-01T00:00:00.000Z';

      if (RegExp(r'^\+1\d{10}$').hasMatch(phoneInput)) {
        step1Data['phone'] = phoneInput;
      }

      final taxInput = _taxIdController.text.trim();
      if (taxInput.isNotEmpty) {
        step1Data['tax_identifier'] = taxInput;
      }

      await ApiClient().dio.post('/users/me/onboarding/1', data: {
        'step': 1,
        'data': step1Data
      });

      // Step 2 API
      final step2Data = <String, dynamic>{};
      if (_employerController.text.trim().isNotEmpty ||
          _jobTitleController.text.trim().isNotEmpty ||
          _incomeController.text.trim().isNotEmpty) {
        step2Data['employment'] = {
          if (_employerController.text.trim().isNotEmpty) 'employer': _employerController.text.trim(),
          if (_jobTitleController.text.trim().isNotEmpty) 'title': _jobTitleController.text.trim(),
          if (_incomeController.text.trim().isNotEmpty) 'income': _incomeController.text.trim(),
        };
      }

      await ApiClient().dio.post('/users/me/onboarding/2', data: {
        'step': 2,
        'data': step2Data
      });

      // Step 3 API
      await ApiClient().dio.post('/users/me/onboarding/3', data: {
        'step': 3,
        'data': {
          'documents': [
            {
              'type': _pickedDocType,
              'url': _mockFileUrl ?? 'https://example.com/dummy_doc.pdf'
            }
          ]
        }
      });

      // Step 4 API
      await ApiClient().dio.post('/users/me/onboarding/4', data: {
        'step': 4,
        'data': {
          'preferences': {
            'email_notifications': _emailNotif,
            'sms_notifications': _smsNotif,
          }
        }
      });

      // Step 5 API (Finalize)
      await ApiClient().dio.post('/users/me/onboarding/5', data: {
        'step': 5,
        'data': {}
      });

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

  Widget _buildField({
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
          filled: true,
          fillColor: AppColors.inputBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  List<Step> get _steps {
    return [
      Step(
        title: const Text('Basic Info'),
        content: Column(
          children: [
            _buildField(hint: 'First Name', controller: _firstNameController),
            _buildField(hint: 'Last Name', controller: _lastNameController),
            _buildField(hint: 'Date of Birth (YYYY-MM-DD)', controller: _dobController),
            _buildField(hint: 'Phone Number (+1...)', controller: _phoneController, keyboardType: TextInputType.phone),
            _buildField(hint: 'SSN (Last 4 digits)', controller: _ssnController, keyboardType: TextInputType.number),
            _buildField(hint: 'Tax ID / EIN (Optional)', controller: _taxIdController),
            _buildField(hint: 'Address Line 1', controller: _addressController),
            _buildField(hint: 'City', controller: _cityController),
            Row(
              children: [
                Expanded(child: _buildField(hint: 'State (e.g. NY)', controller: _stateController)),
                const SizedBox(width: 8),
                Expanded(child: _buildField(hint: 'Zip Code', controller: _postalController, keyboardType: TextInputType.number)),
              ],
            ),
          ],
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Employment & Income'),
        content: Column(
          children: [
            _buildField(hint: 'Employer Name', controller: _employerController),
            _buildField(hint: 'Job Title', controller: _jobTitleController),
            _buildField(hint: 'Annual Income', controller: _incomeController, keyboardType: TextInputType.number),
          ],
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Documents'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Document Type', style: TextStyle(fontWeight: FontWeight.w600)),
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
                    DropdownMenuItem(value: 'passport', child: Text('Passport')),
                    DropdownMenuItem(value: 'drivers_license', child: Text('Driver\'s License')),
                    DropdownMenuItem(value: 'state_id', child: Text('State ID')),
                    DropdownMenuItem(value: 'proof_of_income', child: Text('Proof of Income')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      if (val != null) _pickedDocType = val;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                );
                if (result != null) {
                  setState(() {
                    _pickedFileName = result.files.single.name;
                    // Simulate upload success
                    _mockFileUrl = 'https://example.com/uploads/${result.files.single.name}';
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _pickedFileName != null ? Colors.green.withValues(alpha: 0.1) : AppColors.white,
                  border: Border.all(color: _pickedFileName != null ? Colors.green : AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _pickedFileName != null ? Icons.check_circle : Icons.upload_file,
                      color: _pickedFileName != null ? Colors.green : AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _pickedFileName ?? 'Tap to Upload File',
                        style: TextStyle(
                          color: _pickedFileName != null ? Colors.green[700] : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Preferences'),
        content: Column(
          children: [
            SwitchListTile(
              title: const Text('Email Notifications'),
              value: _emailNotif,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _emailNotif = val),
            ),
            SwitchListTile(
              title: const Text('SMS Notifications'),
              value: _smsNotif,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _smsNotif = val),
            ),
          ],
        ),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Submit'),
        content: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have completed all sections.'),
            SizedBox(height: 8),
            Text('Click the button below to submit your profile for admin verification.', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
        isActive: _currentStep >= 4,
        state: StepState.indexed,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Landlord Setup',
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
            if (_currentStep < _steps.length - 1) {
              setState(() => _currentStep += 1);
            } else {
              _submitAllSteps();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
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
                      child: const Text('Back', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                    ),
                  ]
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
