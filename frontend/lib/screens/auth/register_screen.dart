import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/auth_provider.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_input_field.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_primary_button.dart';

// ── Country data ──────────────────────────────────────────────────────────────
class _Country {
  final String name;
  final String flag;
  final String dialCode;
  final String isoCode;
  final int maxDigits;

  const _Country({
    required this.name,
    required this.flag,
    required this.dialCode,
    required this.isoCode,
    required this.maxDigits,
  });
}

const List<_Country> _countries = [
  _Country(name: 'Pakistan', flag: '🇵🇰', dialCode: '+92', isoCode: 'PK', maxDigits: 10),
  _Country(name: 'United States', flag: '🇺🇸', dialCode: '+1', isoCode: 'US', maxDigits: 10),
  _Country(name: 'United Kingdom', flag: '🇬🇧', dialCode: '+44', isoCode: 'GB', maxDigits: 10),
  _Country(name: 'India', flag: '🇮🇳', dialCode: '+91', isoCode: 'IN', maxDigits: 10),
  _Country(name: 'United Arab Emirates', flag: '🇦🇪', dialCode: '+971', isoCode: 'AE', maxDigits: 9),
  _Country(name: 'Saudi Arabia', flag: '🇸🇦', dialCode: '+966', isoCode: 'SA', maxDigits: 9),
  _Country(name: 'Canada', flag: '🇨🇦', dialCode: '+1', isoCode: 'CA', maxDigits: 10),
  _Country(name: 'Australia', flag: '🇦🇺', dialCode: '+61', isoCode: 'AU', maxDigits: 9),
  _Country(name: 'Germany', flag: '🇩🇪', dialCode: '+49', isoCode: 'DE', maxDigits: 11),
  _Country(name: 'France', flag: '🇫🇷', dialCode: '+33', isoCode: 'FR', maxDigits: 9),
  _Country(name: 'Turkey', flag: '🇹🇷', dialCode: '+90', isoCode: 'TR', maxDigits: 10),
  _Country(name: 'Bangladesh', flag: '🇧🇩', dialCode: '+880', isoCode: 'BD', maxDigits: 10),
  _Country(name: 'Afghanistan', flag: '🇦🇫', dialCode: '+93', isoCode: 'AF', maxDigits: 9),
  _Country(name: 'Qatar', flag: '🇶🇦', dialCode: '+974', isoCode: 'QA', maxDigits: 8),
  _Country(name: 'Kuwait', flag: '🇰🇼', dialCode: '+965', isoCode: 'KW', maxDigits: 8),
  _Country(name: 'Bahrain', flag: '🇧🇭', dialCode: '+973', isoCode: 'BH', maxDigits: 8),
  _Country(name: 'Oman', flag: '🇴🇲', dialCode: '+968', isoCode: 'OM', maxDigits: 8),
  _Country(name: 'Jordan', flag: '🇯🇴', dialCode: '+962', isoCode: 'JO', maxDigits: 9),
  _Country(name: 'Malaysia', flag: '🇲🇾', dialCode: '+60', isoCode: 'MY', maxDigits: 10),
  _Country(name: 'Indonesia', flag: '🇮🇩', dialCode: '+62', isoCode: 'ID', maxDigits: 12),
  _Country(name: 'Nigeria', flag: '🇳🇬', dialCode: '+234', isoCode: 'NG', maxDigits: 10),
  _Country(name: 'South Africa', flag: '🇿🇦', dialCode: '+27', isoCode: 'ZA', maxDigits: 9),
  _Country(name: 'Kenya', flag: '🇰🇪', dialCode: '+254', isoCode: 'KE', maxDigits: 9),
  _Country(name: 'China', flag: '🇨🇳', dialCode: '+86', isoCode: 'CN', maxDigits: 11),
  _Country(name: 'Japan', flag: '🇯🇵', dialCode: '+81', isoCode: 'JP', maxDigits: 10),
];

// ── Country Picker Widget ────────────────────────────────────────────────────
class _PhoneInputField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String? errorText;

  const _PhoneInputField({
    super.key,
    required this.onChanged,
    this.errorText,
  });

  @override
  State<_PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<_PhoneInputField> {
  _Country _selected = _countries.first; // Default: Pakistan
  final TextEditingController _ctrl = TextEditingController();

  void _openCountryPicker() {
    final TextEditingController searchCtrl = TextEditingController();
    List<_Country> filtered = List.from(_countries);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Select Country',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchCtrl,
                    onChanged: (q) {
                      setModalState(() {
                        filtered = _countries
                            .where((c) =>
                                c.name.toLowerCase().contains(q.toLowerCase()) ||
                                c.dialCode.contains(q))
                            .toList();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search country or code...',
                      prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.inputBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Country list
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final c = filtered[i];
                      final isSelected = c.isoCode == _selected.isoCode;
                      return ListTile(
                        leading: Text(c.flag, style: const TextStyle(fontSize: 26)),
                        title: Text(c.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        trailing: Text(
                          c.dialCode,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: AppColors.primary.withValues(alpha: 0.06),
                        onTap: () {
                          setState(() {
                            _selected = c;
                            _ctrl.clear();
                          });
                          widget.onChanged('');
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(_selected.maxDigits),
            _PhoneNumberFormatter(groupSize: _selected.isoCode == 'PK' ? 3 : 3),
          ],
          onChanged: (val) {
            final digits = val.replaceAll(RegExp(r'\D'), '');
            widget.onChanged('${_selected.dialCode}$digits');
          },
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: _buildHint(),
            errorText: widget.errorText,
            prefixIcon: GestureDetector(
              onTap: _openCountryPicker,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_selected.flag, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 6),
                    Text(
                      _selected.dialCode,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textHint),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 24, color: Colors.grey.shade300),
                  ],
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Max ${_selected.maxDigits} digits · ${_selected.name}',
            style: const TextStyle(fontSize: 11, color: AppColors.textHint),
          ),
        ),
      ],
    );
  }

  String _buildHint() {
    // Build a sample number based on country
    switch (_selected.isoCode) {
      case 'PK': return '300 1234567';
      case 'US':
      case 'CA': return '555 000 0000';
      case 'GB': return '7700 900000';
      case 'AE': return '50 123 4567';
      case 'SA': return '50 123 4567';
      case 'IN': return '98765 43210';
      default: return '000 000 0000';
    }
  }
}

// ── Phone Number Text Formatter ───────────────────────────────────────────────
class _PhoneNumberFormatter extends TextInputFormatter {
  final int groupSize;
  _PhoneNumberFormatter({this.groupSize = 3});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % groupSize == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ── Register Screen ───────────────────────────────────────────────────────────
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final routeName = ModalRoute.of(context)?.settings.name;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (routeName == '/login') {
            ref.read(registerProvider.notifier).setLoginMode(true);
          } else if (routeName == '/register') {
            ref.read(registerProvider.notifier).setLoginMode(false);
          }
        }
      });
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerProvider);
    final notif = ref.read(registerProvider.notifier);
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.06;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top area (dark bg) ────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: pad,
                vertical: h * 0.025,
              ),
              child: Column(
                children: [
                  // Back arrow + title
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacementNamed(context, '/welcome');
                          }
                        },
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.white,
                          size: w * 0.05,
                        ),
                      ),
                      SizedBox(width: w * 0.03),
                      Text(
                        state.isLogin ? 'Sign In' : 'Create Account',
                        style: TextStyle(
                          fontSize: w * 0.048,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: h * 0.022),

                  // JOIN T&L subtitle
                  Text(
                    state.isLogin ? 'WELCOME BACK' : 'JOIN T&L',
                    style: TextStyle(
                      fontSize: w * 0.038,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                      letterSpacing: 1.5,
                    ),
                  ),

                  SizedBox(height: h * 0.008),

                  Text(
                    state.isLogin
                        ? 'Sign in to access your smart rental ecosystem\nand manage everything in one place.'
                        : 'Access your smart rental ecosystem and\nmanage everything in one place.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: w * 0.033,
                      color: AppColors.white.withValues(alpha: 0.65),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── White card (scrollable form) ──────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(pad, h * 0.03, pad, h * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.errorMessage!,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: h * 0.018),
                      ],

                      if (!state.isLogin) ...[
                        _FieldLabel('Full Name', w),
                        SizedBox(height: h * 0.008),
                        TLInputField(
                          key: const ValueKey('register_full_name'),
                          hint: 'Alex Thompson',
                          prefixIcon: Icons.person_outline_rounded,
                          onChanged: notif.updateFullName,
                          errorText: state.fullNameError,
                        ),
                        SizedBox(height: h * 0.018),

                        if (state.selectedRole == 'tenant') ...[
                          _FieldLabel('Username', w),
                          SizedBox(height: h * 0.008),
                          TLInputField(
                            key: const ValueKey('register_username'),
                            hint: 'alex123',
                            prefixIcon: Icons.account_circle_outlined,
                            onChanged: notif.updateUsername,
                            errorText: state.usernameError,
                          ),
                          SizedBox(height: h * 0.018),
                        ],
                      ],

                      // Email
                      _FieldLabel('Email', w),
                      SizedBox(height: h * 0.008),
                      TLInputField(
                        key: ValueKey(state.isLogin ? 'login_email' : 'register_email'),
                        hint: 'alex@example.com',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: notif.updateEmail,
                        errorText: state.emailError,
                      ),

                      SizedBox(height: h * 0.018),

                      // Phone (Only show in register)
                      if (!state.isLogin) ...[
                        _FieldLabel('Phone Number', w),
                        SizedBox(height: h * 0.008),
                        _PhoneInputField(
                          key: const ValueKey('register_phone'),
                          onChanged: notif.updatePhone,
                          errorText: state.phoneError,
                        ),
                        SizedBox(height: h * 0.018),
                      ],

                      // Password
                      _FieldLabel('Password', w),
                      SizedBox(height: h * 0.008),
                      TLInputField(
                        key: ValueKey(state.isLogin ? 'login_password' : 'register_password'),
                        hint: '••••••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscure: state.obscurePassword,
                        onChanged: notif.updatePassword,
                        errorText: state.passwordError,
                        helperText: state.isLogin
                            ? null
                            : 'Must be at least 8 characters with one special symbol.',
                        suffixIcon: GestureDetector(
                          onTap: notif.toggleObscure,
                          child: Icon(
                            state.obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.022),

                      // Terms checkbox (Only show in register)
                      if (!state.isLogin) ...[
                        GestureDetector(
                          onTap: notif.toggleTerms,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: w * 0.05,
                                height: w * 0.05,
                                decoration: BoxDecoration(
                                  color: state.agreeToTerms
                                      ? AppColors.primary
                                      : AppColors.white,
                                  border: Border.all(
                                    color: state.agreeToTerms
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: state.agreeToTerms
                                    ? Icon(
                                        Icons.check_rounded,
                                        color: AppColors.white,
                                        size: w * 0.033,
                                      )
                                    : null,
                              ),
                              SizedBox(width: w * 0.03),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: w * 0.033,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                    children: [
                                      const TextSpan(text: 'I agree to the '),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          color: AppColors.secondary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: w * 0.033,
                                        ),
                                      ),
                                      const TextSpan(text: '\nand '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          color: AppColors.secondary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: w * 0.033,
                                        ),
                                      ),
                                      const TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: h * 0.03),
                      ],

                      // Continue button
                      TLPrimaryButton(
                        label: state.isLogin ? 'Sign In' : 'Continue',
                        isLoading: state.isLoading,
                        trailing: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.white,
                          size: 18,
                        ),
                        onTap: () async {
                          FocusScope.of(context).unfocus(); // Dismiss keyboard to prevent overflow during transition
                          if (!state.isLogin && !state.agreeToTerms) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('You must agree to the terms to continue'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          final wasLogin = state.isLogin;
                          final success = await notif.submit();
                          if (!context.mounted) return;

                          final freshState = ref.read(registerProvider);

                          if (success) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            if (wasLogin) {
                              if (freshState.selectedRole == 'landlord') {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/landlord_home', (r) => false);
                              } else if (freshState.selectedRole == 'vendor') {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/vendor_home', (r) => false);
                              } else {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/home', (r) => false);
                              }
                            } else {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/otp', (r) => false);
                            }
                          } else {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    freshState.errorMessage ??
                                        'Authentication failed'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                      ),

                      SizedBox(height: h * 0.025),

                      // Sign In / Sign Up link toggle
                      Center(
                        child: GestureDetector(
                          onTap: notif.toggleMode,
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: w * 0.034,
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                TextSpan(
                                  text: state.isLogin
                                      ? "Don't have an account? "
                                      : 'Already have an account? ',
                                ),
                                TextSpan(
                                  text: state.isLogin ? 'Sign Up' : 'Sign In',
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: w * 0.034,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                          child: const Text(
                            'Explore Properties as Guest',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: w * 0.036,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }
}
