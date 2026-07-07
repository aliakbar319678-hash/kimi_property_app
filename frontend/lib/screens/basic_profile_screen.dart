import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_appbar.dart';
import 'package:tenant_and_landlord_application/provider/basic_profile_provider.dart';

import '../widgets/common/tl_primary_button.dart';
import '../widgets/common/onboarding_progress_bar.dart';

class BasicProfileScreen extends ConsumerWidget {
  const BasicProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(basicProfileProvider);
    final notif = ref.read(basicProfileProvider.notifier);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: TLAppBar(
        trailing: Row(
          children: [
            CircleAvatar(
              radius: w * 0.045,
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/100?img=3',
              ),
            ),
            SizedBox(width: w * 0.03),
            Icon(
              Icons.menu_rounded,
              size: w * 0.06,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Progress bar ─────────────────────────
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

          // ── Scrollable form ──────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // White card
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
                        // Section header
                        Text(
                          'Basic Profile',
                          style: TextStyle(
                            fontSize: w * 0.042,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
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

                        _FieldLabel('Full Legal Name', w),
                        SizedBox(height: h * 0.008),
                        _InputField(
                          hint: 'Johnathan Doe',
                          onChanged: notif.updateFullLegalName,
                        ),

                        SizedBox(height: h * 0.018),

                        _FieldLabel('Date of Birth', w),
                        SizedBox(height: h * 0.008),
                        _InputField(
                          hint: 'mm/dd/yyyy',
                          onChanged: notif.updateDateOfBirth,
                          keyboardType: TextInputType.datetime,
                        ),

                        SizedBox(height: h * 0.018),

                        _FieldLabel('Phone Number', w),
                        SizedBox(height: h * 0.008),
                        _InputField(
                          hint: '+1 (555) 000-0000',
                          prefixIcon: Icons.phone_outlined,
                          onChanged: notif.updatePhoneNumber,
                          keyboardType: TextInputType.phone,
                        ),

                        SizedBox(height: h * 0.018),

                        _FieldLabel('Email Address', w),
                        SizedBox(height: h * 0.008),
                        _InputField(
                          hint: 'alex@example.com',
                          prefixIcon: Icons.mail_outline_rounded,
                          onChanged: notif.updateEmailAddress,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        SizedBox(height: h * 0.018),

                        _FieldLabel('Current Residential Address', w),
                        SizedBox(height: h * 0.008),
                        _InputField(
                          hint: 'Street address, City, State, ZIP code',
                          prefixIcon: Icons.location_on_outlined,
                          onChanged: notif.updateResidentialAddress,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: h * 0.02),

                  // Emergency Contact card
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

                        _FieldLabel('Contact Name', w),
                        SizedBox(height: h * 0.008),
                        _InputField(
                          hint: 'Full Name',
                          onChanged: notif.updateContactName,
                        ),

                        SizedBox(height: h * 0.018),

                        _FieldLabel('Relationship', w),
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
                        ),

                        SizedBox(height: h * 0.018),

                        _FieldLabel('Emergency Phone', w),
                        SizedBox(height: h * 0.008),
                        _InputField(
                          hint: '+1 (555) 000-0000',
                          onChanged: notif.updateEmergencyPhone,
                          keyboardType: TextInputType.phone,
                        ),

                        SizedBox(height: h * 0.025),

                        // Save as Draft + Next row
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: notif.saveAsDraft,
                                child: Text(
                                  'Save as Draft',
                                  style: TextStyle(
                                    fontSize: w * 0.038,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: w * 0.03),
                            Expanded(
                              flex: 2,
                              child: TLPrimaryButton(
                                label: 'Next',
                                isLoading: state.isLoading,
                                trailing: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                                onTap: () async {
                                  await notif.next();
                                  if (context.mounted) Navigator.pushNamed(context, '/employment');
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: h * 0.02),

                  // Info banner
                  Container(
                    padding: EdgeInsets.all(pad * 0.9),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
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

// ── Shared local widgets ──────────────────────

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

class _InputField extends StatelessWidget {
  final String hint;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final int maxLines;

  const _InputField({
    required this.hint,
    this.prefixIcon,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 17, color: AppColors.textHint)
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

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.w,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.035),
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
