import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';

class TenantCreateTicketScreen extends StatefulWidget {
  const TenantCreateTicketScreen({super.key});

  @override
  State<TenantCreateTicketScreen> createState() => _TenantCreateTicketScreenState();
}

class _TenantCreateTicketScreenState extends State<TenantCreateTicketScreen> {
  String _selectedPriority = 'low';
  String _selectedCategory = 'general';
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  bool _hasAttachment = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showMediaBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add Attachment', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: const Text('Take Photo', style: AppTextStyles.bodyMedium),
                onTap: () {
                  setState(() { _hasAttachment = true; });
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: const Text('Choose from Gallery', style: AppTextStyles.bodyMedium),
                onTap: () {
                  setState(() { _hasAttachment = true; });
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitTicket() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an issue title.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final resp = await ApiClient().dio.post(
        '/tickets',
        data: {
          'title': title,
          'description': description,
          'category': _selectedCategory,
          'priority': _selectedPriority,
        },
      );

      if (resp.data != null && resp.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ticket created successfully!')),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception(resp.data?['error'] ?? 'Failed to submit ticket');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(title: const Text('Report Issue')),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Issue Title', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'e.g. Leaking Faucet'),
              ),
              const SizedBox(height: 20),
              const Text('Category', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: 'general',
                decoration: const InputDecoration(hintText: 'Select Category'),
                items: const [
                  DropdownMenuItem(value: 'plumbing', child: Text('Plumbing')),
                  DropdownMenuItem(value: 'electrical', child: Text('Electrical')),
                  DropdownMenuItem(value: 'hvac', child: Text('HVAC')),
                  DropdownMenuItem(value: 'general', child: Text('General/Other')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategory = val);
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text('Priority', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPriorityButton('low', 'Normal', AppColors.primary),
                  _buildPriorityButton('medium', 'Urgent', Colors.orange),
                  _buildPriorityButton('high', 'Emergency', AppColors.error),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Description', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Describe the issue in detail...'),
              ),
              const SizedBox(height: 20),
              const Text('Attachments', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showMediaBottomSheet,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: _hasAttachment 
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: AppColors.scaffoldBg,
                              borderRadius: BorderRadius.circular(8),
                              image: const DecorationImage(
                                image: NetworkImage('https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400&q=80'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('Attachment added. Tap to change.', style: AppTextStyles.bodySmall),
                        ],
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, color: AppColors.textHint, size: 32),
                          SizedBox(height: 8),
                          Text('Tap to add photo/video', style: AppTextStyles.bodySmall),
                        ],
                      ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: AppColors.white)
                    : const Text('Submit Ticket', style: AppTextStyles.buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityButton(String value, String label, Color color) {
    bool selected = _selectedPriority == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPriority = value;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? color : AppColors.border),
            boxShadow: selected ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))] : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
