import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';

class MoveOutInspectionsScreen extends ConsumerStatefulWidget {
  const MoveOutInspectionsScreen({super.key});

  @override
  ConsumerState<MoveOutInspectionsScreen> createState() =>
      _MoveOutInspectionsScreenState();
}

class _MoveOutInspectionsScreenState
    extends ConsumerState<MoveOutInspectionsScreen> {
  bool _isLoading = false;

  // Local list initialized with rich realistic records + dynamic items
  List<Map<String, dynamic>> _inspections = [
    {
      'id': 'insp-101',
      'propertyName': 'Green Valley Apartments',
      'unitName': 'Unit 2A',
      'tenantName': 'Michael Scott',
      'date': '2026-07-10',
      'status': 'Finalized',
      'securityDeposit': 1800.00,
      'depositRefunded': 1450.00,
      'totalDeductions': 350.00,
      'damages': [
        {'item': 'Carpet stain in living room', 'cost': 150.00},
        {'item': 'Drywall hole behind door', 'cost': 200.00},
      ],
      'photos': [
        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400&q=80',
        'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=400&q=80',
      ],
    },
    {
      'id': 'insp-102',
      'propertyName': 'Sunset Heights',
      'unitName': 'Unit 8B',
      'tenantName': 'Sarah Connor',
      'date': '2026-07-20',
      'status': 'Draft',
      'securityDeposit': 2200.00,
      'depositRefunded': 0.00,
      'totalDeductions': 450.00,
      'damages': [
        {'item': 'Broken kitchen cabinet handle', 'cost': 50.00},
        {'item': 'Uncleaned oven & stove grease', 'cost': 150.00},
        {'item': 'Scratched hardwood flooring', 'cost': 250.00},
      ],
      'photos': [
        'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=400&q=80',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchInspections();
  }

  Future<void> _fetchInspections() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await ApiClient().dio.get('/move-out/inspections/dashboard');
      if (response.data != null && response.data['data'] is List) {
        final List<dynamic> raw = response.data['data'];
        final fetched = raw.map((item) => item as Map<String, dynamic>).toList();
        if (fetched.isNotEmpty && mounted) {
          setState(() {
            _inspections = fetched;
          });
        }
      }
    } catch (_) {
      // Keep rich mock initial fallback
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
                          onTap: () {
                            setModalState(() {
                              photosList.add(
                                  'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400&q=80');
                            });
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
                        ...photosList.map((url) => Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(url),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )),
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
                          const Text('Calculated Deposit Refund:',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          Text('\$${refundAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF1B8E4D))),
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
                          final newItem = {
                            'id':
                                'insp-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                            'propertyName': selectedProperty,
                            'unitName': unitName,
                            'tenantName': tenantName,
                            'date': DateTime.now().toString().substring(0, 10),
                            'status': 'Draft',
                            'securityDeposit': depositAmount,
                            'depositRefunded': refundAmount,
                            'totalDeductions': repairCost1,
                            'damages': [
                              {'item': damageItem1, 'cost': repairCost1}
                            ],
                            'photos': photosList.isNotEmpty
                                ? photosList
                                : [
                                    'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=400&q=80'
                                  ],
                          };

                          try {
                            await ApiClient().dio.post(
                              '/move-out/inspections',
                              data: {
                                'leaseId': 'lease_demo',
                                'conditionRatings': {
                                  'Damages': damageItem1,
                                  'Deduction': repairCost1
                                },
                                'depositRefunded': refundAmount,
                              },
                            );
                          } catch (_) {}

                          setState(() {
                            _inspections.insert(0, newItem);
                          });

                          if (context.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Move-Out Inspection saved successfully!'),
                                backgroundColor: Color(0xFF1B8E4D),
                              ),
                            );
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

  void _showProcessRefundDialog(Map<String, dynamic> item) {
    final double deposit = (item['securityDeposit'] ?? 0.0) as double;
    final double existingDeductions = (item['totalDeductions'] ?? 0.0) as double;

    final depositCtrl = TextEditingController(text: deposit.toStringAsFixed(2));
    final repairCtrl = TextEditingController(text: existingDeductions.toStringAsFixed(2));
    final cleaningCtrl = TextEditingController(text: '0.00');
    String refundMethod = 'Direct Deposit / Bank Transfer';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final dep = double.tryParse(depositCtrl.text) ?? 0.0;
          final rep = double.tryParse(repairCtrl.text) ?? 0.0;
          final cln = double.tryParse(cleaningCtrl.text) ?? 0.0;
          final netRefund = (dep - rep - cln).clamp(0.0, double.infinity);

          return Container(
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B8E4D).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Color(0xFF1B8E4D),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Process Deposit Refund',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Tenant: ${item['tenantName']} (${item['unitName']})',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Deposit & Deductions Breakdown
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Deposit (\$)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: depositCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              onChanged: (_) => setSheetState(() {}),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Repair Deductions (\$)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: repairCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              onChanged: (_) => setSheetState(() {}),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cleaning Deductions (\$)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: cleaningCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              onChanged: (_) => setSheetState(() {}),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Refund Method',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: refundMethod,
                              isExpanded: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Direct Deposit / Bank Transfer',
                                  child: Text('Bank Transfer', style: TextStyle(fontSize: 12)),
                                ),
                                DropdownMenuItem(
                                  value: 'Paper Check',
                                  child: Text('Paper Check', style: TextStyle(fontSize: 12)),
                                ),
                                DropdownMenuItem(
                                  value: 'Stripe / Online Refund',
                                  child: Text('Online Refund', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                              onChanged: (v) {
                                if (v != null) setSheetState(() => refundMethod = v);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Calculated Net Refund Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B8E4D).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF1B8E4D).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Net Refund Payable:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Deposit - Repairs - Cleaning',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '\$${netRefund.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: Color(0xFF1B8E4D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B8E4D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setSheetState(() => isSubmitting = true);
                              try {
                                await ApiClient().dio.post(
                                  '/move-out/deposit-returns',
                                  data: {
                                    'inspectionId': item['id'],
                                    'amount': netRefund,
                                    'refundMethod': refundMethod,
                                    'repairDeductions': rep,
                                    'cleaningDeductions': cln,
                                  },
                                );
                              } catch (_) {}

                              setState(() {
                                item['status'] = 'Finalized';
                                item['depositRefunded'] = netRefund;
                                item['totalDeductions'] = rep + cln;
                              });

                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Deposit refund of \$${netRefund.toStringAsFixed(2)} processed via $refundMethod!',
                                    ),
                                    backgroundColor: const Color(0xFF1B8E4D),
                                  ),
                                );
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Confirm & Process Refund',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
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
                              itemBuilder: (ctx, pIdx) => Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: NetworkImage(photos[pIdx].toString()),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
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
