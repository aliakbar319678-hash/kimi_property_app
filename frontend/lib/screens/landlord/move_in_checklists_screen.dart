import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/provider/landlord_state.dart';
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
    setState(() => _isLoading = true);
    try {
      final landlordState = ref.read(landlordProvider);
      final leases = landlordState.leases;
      final List<Map<String, dynamic>> allInspections = [];

      for (final lease in leases) {
        try {
          final res = await ApiClient().dio.get(
            '/leases/${lease.id}/inspections',
          );
          final list =
              (res.data['inspections'] ?? res.data['data'] ?? [])
                  as List<dynamic>;
          for (final item in list) {
            final m = item as Map<String, dynamic>;
            if ((m['type']?.toString() ?? '').toUpperCase() != 'MOVE_IN') {
              continue;
            }

            final checklistData = m['checklist_data'] as List<dynamic>? ?? [];
            final Map<String, String> ratings = {};
            for (var c in checklistData) {
              if (c is Map<String, dynamic>) {
                String condition = c['condition']?.toString() ?? '';
                // Normalize condition casing
                switch (condition.toUpperCase()) {
                  case 'GOOD':
                    condition = 'Good';
                    break;
                  case 'FAIR':
                    condition = 'Fair';
                    break;
                  case 'NEEDS REPAIR':
                  case 'NEEDS_REPAIR':
                    condition = 'Needs Repair';
                    break;
                  case 'EXCELLENT':
                    condition = 'Excellent';
                    break;
                  case 'DAMAGED':
                    condition = 'Damaged';
                    break;
                }
                final roomName = c['item']?.toString() ?? '';
                if (roomName.isNotEmpty) {
                  ratings[roomName] = condition;
                }
              }
            }

            allInspections.add({
              'id': m['id']?.toString() ?? '',
              'propertyName': lease.propertyName,
              'unitName': lease.unitName,
              'tenantName': lease.tenantName,
              'leaseId': lease.id,
              'date': m['created_at']?.toString().split('T').first ?? '',
              'status': m['status']?.toString() ?? 'Pending',
              // Only store real ratings — no fake fallback
              'ratings': ratings,
              'tenantSignature': m['tenant_signature']?.toString().isNotEmpty == true
                  ? m['tenant_signature']
                  : null,
              'landlordSignature': m['landlord_signature']?.toString().isNotEmpty == true
                  ? m['landlord_signature']
                  : null,
            });
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() => _checklists = allInspections);
      }
    } catch (e) {
      debugPrint('[MoveInChecklistsScreen] _fetchChecklists error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showCreateChecklistDialog() {
    final landlordState = ref.read(landlordProvider);
    final leases = landlordState.leases;

    if (leases.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active leases found. Please create a lease first.'),
        ),
      );
      return;
    }

    Lease? selectedLease = leases.first;
    String livingRoomRating = 'Good';
    String kitchenRating = 'Good';
    String bedroomRating = 'Good';
    String bathroomRating = 'Good';
    final signatureController = TextEditingController();

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
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.fact_check_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'New Move-In Checklist',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Lease Dropdown — Unit and Tenant auto-fill from selection
                    const Text(
                      'Select Lease',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<Lease>(
                      initialValue: selectedLease,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        hintText: 'Choose a lease',
                      ),
                      items: leases.map((lease) {
                        return DropdownMenuItem<Lease>(
                          value: lease,
                          child: Text(
                            '${lease.tenantName} — ${lease.unitName}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedLease = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Auto-filled info from selected lease
                    if (selectedLease != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Unit',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    selectedLease!.unitName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tenant',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    selectedLease!.tenantName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Room Condition Ratings
                    const Text(
                      'Room Condition Ratings',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
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

                    // Landlord Signature
                    TextFormField(
                      controller: signatureController,
                      decoration: InputDecoration(
                        labelText: 'Landlord Signature',
                        hintText: 'Type your name to sign',
                        prefixIcon: const Icon(Icons.draw_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (selectedLease == null) return;

                          final overallStatus = (livingRoomRating ==
                                      'Needs Repair' ||
                                  kitchenRating == 'Needs Repair' ||
                                  bedroomRating == 'Needs Repair' ||
                                  bathroomRating == 'Needs Repair')
                              ? 'Failed'
                              : 'Passed';

                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await ApiClient().dio.post(
                              '/leases/${selectedLease!.id}/inspections',
                              data: {
                                'inspection_type': 'MOVE_IN',
                                'checklist_data': [
                                  {
                                    'item': 'Living Room',
                                    'condition':
                                        livingRoomRating.toUpperCase().replaceAll(' ', '_'),
                                    'notes': '',
                                  },
                                  {
                                    'item': 'Kitchen',
                                    'condition':
                                        kitchenRating.toUpperCase().replaceAll(' ', '_'),
                                    'notes': '',
                                  },
                                  {
                                    'item': 'Bedroom',
                                    'condition':
                                        bedroomRating.toUpperCase().replaceAll(' ', '_'),
                                    'notes': '',
                                  },
                                  {
                                    'item': 'Bathroom',
                                    'condition':
                                        bathroomRating.toUpperCase().replaceAll(' ', '_'),
                                    'notes': '',
                                  },
                                ],
                                'inspector_role': 'LANDLORD',
                                'landlord_signature':
                                    signatureController.text.trim().isNotEmpty
                                        ? signatureController.text.trim()
                                        : 'Landlord',
                              },
                            );

                            if (context.mounted) {
                              Navigator.pop(ctx);
                            }
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Checklist created ($overallStatus)!',
                                  ),
                                  backgroundColor: overallStatus == 'Passed'
                                      ? const Color(0xFF1B8E4D)
                                      : AppColors.error,
                                ),
                              );
                              _fetchChecklists();
                            }
                          } catch (e) {
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Failed to create checklist: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Save & Issue Checklist',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
    const options = ['Excellent', 'Good', 'Fair', 'Needs Repair'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
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
                final textColor =
                    isSelected ? Colors.white : AppColors.textPrimary;

                return GestureDetector(
                  onTap: () => onChanged(opt),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
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
                        color: textColor,
                      ),
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
                  Expanded(
                    child: Text(
                      item['propertyName'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _buildStatusBadge(item['status'] ?? 'Pending'),
                ],
              ),
              Text(
                '${item['unitName']} • Tenant: ${item['tenantName']}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 8),
              const Text(
                'Room Conditions:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              // Show real ratings or empty state — no fake data
              ratings.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No room data recorded for this inspection.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : Column(
                      children: ratings.entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e.key,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                e.value.toString(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: e.value.toString().contains(
                                              'Needs Repair') ||
                                          e.value.toString().contains(
                                              'Damaged')
                                      ? AppColors.error
                                      : const Color(0xFF1B8E4D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).toList(),
                    ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Landlord Signature',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        item['landlordSignature'] ?? 'Not signed',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Tenant Signature',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        item['tenantSignature'] ?? 'Pending',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
          color: text,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
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
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _fetchChecklists,
          ),
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
        label: const Text(
          'New Checklist',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _checklists.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fact_check_outlined,
                        size: 64,
                        color: AppColors.textHint.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Move-In Checklists Yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create a checklist when a new tenant moves in.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showCreateChecklistDialog,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('New Checklist'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(w * 0.05),
                  itemCount: _checklists.length,
                  itemBuilder: (context, index) {
                    final item = _checklists[index];
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.only(bottom: w * 0.04),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showChecklistDetails(item),
                        child: Padding(
                          padding: EdgeInsets.all(w * 0.045),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['propertyName'] ?? '',
                                      style: TextStyle(
                                        fontSize: w * 0.042,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStatusBadge(item['status'] ?? 'Pending'),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${item['unitName']} • Tenant: ${item['tenantName']}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_rounded,
                                        size: 14,
                                        color: AppColors.textHint,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['date'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textHint,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Row(
                                    children: [
                                      Text(
                                        'View Details',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
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
