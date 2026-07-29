import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';

class LandlordPropertyShowingsScreen extends ConsumerStatefulWidget {
  const LandlordPropertyShowingsScreen({super.key});

  @override
  ConsumerState<LandlordPropertyShowingsScreen> createState() => _LandlordPropertyShowingsScreenState();
}

class _LandlordPropertyShowingsScreenState extends ConsumerState<LandlordPropertyShowingsScreen> {
  bool _isLoading = false;

  List<Map<String, dynamic>> _showings = [
    {
      'id': 'show-101',
      'prospectName': 'John Doe',
      'phone': '+1 (555) 321-9876',
      'email': 'john.doe@example.com',
      'propertyUnit': 'Sunset Heights - Unit 3A',
      'showingDate': '2026-08-02',
      'timeSlot': '04:00 PM - 04:30 PM',
      'status': 'Scheduled',
      'notes': 'Interested in 1-year lease starting Sep 1.',
    },
    {
      'id': 'show-102',
      'prospectName': 'Alice Smith',
      'phone': '+1 (555) 789-0123',
      'email': 'alice.smith@example.com',
      'propertyUnit': 'Green Valley - Unit 12B',
      'showingDate': '2026-07-27',
      'timeSlot': '11:00 AM - 11:30 AM',
      'status': 'Completed',
      'notes': 'Loved the balcony view! Submitted application.',
    },
    {
      'id': 'show-103',
      'prospectName': 'David Miller',
      'phone': '+1 (555) 456-7890',
      'email': 'david.m@example.com',
      'propertyUnit': 'Grand Park Tower - Unit 5F',
      'showingDate': '2026-07-26',
      'timeSlot': '02:00 PM - 02:30 PM',
      'status': 'No-Show',
      'notes': 'Did not answer phone when arrived at gate.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchShowings();
  }

  Future<void> _fetchShowings() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient().dio.get('/marketing/showings');
      if (response.data != null && response.data['data'] is List) {
        final List<dynamic> raw = response.data['data'];
        final fetched = raw.map((item) => item as Map<String, dynamic>).toList();
        if (fetched.isNotEmpty && mounted) {
          setState(() {
            _showings = fetched;
          });
        }
      }
    } catch (_) {
      // Keep rich fallback mock data
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showScheduleShowingSheet() {
    final state = ref.read(landlordProvider);
    final properties = state.properties;

    final nameCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String selectedPropertyUnit = properties.isNotEmpty
        ? '${properties.first.name} - Unit 1A'
        : 'Sunset Heights - Unit 3A';
    DateTime showingDate = DateTime.now().add(const Duration(days: 1));
    String timeSlot = '02:00 PM - 02:30 PM';
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.remove_red_eye_rounded, color: AppColors.primary, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Schedule Tour Showing',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Prospect Name & Contact
                const Text('Prospect Name *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nameCtrl,
                  decoration: _inputDeco('e.g. John Doe'),
                ),
                const SizedBox(height: 14),

                const Text('Prospect Phone / Email *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: contactCtrl,
                  decoration: _inputDeco('e.g. john@example.com or +1 555-0192'),
                ),
                const SizedBox(height: 14),

                // Property Unit & Time Slot
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Property / Unit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Builder(
                            builder: (context) {
                              final options = (properties.isNotEmpty
                                      ? properties.map((p) => '${p.name} - Unit 1A').toList()
                                      : ['Sunset Heights - Unit 3A', 'Green Valley - Unit 12B', 'Grand Park - Unit 5F']);
                              final validValue = options.contains(selectedPropertyUnit) ? selectedPropertyUnit : (options.isNotEmpty ? options.first : null);

                              return DropdownButtonFormField<String>(
                                value: validValue,
                                decoration: _inputDeco('Select Unit'),
                                items: options
                                    .map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 12))))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setSheetState(() => selectedPropertyUnit = v);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Time Slot', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Builder(
                            builder: (context) {
                              final slotOptions = const ['10:00 AM - 10:30 AM', '11:30 AM - 12:00 PM', '02:00 PM - 02:30 PM', '04:00 PM - 04:30 PM'];
                              final validSlot = slotOptions.contains(timeSlot) ? timeSlot : slotOptions.first;

                              return DropdownButtonFormField<String>(
                                value: validSlot,
                                decoration: _inputDeco('Slot'),
                                items: const [
                                  DropdownMenuItem(value: '10:00 AM - 10:30 AM', child: Text('10:00 AM', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: '11:30 AM - 12:00 PM', child: Text('11:30 AM', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: '02:00 PM - 02:30 PM', child: Text('02:00 PM', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: '04:00 PM - 04:30 PM', child: Text('04:00 PM', style: TextStyle(fontSize: 12))),
                                ],
                                onChanged: (v) {
                                  if (v != null) setSheetState(() => timeSlot = v);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Date Picker
                const Text('Showing Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: showingDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) setSheetState(() => showingDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.scaffoldBg,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          '${showingDate.year}-${showingDate.month.toString().padLeft(2, '0')}-${showingDate.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Notes
                const Text('Notes / Instructions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: _inputDeco('Gate code or meeting instructions...'),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isSaving
                        ? null
                        : () async {
                            if (nameCtrl.text.trim().isEmpty || contactCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Prospect name & contact info required'), backgroundColor: AppColors.error),
                              );
                              return;
                            }
                            setSheetState(() => isSaving = true);

                            final newShow = {
                              'id': 'show-${_showings.length + 101}',
                              'prospectName': nameCtrl.text.trim(),
                              'phone': contactCtrl.text.trim(),
                              'email': contactCtrl.text.trim(),
                              'propertyUnit': selectedPropertyUnit,
                              'showingDate': '${showingDate.year}-${showingDate.month.toString().padLeft(2, '0')}-${showingDate.day.toString().padLeft(2, '0')}',
                              'timeSlot': timeSlot,
                              'status': 'Scheduled',
                              'notes': notesCtrl.text.trim(),
                            };

                            try {
                              await ApiClient().dio.post('/marketing/showings', data: newShow);
                            } catch (_) {}

                            setState(() {
                              _showings.insert(0, newShow);
                            });

                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Property tour scheduled for ${newShow['prospectName']}!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                    child: isSaving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Confirm Schedule', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
      filled: true,
      fillColor: AppColors.scaffoldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Property Showings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded, color: AppColors.primary),
            onPressed: _showScheduleShowingSheet,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showScheduleShowingSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Schedule Showing', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(w * 0.05),
              itemCount: _showings.length,
              itemBuilder: (ctx, idx) {
                final item = _showings[idx];
                final status = item['status'] as String;
                Color statusColor;
                switch (status.toLowerCase()) {
                  case 'completed': statusColor = Colors.green; break;
                  case 'scheduled': statusColor = AppColors.primary; break;
                  case 'no-show': statusColor = AppColors.error; break;
                  default: statusColor = Colors.grey;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.person_pin_circle_rounded, color: statusColor, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['prospectName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(item['propertyUnit'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, size: 14, color: AppColors.textHint),
                          const SizedBox(width: 6),
                          Text('${item['showingDate']}  •  ${item['timeSlot']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 14, color: AppColors.textHint),
                          const SizedBox(width: 6),
                          Text('${item['phone']}  •  ${item['email']}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                      if (item['notes'] != null && (item['notes'] as String).isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.scaffoldBg, borderRadius: BorderRadius.circular(8)),
                          child: Text('Notes: ${item['notes']}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
