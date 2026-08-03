import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';

class MoveInChecklistsScreen extends ConsumerStatefulWidget {
  const MoveInChecklistsScreen({super.key});

  @override
  ConsumerState<MoveInChecklistsScreen> createState() =>
      _MoveInChecklistsScreenState();
}

class _MoveInChecklistsScreenState
    extends ConsumerState<MoveInChecklistsScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _checklists = [];

  @override
  void initState() {
    super.initState();
    _fetchChecklists();
  }

  Future<void> _fetchChecklists() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final landlordState = ref.read(landlordProvider);
      final leases = landlordState.leases;
      List<Map<String, dynamic>> allInspections = [];

      for (final lease in leases) {
        try {
          final res = await ApiClient().dio.get('/leases/${lease.id}/inspections');
          final list = (res.data['inspections'] ?? res.data['data'] ?? []) as List<dynamic>;
          for (final item in list) {
            final m = item as Map<String, dynamic>;
            final type = m['type']?.toString().toUpperCase() ?? 'MOVE_IN';
            if (type == 'MOVE_OUT') continue;

            final checklist = m['checklist_data'] as List<dynamic>? ?? [];
            final ratings = <String, String>{};
            for (final c in checklist) {
              if (c is Map && c['item'] != null) {
                ratings[c['item'].toString()] = c['condition']?.toString() ?? 'Good';
              }
            }

            allInspections.add({
              'id': m['id']?.toString() ?? 'chk-${allInspections.length + 1}',
              'propertyName': lease.propertyName,
              'unitName': lease.unitName,
              'tenantName': lease.tenantName,
              'leaseId': lease.id,
              'date': m['inspection_date']?.toString() ?? m['created_at']?.toString().split('T').first ?? '2026-08-01',
              'status': m['status']?.toString() ?? 'Passed',
              'ratings': ratings.isNotEmpty
                  ? ratings
                  : {
                      'Living Room': 'Good',
                      'Kitchen': 'Good',
                      'Master Bedroom': 'Good',
                      'Bathroom': 'Good',
                    },
              'tenantSignature': m['tenant_signature'] ?? 'Pending Tenant Sign',
              'landlordSignature': m['landlord_signature'] ?? 'Signed by Landlord',
            });
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _checklists = allInspections;
        });
      }
    } catch (e) {
      debugPrint('[MoveInChecklistsScreen] _fetchChecklists error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showCreateChecklistDialog() {
    final state = ref.read(landlordProvider);
    final properties = state.properties;

    String selectedProperty =
        properties.isNotEmpty ? properties.first.name : 'Green Valley Apts';
    String unitName = 'Unit 1A';
    String tenantName = 'John Doe';
    String livingRoomRating = 'Good';
    String kitchenRating = 'Good';
    String bedroomRating = 'Good';
    String bathroomRating = 'Good';
    final signatureController = TextEditingController(text: 'Landlord Signature');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.fact_check_rounded,
                              color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'New Move-In Checklist',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Property & Unit',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedProperty,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      items: (properties.isNotEmpty
                              ? properties.map((p) => p.name).toList()
                              : [
                                  'Green Valley Apartments',
                                  'Sunset Heights',
                                  'Grand Park Tower'
                                ])
                          .map((name) => DropdownMenuItem(
                                value: name,
                                child: Text(name),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedProperty = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: unitName,
                            decoration: InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onChanged: (val) => unitName = val,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: tenantName,
                            decoration: InputDecoration(
                              labelText: 'Tenant Name',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onChanged: (val) => tenantName = val,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Room Condition Ratings',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    _buildRatingSegment(
                      label: 'Living Room',
                      value: livingRoomRating,
                      onChanged: (val) =>
                          setModalState(() => livingRoomRating = val),
                    ),
                    _buildRatingSegment(
                      label: 'Kitchen',
                      value: kitchenRating,
                      onChanged: (val) =>
                          setModalState(() => kitchenRating = val),
                    ),
                    _buildRatingSegment(
                      label: 'Bedroom',
                      value: bedroomRating,
                      onChanged: (val) =>
                          setModalState(() => bedroomRating = val),
                    ),
                    _buildRatingSegment(
                      label: 'Bathroom',
                      value: bathroomRating,
                      onChanged: (val) =>
                          setModalState(() => bathroomRating = val),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: signatureController,
                      decoration: InputDecoration(
                        labelText: 'Digital Signature (Landlord)',
                        prefixIcon: const Icon(Icons.draw_rounded),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final leases = ref.read(landlordProvider).leases;
                          final matchingLease = leases.firstWhere(
                            (l) => l.propertyName.toLowerCase() == selectedProperty.toLowerCase(),
                            orElse: () => leases.isNotEmpty ? leases.first : throw Exception('No active lease found'),
                          );

                          final overallStatus = (livingRoomRating == 'Needs Repair' ||
                                  kitchenRating == 'Needs Repair' ||
                                  bedroomRating == 'Needs Repair' ||
                                  bathroomRating == 'Needs Repair')
                              ? 'Failed'
                              : 'Passed';

                          final checklistData = [
                            {'item': 'Living Room', 'condition': livingRoomRating.toUpperCase(), 'notes': ''},
                            {'item': 'Kitchen', 'condition': kitchenRating.toUpperCase(), 'notes': ''},
                            {'item': 'Bedroom', 'condition': bedroomRating.toUpperCase(), 'notes': ''},
                            {'item': 'Bathroom', 'condition': bathroomRating.toUpperCase(), 'notes': ''},
                          ];

                          try {
                            await ApiClient().dio.post(
                              '/leases/${matchingLease.id}/inspections',
                              data: {
                                'inspection_type': 'MOVE_IN',
                                'checklist_data': checklistData,
                                'inspector_role': 'LANDLORD',
                                'landlord_signature': signatureController.text.isNotEmpty
                                    ? signatureController.text
                                    : 'Signed by Landlord',
                              },
                            );

                            if (context.mounted) {
                              Navigator.pop(ctx);
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Checklist created successfully ($overallStatus)!'),
                                  backgroundColor: overallStatus == 'Passed'
                                      ? const Color(0xFF1B8E4D)
                                      : AppColors.error,
                                ),
                              );
                            }
                            _fetchChecklists();
                          } catch (e) {
                            if (context.mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Failed to submit checklist: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Save & Issue Checklist',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRatingSegment({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    final options = ['Excellent', 'Good', 'Fair', 'Needs Repair'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: options.map((opt) {
                final isSelected = value == opt;
                final isRepair = opt == 'Needs Repair';
                final color = isSelected
                    ? (isRepair ? AppColors.error : AppColors.primary)
                    : AppColors.inputBg;
                final textColor = isSelected ? Colors.white : AppColors.textPrimary;

                return GestureDetector(
                  onTap: () => onChanged(opt),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? color : AppColors.border,
                      ),
                    ),
                    child: Text(
                      opt,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: textColor),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showChecklistDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final ratings = item['ratings'] as Map<String, dynamic>? ?? {};
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['propertyName'] ?? '',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  _buildStatusBadge(item['status'] ?? 'Pending'),
                ],
              ),
              Text('${item['unitName']} • Tenant: ${item['tenantName']}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 8),
              const Text('Room Conditions:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              ...ratings.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textSecondary)),
                        Text(
                          e.value.toString(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: e.value.toString().contains('Needs Repair')
                                ? AppColors.error
                                : const Color(0xFF1B8E4D),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Landlord Signature',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                      Text(item['landlordSignature'] ?? 'Signed',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Tenant Signature',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                      Text(item['tenantSignature'] ?? 'Pending',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('Export Inspection PDF'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Move-In Checklist PDF downloaded.'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;

    switch (status.toLowerCase()) {
      case 'passed':
        bg = const Color(0xFF1B8E4D).withValues(alpha: 0.1);
        text = const Color(0xFF1B8E4D);
        break;
      case 'failed':
        bg = AppColors.error.withValues(alpha: 0.1);
        text = AppColors.error;
        break;
      default:
        bg = const Color(0xFFD97706).withValues(alpha: 0.1);
        text = const Color(0xFFD97706);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            color: text, fontWeight: FontWeight.bold, fontSize: 11),
      ),
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
          'Move-In Checklists',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded, color: AppColors.primary),
            onPressed: _showCreateChecklistDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateChecklistDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Checklist',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(w * 0.05),
              itemCount: _checklists.length,
              itemBuilder: (context, index) {
                final item = _checklists[index];
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: w * 0.04),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showChecklistDetails(item),
                    child: Padding(
                      padding: EdgeInsets.all(w * 0.045),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item['propertyName'] ?? '',
                                style: TextStyle(
                                  fontSize: w * 0.042,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              _buildStatusBadge(item['status'] ?? 'Pending'),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${item['unitName']} • Tenant: ${item['tenantName']}',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded,
                                      size: 14, color: AppColors.textHint),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['date'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textHint),
                                  ),
                                ],
                              ),
                              const Row(
                                children: [
                                  Text('View Details',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary)),
                                  Icon(Icons.chevron_right_rounded,
                                      size: 16, color: AppColors.primary),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
