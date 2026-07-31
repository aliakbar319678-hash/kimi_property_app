import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class ManualPaymentFormData {
  final String tenantName;
  final double amount;
  final String paymentMethod;
  final String referenceNumber;
  final DateTime paymentDate;
  final String notes;

  ManualPaymentFormData({
    required this.tenantName,
    required this.amount,
    required this.paymentMethod,
    required this.referenceNumber,
    required this.paymentDate,
    required this.notes,
  });
}

class RecordManualPaymentDialog extends StatefulWidget {
  const RecordManualPaymentDialog({super.key});

  static Future<ManualPaymentFormData?> show(BuildContext context) {
    return showDialog<ManualPaymentFormData>(
      context: context,
      builder: (ctx) => const RecordManualPaymentDialog(),
    );
  }

  @override
  State<RecordManualPaymentDialog> createState() => _RecordManualPaymentDialogState();
}

class _RecordManualPaymentDialogState extends State<RecordManualPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tenantNameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController(text: '1500');
  final _refNumCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _paymentMethod = 'cash';
  DateTime _paymentDate = DateTime.now();

  @override
  void dispose() {
    _tenantNameCtrl.dispose();
    _amountCtrl.dispose();
    _refNumCtrl.dispose();
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
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Record Offline Payment',
              style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.bold),
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
              _FieldLabel('Tenant Name / Unit'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tenantNameCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. Sarah Jenkins (Unit 4B)',
                  fillColor: AppColors.inputBg,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Amount Received (\$)'),
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Method'),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _paymentMethod,
                          decoration: InputDecoration(
                            fillColor: AppColors.inputBg,
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'cash', child: Text('Cash')),
                            DropdownMenuItem(value: 'check', child: Text('Check')),
                            DropdownMenuItem(value: 'bank_wire', child: Text('Bank Wire')),
                            DropdownMenuItem(value: 'money_order', child: Text('Money Order')),
                          ],
                          onChanged: (val) => setState(() => _paymentMethod = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _FieldLabel('Check / Wire Reference # (Optional)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _refNumCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. Check #94012',
                  fillColor: AppColors.inputBg,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 14),

              _FieldLabel('Payment Date'),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _paymentDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 90)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _paymentDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.inputBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(DateFormat('MMM dd, yyyy').format(_paymentDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              _FieldLabel('Receipt Notes / Remarks'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. Received full month rent for July.',
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
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                ManualPaymentFormData(
                  tenantName: _tenantNameCtrl.text.trim(),
                  amount: double.tryParse(_amountCtrl.text.trim()) ?? 0.0,
                  paymentMethod: _paymentMethod,
                  referenceNumber: _refNumCtrl.text.trim(),
                  paymentDate: _paymentDate,
                  notes: _notesCtrl.text.trim(),
                ),
              );
            }
          },
          child: const Text('Record & Generate Receipt', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _FieldLabel(String label) {
    return Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12));
  }
}
