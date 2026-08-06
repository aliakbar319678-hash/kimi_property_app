import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

// ── Country data ──────────────────────────────────────────────────────────────
class TLCountry {
  final String name;
  final String flag;
  final String dialCode;
  final String isoCode;
  final int maxDigits;

  const TLCountry({
    required this.name,
    required this.flag,
    required this.dialCode,
    required this.isoCode,
    required this.maxDigits,
  });
}

const List<TLCountry> tlCountries = [
  TLCountry(name: 'Pakistan', flag: '🇵🇰', dialCode: '+92', isoCode: 'PK', maxDigits: 10),
  TLCountry(name: 'United States', flag: '🇺🇸', dialCode: '+1', isoCode: 'US', maxDigits: 10),
  TLCountry(name: 'United Kingdom', flag: '🇬🇧', dialCode: '+44', isoCode: 'GB', maxDigits: 10),
  TLCountry(name: 'India', flag: '🇮🇳', dialCode: '+91', isoCode: 'IN', maxDigits: 10),
  TLCountry(name: 'United Arab Emirates', flag: '🇦🇪', dialCode: '+971', isoCode: 'AE', maxDigits: 9),
  TLCountry(name: 'Saudi Arabia', flag: '🇸🇦', dialCode: '+966', isoCode: 'SA', maxDigits: 9),
  TLCountry(name: 'Canada', flag: '🇨🇦', dialCode: '+1', isoCode: 'CA', maxDigits: 10),
  TLCountry(name: 'Australia', flag: '🇦🇺', dialCode: '+61', isoCode: 'AU', maxDigits: 9),
  TLCountry(name: 'Germany', flag: '🇩🇪', dialCode: '+49', isoCode: 'DE', maxDigits: 11),
  TLCountry(name: 'France', flag: '🇫🇷', dialCode: '+33', isoCode: 'FR', maxDigits: 9),
  TLCountry(name: 'Turkey', flag: '🇹🇷', dialCode: '+90', isoCode: 'TR', maxDigits: 10),
  TLCountry(name: 'Bangladesh', flag: '🇧🇩', dialCode: '+880', isoCode: 'BD', maxDigits: 10),
  TLCountry(name: 'Afghanistan', flag: '🇦🇫', dialCode: '+93', isoCode: 'AF', maxDigits: 9),
  TLCountry(name: 'Qatar', flag: '🇶🇦', dialCode: '+974', isoCode: 'QA', maxDigits: 8),
  TLCountry(name: 'Kuwait', flag: '🇰🇼', dialCode: '+965', isoCode: 'KW', maxDigits: 8),
  TLCountry(name: 'Bahrain', flag: '🇧🇭', dialCode: '+973', isoCode: 'BH', maxDigits: 8),
  TLCountry(name: 'Oman', flag: '🇴🇲', dialCode: '+968', isoCode: 'OM', maxDigits: 8),
  TLCountry(name: 'Jordan', flag: '🇯🇴', dialCode: '+962', isoCode: 'JO', maxDigits: 9),
  TLCountry(name: 'Malaysia', flag: '🇲🇾', dialCode: '+60', isoCode: 'MY', maxDigits: 10),
  TLCountry(name: 'Indonesia', flag: '🇮🇩', dialCode: '+62', isoCode: 'ID', maxDigits: 12),
  TLCountry(name: 'Nigeria', flag: '🇳🇬', dialCode: '+234', isoCode: 'NG', maxDigits: 10),
  TLCountry(name: 'South Africa', flag: '🇿🇦', dialCode: '+27', isoCode: 'ZA', maxDigits: 9),
  TLCountry(name: 'Kenya', flag: '🇰🇪', dialCode: '+254', isoCode: 'KE', maxDigits: 9),
  TLCountry(name: 'China', flag: '🇨🇳', dialCode: '+86', isoCode: 'CN', maxDigits: 11),
  TLCountry(name: 'Japan', flag: '🇯🇵', dialCode: '+81', isoCode: 'JP', maxDigits: 10),
];

// ── Country Picker Widget ────────────────────────────────────────────────────
class TLPhoneInputField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String? errorText;
  final String? initialValue;

  const TLPhoneInputField({
    super.key,
    required this.onChanged,
    this.errorText,
    this.initialValue,
  });

  @override
  State<TLPhoneInputField> createState() => _TLPhoneInputFieldState();
}

class _TLPhoneInputFieldState extends State<TLPhoneInputField> {
  TLCountry _selected = tlCountries.first; // Default: Pakistan
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _initializeValue();
  }

  void _initializeValue() {
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      final val = widget.initialValue!;
      // Find matching country code
      for (final c in tlCountries) {
        if (val.startsWith(c.dialCode)) {
          _selected = c;
          String remaining = val.substring(c.dialCode.length);
          // Format the remaining digits
          final digits = remaining.replaceAll(RegExp(r'\D'), '');
          final buffer = StringBuffer();
          final groupSize = _selected.isoCode == 'PK' ? 3 : 3;
          for (int i = 0; i < digits.length; i++) {
            if (i > 0 && i % groupSize == 0) buffer.write(' ');
            buffer.write(digits[i]);
          }
          _ctrl.text = buffer.toString();
          break;
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant TLPhoneInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue && _ctrl.text.isEmpty) {
      _initializeValue();
    }
  }

  void _openCountryPicker() {
    final TextEditingController searchCtrl = TextEditingController();
    List<TLCountry> filtered = List.from(tlCountries);

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
                        filtered = tlCountries
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
          ],
          onChanged: (val) {
            widget.onChanged('${_selected.dialCode}$val');
          },
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: _buildHint(),
            errorText: widget.errorText,
            filled: true,
            fillColor: AppColors.inputBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
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
class TLPhoneNumberFormatter extends TextInputFormatter {
  final int groupSize;
  TLPhoneNumberFormatter({this.groupSize = 3});

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
