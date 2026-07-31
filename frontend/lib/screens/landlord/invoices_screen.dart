import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/landlord/record_manual_payment_dialog.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';

class LandlordInvoicesScreen extends ConsumerStatefulWidget {
  const LandlordInvoicesScreen({super.key});

  @override
  ConsumerState<LandlordInvoicesScreen> createState() => _LandlordInvoicesScreenState();
}

class _LandlordInvoicesScreenState extends ConsumerState<LandlordInvoicesScreen> {
  String _selectedFilter = 'All';
  bool _isLoading = false;

  List<Map<String, dynamic>> _invoices = [
    {
      'id': 'INV-2026-001',
      'tenantName': 'Michael Scott',
      'unitName': 'Unit 2A',
      'amount': 1500.00,
      'dueDate': '2026-08-01',
      'status': 'Paid',
      'category': 'Monthly Rent',
    },
    {
      'id': 'INV-2026-002',
      'tenantName': 'Sarah Connor',
      'unitName': 'Unit 8B',
      'amount': 2200.00,
      'dueDate': '2026-07-25',
      'status': 'Overdue',
      'category': 'Monthly Rent',
    },
    {
      'id': 'INV-2026-003',
      'tenantName': 'Robert Vance',
      'unitName': 'Unit 4C',
      'amount': 180.00,
      'dueDate': '2026-08-05',
      'status': 'Pending',
      'category': 'Water & Utility Fee',
    },
    {
      'id': 'INV-2026-004',
      'tenantName': 'Jim Halpert',
      'unitName': 'Unit 12',
      'amount': 1350.00,
      'dueDate': '2026-08-10',
      'status': 'Pending',
      'category': 'Monthly Rent',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  Future<void> _fetchInvoices() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient().dio.get('/finance/invoices');
      List<dynamic> raw = [];
      if (response.data != null && response.data['data'] != null) {
        if (response.data['data'] is List) {
          raw = response.data['data'];
        } else if (response.data['data']['transactions'] is List) {
          raw = response.data['data']['transactions'];
        }
      }
      
      if (raw.isEmpty) {
        final statsResp = await ApiClient().dio.get('/finance/stats');
        if (statsResp.data != null && statsResp.data['data'] != null && statsResp.data['data']['transactions'] is List) {
          raw = statsResp.data['data']['transactions'];
        }
      }

      if (raw.isNotEmpty && mounted) {
        final fetched = raw.map((item) {
          final m = item as Map<String, dynamic>;
          final amt = double.tryParse((m['amount'] ?? 0).toString()) ?? 0.0;
          return {
            'id': m['id']?.toString() ?? 'INV-${m['created_at']?.toString().substring(0, 4) ?? '2026'}',
            'tenantName': m['user_name']?.toString() ?? m['tenantName']?.toString() ?? m['payer_name']?.toString() ?? 'Tenant',
            'unitName': m['unit_name']?.toString() ?? m['unitName']?.toString() ?? 'Unit',
            'amount': amt,
            'dueDate': m['created_at']?.toString().split('T').first ?? '2026-08-01',
            'status': (m['status']?.toString().toLowerCase() == 'completed') ? 'Paid' : _capitalize(m['status']?.toString() ?? 'Pending'),
            'category': m['type']?.toString() ?? 'Monthly Rent',
          };
        }).toList();

        setState(() {
          _invoices = fetched;
        });
      }
    } catch (e) {
      debugPrint('[InvoicesScreen] _fetchInvoices error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  double get _totalInvoiced => _invoices.fold(0.0, (sum, i) => sum + (i['amount'] as double));
  double get _paidAmount => _invoices.where((i) => (i['status'] as String).toLowerCase() == 'paid').fold(0.0, (sum, i) => sum + (i['amount'] as double));
  double get _overdueAmount => _invoices.where((i) => (i['status'] as String).toLowerCase() == 'overdue').fold(0.0, (sum, i) => sum + (i['amount'] as double));

  List<Map<String, dynamic>> get _filteredInvoices {
    if (_selectedFilter == 'All') return _invoices;
    return _invoices.where((i) => (i['status'] as String).toLowerCase() == _selectedFilter.toLowerCase()).toList();
  }

  void _showCreateInvoiceSheet() {
    final state = ref.read(landlordProvider);
    final tenants = state.tenants;

    String selectedTenant = tenants.isNotEmpty ? tenants.first.name : 'Michael Scott';
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String category = 'Monthly Rent';
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));
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
                    Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Create New Invoice',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Select Tenant
                const Text('Tenant', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedTenant,
                  decoration: _inputDeco('Select Tenant'),
                  items: (tenants.isNotEmpty
                          ? tenants.map((t) => t.name).toList()
                          : ['Michael Scott', 'Sarah Connor', 'Robert Vance', 'Jim Halpert'])
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setSheetState(() => selectedTenant = v);
                  },
                ),
                const SizedBox(height: 14),

                // Amount & Category
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Amount (\$)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: amountCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDeco('1500.00'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: category,
                            decoration: _inputDeco('Category'),
                            items: const [
                              DropdownMenuItem(value: 'Monthly Rent', child: Text('Monthly Rent', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'Water & Utility Fee', child: Text('Utilities', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'Maintenance Fee', child: Text('Maintenance', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'Late Fee', child: Text('Late Fee', style: TextStyle(fontSize: 12))),
                            ],
                            onChanged: (v) {
                              if (v != null) setSheetState(() => category = v);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Due Date Picker
                const Text('Due Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) setSheetState(() => dueDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                          '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Notes
                const Text('Notes / Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: _inputDeco('Optional invoice description...'),
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
                            final amt = double.tryParse(amountCtrl.text) ?? 0.0;
                            if (amt <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter a valid amount'), backgroundColor: AppColors.error),
                              );
                              return;
                            }
                            setSheetState(() => isSaving = true);

                            final newInv = {
                              'id': 'INV-2026-00${_invoices.length + 1}',
                              'tenantName': selectedTenant,
                              'unitName': 'Unit 1A',
                              'amount': amt,
                              'dueDate': '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}',
                              'status': 'Pending',
                              'category': category,
                            };

                            try {
                              await ApiClient().dio.post(
                                '/finance/invoices',
                                data: {
                                  'tenantName': selectedTenant,
                                  'amount': amt,
                                  'category': category,
                                  'dueDate': newInv['dueDate'],
                                },
                              );
                            } catch (_) {}

                            setState(() {
                              _invoices.insert(0, newInv);
                            });

                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Invoice #${newInv['id']} issued for \$${amt.toStringAsFixed(2)}!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                    child: isSaving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Issue Invoice', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
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
          'Invoices',
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
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: _showCreateInvoiceSheet,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateInvoiceSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.receipt_rounded, color: Colors.white),
        label: const Text('Create Invoice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(w * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary cards row
                  Row(
                    children: [
                      _statCard('Total Invoiced', '\$${_totalInvoiced.toStringAsFixed(0)}', AppColors.primary, Colors.white, w),
                      SizedBox(width: w * 0.03),
                      _statCard('Paid Amount', '\$${_paidAmount.toStringAsFixed(0)}', Colors.green, Colors.white, w),
                      SizedBox(width: w * 0.03),
                      _statCard('Overdue', '\$${_overdueAmount.toStringAsFixed(0)}', AppColors.error, Colors.white, w),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Interactive Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Paid', 'Pending', 'Overdue'].map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedFilter = filter),
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

                  // Invoices List
                  _filteredInvoices.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                          child: const Column(
                            children: [
                              Icon(Icons.receipt_outlined, size: 40, color: AppColors.textHint),
                              SizedBox(height: 8),
                              Text('No invoices match this filter', style: TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredInvoices.length,
                          itemBuilder: (ctx, idx) {
                            final inv = _filteredInvoices[idx];
                            final status = inv['status'] as String;
                            Color statusColor;
                            switch (status.toLowerCase()) {
                              case 'paid': statusColor = Colors.green; break;
                              case 'overdue': statusColor = AppColors.error; break;
                              default: statusColor = Colors.orange;
                            }

                            return GestureDetector(
                              onTap: status.toLowerCase() == 'paid'
                                  ? null
                                  : () async {
                                      final res = await showModalBottomSheet<String>(
                                        context: context,
                                        backgroundColor: Colors.transparent,
                                        builder: (ctx) => Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text('Invoice Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 16),
                                              ListTile(
                                                leading: const Icon(Icons.payments_rounded, color: AppColors.primary),
                                                title: const Text('Record Manual Payment'),
                                                onTap: () => Navigator.pop(ctx, 'record'),
                                              ),
                                              ListTile(
                                                leading: const Icon(Icons.cancel_rounded),
                                                title: const Text('Cancel'),
                                                onTap: () => Navigator.pop(ctx),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                      if (res == 'record' && mounted) {
                                        final payment = await RecordManualPaymentDialog.show(context);
                                        if (payment != null && mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment recorded successfully!'), backgroundColor: Colors.green));
                                          _fetchInvoices(); // Refresh
                                        }
                                      }
                                    },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(Icons.receipt_long_rounded, color: statusColor, size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(inv['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          const SizedBox(height: 2),
                                          Text('${inv['tenantName']} • ${inv['unitName']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                          const SizedBox(height: 2),
                                          Text('Due: ${inv['dueDate']}', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '\$${(inv['amount'] as double).toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          status.toUpperCase(),
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String label, String val, Color bgColor, Color textColor, double w) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(val, style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.w800, color: textColor)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: w * 0.024, color: textColor.withValues(alpha: 0.85)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
