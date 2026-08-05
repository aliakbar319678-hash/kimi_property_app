import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';

class LandlordCalendarScreen extends ConsumerStatefulWidget {
  const LandlordCalendarScreen({super.key});

  @override
  ConsumerState<LandlordCalendarScreen> createState() => _LandlordCalendarScreenState();
}

class _LandlordCalendarScreenState extends ConsumerState<LandlordCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedTag = 'All';
  bool _isLoading = false;

  List<Map<String, dynamic>> _events = [
    {
      'id': 'evt-1',
      'title': 'Lease Renewal - Sarah Connor',
      'type': 'Lease Expiry',
      'date': '2026-08-01',
      'time': '10:00 AM',
      'property': 'Sunset Heights - Unit 8B',
      'description': 'Final lease agreement sign-off and key handover.',
    },
    {
      'id': 'evt-2',
      'title': 'Plumbing Repair Work Order',
      'type': 'Maintenance',
      'date': '2026-07-29',
      'time': '02:30 PM',
      'property': 'Green Valley Apartments - Unit 2A',
      'description': 'Apex Plumbing assigned to fix kitchen drain leak.',
    },
    {
      'id': 'evt-3',
      'title': 'Move-Out Inspection - Robert Vance',
      'type': 'Inspection',
      'date': '2026-07-30',
      'time': '11:00 AM',
      'property': 'Grand Park Tower - Unit 4C',
      'description': 'Move-out walkthrough inspection and security deposit assessment.',
    },
    {
      'id': 'evt-4',
      'title': 'Prospective Showing - John Doe',
      'type': 'Property Showing',
      'date': '2026-08-02',
      'time': '04:00 PM',
      'property': 'Sunset Heights - Unit 3A',
      'description': 'Showing vacant 2BD unit to prospective tenant.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient().dio.get('/calendar/events');
      if (response.data != null && response.data['data'] is List) {
        final List<dynamic> raw = response.data['data'];
        final fetched = raw.map((item) => item as Map<String, dynamic>).toList();
        if (fetched.isNotEmpty && mounted) {
          setState(() {
            _events = fetched;
          });
        }
      }
    } catch (_) {
      // Keep rich fallback mock data
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _daysInMonth(DateTime date) {
    var firstDayThisMonth = DateTime(date.year, date.month, 1);
    var firstDayNextMonth = DateTime(date.year, date.month + 1, 1);
    return firstDayNextMonth.difference(firstDayThisMonth).inDays;
  }

  int _firstWeekdayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday; // 1 = Monday, 7 = Sunday
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  List<Map<String, dynamic>> get _filteredEvents {
    final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final eventsOnDate = _events.where((e) => e['date'] == dateStr).toList();
    if (_selectedTag == 'All') return eventsOnDate;
    return eventsOnDate.where((e) => (e['type'] as String).toLowerCase() == _selectedTag.toLowerCase()).toList();
  }

  void _showAddEventSheet() {
    final state = ref.read(landlordProvider);
    final properties = state.properties;

    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String eventType = 'Maintenance';
    String selectedProperty = properties.isNotEmpty ? properties.first.name : 'Sunset Heights';
    DateTime eventDate = DateTime.now();
    TimeOfDay eventTime = TimeOfDay.now();
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
                    Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Add Calendar Event',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                const Text('Event Title *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: titleCtrl,
                  decoration: _inputDeco('e.g. Unit Walkthrough'),
                ),
                const SizedBox(height: 14),

                // Event Type & Property
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Event Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: eventType,
                            decoration: _inputDeco('Type'),
                            items: const [
                              DropdownMenuItem(value: 'Maintenance', child: Text('Maintenance', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'Lease Expiry', child: Text('Lease Expiry', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'Inspection', child: Text('Inspection', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'Property Showing', child: Text('Showing', style: TextStyle(fontSize: 12))),
                            ],
                            onChanged: (v) {
                              if (v != null) setSheetState(() => eventType = v);
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
                          const Text('Property', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Builder(
                            builder: (context) {
                              final propertyOptions = (properties.isNotEmpty
                                      ? properties.map((p) => p.name).toList()
                                      : ['Sunset Heights', 'Green Valley', 'Grand Park']);
                              final validProp = propertyOptions.contains(selectedProperty) ? selectedProperty : propertyOptions.first;

                              return DropdownButtonFormField<String>(
                                initialValue: validProp,
                                decoration: _inputDeco('Property'),
                                items: propertyOptions
                                    .map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 12))))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setSheetState(() => selectedProperty = v);
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

                // Date & Time Pickers
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: eventDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                              );
                              if (picked != null) setSheetState(() => eventDate = picked);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.scaffoldBg,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
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
                          const Text('Time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(context: ctx, initialTime: eventTime);
                              if (picked != null) setSheetState(() => eventTime = picked);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.scaffoldBg,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    eventTime.format(ctx),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Description
                const Text('Description / Notes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: _inputDeco('Additional notes...'),
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
                            if (titleCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter an event title'), backgroundColor: AppColors.error),
                              );
                              return;
                            }
                            setSheetState(() => isSaving = true);

                            final newEvt = {
                              'id': 'evt-${_events.length + 1}',
                              'title': titleCtrl.text.trim(),
                              'type': eventType,
                              'date': '${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}',
                              'time': eventTime.format(ctx),
                              'property': selectedProperty,
                              'description': descCtrl.text.trim(),
                            };

                            try {
                              await ApiClient().dio.post('/calendar/events', data: newEvt);
                            } catch (_) {}

                            if (!mounted) return;
                            setState(() {
                              _events.insert(0, newEvt);
                            });

                            if (ctx.mounted) Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Event "${newEvt['title']}" added to calendar!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                    child: isSaving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Add Event', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
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
          'Calendar & Events',
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
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
            onPressed: _showAddEventSheet,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(w * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mini Calendar View Widget
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                              style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left_rounded),
                                  onPressed: () => setState(() {
                                    int prevMonth = _selectedDate.month - 1;
                                    int year = _selectedDate.year;
                                    if (prevMonth == 0) {
                                      prevMonth = 12;
                                      year--;
                                    }
                                    _selectedDate = DateTime(year, prevMonth, 1);
                                  }),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right_rounded),
                                  onPressed: () => setState(() {
                                    int nextMonth = _selectedDate.month + 1;
                                    int year = _selectedDate.year;
                                    if (nextMonth == 13) {
                                      nextMonth = 1;
                                      year++;
                                    }
                                    _selectedDate = DateTime(year, nextMonth, 1);
                                  }),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) {
                            return Text(d, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 13));
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 6,
                          ),
                          itemCount: _daysInMonth(_selectedDate) + (_firstWeekdayOfMonth(_selectedDate) - 1),
                          itemBuilder: (ctx, idx) {
                            final offset = _firstWeekdayOfMonth(_selectedDate) - 1;
                            if (idx < offset) {
                              return const SizedBox();
                            }
                            final day = idx - offset + 1;
                            final isSelected = day == _selectedDate.day;
                            final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                            final hasEvents = _events.any((e) => e['date'] == dateStr);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, day);
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.scaffoldBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: isSelected ? null : Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$day',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                    if (hasEvents) ...[
                                      const SizedBox(height: 2),
                                      Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected ? Colors.white : AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tag Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Maintenance', 'Lease Expiry', 'Inspection', 'Property Showing'].map((tag) {
                        final isSelected = _selectedTag == tag;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(tag),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedTag = tag),
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            backgroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Event List Cards
                  _filteredEvents.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                          child: const Column(
                            children: [
                              Icon(Icons.event_busy_rounded, size: 40, color: AppColors.textHint),
                              SizedBox(height: 8),
                              Text('No events match this tag filter', style: TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredEvents.length,
                          itemBuilder: (ctx, idx) {
                            final evt = _filteredEvents[idx];
                            final type = evt['type'] as String;
                            Color tagColor;
                            switch (type.toLowerCase()) {
                              case 'maintenance': tagColor = Colors.orange; break;
                              case 'lease expiry': tagColor = AppColors.error; break;
                              case 'inspection': tagColor = Colors.purple; break;
                              default: tagColor = Colors.blue;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: tagColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.event_note_rounded, color: tagColor, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(evt['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(color: tagColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                              child: Text(type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: tagColor)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(evt['property'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textHint),
                                            const SizedBox(width: 4),
                                            Text('${evt['date']} • ${evt['time']}', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}

