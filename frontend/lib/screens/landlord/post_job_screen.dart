import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class PostJobScreen extends ConsumerStatefulWidget {
  const PostJobScreen({super.key});

  @override
  ConsumerState<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedPropertyId;
  String? _selectedUnitId;
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _budgetMinCtrl = TextEditingController(text: '100');
  final TextEditingController _budgetMaxCtrl = TextEditingController(text: '500');
  final TextEditingController _timelineCtrl = TextEditingController(text: 'Within 3 days');
  final TextEditingController _notesCtrl = TextEditingController();

  DateTime? _bidDeadline;
  String _selectedCategory = 'Essential Maintenance';
  String _selectedSubCategory = 'Plumbing';
  String _selectedUrgency = 'standard';
  bool _isSubmitting = false;

  final Map<String, List<String>> _categoryMap = {
    'Essential Maintenance': [
      'Plumbing',
      'Electrical',
      'HVAC',
      'Appliance Repair',
      'Handyman Services',
    ],
    'Turnover & Cleaning': [
      'Janitorial/Cleaning',
      'Painting',
      'Flooring',
      'Junk Removal',
    ],
    'Exterior & Seasonal': [
      'Landscaping',
      'Snow Removal',
      'Roofing',
      'Paving/Concrete',
    ],
    'Safety & Security': [
      'Locksmith',
      'Pest Control',
      'Fire Safety',
      'Security Systems',
    ],
    'Specialized Services': [
      'Pool Maintenance',
      'Elevator Service',
      'Window Cleaning',
      'Mold/Water Remediation',
      'Other',
    ],
  };

  @override
  void initState() {
    super.initState();
    _bidDeadline = DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _budgetMinCtrl.dispose();
    _budgetMaxCtrl.dispose();
    _timelineCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPropertyId == null || _selectedPropertyId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a property for this job.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payload = {
        'propertyId': _selectedPropertyId,
        'unitId': _selectedUnitId,
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'category': _selectedCategory,
        'subCategory': _selectedSubCategory,
        'urgency': _selectedUrgency,
        'budgetMin': double.tryParse(_budgetMinCtrl.text.trim()) ?? 0.0,
        'budgetMax': double.tryParse(_budgetMaxCtrl.text.trim()) ?? 0.0,
        'preferredTimeline': _timelineCtrl.text.trim(),
        'bidDeadline': _bidDeadline?.toIso8601String(),
        'specialNotes': _notesCtrl.text.trim(),
        'photos': [],
      };

      final response = await ApiClient().dio.post(
        ApiConstants.jobs,
        data: payload,
      );

      if (mounted) setState(() => _isSubmitting = false);

      if (response.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Job posted successfully for vendor bidding!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data['message'] ?? 'Failed to post job'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting job: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final landlordState = ref.watch(landlordProvider);
    final properties = landlordState.properties;
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Post Vendor Job', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property Dropdown
              _SectionLabel('Property', w),
              SizedBox(height: h * 0.008),
              DropdownButtonFormField<String>(
                value: _selectedPropertyId ?? (properties.isNotEmpty ? properties.first.id : null),
                decoration: InputDecoration(
                  fillColor: AppColors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: properties.map((p) {
                  return DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedPropertyId = val),
                validator: (val) => val == null ? 'Property is required' : null,
              ),

              SizedBox(height: h * 0.02),

              // Title
              _SectionLabel('Job Title', w),
              SizedBox(height: h * 0.008),
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. Kitchen Sink Pipe Leak Repair & Cleanup',
                  fillColor: AppColors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
              ),

              SizedBox(height: h * 0.02),

              // Category & Sub-Category
              _SectionLabel('Main Category', w),
              SizedBox(height: h * 0.008),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  fillColor: AppColors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _categoryMap.keys.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                      _selectedSubCategory = _categoryMap[val]!.first;
                    });
                  }
                },
              ),

              SizedBox(height: h * 0.015),

              _SectionLabel('Sub-Service', w),
              SizedBox(height: h * 0.008),
              DropdownButtonFormField<String>(
                value: _selectedSubCategory,
                decoration: InputDecoration(
                  fillColor: AppColors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: (_categoryMap[_selectedCategory] ?? []).map((sub) {
                  return DropdownMenuItem(value: sub, child: Text(sub));
                }).toList(),
                onChanged: (val) => setState(() => _selectedSubCategory = val!),
              ),

              SizedBox(height: h * 0.02),

              // Urgency Level
              _SectionLabel('Urgency Level', w),
              SizedBox(height: h * 0.008),
              Row(
                children: [
                  _UrgencyChip('Standard', 'standard', Colors.blue),
                  _UrgencyChip('Urgent', 'urgent', Colors.orange),
                  _UrgencyChip('Emergency', 'emergency', Colors.red),
                ],
              ),

              SizedBox(height: h * 0.02),

              // Description
              _SectionLabel('Description', w),
              SizedBox(height: h * 0.008),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe the maintenance/turnover job details for vendors...',
                  fillColor: AppColors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Description is required' : null,
              ),

              SizedBox(height: h * 0.02),

              // Budget Range
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel('Min Budget (\$)', w),
                        SizedBox(height: h * 0.008),
                        TextFormField(
                          controller: _budgetMinCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            fillColor: AppColors.white,
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel('Max Budget (\$)', w),
                        SizedBox(height: h * 0.008),
                        TextFormField(
                          controller: _budgetMaxCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            fillColor: AppColors.white,
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: h * 0.02),

              // Bid Deadline
              _SectionLabel('Bid Deadline', w),
              SizedBox(height: h * 0.008),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _bidDeadline ?? DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) {
                    setState(() => _bidDeadline = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(
                        _bidDeadline != null
                            ? DateFormat('MMM dd, yyyy').format(_bidDeadline!)
                            : 'Select Deadline',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: h * 0.02),

              // Special Notes
              _SectionLabel('Special Notes (Optional)', w),
              SizedBox(height: h * 0.008),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. Vendor must provide proof of insurance before entering property.',
                  fillColor: AppColors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              SizedBox(height: h * 0.04),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, h * 0.065),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Post Job to Vendors',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              SizedBox(height: h * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  Widget _SectionLabel(String text, double w) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.w700, fontSize: w * 0.035, color: AppColors.textPrimary),
    );
  }

  Widget _UrgencyChip(String label, String value, Color color) {
    final isSelected = _selectedUrgency == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedUrgency = value),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? color : AppColors.border),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
