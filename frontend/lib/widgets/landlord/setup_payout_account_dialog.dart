import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class SetupPayoutAccountDialog extends StatefulWidget {
  const SetupPayoutAccountDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => const SetupPayoutAccountDialog(),
    );
  }

  @override
  State<SetupPayoutAccountDialog> createState() => _SetupPayoutAccountDialogState();
}

class _SetupPayoutAccountDialogState extends State<SetupPayoutAccountDialog> {
  final TextEditingController _routingCtrl = TextEditingController();
  final TextEditingController _accountCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _routingCtrl.dispose();
    _accountCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (_routingCtrl.text.isEmpty || _accountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isSaving = true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_balance_rounded, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Setup Payout Account', style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Link a bank account to receive rent payments securely.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            
            const Text('Routing Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _routingCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '9 digit routing number',
                fillColor: AppColors.inputBg,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 14),

            const Text('Account Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _accountCtrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Account number',
                fillColor: AppColors.inputBg,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
          onPressed: _isSaving ? null : _saveAccount,
          child: _isSaving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Save & Link Account', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
