import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class TLInputField extends StatelessWidget {
  final String hint;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final Widget? suffixIcon;
  final bool obscure;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;

  const TLInputField({
    super.key,
    required this.hint,
    this.prefixIcon,
    this.prefixWidget,
    this.suffixIcon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.helperText,
    this.errorText,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixWidget ?? (prefixIcon != null ? Icon(prefixIcon, size: 18, color: AppColors.textHint) : null),
            suffixIcon: suffixIcon,
            errorText: errorText,
          ),
        ),
        if (helperText != null && errorText == null) ...[
          const SizedBox(height: 6),
          Text(helperText!, style: AppTextStyles.bodySmall),
        ],
      ],
    );
  }
}
