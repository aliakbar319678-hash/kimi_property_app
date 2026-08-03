import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';

class MoveInspectionFormScreen extends StatefulWidget {
  final String leaseId;
  final String type; // 'Move-In' or 'Move-Out'

  const MoveInspectionFormScreen({super.key, required this.leaseId, required this.type});

  @override
  State<MoveInspectionFormScreen> createState() => _MoveInspectionFormScreenState();
}

class _MoveInspectionFormScreenState extends State<MoveInspectionFormScreen> {
  final List<Map<String, dynamic>> _rooms = [
    {'name': 'Living Room', 'condition': 'Good', 'notes': '', 'images': []},
    {'name': 'Kitchen', 'condition': 'Fair', 'notes': '', 'images': []},
    {'name': 'Bedroom 1', 'condition': 'Good', 'notes': '', 'images': []},
    {'name': 'Bathroom', 'condition': 'Good', 'notes': '', 'images': []},
  ];

  bool _isSubmitting = false;

  Future<void> _submitInspection() async {
    setState(() => _isSubmitting = true);
    try {
      final checklistData = _rooms.map((r) => {
        'item': r['name']?.toString() ?? '',
        'condition': (r['condition']?.toString() ?? 'GOOD').toUpperCase(),
        'notes': r['notes']?.toString() ?? '',
      }).toList();

      await ApiClient().dio.post('/leases/${widget.leaseId}/inspections', data: {
        'inspection_type': widget.type == 'Move-In' ? 'MOVE_IN' : 'MOVE_OUT',
        'checklist_data': checklistData,
        'inspector_role': 'LANDLORD',
        'landlord_signature': 'Signed by Landlord',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.type} inspection submitted successfully!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit inspection. Please try again.'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text('${widget.type} Inspection Form'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _rooms.length,
                itemBuilder: (context, index) {
                  return _buildRoomCard(_rooms[index], index);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isSubmitting ? null : _submitInspection,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Inspection', style: AppTextStyles.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(room['name'], style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            const Text('Condition', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: room['condition'],
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              items: const [
                DropdownMenuItem(value: 'Excellent', child: Text('Excellent')),
                DropdownMenuItem(value: 'Good', child: Text('Good')),
                DropdownMenuItem(value: 'Fair', child: Text('Fair')),
                DropdownMenuItem(value: 'Damaged', child: Text('Damaged')),
              ],
              onChanged: (val) => setState(() => room['condition'] = val!),
            ),
            const SizedBox(height: 16),
            const Text('Notes', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: room['notes'],
              maxLines: 2,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: 'Add any specific notes about the condition...',
              ),
              onChanged: (val) => room['notes'] = val,
            ),
            const SizedBox(height: 16),
            const Text('Images', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      setState(() {
                        room['images'].add(picked.path);
                      });
                    }
                  },
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.inputBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                    ),
                    child: const Icon(Icons.add_a_photo, color: AppColors.textHint),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: room['images'].length,
                      itemBuilder: (ctx, i) {
                        final imgPath = room['images'][i].toString();
                        final isNet = imgPath.startsWith('http');
                        return Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: isNet
                                  ? NetworkImage(imgPath) as ImageProvider
                                  : FileImage(File(imgPath)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
