import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_phone_input_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_user_avatar.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_appbar.dart';
import 'package:tenant_and_landlord_application/provider/basic_profile_provider.dart';

import '../widgets/common/tl_primary_button.dart';
import '../widgets/common/onboarding_progress_bar.dart';
import '../widgets/common/tl_map_picker.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (newValue.selection.baseOffset < oldValue.selection.baseOffset) {
      return newValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final nonSlashIndex = i - text.substring(0, i).split('/').length + 1;
      if (nonSlashIndex == 1 && i == 1 && text.length == 2) {
        buffer.write('/');
      } else if (nonSlashIndex == 3 && i == 4 && text.length == 5) {
        buffer.write('/');
      }
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class BasicProfileScreen extends ConsumerWidget {
  const BasicProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(basicProfileProvider);
    final notif = ref.read(basicProfileProvider.notifier);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;
    final errors = state.fieldErrors;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: TLAppBar(
        trailing: Row(
          children: [
            Icon(
              Icons.filter_list_rounded,
              size: w * 0.055,
              color: AppColors.textPrimary,
            ),
            SizedBox(width: w * 0.03),
            TLUserAvatar(radius: w * 0.045),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: EdgeInsets.fromLTRB(pad, h * 0.015, pad, h * 0.02),
            child: const OnboardingProgressBar(
              stepLabel: 'ONBOARDING',
              stepTitle: 'Step 1/5: Personal Info',
              progress: 0.20,
              percentLabel: '20% Complete',
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
              padding: EdgeInsets.fromLTRB(
                pad,
                pad,
                pad,
                pad + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                    padding: EdgeInsets.all(pad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.primary,
                              size: w * 0.05,
                            ),
                            SizedBox(width: w * 0.02),
                            Text(
                              'PERSONAL INFORMATION',
                              style: TextStyle(
                                fontSize: w * 0.033,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: h * 0.006),
                        Text(
                          'Please provide your legal details as they appear on your identification documents.',
                          style: TextStyle(
                            fontSize: w * 0.033,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: h * 0.025),
                        _FieldLabel('Full Legal Name *', w),
                        SizedBox(height: h * 0.008),
                        _InputField(
                          hint: 'Johnathan Doe',
                          initialValue: state.fullLegalName,
                          onChanged: notif.updateFullLegalName,
                          errorText: errors['fullLegalName'],
                        ),
                        SizedBox(height: h * 0.018),
                        _FieldLabel('Date of Birth *', w),
                        SizedBox(height: h * 0.008),
                        _InputField(
                          hint: 'Tap to pick date',
                          initialValue: state.dateOfBirth,
                          onChanged: notif.updateDateOfBirth,
                          readOnly: true,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              final d = date.day.toString().padLeft(2, '0');
                              final m = date.month.toString().padLeft(2, '0');
                              final y = date.year.toString();
                              notif.updateDateOfBirth('$d/$m/$y');
                            }
                          },
                          errorText: errors['dateOfBirth'],
                        ),
                        SizedBox(height: h * 0.018),
                        _FieldLabel('Phone Number *', w),
                        SizedBox(height: h * 0.008),
                        TLPhoneInputField(
                          initialValue: state.phoneNumber,
                          onChanged: notif.updatePhoneNumber,
                          errorText: errors['phoneNumber'],
                        ),
                        SizedBox(height: h * 0.018),
                        _FieldLabel('Email Address', w),
                        SizedBox(height: h * 0.008),
                        _InputField(
                          initialValue: state.emailAddress,
                          hint: 'alex@example.com',
                          prefixIcon: Icons.mail_outline_rounded,
                          onChanged: notif.updateEmailAddress,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: h * 0.025),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _FieldLabel('Current Residential Address *', w),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(Icons.map_rounded, size: 18, color: AppColors.primary),
                              label: const Text('Pick on Map', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                              onPressed: () async {
                                // Returns Map<String, String> with street, city, state, postal, country
                                final addressData = await Navigator.push<Map<String, String>>(
                                  context,
                                  MaterialPageRoute(builder: (_) => const TLMapPicker()),
                                );
                                if (addressData != null) {
                                  notif.updateFullAddress(
                                    street: addressData['street'] ?? '',
                                    city: addressData['city'] ?? '',
                                    stateProv: addressData['state'] ?? '',
                                    postal: addressData['postal'] ?? '',
                                    countryName: addressData['country'] ?? '',
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: h * 0.008),
                        _InputField(
                          initialValue: state.streetAddress,
                          hint: 'Street Address (e.g. 123 Main St, Apt 4B)',
                          prefixIcon: Icons.location_on_outlined,
                          onChanged: notif.updateStreetAddress,
                          errorText: errors['streetAddress'],
                        ),
                        SizedBox(height: h * 0.012),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('City *', w),
                                  SizedBox(height: 4),
                                  _InputField(
                                    initialValue: state.city,
                                    hint: 'e.g. Lahore',
                                    onChanged: notif.updateCity,
                                    errorText: errors['city'],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: w * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('State / Province', w),
                                  SizedBox(height: 4),
                                  _InputField(
                                    initialValue: state.stateProvince,
                                    hint: 'e.g. Punjab',
                                    onChanged: notif.updateStateProvince,
                                    errorText: errors['stateProvince'],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: h * 0.012),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Postal / ZIP Code', w),
                                  SizedBox(height: 4),
                                  _InputField(
                                    initialValue: state.postalCode,
                                    hint: 'e.g. 54000',
                                    onChanged: notif.updatePostalCode,
                                    errorText: errors['postalCode'],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: w * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Country *', w),
                                  SizedBox(height: 4),
                                  _InputField(
                                    initialValue: state.country,
                                    hint: 'e.g. Pakistan',
                                    onChanged: notif.updateCountry,
                                    errorText: errors['country'],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                  Container(
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
                    padding: EdgeInsets.all(pad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.emergency_rounded,
                              color: AppColors.secondary,
                              size: w * 0.045,
                            ),
                            SizedBox(width: w * 0.02),
                            Text(
                              'EMERGENCY CONTACT',
                              style: TextStyle(
                                fontSize: w * 0.033,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: h * 0.02),
                        _FieldLabel('Contact Name *', w),
                        SizedBox(height: h * 0.008),
                        _InputField(
                          initialValue: state.contactName,
                          hint: 'Full Name',
                          onChanged: notif.updateContactName,
                          errorText: errors['contactName'],
                        ),
                        SizedBox(height: h * 0.018),
                        _FieldLabel('Relationship *', w),
                        SizedBox(height: h * 0.008),
                        _DropdownField(
                          hint: 'Select Relation',
                          value: state.relationship.isEmpty
                              ? null
                              : state.relationship,
                          items: const [
                            'Parent',
                            'Sibling',
                            'Spouse',
                            'Friend',
                            'Other',
                          ],
                          onChanged: notif.updateRelationship,
                          w: w,
                          errorText: errors['relationship'],
                        ),
                        SizedBox(height: h * 0.018),
                        _FieldLabel('Emergency Phone *', w),
                        SizedBox(height: h * 0.008),
                        TLPhoneInputField(
                          initialValue: state.emergencyPhone,
                          onChanged: notif.updateEmergencyPhone,
                          errorText: errors['emergencyPhone'],
                        ),
                        SizedBox(height: h * 0.025),
                        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
                          Container(
                            padding: EdgeInsets.all(pad * 0.8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                                SizedBox(width: w * 0.02),
                                Expanded(
                                  child: Text(
                                    state.errorMessage!,
                                    style: const TextStyle(color: Colors.red, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: h * 0.02),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: state.isLoading
                                    ? null
                                    : () async {
                                        final ok = await notif.saveAsDraft();
                                        if (context.mounted && ok) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Draft saved successfully!')),
                                          );
                                        }
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: BorderSide(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: h * 0.016,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Save as Draft',
                                  style: TextStyle(
                                    fontSize: w * 0.038,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: w * 0.03),
                            Expanded(
                              child: TLPrimaryButton(
                                label: 'Next',
                                trailing: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                isLoading: state.isLoading,
                                onTap: () async {
                                  final ok = await notif.next();
                                  if (context.mounted && ok) {
                                    Navigator.pushNamed(
                                      context,
                                      '/employment',
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                  Container(
                    padding: EdgeInsets.all(pad * 0.8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.04),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: w * 0.045,
                          color: AppColors.secondary,
                        ),
                        SizedBox(width: w * 0.025),
                        Expanded(
                          child: Text(
                            'Your information is encrypted and only shared with property managers once you explicitly apply for a listing.',
                            style: TextStyle(
                              fontSize: w * 0.032,
                              color: AppColors.secondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
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

class _FieldLabel extends StatelessWidget {
  final String text;
  final double w;
  const _FieldLabel(this.text, this.w);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: w * 0.035,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
  );
}

class _InputField extends StatefulWidget {
  final String hint;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final String? errorText;
  final String? initialValue;
  final bool readOnly;
  final VoidCallback? onTap;

  const _InputField({
    
    required this.hint,
    this.prefixIcon,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.initialValue,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }
  @override
  void didUpdateWidget(covariant _InputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != null &&
        widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: widget.hint,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: 17, color: AppColors.textHint)
            : null,
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final double w;
  final String? errorText;

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.w,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.035),
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? Colors.red : AppColors.border,
            ),
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
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}
