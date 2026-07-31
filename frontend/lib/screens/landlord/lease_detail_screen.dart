import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/provider/landlord_state.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/landlord/lease_renewal_dialog.dart';

class LandlordLeaseDetailScreen extends ConsumerStatefulWidget {
  const LandlordLeaseDetailScreen({super.key});

  @override
  ConsumerState<LandlordLeaseDetailScreen> createState() =>
      _LandlordLeaseDetailScreenState();
}

class _LandlordLeaseDetailScreenState
    extends ConsumerState<LandlordLeaseDetailScreen> {
  Map<String, dynamic>? _detail;
  List<Map<String, dynamic>> _inspections = [];
  bool _isLoading = true;
  bool _isInspectionsLoading = true;
  String _error = '';
  String? _leaseId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Lease && _leaseId == null) {
      _leaseId = arg.id;
      _fetchDetail();
    }
  }

  Future<void> _fetchDetail() async {
    if (_leaseId == null) return;
    setState(() { _isLoading = true; _isInspectionsLoading = true; _error = ''; });
    try {
      final resp = await ApiClient().dio.get(ApiConstants.leaseById(_leaseId!));
      setState(() { _detail = resp.data['data'] as Map<String, dynamic>?; _isLoading = false; });
      
      // Fetch inspections
      final inspections = await ref.read(landlordProvider.notifier).getLeaseInspections(_leaseId!);
      setState(() { _inspections = inspections; _isInspectionsLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; _isInspectionsLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    final lease = arg is Lease ? arg : null;
    final notifier = ref.read(landlordProvider.notifier);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Lease Detail', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(w * 0.06),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(_error, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _fetchDetail,
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                        label: const Text('Retry', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ]),
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(w * 0.05),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Status banner
                    _statusBanner(lease, w),
                    SizedBox(height: h * 0.025),

                    // Detail card
                    _sectionCard(
                      title: 'Lease Info',
                      icon: Icons.description_outlined,
                      children: [
                        _detailRow('Unit', _field('unit_name', fallback: lease?.unitName ?? 'N/A')),
                        _detailRow('Property', _field('property_name', fallback: lease?.propertyName ?? '')),
                        _detailRow('Tenant', _tenantName()),
                        _detailRow('Start Date', _formatDate(_detail?['start_date']?.toString() ?? '') ?? (lease?.startDate ?? '')),
                        _detailRow('End Date', _formatDate(_detail?['end_date']?.toString() ?? '') ?? (lease?.endDate ?? '')),
                        _detailRow('Status', (_detail?['status'] ?? lease?.status ?? '').toString().toUpperCase()),
                      ],
                    ),
                    SizedBox(height: h * 0.02),

                    _sectionCard(
                      title: 'Financial',
                      icon: Icons.monetization_on_outlined,
                      children: [
                        _detailRow('Rent / Month', '\$${(double.tryParse((_detail?['rent_amount'] ?? lease?.rentAmount ?? 0).toString()) ?? 0.0).toStringAsFixed(0)}'),
                        _detailRow('Security Deposit', '\$${(double.tryParse((_detail?['security_deposit'] ?? _detail?['deposit_amount'] ?? 0).toString()) ?? 0.0).toStringAsFixed(0)}'),
                        _detailRow('Days Until Expiry', _daysLeft(lease)),
                      ],
                    ),
                    SizedBox(height: h * 0.025),

                    // Inspections
                    _sectionCard(
                      title: 'Inspections',
                      icon: Icons.fact_check_outlined,
                      children: [
                        if (_isInspectionsLoading)
                          const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator()))
                        else if (_inspections.isEmpty)
                          const Padding(padding: EdgeInsets.all(12), child: Text('No inspections found for this lease.', style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)))
                        else
                          ..._inspections.map((insp) {
                            return _detailRow(insp['type'] ?? 'Inspection', insp['status']?.toString().toUpperCase() ?? 'COMPLETED');
                          }),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/landlord_move_inspection_form', arguments: {'leaseId': _leaseId, 'type': 'Mid-Lease'});
                            },
                            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            icon: const Icon(Icons.add_task_rounded, size: 18),
                            label: const Text('New Inspection'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: h * 0.025),

                    // Action buttons
                    if (lease != null) ...[ 
                      _actionButtons(context, notifier, lease, w),
                    ],
                    SizedBox(height: h * 0.04),
                  ]),
                ),
    );
  }

  String? _formatDate(String raw) {
    if (raw.isEmpty) return null;
    final dt = DateTime.tryParse(raw);
    if (dt == null) return null;
    return '${_month(dt.month)} ${dt.day}, ${dt.year}';
  }

  String _month(int m) => const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];

  String _field(String key, {String fallback = ''}) {
    return _detail?[key]?.toString() ?? fallback;
  }

  String _tenantName() {
    final tenant = _detail?['tenant'] as Map<String, dynamic>?;
    if (tenant == null) return 'N/A';
    final fn = tenant['legal_first_name']?.toString() ?? '';
    final ln = tenant['legal_last_name']?.toString() ?? '';
    final name = [fn, ln].where((s) => s.isNotEmpty).join(' ');
    return name.isNotEmpty ? name : (tenant['email']?.toString().split('@').first ?? 'N/A');
  }

  String _daysLeft(Lease? lease) {
    if (lease == null) return 'N/A';
    if (lease.daysLeft <= 0) return 'Expired';
    return '${lease.daysLeft} days';
  }

  Widget _statusBanner(Lease? lease, double w) {
    final status = lease?.status.toLowerCase() ?? '';
    Color color;
    IconData icon;
    switch (status) {
      case 'active': color = Colors.green; icon = Icons.check_circle_rounded; break;
      case 'expiring': color = Colors.orange; icon = Icons.schedule_rounded; break;
      case 'terminated': color = AppColors.error; icon = Icons.cancel_rounded; break;
      case 'renewed': color = AppColors.primary; icon = Icons.refresh_rounded; break;
      default: color = AppColors.textSecondary; icon = Icons.info_outline_rounded;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(status.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: w * 0.042, color: color)),
          if (lease != null && lease.daysLeft > 0 && lease.daysLeft <= 60)
            Text('Expires in ${lease.daysLeft} days', style: TextStyle(fontSize: w * 0.028, color: color.withValues(alpha: 0.8))),
        ]),
      ]),
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary, size: 18)),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 14),
        const Divider(color: AppColors.border, height: 1),
        const SizedBox(height: 10),
        ...children,
      ]),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary), textAlign: TextAlign.right)),
      ]),
    );
  }

  Widget _actionButtons(BuildContext context, LandlordNotifier notifier, Lease lease, double w) {
    final canRenew = lease.status != 'terminated';
    final canTerminate = lease.status != 'terminated';
    return Column(children: [
      if (canRenew)
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => _showRenewSheet(context, notifier, lease),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            label: const Text('Renew Lease', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      if (canRenew) const SizedBox(height: 12),
      if (canTerminate)
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => _confirmTerminate(context, notifier, lease),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
            label: const Text('Terminate Lease', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.error)),
          ),
        ),
    ]);
  }

  void _showRenewSheet(BuildContext context, LandlordNotifier notifier, Lease lease) async {
    final data = await LeaseRenewalDialog.show(
      context,
      tenantName: lease.tenantName,
      currentRent: lease.rentAmount,
    );
    if (data != null && context.mounted) {
      try {
        final start = data.startDate;
        final end = DateTime(start.year, start.month + data.durationMonths, start.day);
        await notifier.renewLease(lease.id, {
          'rentAmount': data.proposedRent,
          'startDate': start.toIso8601String(),
          'endDate': end.toIso8601String(),
          'notes': data.notes,
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lease renewed successfully ✅'), backgroundColor: Color(0xFF27AE60)));
          _fetchDetail();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
        }
      }
    }
  }

  void _confirmTerminate(BuildContext context, LandlordNotifier notifier, Lease lease) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Terminate Lease', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to terminate this lease? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await notifier.updateLeaseStatus(lease.id, 'terminated');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lease terminated.'), backgroundColor: AppColors.error));
                  _fetchDetail();
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
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
