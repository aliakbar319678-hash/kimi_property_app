import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class LeaseRenewalFormData {
  final double proposedRent;
  final int durationMonths;
  final DateTime startDate;
  final String notes;

  LeaseRenewalFormData({
    required this.proposedRent,
    required this.durationMonths,
    required this.startDate,
    required this.notes,
  });
}

class LeaseRenewalDialog extends StatefulWidget {
  final String tenantName;
  final double currentRent;

  const LeaseRenewalDialog({super.key, required this.tenantName, required this.currentRent});

  static Future<LeaseRenewalFormData?> show(BuildContext context, {required String tenantName, required double currentRent}) {
    return showDialog<LeaseRenewalFormData>(
      context: context,
      builder: (ctx) => LeaseRenewalDialog(tenantName: tenantName, currentRent: currentRent),
    );
  }

  @override
  State<LeaseRenewalDialog> createState() => _LeaseRenewalDialogState();
}

class _LeaseRenewalDialogState extends State<LeaseRenewalDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _rentCtrl;
  final TextEditingController _notesCtrl = TextEditingController();

  int _durationMonths = 12;
  DateTime _startDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    _rentCtrl = TextEditingController(text: widget.currentRent.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _rentCtrl.dispose();
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
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.autorenew_rounded, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Propose Lease Renewal', style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.bold)),
                Text('Tenant: ${widget.tenantName}', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
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
              Text('Current Rent: \$${widget.currentRent.toStringAsFixed(0)} / mo',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 12),

              _fieldLabel('New Proposed Rent (\$)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _rentCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  fillColor: AppColors.inputBg,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 14),

              _fieldLabel('Renewal Duration'),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                initialValue: _durationMonths,
                decoration: InputDecoration(
                  fillColor: AppColors.inputBg,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 6, child: Text('6 Months')),
                  DropdownMenuItem(value: 12, child: Text('12 Months (1 Year)')),
                  DropdownMenuItem(value: 24, child: Text('24 Months (2 Years)')),
                ],
                onChanged: (val) => setState(() => _durationMonths = val!),
              ),

              const SizedBox(height: 14),

              _fieldLabel('Proposed Start Date'),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _startDate = picked);
                  }
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
                      Text(DateFormat('MMM dd, yyyy').format(_startDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              _fieldLabel('Notes / Terms for Tenant'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g. Includes complimentary AC service check for the upcoming renewal period.',
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
            backgroundColor: AppColors.secondary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                LeaseRenewalFormData(
                  proposedRent: double.tryParse(_rentCtrl.text.trim()) ?? widget.currentRent,
                  durationMonths: _durationMonths,
                  startDate: _startDate,
                  notes: _notesCtrl.text.trim(),
                ),
              );
            }
          },
          child: const Text('Send Renewal Offer', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12));
  }
}
