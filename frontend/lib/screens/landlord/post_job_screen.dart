import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/provider/landlord_state.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class PostJobScreen extends ConsumerStatefulWidget {
  const PostJobScreen({super.key});

  @override
  ConsumerState<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> {
  String _selectedCategory = 'Plumbing';
  String _selectedPriority = 'High';
  String _visibility = 'All approved vendors';
  bool _tenantChatAccess = true;

  final _descController = TextEditingController(
    text:
        'Tenant reported a leak under the kitchen sink. Water is pooling inside the cabinet and needs inspection and repair.',
  );
  final _budgetController = TextEditingController(text: '200 - 500');

  final List<String> _categories = [
    'General Repair',
    'Plumbing',
    'Electrical',
    'HVAC',
    'Appliance',
  ];
  final List<String> _priorities = ['Low', 'Medium', 'High', 'Emergency'];

  @override
  void dispose() {
    _descController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.05;

    // Retrieve order arguments if present
    final WorkOrder? order =
        ModalRoute.of(context)!.settings.arguments as WorkOrder?;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'Post New Job',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: pad, vertical: h * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category list
            const Text(
              'Repair Category',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = cat);
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Job Description
            const Text(
              'Job Description',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe the issue...',
              ),
            ),

            const SizedBox(height: 20),

            // Priority selectors
            const Text(
              'Priority',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: _priorities.map((priority) {
                final isSelected = _selectedPriority == priority;
                Color activeColor;
                switch (priority.toLowerCase()) {
                  case 'emergency':
                    activeColor = AppColors.error;
                    break;
                  case 'high':
                    activeColor = Colors.orange;
                    break;
                  default:
                    activeColor = AppColors.primary;
                }

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPriority = priority),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? activeColor : AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? activeColor : AppColors.border,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            priority,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Budget range input
            const Text(
              'Budget Range (SAR)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _budgetController,
              decoration: const InputDecoration(hintText: 'e.g. 200 - 500'),
            ),
            const SizedBox(height: 4),
            const Text(
              'Estimate based on similar plumbing repairs.',
              style: TextStyle(fontSize: 10, color: AppColors.textHint),
            ),

            const SizedBox(height: 24),

            // Photos gallery
            const Text(
              'Photos',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: w * 0.22,
                  height: w * 0.22,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_photo_alternate_rounded,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=200&q=80',
                    width: w * 0.22,
                    height: w * 0.22,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Vendor Visibility radio layout
            const Text(
              'Vendor Visibility',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: RadioGroup<String>(
                groupValue: _visibility,
                onChanged: (val) => setState(() => _visibility = val!),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text(
                        'All approved vendors',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      value: 'All approved vendors',
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      activeColor: AppColors.primary,
                    ),
                    RadioListTile<String>(
                      title: const Text(
                        'Only my saved vendors',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      value: 'Only my saved vendors',
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      activeColor: AppColors.primary,
                    ),
                    RadioListTile<String>(
                      title: const Text(
                        'Invite specific vendors',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      value: 'Invite specific vendors',
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tenant Chat Access toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tenant Chat Access',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Add ${order?.tenantName ?? 'John Smith'} to chat room',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _tenantChatAccess,
                    onChanged: (val) => setState(() => _tenantChatAccess = val),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                if (order != null) {
                  // Post job updates to existing work order status if needed
                  ref
                      .read(landlordProvider.notifier)
                      .updateWorkOrderStatus(order.id, 'Request');
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, w * 0.13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Post Job to Vendors',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
