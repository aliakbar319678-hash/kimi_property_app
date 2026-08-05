import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/provider/landlord_state.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';

class FinancialOverviewScreen extends ConsumerStatefulWidget {
  const FinancialOverviewScreen({super.key});

  @override
  ConsumerState<FinancialOverviewScreen> createState() =>
      _FinancialOverviewScreenState();
}

class _FinancialOverviewScreenState
    extends ConsumerState<FinancialOverviewScreen> {
  bool _isLoadingInvoices = true;
  double _totalCollected = 0.0;
  double _totalOutstanding = 0.0;
  List<dynamic> _invoices = [];

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(landlordProvider.notifier).loadLeases();
    });
  }

  Future<void> _fetchInvoices() async {
    try {
      final resp = await ApiClient().dio.get(ApiConstants.invoices);
      final data = resp.data['data'] as Map<String, dynamic>? ?? {};
      if (mounted) {
        setState(() {
          _totalCollected =
              double.tryParse(data['totalCollected']?.toString() ?? '0') ?? 0.0;
          _totalOutstanding =
              double.tryParse(data['totalOutstanding']?.toString() ?? '0') ??
              0.0;
          _invoices = data['invoices'] as List<dynamic>? ?? [];
          _isLoadingInvoices = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching invoices: $e');
      if (mounted) {
        setState(() {
          _totalCollected = 0.0;
          _totalOutstanding = 0.0;
          _invoices = [];
          _isLoadingInvoices = false;
        });
      }
    }
  }

  void _showRecordPaymentModal(LandlordState state) {
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String paymentMethod = 'cash';
    String? selectedLeaseId;
    DateTime selectedDate = DateTime.now();
    bool isSubmitting = false;

    // Trigger loadLeases if empty
    if (state.leases.isEmpty) {
      ref.read(landlordProvider.notifier).loadLeases();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final currentLeases = ref.watch(landlordProvider).leases;
            final activeLeases = currentLeases
                .where(
                  (l) => l.status.toLowerCase() == 'active' || l.status.isEmpty,
                )
                .toList();
            final dropdownItems = activeLeases.isNotEmpty
                ? activeLeases
                : currentLeases;

            if (dropdownItems.isNotEmpty &&
                (selectedLeaseId == null ||
                    !dropdownItems.any((l) => l.id == selectedLeaseId))) {
              selectedLeaseId = dropdownItems.first.id;
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Record Offline Payment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Lease / Unit',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: dropdownItems.any((l) => l.id == selectedLeaseId)
                          ? selectedLeaseId
                          : null,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      items: dropdownItems.isEmpty
                          ? [
                              const DropdownMenuItem(
                                value: null,
                                child: Text(
                                  'No active leases available',
                                  style: TextStyle(color: AppColors.textHint),
                                ),
                              ),
                            ]
                          : dropdownItems
                                .map(
                                  (l) => DropdownMenuItem(
                                    value: l.id,
                                    child: Text(
                                      '${l.unitName.isNotEmpty ? l.unitName : "Unit"} - ${l.tenantName.isNotEmpty ? l.tenantName : "Tenant"}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                      onChanged: dropdownItems.isEmpty
                          ? null
                          : (val) {
                              if (val != null) {
                                setModalState(() => selectedLeaseId = val);
                              }
                            },
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Amount Received (\$)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. 1500.00',
                        prefixIcon: const Icon(Icons.attach_money, size: 20),
                        filled: true,
                        fillColor: AppColors.inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: paymentMethod,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'cash', child: Text('Cash')),
                        DropdownMenuItem(
                          value: 'cheque',
                          child: Text('Cheque / Check'),
                        ),
                        DropdownMenuItem(
                          value: 'bank_transfer',
                          child: Text('Bank Wire / Transfer'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => paymentMethod = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Payment Date',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setModalState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.inputBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 20,
                              color: AppColors.textHint,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Notes / Reference',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. Received Cheque #10492',
                        filled: true,
                        fillColor: AppColors.inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final amt =
                                    double.tryParse(amountCtrl.text) ?? 0;
                                if (amt <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter a valid amount',
                                      ),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                  return;
                                }
                                if (selectedLeaseId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please select a lease first.'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                  return;
                                }
                                setModalState(() => isSubmitting = true);
                                final messenger = ScaffoldMessenger.of(context);
                                try {
                                  await ApiClient().dio.post(
                                    ApiConstants.recordManualPayment,
                                    data: {
                                      'leaseId': selectedLeaseId,
                                      'amount': amt,
                                      'paymentMethod': paymentMethod,
                                      'paymentDate': selectedDate
                                          .toIso8601String(),
                                      'notes': notesCtrl.text.trim(),
                                    },
                                  );
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                  if (mounted) {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Offline payment recorded successfully! 🎉',
                                        ),
                                        backgroundColor: Color(0xFF27AE60),
                                      ),
                                    );
                                  }
                                  _fetchInvoices();
                                } catch (e) {
                                  if (mounted) {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Failed to record payment.',
                                        ),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setModalState(() => isSubmitting = false);
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Record Payment',
                                style: TextStyle(
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(landlordProvider);
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.05;

    final displayCollected = _totalCollected > 0
        ? _totalCollected
        : state.totalCollected;
    final displayOutstanding = _totalOutstanding > 0
        ? _totalOutstanding
        : state.totalOutstanding;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'Financial Overview',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: pad, vertical: h * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Financial Metrics Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(w * 0.05),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL COLLECTED',
                      style: TextStyle(
                        fontSize: w * 0.03,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${displayCollected.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: w * 0.08,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const Divider(height: 30, color: AppColors.border),
                    Text(
                      'OUTSTANDING',
                      style: TextStyle(
                        fontSize: w * 0.03,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${displayOutstanding.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: w * 0.07,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.02),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showRecordPaymentModal(state),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        minimumSize: Size(double.infinity, w * 0.12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add_card_rounded, size: 18),
                      label: const Text(
                        'Record Offline Payment',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: h * 0.035),

              // Recent Invoices / Activity Timeline
              Text(
                'Invoices & Payments',
                style: TextStyle(
                  fontSize: w * 0.042,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: h * 0.015),

              _isLoadingInvoices
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : (_invoices.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'No invoice activity recorded yet.',
                                style: TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _invoices.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, idx) {
                              final inv = _invoices[idx];
                              final isPaid =
                                  (inv['status']?.toString().toLowerCase() ??
                                      '') ==
                                  'paid';
                              final tenantName =
                                  inv['tenant_name'] ??
                                  inv['tenantName'] ??
                                  'Tenant';
                              final propName =
                                  inv['property_name'] ??
                                  inv['propertyName'] ??
                                  'Property';
                              final rawPaid =
                                  double.tryParse(
                                    (inv['amount_paid'] ?? inv['amountPaid'])
                                            ?.toString() ??
                                        '0',
                                  ) ??
                                  0.0;
                              final rawDue =
                                  double.tryParse(
                                    (inv['amount_due'] ??
                                                inv['amountDue'] ??
                                                inv['amount'] ??
                                                inv['total'])
                                            ?.toString() ??
                                        '0',
                                  ) ??
                                  0.0;
                              final amt = rawPaid > 0 ? rawPaid : rawDue;
                              final method =
                                  inv['payment_method'] ??
                                  inv['paymentMethod'] ??
                                  'offline';

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isPaid
                                                ? Colors.green.withValues(
                                                    alpha: 0.1,
                                                  )
                                                : AppColors.error.withValues(
                                                    alpha: 0.1,
                                                  ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isPaid
                                                ? Icons.check_rounded
                                                : Icons.pending_actions_rounded,
                                            color: isPaid
                                                ? Colors.green
                                                : AppColors.error,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tenantName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '$propName • $method',
                                              style: const TextStyle(
                                                color: AppColors.textHint,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${isPaid ? '+' : ''}\$${amt.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: isPaid
                                            ? Colors.green
                                            : AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )),
            ],
          ),
        ),
      ),
    );
  }
}
