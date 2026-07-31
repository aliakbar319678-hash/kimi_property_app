import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class ReleaseEscrowResult {
  final String workOrderId;
  final String vendorId;
  final double amount;
  final String notes;

  ReleaseEscrowResult({
    required this.workOrderId,
    required this.vendorId,
    required this.amount,
    required this.notes,
  });
}

class ReleaseEscrowDialog extends StatefulWidget {
  final String workOrderId;
  final String vendorName;
  final String vendorId;
  final double jobCost;

  const ReleaseEscrowDialog({
    super.key,
    required this.workOrderId,
    required this.vendorName,
    required this.vendorId,
    required this.jobCost,
  });

  static Future<ReleaseEscrowResult?> show(
    BuildContext context, {
    required String workOrderId,
    required String vendorName,
    required String vendorId,
    required double jobCost,
  }) {
    return showDialog<ReleaseEscrowResult>(
      context: context,
      builder: (ctx) => ReleaseEscrowDialog(
        workOrderId: workOrderId,
        vendorName: vendorName,
        vendorId: vendorId,
        jobCost: jobCost,
      ),
    );
  }

  @override
  State<ReleaseEscrowDialog> createState() => _ReleaseEscrowDialogState();
}

class _ReleaseEscrowDialogState extends State<ReleaseEscrowDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountCtrl;
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: widget.jobCost.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
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
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Release Vendor Escrow', style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.bold)),
                Text('Vendor: ${widget.vendorName}', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Escrow Balance Held:', style: TextStyle(fontSize: 12)),
                    Text('\$${widget.jobCost.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14)),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              const Text('Release Amount (\$)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  fillColor: AppColors.inputBg,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 14),

              const Text('Release Notes / Work Approval Reference', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g. Work inspected and verified complete by property manager.',
                  fillColor: AppColors.inputBg,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                ReleaseEscrowResult(
                  workOrderId: widget.workOrderId,
                  vendorId: widget.vendorId,
                  amount: double.tryParse(_amountCtrl.text.trim()) ?? widget.jobCost,
                  notes: _notesCtrl.text.trim(),
                ),
              );
            }
          },
          child: const Text('Release Funds to Vendor', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
