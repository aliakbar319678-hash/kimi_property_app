import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';

class FinancialOverviewScreen extends ConsumerStatefulWidget {
  const FinancialOverviewScreen({super.key});

  @override
  ConsumerState<FinancialOverviewScreen> createState() => _FinancialOverviewScreenState();
}

class _FinancialOverviewScreenState extends ConsumerState<FinancialOverviewScreen> {
  bool _isLoadingInvoices = true;
  double _totalCollected = 0.0;
  double _totalOutstanding = 0.0;
  List<dynamic> _invoices = [];

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  Future<void> _fetchInvoices() async {
    try {
      final resp = await ApiClient().dio.get('/finance/invoices');
      final data = resp.data['data'] as Map<String, dynamic>? ?? {};
      if (mounted) {
        setState(() {
          _totalCollected = (data['totalCollected'] as num?)?.toDouble() ?? 0.0;
          _totalOutstanding = (data['totalOutstanding'] as num?)?.toDouble() ?? 0.0;
          _invoices = data['invoices'] as List<dynamic>? ?? [];
          _isLoadingInvoices = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching invoices: $e');
      if (mounted) setState(() => _isLoadingInvoices = false);
    }
  }

  void _showRecordPaymentModal() {
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String paymentMethod = 'cash';
    bool isSubmitting = false;

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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Amount Received (\$)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'e.g. 1500.00',
                        prefixIcon: const Icon(Icons.attach_money, size: 20),
                        filled: true,
                        fillColor: AppColors.inputBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Payment Method', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: paymentMethod,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.inputBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'cheque', child: Text('Cheque / Check')),
                        DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Wire / Transfer')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => paymentMethod = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text('Notes / Reference', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. Received Cheque #10492',
                        filled: true,
                        fillColor: AppColors.inputBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final amt = double.tryParse(amountCtrl.text.trim());
                                if (amt == null || amt <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter a valid amount'), backgroundColor: AppColors.error),
                                  );
                                  return;
                                }
                                setModalState(() => isSubmitting = true);
                                try {
                                  await ApiClient().dio.post('/finance/invoices/record-manual', data: {
                                    'amount': amt,
                                    'paymentMethod': paymentMethod,
                                    'notes': notesCtrl.text.trim(),
                                  });
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    _fetchPayout();
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to record payment: $e'), backgroundColor: AppColors.error),
                                    );
                                  }
                                } finally {
                                  setModalState(() => isSubmitting = false);
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Record Payment', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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

  void _fetchPayout() {
    _fetchInvoices();
    ref.read(landlordProvider.notifier).loadFinanceDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(landlordProvider);
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.05;

    final displayCollected = _totalCollected > 0 ? _totalCollected : state.totalCollected;
    final displayOutstanding = _totalOutstanding > 0 ? _totalOutstanding : state.totalOutstanding;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Financial Overview', style: TextStyle(fontWeight: FontWeight.w700)),
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
                      onPressed: _showRecordPaymentModal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        minimumSize: Size(double.infinity, w * 0.12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add_card_rounded, size: 18),
                      label: const Text('Record Offline Payment', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                ],
              ),

              SizedBox(height: h * 0.035),

              // Recent Invoices / Activity Timeline
              Text(
                'Invoices & Payments',
                style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              SizedBox(height: h * 0.015),

              _isLoadingInvoices
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                  : (_invoices.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text('No invoice activity recorded yet.', style: TextStyle(color: AppColors.textHint, fontSize: 13)),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _invoices.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, idx) {
                            final inv = _invoices[idx];
                            final isPaid = inv['status'] == 'paid';
                            final tenantName = inv['tenant_name'] ?? 'Tenant';
                            final propName = inv['property_name'] ?? 'Property';
                            final amt = (inv['amount_paid'] != null && (inv['amount_paid'] as num) > 0)
                                ? (inv['amount_paid'] as num).toDouble()
                                : (inv['amount_due'] as num?)?.toDouble() ?? 0.0;
                            final method = inv['payment_method'] ?? 'offline';

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isPaid ? Colors.green.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isPaid ? Icons.check_rounded : Icons.pending_actions_rounded,
                                          color: isPaid ? Colors.green : AppColors.error,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(tenantName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                          const SizedBox(height: 2),
                                          Text('$propName • $method', style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${isPaid ? '+' : ''}\$${amt.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: isPaid ? Colors.green : AppColors.error,
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

  Widget _buildProgressBar(String label, String pctText, String amtText, Color color, double w) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text('$pctText ($amtText)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ],
    );
  }
}
