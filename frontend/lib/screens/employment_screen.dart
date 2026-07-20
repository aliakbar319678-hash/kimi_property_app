import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_appbar.dart';
import 'package:tenant_and_landlord_application/provider/employment_provider.dart';

import '../../widgets/common/tl_primary_button.dart';
import '../../widgets/common/onboarding_progress_bar.dart';

class EmploymentScreen extends ConsumerWidget {
  const EmploymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(employmentProvider);
    final notif = ref.read(employmentProvider.notifier);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: TLAppBar(
        showBack: true,
        trailing: Row(
          children: [
            Icon(
              Icons.filter_list_rounded,
              size: w * 0.055,
              color: AppColors.textPrimary,
            ),
            SizedBox(width: w * 0.03),
            CircleAvatar(
              radius: w * 0.045,
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/100?img=3',
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            color: AppColors.white,
            padding: EdgeInsets.fromLTRB(pad, h * 0.015, pad, h * 0.02),
            child: const OnboardingProgressBar(
              stepLabel: 'ONBOARDING',
              stepTitle: 'Step 2/3: Employment',
              progress: 0.40,
              percentLabel: '40% Complete',
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    padding: EdgeInsets.all(pad * 0.9),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                        left: BorderSide(color: AppColors.secondary, width: 3),
                      ),
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
                          Icons.info_outline_rounded,
                          size: w * 0.045,
                          color: AppColors.secondary,
                        ),
                        SizedBox(width: w * 0.025),
                        Expanded(
                          child: Text(
                            'Please provide your current employment details. This information helps property managers verify your income stability and lease eligibility.',
                            style: TextStyle(
                              fontSize: w * 0.033,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: h * 0.025),

                  _FieldLabel('Company Name *', w),
                  SizedBox(height: h * 0.008),
                  _InputField(
                    hint: 'e.g. Acme Tech Solutions',
                    prefixIcon: Icons.business_outlined,
                    onChanged: notif.updateCompanyName,
                    errorText: state.fieldErrors['companyName'],
                  ),

                  SizedBox(height: h * 0.018),

                  _FieldLabel('Annual Gross Salary *', w),
                  SizedBox(height: h * 0.008),
                  _InputField(
                    hint: 'e.g. 85000',
                    prefixIcon: Icons.account_balance_wallet_outlined,
                    onChanged: notif.updateAnnualSalary,
                    keyboardType: TextInputType.number,
                    errorText: state.fieldErrors['annualSalary'],
                  ),

                  SizedBox(height: h * 0.018),

                  _FieldLabel('Employment Length *', w),
                  SizedBox(height: h * 0.008),
                  _DropdownField(
                    value: state.employmentLength.isEmpty ? null : state.employmentLength,
                    items: const [
                      'Less than 1 year',
                      '1-2 years',
                      '2-5 years',
                      '5+ years',
                      'Self-employed',
                    ],
                    onChanged: notif.updateEmploymentLength,
                    w: w,
                    prefixIcon: Icons.calendar_today_outlined,
                    errorText: state.fieldErrors['employmentLength'],
                  ),

                  SizedBox(height: h * 0.018),

                  _FieldLabel('Other Income Sources *', w),
                  SizedBox(height: h * 0.008),
                  _InputField(
                    hint: 'e.g. Freelance, Investments (or "None")',
                    prefixIcon: Icons.attach_money_rounded,
                    onChanged: notif.updateOtherIncome,
                    errorText: state.fieldErrors['otherIncome'],
                  ),

                  SizedBox(height: h * 0.025),

                  // Upload box
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(pad * 1.2),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.border,
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: w * 0.14,
                          height: w * 0.14,
                          decoration: BoxDecoration(
                            color: AppColors.inputBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.upload_file_rounded,
                            size: w * 0.07,
                            color: AppColors.secondary,
                          ),
                        ),
                        SizedBox(height: h * 0.015),
                        Text(
                          'Upload Proof of Income *',
                          style: TextStyle(
                            fontSize: w * 0.042,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: h * 0.008),
                        Text(
                          'Required: Upload your most recent pay stub or offer letter. (PDF, JPG up to 10MB)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: w * 0.031,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: h * 0.018),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await notif.pickFile();
                          },
                          icon: Icon(
                            state.uploadedFileName != null
                                ? Icons.check_circle_outline
                                : Icons.upload_file_rounded,
                            size: 18,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: state.fieldErrors['uploadedFile'] != null
                                ? Colors.red
                                : state.uploadedFileName != null
                                    ? Colors.green
                                    : AppColors.secondary,
                            side: BorderSide(
                              color: state.fieldErrors['uploadedFile'] != null
                                  ? Colors.red
                                  : state.uploadedFileName != null
                                      ? Colors.green
                                      : AppColors.secondary,
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: w * 0.07,
                              vertical: h * 0.012,
                            ),
                          ),
                          label: Text(
                            state.uploadedFileName ?? 'Select File (PDF / JPG)',
                            style: TextStyle(
                              fontSize: w * 0.035,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (state.fieldErrors['uploadedFile'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              state.fieldErrors['uploadedFile']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: h * 0.025),

                  // Back + Next
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          size: w * 0.042,
                          color: AppColors.textSecondary,
                        ),
                        label: Text(
                          'Back',
                          style: TextStyle(
                            fontSize: w * 0.038,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: w * 0.42,
                        child: TLPrimaryButton(
                          label: 'Next',
                          isLoading: state.isLoading,
                          trailing: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.white,
                            size: 16,
                          ),
                          onTap: state.isLoading
                              ? null
                              : () async {
                                  final success = await notif.next();
                                  if (!context.mounted) return;
                                  if (success) {
                                    Navigator.pushNamed(context, '/preferences');
                                  } else if (state.errorMessage != null) {
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(state.errorMessage!),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: h * 0.025),

                  // Bottom info cards
                  _InfoCard(
                    icon: Icons.shield_outlined,
                    iconColor: AppColors.primary,
                    title: 'Secure Transmission',
                    body:
                        'Your employment data is encrypted and only shared with prospective landlords.',
                    w: w,
                  ),
                  SizedBox(height: h * 0.015),
                  _InfoCard(
                    icon: Icons.help_outline_rounded,
                    iconColor: AppColors.secondary,
                    title: 'Need Help?',
                    body:
                        'Contact our support team if you have non-traditional income sources.',
                    w: w,
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final double w;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.w,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: w * 0.05, color: iconColor),
          SizedBox(width: w * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: w * 0.035,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: w * 0.031,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
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

class _InputField extends StatelessWidget {
  final String hint;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final String? errorText;

  const _InputField({
    required this.hint,
    this.prefixIcon,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 17, color: AppColors.textHint)
            : null,
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final double w;
  final IconData? prefixIcon;
  final String? errorText;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.w,
    this.prefixIcon,
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
            border: Border.all(color: errorText != null ? Colors.red : AppColors.border),
          ),
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                Icon(prefixIcon, size: 17, color: AppColors.textHint),
                SizedBox(width: w * 0.025),
              ],
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    hint: Text(
                      'Select duration',
                      style: TextStyle(fontSize: w * 0.035, color: AppColors.textHint),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textHint,
                      size: w * 0.055,
                    ),
                    style: TextStyle(
                      fontSize: w * 0.035,
                      color: AppColors.textPrimary,
                    ),
                    items: items
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => v != null ? onChanged(v) : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
