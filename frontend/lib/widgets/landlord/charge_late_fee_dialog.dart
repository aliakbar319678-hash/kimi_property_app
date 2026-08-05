import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class ChargeLateFeeDialog extends StatefulWidget {
  final double overdueAmount;
  final String tenantName;

  const ChargeLateFeeDialog({super.key, required this.overdueAmount, required this.tenantName});

  @override
  State<ChargeLateFeeDialog> createState() => _ChargeLateFeeDialogState();
}

class _ChargeLateFeeDialogState extends State<ChargeLateFeeDialog> {
  final _amountCtrl = TextEditingController(text: '50.00');
  final _reasonCtrl = TextEditingController(text: 'Late Rent Payment');
  bool _extendDueDate = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Charge Late Fee', style: AppTextStyles.headlineMedium),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Tenant: ${widget.tenantName}', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Current Overdue:', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  Text('\$${widget.overdueAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Late Fee Amount (\$)', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Reason', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reasonCtrl,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Extend Due Date by 3 Days'),
              value: _extendDueDate,
              onChanged: (val) => setState(() => _extendDueDate = val),
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primary,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Late fee applied successfully!')));
              },
              child: const Text('Apply Late Fee', style: AppTextStyles.buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
