import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';

class LandlordPayoutSettingsScreen extends ConsumerStatefulWidget {
  const LandlordPayoutSettingsScreen({super.key});

  @override
  ConsumerState<LandlordPayoutSettingsScreen> createState() => _LandlordPayoutSettingsScreenState();
}

class _LandlordPayoutSettingsScreenState extends ConsumerState<LandlordPayoutSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController _bankNameCtrl = TextEditingController();
  final TextEditingController _accountHolderCtrl = TextEditingController();
  final TextEditingController _ibanCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPayoutAccount();
  }

  Future<void> _fetchPayoutAccount() async {
    try {
      final resp = await ApiClient().dio.get('/finance/payout-account');
      final data = resp.data['data'] as Map<String, dynamic>?;
      if (data != null) {
        _bankNameCtrl.text = data['bank_name']?.toString() ?? '';
        _accountHolderCtrl.text = data['account_holder']?.toString() ?? '';
        _ibanCtrl.text = data['iban_account_no']?.toString() ?? '';
      }
    } catch (e) {
      debugPrint('Error loading payout info: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePayoutAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await ApiClient().dio.post('/finance/payout-account', data: {
        'bankName': _bankNameCtrl.text.trim(),
        'accountHolder': _accountHolderCtrl.text.trim(),
        'ibanAccountNo': _ibanCtrl.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payout settings saved successfully! 🎉'),
            backgroundColor: Color(0xFF27AE60),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save payout settings: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bank Payout Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance_outlined, color: AppColors.primary, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Configure your direct deposit details to receive automated monthly rent disbursements.',
                                style: TextStyle(fontSize: 13, color: AppColors.textPrimary.withValues(alpha: 0.8), height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField('Bank Name', _bankNameCtrl, Icons.account_balance, hint: 'e.g. Chase, HSBC, Wells Fargo'),
                      const SizedBox(height: 16),
                      _buildTextField('Account Holder Title', _accountHolderCtrl, Icons.person_outline, hint: 'Full Name on Account'),
                      const SizedBox(height: 16),
                      _buildTextField('IBAN / Account Number', _ibanCtrl, Icons.numbers_outlined, hint: 'Account or IBAN Number'),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _savePayoutAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Save Payout Settings',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon, {required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return '$label is required';
            return null;
          },
        ),
      ],
    );
  }
}
