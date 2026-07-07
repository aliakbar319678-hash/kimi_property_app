import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_appbar.dart';
import 'package:tenant_and_landlord_application/provider/preferences_provider.dart';
import '../../widgets/common/tl_primary_button.dart';
import '../../widgets/common/onboarding_progress_bar.dart';

class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(preferencesProvider);
    final notif = ref.read(preferencesProvider.notifier);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: TLAppBar(
        showBack: true,
        subtitle: 'Onboarding',
        trailing: CircleAvatar(
          radius: w * 0.045,
          backgroundImage: const NetworkImage(
            'https://i.pravatar.cc/100?img=3',
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress
          Container(
            color: AppColors.white,
            padding: EdgeInsets.fromLTRB(pad, h * 0.015, pad, h * 0.02),
            child: const OnboardingProgressBar(
              stepLabel: 'Lifestyle Preferences',
              stepTitle: 'Step 3/3: Preferences',
              progress: 0.60,
              percentLabel: '60% Complete',
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pets card
                  _PreferenceCard(
                    icon: Icons.pets_rounded,
                    question: 'Pets?',
                    subtitle: 'Do you have pets?',
                    leftLabel: 'Yes',
                    rightLabel: 'No',
                    leftSelected: state.hasPets,
                    onLeft: () => notif.togglePets(true),
                    onRight: () => notif.togglePets(false),
                    w: w,
                    h: h,
                  ),

                  SizedBox(height: h * 0.018),

                  // Parking card
                  _PreferenceCard(
                    icon: Icons.directions_car_outlined,
                    question: 'Parking Required?',
                    subtitle: 'Need a space?',
                    leftLabel: 'No',
                    rightLabel: 'Yes',
                    leftSelected: !state.needsParking,
                    onLeft: () => notif.toggleParking(false),
                    onRight: () => notif.toggleParking(true),
                    w: w,
                    h: h,
                  ),

                  SizedBox(height: h * 0.025),

                  // Insurance + Utilities
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(pad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Insurance provider/details', w),
                        SizedBox(height: h * 0.01),
                        _InputField(
                          hint: 'e.g. State Farm, Policy #12345',
                          onChanged: notif.updateInsurance,
                        ),
                        SizedBox(height: h * 0.018),
                        _FieldLabel('Utilities Provider', w),
                        SizedBox(height: h * 0.01),
                        _InputField(
                          hint: 'e.g. National Grid, ConEd',
                          onChanged: notif.updateUtilities,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: h * 0.018),

                  // Special Needs
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(pad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Special Needs', w),
                        SizedBox(height: h * 0.006),
                        Text(
                          'Please specify any accessibility or specific housing requirements',
                          style: TextStyle(
                            fontSize: w * 0.031,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: h * 0.012),
                        TextField(
                          onChanged: notif.updateSpecialNeeds,
                          maxLines: 4,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            hintText:
                                'Describe any special needs or requests...',
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: h * 0.03),

                  TLPrimaryButton(
                    label: 'Next',
                    isLoading: state.isLoading,
                    trailing: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.white,
                      size: 16,
                    ),
                    onTap: () async {
                      await notif.next();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (r) => false,
                        );
                      }
                    },
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

// ── Yes/No preference card ────────────────────
class _PreferenceCard extends StatelessWidget {
  final IconData icon;
  final String question;
  final String subtitle;
  final String leftLabel;
  final String rightLabel;
  final bool leftSelected;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final double w;
  final double h;

  const _PreferenceCard({
    required this.icon,
    required this.question,
    required this.subtitle,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftSelected,
    required this.onLeft,
    required this.onRight,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: AppColors.secondary, width: 3)),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      padding: EdgeInsets.all(w * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: w * 0.1,
                height: w * 0.1,
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: w * 0.05, color: AppColors.secondary),
              ),
              SizedBox(width: w * 0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question,
                    style: TextStyle(
                      fontSize: w * 0.038,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: w * 0.031,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: h * 0.015),
          Row(
            children: [
              Expanded(
                child: _ToggleBtn(
                  label: leftLabel,
                  selected: leftSelected,
                  onTap: onLeft,
                  w: w,
                ),
              ),
              SizedBox(width: w * 0.03),
              Expanded(
                child: _ToggleBtn(
                  label: rightLabel,
                  selected: !leftSelected,
                  onTap: onRight,
                  w: w,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double w;

  const _ToggleBtn({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.w,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: w * 0.03),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.inputBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: w * 0.037,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
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
  final ValueChanged<String>? onChanged;

  const _InputField({required this.hint, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(hintText: hint),
    );
  }
}

