import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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

  String _selectedProperty = '';
  String _selectedPropertyId = '';
  String _selectedUnitName = '';
  String _selectedUnitId = '';
  String _selectedTenant = '';
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

  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  String? _selectedVendorId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(landlordProvider.notifier);
      notifier.loadVendors();
      notifier.loadProperties();
      notifier.loadTenants();
    });
  }

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
            Builder(builder: (context) {
              final state = ref.watch(landlordProvider);
              final properties = state.properties;
              // Auto-select first if nothing selected yet
              if (_selectedPropertyId.isEmpty && properties.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _selectedPropertyId = properties.first.id;
                      _selectedProperty = properties.first.name;
                    });
                    notifier.loadUnits(properties.first.id).catchError((e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to load units: $e'), backgroundColor: Colors.red),
                        );
                      }
                    });
                  }
                });
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPropertyId.isEmpty 
                        ? null 
                        : (properties.any((p) => p.id == _selectedPropertyId) ? _selectedPropertyId : null),
                    isExpanded: true,
                    hint: const Text('Select Property'),
                    items: properties.isEmpty
                        ? [const DropdownMenuItem<String>(value: null, child: Text('No Properties Available'))]
                        : properties.map((p) {
                            return DropdownMenuItem<String>(
                              value: p.id,
                              child: Text(p.name, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                    onChanged: properties.isEmpty ? (_) {} : (val) {
                      if (val != null) {
                        final prop = properties.firstWhere((p) => p.id == val);
                        setState(() {
                          _selectedPropertyId = prop.id;
                          _selectedProperty = prop.name;
                          _selectedUnitId = '';
                          _selectedUnitName = '';
                        });
                        notifier.loadUnits(prop.id).catchError((e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to load units: $e'), backgroundColor: Colors.red),
                            );
                          }
                        });
                      }
                    },
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Unit Selection Dropdown
            const Text(
              'Unit',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Builder(builder: (context) {
              final state = ref.watch(landlordProvider);
              final units = state.units.where((u) => u.propertyId == _selectedPropertyId).toList();
              // Auto-select first unit
              if (_selectedUnitId.isEmpty && units.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _selectedUnitId = units.first.id;
                      _selectedUnitName = units.first.name;
                    });
                  }
                });
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedUnitId.isEmpty 
                        ? null 
                        : (units.any((u) => u.id == _selectedUnitId) ? _selectedUnitId : null),
                    isExpanded: true,
                    hint: const Text('Select Unit'),
                    items: units.isEmpty
                        ? [const DropdownMenuItem<String>(value: null, child: Text('No Units Available'))]
                        : units.map((u) {
                            return DropdownMenuItem<String>(
                              value: u.id,
                              child: Text(u.name, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                    onChanged: units.isEmpty ? (_) {} : (val) {
                      if (val != null) {
                        final unit = units.firstWhere((u) => u.id == val);
                        setState(() {
                          _selectedUnitId = unit.id;
                          _selectedUnitName = unit.name;
                        });
                      }
                    },
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Tenant Selection Dropdown
            const Text(
              'Tenant',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Builder(builder: (context) {
              final state = ref.watch(landlordProvider);
              final tenants = state.tenants;
              // Auto-select first tenant
              if (_selectedTenant.isEmpty && tenants.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _selectedTenant = tenants.first.name);
                });
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTenant.isEmpty 
                        ? null 
                        : (tenants.any((t) => t.name == _selectedTenant) ? _selectedTenant : null),
                    isExpanded: true,
                    hint: const Text('Select Tenant (optional)'),
                    items: tenants.isEmpty
                        ? [const DropdownMenuItem<String>(value: null, child: Text('No Tenants Available'))]
                        : tenants.map((t) {
                            return DropdownMenuItem<String>(
                              value: t.name,
                              child: Text(t.name, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                    onChanged: tenants.isEmpty ? (_) {} : (val) {
                      if (val != null) setState(() => _selectedTenant = val);
                    },
                  ),
                ),
              );
            }),

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
                GestureDetector(
                  onTap: () async {
                    final List<XFile> images = await _picker.pickMultiImage();
                    if (images.isNotEmpty) {
                      setState(() {
                        _selectedImages.addAll(images);
                      });
                    }
                  },
                  child: Container(
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _selectedImages.map((img) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(img.path),
                              width: w * 0.22,
                              height: w * 0.22,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
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
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Select a Vendor (Optional)'),
                  value: _selectedVendorId == null 
                      ? null 
                      : (ref.watch(landlordProvider).vendors.any((v) => v.id == _selectedVendorId) ? _selectedVendorId : null),
                  items: ref.watch(landlordProvider).vendors.isEmpty
                      ? [const DropdownMenuItem<String>(value: null, child: Text('No Vendors Available'))]
                      : ref.watch(landlordProvider).vendors.map((v) {
                          return DropdownMenuItem<String>(
                            value: v.id,
                            child: Text('${v.displayName} (⭐ ${v.avgRating})'),
                          );
                        }).toList(),
                  onChanged: ref.watch(landlordProvider).vendors.isEmpty ? (_) {} : (val) {
                    setState(() => _selectedVendorId = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Schedule Visit Form
            const Text(
              'Schedule Visit',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _selectedDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() => _selectedTime = time);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _selectedTime == null ? 'Select Time' : _selectedTime!.format(context),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
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
                    onPressed: () async {
                      if (_titleController.text.isEmpty || _descController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in Title and Description')),
                        );
                        return;
                      }
                      if (_selectedPropertyId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a property')),
                        );
                        return;
                      }
                      if (_selectedUnitId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a unit')),
                        );
                        return;
                      }

                      // Combine date and time
                      String? scheduledDateTimeIso;
                      if (_selectedDate != null) {
                        var dt = _selectedDate!;
                        if (_selectedTime != null) {
                          dt = DateTime(dt.year, dt.month, dt.day, _selectedTime!.hour, _selectedTime!.minute);
                        }
                        scheduledDateTimeIso = dt.toIso8601String();
                      }

                      // Build the work order with real IDs from dropdowns
                      final newWo = WorkOrder(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _titleController.text.trim(),
                        description: _descController.text.trim(),
                        propertyName: _selectedProperty,   // matched to ID in provider
                        unitName: _selectedUnitName,        // matched to ID in provider
                        tenantName: _selectedTenant,
                        priority: _selectedPriority,
                        status: _selectedVendorId != null ? 'Assigned' : 'Request',
                        photos: [],
                        category: _selectedCategory,
                        date: '',
                        timeSlot: '',
                        accessInstructions: _accessController.text.trim(),
                      );

                      try {
                        final newOrderId = await notifier.createWorkOrder(
                          newWo,
                          assignedVendorId: _selectedVendorId,
                          scheduledDate: scheduledDateTimeIso,
                        );

                        // Upload photos sequentially
                        for (var img in _selectedImages) {
                          final bytes = await File(img.path).readAsBytes();
                          await notifier.uploadWorkOrderPhoto(newOrderId, bytes, img.name);
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Work order created successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ Failed: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
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
