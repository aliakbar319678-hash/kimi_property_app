import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/provider/landlord_state.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class CreateWorkOrderScreen extends ConsumerStatefulWidget {
  const CreateWorkOrderScreen({super.key});

  @override
  ConsumerState<CreateWorkOrderScreen> createState() =>
      _CreateWorkOrderScreenState();
}

class _CreateWorkOrderScreenState extends ConsumerState<CreateWorkOrderScreen> {
  final _titleController = TextEditingController(text: 'Kitchen Sink Leak');
  final _descController = TextEditingController(
    text:
        'Tenant reported a leak under the kitchen sink. Water is pooling inside the cabinet and needs inspection.',
  );
  final _accessController = TextEditingController(
    text: 'Tenant is available after 1 PM. Vendor should call before arrival.',
  );

  String _selectedProperty = 'Sunset Heights Apts, Unit 402';
  String _selectedTenant = 'John Smith';
  String _selectedCategory = 'Plumbing';
  String _selectedPriority = 'High';

  bool _notifyTenant = true;
  bool _notifyVendor = true;
  bool _sendCopy = false;

  final List<String> _categories = [
    'General Repair',
    'Plumbing',
    'Electrical',
    'HVAC',
    'Appliance',
    'Painting',
    'Other',
  ];
  final List<String> _priorities = ['Low', 'Medium', 'High', 'Emergency'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _accessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(landlordProvider.notifier);
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'Create Work Order',
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
            // Work Order Details
            Text(
              'Work Order Details',
              style: TextStyle(
                fontSize: w * 0.042,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Title Input
            const Text(
              'Title',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Enter title...'),
            ),

            const SizedBox(height: 16),

            // Property Selection Dropdown
            const Text(
              'Property',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedProperty,
                  isExpanded: true,
                  items:
                      [
                        'Sunset Heights Apts, Unit 402',
                        'Maple Residency, Unit 4',
                      ].map((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(
                            val,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedProperty = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tenant Selection Dropdown
            const Text(
              'Tenant',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTenant,
                  isExpanded: true,
                  items: ['John Smith', 'Sarah Jenkins'].map((String val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedTenant = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Repair Category Wrap Buttons
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

            // Issue Description text area
            const Text(
              'Issue Description',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Enter details...'),
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

            const SizedBox(height: 24),

            // Photos Gallery
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
                    border: Border.all(
                      color: AppColors.border,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
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

            // Assign Vendor Section Card
            const Text(
              'Assign Vendor',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.build_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'QuickFix Maintenance',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            const Text(
                              '4.8',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Available Today',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_right_rounded),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Schedule Visit Form
            const Text(
              'Schedule Visit',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Today, May 19',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                  SizedBox(width: 10),
                  Text(
                    '2:00 PM - 4:00 PM',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _accessController,
              decoration: const InputDecoration(
                hintText: 'Access instructions...',
              ),
            ),

            const SizedBox(height: 24),

            // Notifications toggles
            const Text(
              'Notifications',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            CheckboxListTile(
              title: const Text(
                'Notify Tenant',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              value: _notifyTenant,
              onChanged: (val) => setState(() => _notifyTenant = val ?? true),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
              activeColor: AppColors.primary,
            ),
            CheckboxListTile(
              title: const Text(
                'Notify Vendor',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              value: _notifyVendor,
              onChanged: (val) => setState(() => _notifyVendor = val ?? true),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
              activeColor: AppColors.primary,
            ),
            CheckboxListTile(
              title: const Text(
                'Send copy to landlord email',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              value: _sendCopy,
              onChanged: (val) => setState(() => _sendCopy = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
              activeColor: AppColors.primary,
            ),

            const SizedBox(height: 30),

            // Submit Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Save as Draft',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final newWo = WorkOrder(
                        id: DateTime.now().millisecondsSinceEpoch
                            .toString()
                            .substring(8),
                        title: _titleController.text,
                        description: _descController.text,
                        propertyName: _selectedProperty.split(',')[0],
                        unitName: _selectedProperty.split(',')[1].trim(),
                        tenantName: _selectedTenant,
                        priority: _selectedPriority,
                        status: 'In-Progress',
                        photos: [
                          'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400&q=80',
                        ],
                        category: _selectedCategory,
                        date: 'May 19, 2026',
                        timeSlot: '2:00 PM - 4:00 PM',
                        accessInstructions: _accessController.text,
                        vendorName: 'QuickFix Maintenance',
                        vendorPhone: '(555) 000-1111',
                        bidAmount: 300.0,
                      );
                      notifier.createWorkOrder(newWo);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Create Work Order',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
