import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class UnitFormData {
  final String unitNumber;
  final double rentAmount;
  final double depositAmount;
  final int bedrooms;
  final double bathrooms;
  final int sqft;
  final String status;

  UnitFormData({
    required this.unitNumber,
    required this.rentAmount,
    required this.depositAmount,
    required this.bedrooms,
    required this.bathrooms,
    required this.sqft,
    required this.status,
  });
}

class AddUnitDialog extends StatefulWidget {
  final String propertyName;

  const AddUnitDialog({super.key, required this.propertyName});

  static Future<UnitFormData?> show(BuildContext context, {required String propertyName}) {
    return showDialog<UnitFormData>(
      context: context,
      builder: (ctx) => AddUnitDialog(propertyName: propertyName),
    );
  }

  @override
  State<AddUnitDialog> createState() => _AddUnitDialogState();
}

class _AddUnitDialogState extends State<AddUnitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _unitNumCtrl = TextEditingController();
  final _rentCtrl = TextEditingController(text: '1200');
  final _depositCtrl = TextEditingController(text: '1200');
  final _sqftCtrl = TextEditingController(text: '850');

  int _bedrooms = 2;
  double _bathrooms = 1.0;
  String _status = 'vacant';

  @override
  void dispose() {
    _unitNumCtrl.dispose();
    _rentCtrl.dispose();
    _depositCtrl.dispose();
    _sqftCtrl.dispose();
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
            child: const Icon(Icons.meeting_room_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Unit', style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.bold)),
                Text(widget.propertyName, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
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
              _fieldLabel('Unit Number / Designation'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _unitNumCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. Apt 3B or Unit 102',
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
                        _fieldLabel('Rent (\$)'),
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Deposit (\$)'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _depositCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            fillColor: AppColors.inputBg,
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Bedrooms'),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          initialValue: _bedrooms,
                          decoration: InputDecoration(
                            fillColor: AppColors.inputBg,
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: [1, 2, 3, 4, 5].map((b) => DropdownMenuItem(value: b, child: Text('$b Bed'))).toList(),
                          onChanged: (val) => setState(() => _bedrooms = val!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Bathrooms'),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<double>(
                          initialValue: _bathrooms,
                          decoration: InputDecoration(
                            fillColor: AppColors.inputBg,
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: [1.0, 1.5, 2.0, 2.5, 3.0].map((b) => DropdownMenuItem(value: b, child: Text('$b Bath'))).toList(),
                          onChanged: (val) => setState(() => _bathrooms = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Area (Sq Ft)'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _sqftCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            fillColor: AppColors.inputBg,
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Initial Status'),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _status,
                          decoration: InputDecoration(
                            fillColor: AppColors.inputBg,
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'vacant', child: Text('Vacant')),
                            DropdownMenuItem(value: 'occupied', child: Text('Occupied')),
                            DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                          ],
                          onChanged: (val) => setState(() => _status = val!),
                        ),
                      ],
                    ),
                  ),
                ],
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
                UnitFormData(
                  unitNumber: _unitNumCtrl.text.trim(),
                  rentAmount: double.tryParse(_rentCtrl.text.trim()) ?? 0.0,
                  depositAmount: double.tryParse(_depositCtrl.text.trim()) ?? 0.0,
                  bedrooms: _bedrooms,
                  bathrooms: _bathrooms,
                  sqft: int.tryParse(_sqftCtrl.text.trim()) ?? 0,
                  status: _status,
                ),
              );
            }
          },
          child: const Text('Add Unit', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12));
  }
}
