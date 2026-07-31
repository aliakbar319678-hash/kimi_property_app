import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class DepositRefundResult {
  final double originalDeposit;
  final double cleaningDeduction;
  final double damageDeduction;
  final double unpaidRentDeduction;
  final double netRefundAmount;
  final String notes;

  DepositRefundResult({
    required this.originalDeposit,
    required this.cleaningDeduction,
    required this.damageDeduction,
    required this.unpaidRentDeduction,
    required this.netRefundAmount,
    required this.notes,
  });
}

class DepositRefundCalculatorDialog extends StatefulWidget {
  final String tenantName;
  final double initialDeposit;

  const DepositRefundCalculatorDialog({
    super.key,
    required this.tenantName,
    required this.initialDeposit,
  });

  static Future<DepositRefundResult?> show(
    BuildContext context, {
    required String tenantName,
    required double initialDeposit,
  }) {
    return showDialog<DepositRefundResult>(
      context: context,
      builder: (ctx) => DepositRefundCalculatorDialog(
        tenantName: tenantName,
        initialDeposit: initialDeposit,
      ),
    );
  }

  @override
  State<DepositRefundCalculatorDialog> createState() => _DepositRefundCalculatorDialogState();
}

class _DepositRefundCalculatorDialogState extends State<DepositRefundCalculatorDialog> {
  late TextEditingController _depositCtrl;
  final TextEditingController _cleaningCtrl = TextEditingController(text: '0');
  final TextEditingController _damageCtrl = TextEditingController(text: '0');
  final TextEditingController _unpaidRentCtrl = TextEditingController(text: '0');
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _depositCtrl = TextEditingController(text: widget.initialDeposit.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _depositCtrl.dispose();
    _cleaningCtrl.dispose();
    _damageCtrl.dispose();
    _unpaidRentCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _netRefund {
    final dep = double.tryParse(_depositCtrl.text.trim()) ?? 0.0;
    final clean = double.tryParse(_cleaningCtrl.text.trim()) ?? 0.0;
    final dmg = double.tryParse(_damageCtrl.text.trim()) ?? 0.0;
    final rent = double.tryParse(_unpaidRentCtrl.text.trim()) ?? 0.0;

    final totalDeductions = clean + dmg + rent;
    final net = dep - totalDeductions;
    return net < 0 ? 0.0 : net;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final net = _netRefund;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calculate_rounded, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deposit Refund Calculator', style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.bold)),
                Text('Tenant: ${widget.tenantName}', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel('Held Security Deposit (\$)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _depositCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                fillColor: AppColors.inputBg,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 14),

            const Text('Deductions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.error)),
            const SizedBox(height: 8),

            _FieldLabel('Deep Cleaning Charges (\$)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _cleaningCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                fillColor: AppColors.inputBg,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 10),

            _FieldLabel('Damage & Repair Costs (\$)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _damageCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                fillColor: AppColors.inputBg,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 10),

            _FieldLabel('Unpaid Rent / Utility Dues (\$)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _unpaidRentCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                fillColor: AppColors.inputBg,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 16),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Net Refund to Tenant:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('\$${net.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _FieldLabel('Itemized Deduction Notes'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Provide reasons for deductions to attach to move-out statement...',
                fillColor: AppColors.inputBg,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            Navigator.pop(
              context,
              DepositRefundResult(
                originalDeposit: double.tryParse(_depositCtrl.text.trim()) ?? widget.initialDeposit,
                cleaningDeduction: double.tryParse(_cleaningCtrl.text.trim()) ?? 0.0,
                damageDeduction: double.tryParse(_damageCtrl.text.trim()) ?? 0.0,
                unpaidRentDeduction: double.tryParse(_unpaidRentCtrl.text.trim()) ?? 0.0,
                netRefundAmount: net,
                notes: _notesCtrl.text.trim(),
              ),
            );
          },
          child: const Text('Finalize Statement & Refund', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _FieldLabel(String label) {
    return Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12));
  }
}
