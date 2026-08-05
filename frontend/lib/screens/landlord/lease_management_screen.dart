import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/provider/landlord_state.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:dio/dio.dart';

class LeaseManagementScreen extends ConsumerStatefulWidget {
  const LeaseManagementScreen({super.key});

  @override
  ConsumerState<LeaseManagementScreen> createState() => _LeaseManagementScreenState();
}

class _LeaseManagementScreenState extends ConsumerState<LeaseManagementScreen> {
  // Status filter: null means "All"
  String? _selectedStatus;

  static const List<_StatusFilter> _statusFilters = [
    _StatusFilter(label: 'All', value: null, icon: Icons.list_rounded),
    _StatusFilter(label: 'Active', value: 'active', icon: Icons.check_circle_outline_rounded),
    _StatusFilter(label: 'Expiring', value: 'expiring', icon: Icons.hourglass_bottom_rounded),
    _StatusFilter(label: 'Terminated', value: 'terminated', icon: Icons.cancel_outlined),
    _StatusFilter(label: 'Draft', value: 'draft', icon: Icons.edit_note_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(landlordProvider);
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.05;

    // Expiring leases: daysLeft > 0 && daysLeft <= 60
    final expiringLeases = state.leases
        .where((l) => l.daysLeft > 0 && l.daysLeft <= 60)
        .toList()
      ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));

    // Apply status filter
    final allLeases = _selectedStatus == null
        ? state.leases
        : state.leases.where((l) => l.status.toLowerCase() == _selectedStatus).toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Lease Management', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.read(landlordProvider.notifier).loadLeases(),
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_lease',
        onPressed: () => _showCreateLeaseSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Create Lease', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
      ),
      body: state.isLeasesLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: pad, vertical: h * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Lease Summary Cards ───────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          label: 'Active Leases',
                          value: state.activeLeaseCount.toString(),
                          color: AppColors.primary,
                          textColor: AppColors.white,
                          w: w,
                        ),
                      ),
                      SizedBox(width: w * 0.04),
                      Expanded(
                        child: _statCard(
                          label: 'Expiring Leases',
                          value: state.expiringLeaseCount.toString(),
                          color: AppColors.white,
                          textColor: AppColors.error,
                          border: true,
                          w: w,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: h * 0.035),

                  // ─── Priority Renewals ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Priority Renewals', style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      Text('${expiringLeases.length} expiring', style: TextStyle(fontSize: w * 0.03, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                    ],
                  ),
                  SizedBox(height: h * 0.015),

                  if (expiringLeases.isEmpty)
                    _emptyCard(icon: Icons.check_circle_outline_rounded, iconColor: Colors.green, text: 'No leases expiring within 60 days', w: w)
                  else
                    SizedBox(
                      height: h * 0.25,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: expiringLeases.length,
                        separatorBuilder: (_, _) => SizedBox(width: w * 0.04),
                        itemBuilder: (context, idx) {
                          final lease = expiringLeases[idx];
                          return _expiringLeaseCard(lease, w, h);
                        },
                      ),
                    ),

                  SizedBox(height: h * 0.035),

                  // ─── All Leases ────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('All Leases', style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      Text(
                        '${allLeases.length} ${_selectedStatus ?? 'total'}',
                        style: TextStyle(fontSize: w * 0.03, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  SizedBox(height: h * 0.012),

                  // ── Status Filter Chips ────────────────────────────────
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _statusFilters.map((f) {
                        final isSelected = _selectedStatus == f.value;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedStatus = f.value),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2))]
                                  : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(f.icon, size: 13, color: isSelected ? Colors.white : AppColors.textSecondary),
                                const SizedBox(width: 5),
                                Text(
                                  f.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: h * 0.015),

                  if (allLeases.isEmpty)
                    _emptyCard(icon: Icons.description_outlined, iconColor: AppColors.textHint, text: 'No leases found. Tap "+ Create Lease" to get started.', w: w)
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allLeases.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/landlord_lease_detail',
                            arguments: allLeases[idx],
                          ),
                          child: _leaseListCard(allLeases[idx], w),
                        );
                      },
                    ),

                  SizedBox(height: h * 0.12), // Space for FAB
                ],
              ),
            ),
    );
  }

  // ─── Stat Card ─────────────────────────────────────────────────────────────
  Widget _statCard({
    required String label,
    required String value,
    required Color color,
    required Color textColor,
    required double w,
    bool border = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: border ? Border.all(color: AppColors.border) : null,
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: w * 0.08, fontWeight: FontWeight.w800, color: textColor)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: w * 0.028, color: border ? AppColors.textSecondary : AppColors.white.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  // ─── Expiring Lease Card ────────────────────────────────────────────────────
  Widget _expiringLeaseCard(Lease lease, double w, double h) {
    return Container(
      width: w * 0.65,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(lease.unitName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16), overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text('${lease.daysLeft}d left', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.error)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(lease.tenantName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          if (lease.propertyName.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(lease.propertyName, style: const TextStyle(color: AppColors.textHint, fontSize: 11), overflow: TextOverflow.ellipsis),
          ],
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${lease.rentAmount.toStringAsFixed(0)}/mo', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ElevatedButton(
                onPressed: () => _showRenewSheet(context, lease),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Renew', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Lease List Card ────────────────────────────────────────────────────────
  Widget _leaseListCard(Lease lease, double w) {
    final isExpiring = lease.daysLeft > 0 && lease.daysLeft <= 60;
    final statusColor = _statusColor(lease.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isExpiring ? AppColors.error.withValues(alpha: 0.3) : AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lease.unitName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Text(lease.tenantName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                if (lease.propertyName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(lease.propertyName, style: const TextStyle(color: AppColors.textHint, fontSize: 11), overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      'Expires: ${lease.endDate}',
                      style: TextStyle(
                        color: isExpiring ? AppColors.error : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: isExpiring ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Status Badge + Change Status popup
              PopupMenuButton<String>(
                tooltip: 'Change Status',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onSelected: (newStatus) async {
                  if (newStatus == lease.status) return;
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await ref.read(landlordProvider.notifier).updateLeaseStatus(lease.id, newStatus);
                    if (context.mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Lease status updated to ${newStatus.toUpperCase()}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                      );
                    }
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'active',     child: Text('✅  Active')),
                  const PopupMenuItem(value: 'expiring',   child: Text('⏳  Expiring')),
                  const PopupMenuItem(value: 'draft',      child: Text('📝  Draft')),
                  const PopupMenuItem(value: 'terminated', child: Text('🚫  Terminated')),
                  const PopupMenuItem(value: 'renewed',    child: Text('🔄  Renewed')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(lease.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down_rounded, size: 14, color: statusColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text('\$${lease.rentAmount.toStringAsFixed(0)}/mo', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.green)),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (lease.status != 'terminated') ...[
                    OutlinedButton(
                      onPressed: () => _showRenewSheet(context, lease),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      child: const Text('Renew', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton(
                      onPressed: () => _confirmTerminate(context, lease),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      child: const Text('End', style: TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Empty card ─────────────────────────────────────────────────────────────
  Widget _emptyCard({required IconData icon, required Color iconColor, required String text, required double w}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.05),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(fontSize: w * 0.032, color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active': return Colors.green;
      case 'expiring': return Colors.orange;
      case 'terminated': return AppColors.error;
      case 'renewed': return AppColors.primary;
      default: return AppColors.textSecondary;
    }
  }

  // ─── Create Lease Bottom Sheet ──────────────────────────────────────────────
  void _showCreateLeaseSheet(BuildContext context) {
    final state = ref.read(landlordProvider);
    final rentCtrl = TextEditingController();
    final depositCtrl = TextEditingController();
    final tenantEmailCtrl = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    String schedule = 'monthly';
    bool autoRenew = false;
    bool isLoading = false;
    String? tenantLookupError;

    // Build dropdown lists from state
    final properties = state.properties;
    final tenants = state.tenants;
    String? selectedPropertyId;
    String? selectedUnitId;
    String? selectedTenantId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                const Text('Create Lease', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 20),

                // Tenant selection
                const Text('Tenant *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                if (tenants.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: selectedTenantId,
                    hint: const Text('Select Tenant'),
                    isExpanded: true,
                    decoration: _sheetFieldDeco(),
                    items: tenants.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (v) => setSheetState(() => selectedTenantId = v),
                  ),
                  const SizedBox(height: 6),
                  const Text('Or enter tenant email manually:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                ],
                TextField(
                  controller: tenantEmailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _sheetFieldDeco(hint: 'tenant@email.com'),
                  onChanged: (_) => setSheetState(() => tenantLookupError = null),
                ),
                if (tenantLookupError != null) ...[
                  const SizedBox(height: 4),
                  Text(tenantLookupError!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
                ],
                const SizedBox(height: 4),
                const Text('Tenant must have a registered account in the app', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                const SizedBox(height: 16),

                // Property Selection
                if (properties.isEmpty) ...[
                  const Text('Property *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  const Text('No properties found. Please create a property first.', style: TextStyle(color: AppColors.error, fontSize: 13)),
                  const SizedBox(height: 16),
                ] else ...[
                  const Text('Property *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPropertyId,
                    hint: const Text('Select Property'),
                    decoration: _sheetFieldDeco(),
                    items: properties.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                    onChanged: (v) async {
                      setSheetState(() {
                        selectedPropertyId = v;
                        selectedUnitId = null; // reset unit selection when property changes
                        rentCtrl.clear();
                      });
                      if (v != null) {
                        await ref.read(landlordProvider.notifier).loadUnits(v);
                        setSheetState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Unit Selection
                  const Text('Unit *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Builder(
                    builder: (context) {
                      final currentUnits = ref.read(landlordProvider).units;
                      final propertyUnits = selectedPropertyId == null 
                          ? <Unit>[] 
                          : currentUnits.where((u) => u.propertyId == selectedPropertyId && u.status.toLowerCase() == 'vacant').toList();
                          
                      if (selectedPropertyId == null) {
                        return const Text('Please select a property first.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13));
                      } else if (ref.read(landlordProvider).isUnitsLoading) {
                        return const Text('Loading units...', style: TextStyle(color: AppColors.textSecondary, fontSize: 13));
                      } else if (propertyUnits.isEmpty) {
                        return const Text('No vacant units found for this property.', style: TextStyle(color: AppColors.error, fontSize: 13));
                      }
                      
                      return DropdownButtonFormField<String>(
                        initialValue: selectedUnitId,
                        hint: const Text('Select Unit'),
                        decoration: _sheetFieldDeco(),
                        items: propertyUnits.map((u) => DropdownMenuItem(value: u.id, child: Text('${u.name} — \$${u.rent.toStringAsFixed(0)}/mo'))).toList(),
                        onChanged: (v) {
                          setSheetState(() => selectedUnitId = v);
                          // Auto-fill rent
                          if (v != null) {
                            final u = propertyUnits.firstWhere((u) => u.id == v);
                            rentCtrl.text = u.rent.toStringAsFixed(0);
                          }
                        },
                      );
                    }
                  ),
                  const SizedBox(height: 16),
                ],

                // Dates
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Start Date *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2035));
                              if (picked != null) setSheetState(() => startDate = picked);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textHint),
                                  const SizedBox(width: 8),
                                  Text(startDate != null ? '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}' : 'Pick date', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
                          const Text('End Date *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(context: ctx, initialDate: DateTime.now().add(const Duration(days: 365)), firstDate: DateTime(2020), lastDate: DateTime(2035));
                              if (picked != null) setSheetState(() => endDate = picked);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textHint),
                                  const SizedBox(width: 8),
                                  Text(endDate != null ? '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}' : 'Pick date', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Rent & Deposit
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Monthly Rent (\$) *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextField(controller: rentCtrl, keyboardType: TextInputType.number, decoration: _sheetFieldDeco(hint: '1500')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Deposit (\$)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextField(controller: depositCtrl, keyboardType: TextInputType.number, decoration: _sheetFieldDeco(hint: '3000')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Payment schedule
                const Text('Payment Schedule', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: schedule,
                  decoration: _sheetFieldDeco(),
                  items: const [
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                    DropdownMenuItem(value: 'bi_weekly', child: Text('Bi-Weekly')),
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  ],
                  onChanged: (v) => setSheetState(() => schedule = v ?? 'monthly'),
                ),
                const SizedBox(height: 12),

                // Auto-Renew
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Auto-Renew', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Switch(
                      value: autoRenew,
                      onChanged: (v) => setSheetState(() => autoRenew = v),
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final uId = selectedUnitId ?? '';
                            final pId = selectedPropertyId ?? '';
                            if (uId.isEmpty || pId.isEmpty || startDate == null || endDate == null || rentCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.error));
                              return;
                            }
                            // Resolve tenant ID: prefer dropdown selection, else look up by email
                            String tId = selectedTenantId ?? '';
                            final emailInput = tenantEmailCtrl.text.trim();
                            if (tId.isEmpty && emailInput.isEmpty) {
                              setSheetState(() => tenantLookupError = 'Please select a tenant or enter tenant email');
                              return;
                            }
                            setSheetState(() { isLoading = true; tenantLookupError = null; });
                            if (tId.isEmpty && emailInput.isNotEmpty) {
                              // Lookup tenant by email via backend
                              try {
                                final resp = await ApiClient().dio.get('/users', queryParameters: {'email': emailInput});
                                final rows = (resp.data['data'] as List<dynamic>?);
                                final match = rows?.firstWhere(
                                  (u) => (u['email'] as String?)?.toLowerCase() == emailInput.toLowerCase(),
                                  orElse: () => null,
                                );
                                if (match == null) {
                                  setSheetState(() { isLoading = false; tenantLookupError = 'No user found with email: $emailInput'; });
                                  return;
                                }
                                tId = match['id']?.toString() ?? '';
                              } catch (_) {
                                setSheetState(() { isLoading = false; tenantLookupError = 'Could not look up tenant. Check connection.'; });
                                return;
                              }
                            }
                            try {
                              final sd = '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}';
                              final ed = '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}';

                              await ref.read(landlordProvider.notifier).createLease(
                                    tenantId: tId,
                                    unitId: uId,
                                    propertyId: pId,
                                    startDate: sd,
                                    endDate: ed,
                                    rentAmount: double.parse(rentCtrl.text.trim()),
                                    securityDeposit: double.tryParse(depositCtrl.text.trim()) ?? 0.0,
                                    paymentSchedule: schedule,
                                    autoRenew: autoRenew,
                                  );
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lease created successfully! ✅'), backgroundColor: Color(0xFF27AE60)));
                              }
                            } on DioException catch (e) {
                              if (ctx.mounted) {
                                final msg = e.response?.data['message'] ?? e.response?.data['error'] ?? e.message;
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('API Error: $msg'), backgroundColor: AppColors.error));
                              }
                            } catch (e) {
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.error));
                              }
                            } finally {
                              if (ctx.mounted) setSheetState(() => isLoading = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isLoading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('Create Lease', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Renew Lease Sheet ──────────────────────────────────────────────────────
  void _showRenewSheet(BuildContext context, Lease lease) {
    DateTime? newStartDate;
    DateTime? newEndDate;
    final rentCtrl = TextEditingController(text: lease.rentAmount.toStringAsFixed(0));
    final termsCtrl = TextEditingController();
    bool isLoading = false;

    String fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.autorenew_rounded, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Renew Lease', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        Text('${lease.unitName} • ${lease.tenantName}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Dates Row ────────────────────────────────────────
                Row(
                  children: [
                    // New Start Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('New Start Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                lastDate: DateTime(2040),
                              );
                              if (picked != null) setSheetState(() => newStartDate = picked);
                            },
                            child: _dateTile(newStartDate, 'Pick start'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // New End Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('New End Date *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: DateTime.now().add(const Duration(days: 365)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2040),
                              );
                              if (picked != null) setSheetState(() => newEndDate = picked);
                            },
                            child: _dateTile(newEndDate, 'Pick end'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Updated Rent ─────────────────────────────────────
                const Text('Updated Rent Amount (\$)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: rentCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _sheetFieldDeco(hint: 'e.g. 1800'),
                ),
                const SizedBox(height: 16),

                // ── Terms ────────────────────────────────────────────
                const Text('Renewal Terms / Notes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: termsCtrl,
                  maxLines: 3,
                  decoration: _sheetFieldDeco(hint: 'e.g. Same terms apply. Rent increased by 3%.'),
                ),
                const SizedBox(height: 24),

                // ── Submit ───────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading || newEndDate == null
                        ? null
                        : () async {
                            setSheetState(() => isLoading = true);
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              final payload = <String, dynamic>{
                                'endDate': fmt(newEndDate!),
                                'end_date': fmt(newEndDate!),
                                if (newStartDate != null) ...{
                                  'startDate': fmt(newStartDate!),
                                  'start_date': fmt(newStartDate!),
                                },
                                if (rentCtrl.text.trim().isNotEmpty)
                                  'rent_amount': double.tryParse(rentCtrl.text.trim()),
                                if (termsCtrl.text.trim().isNotEmpty)
                                  'notes': termsCtrl.text.trim(),
                              };
                              await ref.read(landlordProvider.notifier).renewLease(lease.id, payload);
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                messenger.showSnackBar(
                                  const SnackBar(content: Text('Lease renewed successfully! ✅'), backgroundColor: Color(0xFF27AE60)),
                                );
                              }
                            } catch (e) {
                              if (ctx.mounted) {
                                messenger.showSnackBar(
                                  SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.error),
                                );
                              }
                            } finally {
                              if (ctx.mounted) setSheetState(() => isLoading = false);
                            }
                          },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isLoading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('Confirm Renewal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper: date picker tile
  Widget _dateTile(DateTime? date, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: date != null ? AppColors.primary : AppColors.border, width: date != null ? 1.5 : 1),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.scaffoldBg,
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_rounded, size: 15, color: date != null ? AppColors.primary : AppColors.textHint),
          const SizedBox(width: 7),
          Text(
            date != null ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}' : hint,
            style: TextStyle(fontSize: 12, color: date != null ? AppColors.textPrimary : AppColors.textHint, fontWeight: date != null ? FontWeight.w600 : FontWeight.normal),
          ),
        ],
      ),
    );
  }

  InputDecoration _sheetFieldDeco({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
        filled: true,
        fillColor: AppColors.scaffoldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      );

  void _confirmTerminate(BuildContext context, Lease lease) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Terminate Lease', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to terminate this lease? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(landlordProvider.notifier).updateLeaseStatus(lease.id, 'terminated');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lease terminated.'), backgroundColor: AppColors.error));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Terminate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// Simple data holder for status filter chips
class _StatusFilter {
  final String label;
  final String? value;
  final IconData icon;
  const _StatusFilter({required this.label, required this.value, required this.icon});
}
