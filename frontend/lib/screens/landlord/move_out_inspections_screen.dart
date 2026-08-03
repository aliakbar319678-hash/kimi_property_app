import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/widgets/landlord/deposit_refund_calculator_dialog.dart';

class MoveOutInspectionsScreen extends ConsumerStatefulWidget {
  const MoveOutInspectionsScreen({super.key});

  @override
  ConsumerState<MoveOutInspectionsScreen> createState() =>
      _MoveOutInspectionsScreenState();
}

class _MoveOutInspectionsScreenState
    extends ConsumerState<MoveOutInspectionsScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _inspections = [];

  @override
  void initState() {
    super.initState();
    _fetchInspections();
  }

  Future<void> _fetchInspections() async {
    setState(() => _isLoading = true);
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
            final type = m['type']?.toString().toUpperCase() ?? 'MOVE_OUT';
            if (type != 'MOVE_OUT') continue;

            final checklist = m['checklist_data'] as List<dynamic>? ?? [];
            final damages = <Map<String, dynamic>>[];
            double totalDeductions = 0.0;

            for (final c in checklist) {
              if (c is Map) {
                final itemStr = c['item']?.toString() ?? 'Damage item';
                final costVal = double.tryParse(c['cost']?.toString() ?? '0') ?? 0.0;
                totalDeductions += costVal;
                damages.add({
                  'item': itemStr,
                  'cost': costVal,
                });
              }
            }

            final deposit = lease.depositAmount > 0 ? lease.depositAmount : lease.rentAmount;
            final refunded = (deposit - totalDeductions).clamp(0.0, deposit);

            allInspections.add({
              'id': m['id']?.toString() ?? 'insp-${allInspections.length + 1}',
              'propertyName': lease.propertyName,
              'unitName': lease.unitName,
              'tenantName': lease.tenantName,
              'date': m['inspection_date']?.toString() ?? m['created_at']?.toString().split('T').first ?? '2026-08-01',
              'status': m['status']?.toString() ?? 'Finalized',
              'securityDeposit': deposit,
              'depositRefunded': refunded,
              'totalDeductions': totalDeductions,
              'damages': damages,
              'photos': m['photos'] is List ? (m['photos'] as List).map((p) => p.toString()).toList() : [],
            });
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _inspections = allInspections;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showCreateInspectionDialog() {
    final state = ref.read(landlordProvider);
    final properties = state.properties;

    String selectedProperty =
        properties.isNotEmpty ? properties.first.name : 'Green Valley Apartments';
    String unitName = 'Unit 4C';
    String tenantName = 'Robert Vance';
    double depositAmount = 2000.00;
    double repairCost1 = 120.00;
    String damageItem1 = 'Wall scuffs & paint touchup';
    List<String> photosList = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final refundAmount = (depositAmount - repairCost1).clamp(0.0, depositAmount);

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
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.output_rounded,
                              color: AppColors.error, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'New Move-Out Inspection',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Property Details',
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
                        if (val != null) setModalState(() => selectedProperty = val);
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
                    const Text('Security Deposit & Deductions',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: depositAmount.toStringAsFixed(0),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Held Deposit (\$)',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onChanged: (val) {
                              final parsed = double.tryParse(val);
                              if (parsed != null) {
                                setModalState(() => depositAmount = parsed);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: repairCost1.toStringAsFixed(0),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Deductions (\$)',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onChanged: (val) {
                              final parsed = double.tryParse(val);
                              if (parsed != null) {
                                setModalState(() => repairCost1 = parsed);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: damageItem1,
                      decoration: InputDecoration(
                        labelText: 'Damage Assessment Description',
                        prefixIcon: const Icon(Icons.report_problem_rounded),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (val) => damageItem1 = val,
                    ),
                    const SizedBox(height: 16),
                    const Text('Inspection Photo Attachments',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(source: ImageSource.gallery);
                            if (picked != null) {
                              setModalState(() {
                                photosList.add(picked.path);
                              });
                            }
                          },
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: AppColors.inputBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.border, style: BorderStyle.solid),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_rounded,
                                    color: AppColors.primary, size: 22),
                                SizedBox(height: 4),
                                Text('Add Photo',
                                    style: TextStyle(
                                        fontSize: 9, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 70,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: photosList.length,
                              itemBuilder: (ctx, idx) {
                                final urlOrPath = photosList[idx];
                                final isNet = urlOrPath.startsWith('http');
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: isNet
                                          ? NetworkImage(urlOrPath) as ImageProvider
                                          : FileImage(File(urlOrPath)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text('Calculated Deposit Refund:',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13),
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('\$${refundAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF1B8E4D))),
                          ),
                        ],
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

                          final checklistData = [
                            {'item': damageItem1, 'condition': 'DAMAGED', 'cost': repairCost1, 'notes': 'Move-Out Deduction'},
                          ];

                          try {
                            await ApiClient().dio.post(
                              '/leases/${matchingLease.id}/inspections',
                              data: {
                                'inspection_type': 'MOVE_OUT',
                                'checklist_data': checklistData,
                                'inspector_role': 'LANDLORD',
                                'landlord_signature': 'Signed by Landlord',
                              },
                            );

                            if (context.mounted) {
                              Navigator.pop(ctx);
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Move-Out Inspection saved successfully!'),
                                  backgroundColor: Color(0xFF1B8E4D),
                                ),
                              );
                            }
                            _fetchInspections();
                          } catch (e) {
                            if (context.mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Failed to save inspection: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Save Inspection Report',
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

  void _showProcessRefundDialog(Map<String, dynamic> item) async {
    final double deposit = (item['securityDeposit'] ?? 0.0) as double;
    final String tenantName = (item['tenantName'] ?? 'Tenant') as String;

    final result = await DepositRefundCalculatorDialog.show(
      context,
      tenantName: tenantName,
      initialDeposit: deposit,
    );

    if (result != null && mounted) {
      try {
        await ApiClient().dio.post(
          '/move-out/deposit-returns',
          data: {
            'inspectionId': item['id'],
            'amount': result.netRefundAmount,
            'cleaningDeductions': result.cleaningDeduction,
            'damageDeductions': result.damageDeduction,
            'unpaidRentDeductions': result.unpaidRentDeduction,
            'notes': result.notes,
          },
        );
      } catch (_) {}

      setState(() {
        item['status'] = 'Finalized';
        item['depositRefunded'] = result.netRefundAmount;
        item['totalDeductions'] = result.cleaningDeduction + result.damageDeduction + result.unpaidRentDeduction;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deposit refund of \$${result.netRefundAmount.toStringAsFixed(2)} processed!'),
            backgroundColor: const Color(0xFF1B8E4D),
          ),
        );
      }
    }
  }









  Widget _buildStatusBadge(String status) {
    final isFinalized = status.toLowerCase() == 'finalized';
    final color = isFinalized ? const Color(0xFF1B8E4D) : const Color(0xFFD97706);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 11),
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
          'Move-Out Inspections',
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
            icon: const Icon(Icons.add_a_photo_rounded, color: AppColors.primary),
            onPressed: _showCreateInspectionDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateInspectionDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Move-Out Report',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(w * 0.05),
              itemCount: _inspections.length,
              itemBuilder: (context, index) {
                final item = _inspections[index];
                final damages = (item['damages'] as List<dynamic>?) ?? [];
                final photos = (item['photos'] as List<dynamic>?) ?? [];
                final isFinalized = item['status'] == 'Finalized';

                return Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: w * 0.04),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
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
                            _buildStatusBadge(item['status'] ?? 'Draft'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item['unitName']} • Tenant: ${item['tenantName']}',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        const Text('Damage Assessment:',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        ...damages.map((d) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text('• ${d['item']}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary)),
                                  ),
                                  Text('-\$${d['cost']}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.error)),
                                ],
                              ),
                            )),
                        const SizedBox(height: 12),
                        if (photos.isNotEmpty) ...[
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: photos.length,
                              itemBuilder: (ctx, pIdx) {
                                final pPath = photos[pIdx].toString();
                                final isNet = pPath.startsWith('http');
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: isNet
                                          ? NetworkImage(pPath) as ImageProvider
                                          : FileImage(File(pPath)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.scaffoldBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Deductions Total',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary)),
                                  Text('-\$${item['totalDeductions']}',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.error)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Refund Payable',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary)),
                                  Text('\$${item['depositRefunded']}',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1B8E4D))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: isFinalized
                                  ? const Color(0xFF1B8E4D)
                                  : AppColors.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: Icon(isFinalized
                                ? Icons.check_circle_rounded
                                : Icons.account_balance_wallet_rounded),
                            label: Text(
                              isFinalized
                                  ? 'Refund Finalized (\$${item['depositRefunded']})'
                                  : 'Process Deposit Refund',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: isFinalized
                                ? null
                                : () => _showProcessRefundDialog(item),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
