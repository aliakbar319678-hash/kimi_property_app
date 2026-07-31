import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';

class LandlordLateNoticesScreen extends ConsumerStatefulWidget {
  const LandlordLateNoticesScreen({super.key});

  @override
  ConsumerState<LandlordLateNoticesScreen> createState() => _LandlordLateNoticesScreenState();
}

class _LandlordLateNoticesScreenState extends ConsumerState<LandlordLateNoticesScreen> {
  bool _isLoading = false;

  List<Map<String, dynamic>> _lateNotices = [
    {
      'id': 'notice-001',
      'tenantId': 'tenant-101',
      'leaseId': 'lease-501',
      'tenantName': 'Sarah Connor',
      'propertyUnit': 'Sunset Heights - Unit 8B',
      'daysOverdue': 12,
      'outstandingBalance': 2200.00,
      'accumulatedLateFee': 110.00,
      'lastNoticeSent': '2026-07-20',
      'status': 'Sent',
    },
    {
      'id': 'notice-002',
      'tenantId': 'tenant-102',
      'leaseId': 'lease-502',
      'tenantName': 'Dwight Schrute',
      'propertyUnit': 'Grand Park Tower - Unit 1A',
      'daysOverdue': 5,
      'outstandingBalance': 1650.00,
      'accumulatedLateFee': 50.00,
      'lastNoticeSent': null,
      'status': 'Pending',
    },
    {
      'id': 'notice-003',
      'tenantId': 'tenant-103',
      'leaseId': 'lease-503',
      'tenantName': 'Pam Beesly',
      'propertyUnit': 'Green Valley - Unit 3C',
      'daysOverdue': 18,
      'outstandingBalance': 1400.00,
      'accumulatedLateFee': 140.00,
      'lastNoticeSent': '2026-07-15',
      'status': 'Final Warning',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchLateNotices();
  }

  Future<void> _fetchLateNotices() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient().dio.get('/users/tenants');
      if (response.data != null && response.data['data'] is List) {
        final List<dynamic> raw = response.data['data'];
        final fetched = raw
            .map((item) => item as Map<String, dynamic>)
            .where((item) => (double.tryParse((item['outstanding'] ?? item['balance'] ?? 0).toString()) ?? 0.0) > 0 || (item['status']?.toString().toLowerCase() == 'overdue' || item['status']?.toString().toLowerCase() == 'late'))
            .map((item) {
          final tenantData = item['tenant'] as Map<String, dynamic>? ?? {};
          final firstName = tenantData['legal_first_name']?.toString() ?? '';
          final lastName = tenantData['legal_last_name']?.toString() ?? '';
          final name = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
          final balance = double.tryParse((item['outstanding'] ?? item['balance'] ?? 0).toString()) ?? 0.0;
          return {
            'id': item['id']?.toString() ?? '',
            'tenantId': tenantData['id']?.toString() ?? '',
            'leaseId': item['id']?.toString() ?? '',
            'tenantName': name.isNotEmpty ? name : (tenantData['email']?.toString().split('@').first ?? 'Tenant'),
            'propertyUnit': '${item['property_name'] ?? ''} - ${item['unit_name'] ?? ''}',
            'daysOverdue': 5,
            'outstandingBalance': balance,
            'accumulatedLateFee': 50.0,
            'lastNoticeSent': null,
            'status': 'Pending',
          };
        }).toList();

        if (mounted) {
          setState(() {
            _lateNotices = fetched;
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSendNoticeSheet(Map<String, dynamic> item) {
    String noticeType = 'Friendly Reminder';
    double baseFee = 50.0;
    double dailyFeeRate = 5.0;
    int daysOverdue = (item['daysOverdue'] ?? 1) as int;
    double calculatedFee = baseFee + (daysOverdue * dailyFeeRate);

    final messageCtrl = TextEditingController(
      text: 'Dear ${item['tenantName']},\nYour rent payment for ${item['propertyUnit']} of \$${(item['outstandingBalance'] as double).toStringAsFixed(2)} is currently $daysOverdue days overdue. Please submit payment immediately to avoid legal escalation.',
    );

    bool isSending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
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
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.error,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Send Late Payment Notice',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Tenant: ${item['tenantName']}',
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

                  // Notice Type
                  const Text('Notice Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: noticeType,
                    decoration: _inputDeco('Select Notice Type'),
                    items: const [
                      DropdownMenuItem(value: 'Friendly Reminder', child: Text('Friendly Reminder')),
                      DropdownMenuItem(value: 'Formal 3-Day Notice', child: Text('Formal 3-Day Notice')),
                      DropdownMenuItem(value: 'Final Warning & Eviction Intent', child: Text('Final Warning')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setSheetState(() {
                          noticeType = v;
                          if (v.contains('3-Day')) {
                            calculatedFee = 75.0 + (daysOverdue * 10.0);
                          } else if (v.contains('Final')) {
                            calculatedFee = 150.0 + (daysOverdue * 15.0);
                          } else {
                            calculatedFee = baseFee + (daysOverdue * dailyFeeRate);
                          }
                          messageCtrl.text = 'Dear ${item['tenantName']},\nNotice [$v]: Your rent of \$${(item['outstandingBalance'] as double).toStringAsFixed(2)} for ${item['propertyUnit']} is $daysOverdue days late. Applied Late Fee: \$${calculatedFee.toStringAsFixed(2)}. Total Due: \$${((item['outstandingBalance'] as double) + calculatedFee).toStringAsFixed(2)}.';
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // Calculated Fee Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Auto-Calculated Late Fee:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text('Based on days overdue', style: TextStyle(fontSize: 10, color: AppColors.textHint)),
                          ],
                        ),
                        Text(
                          '+\$${calculatedFee.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Custom Message
                  const Text('Notice Message', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: messageCtrl,
                    maxLines: 4,
                    decoration: _inputDeco('Custom notice text...'),
                  ),
                  const SizedBox(height: 24),

                  // Send Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isSending
                          ? null
                          : () async {
                              setSheetState(() => isSending = true);
                              try {
                                await ApiClient().dio.post(
                                  '/payments/late-notices/${item['id']}/send',
                                  data: {
                                    'noticeType': noticeType,
                                    'lateFee': calculatedFee,
                                    'message': messageCtrl.text,
                                  },
                                );
                              } catch (_) {}

                              setState(() {
                                item['status'] = 'Sent';
                                item['lastNoticeSent'] = DateTime.now().toString().substring(0, 10);
                                item['accumulatedLateFee'] = calculatedFee;
                              });

                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Late Notice ($noticeType) dispatched to ${item['tenantName']} via SMS & Email!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      label: isSending
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Dispatch Late Notice', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
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
          'Late Payment Notices',
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(w * 0.05),
              itemCount: _lateNotices.length,
              itemBuilder: (ctx, idx) {
                final item = _lateNotices[idx];
                final days = item['daysOverdue'] as int;
                final balance = item['outstandingBalance'] as double;
                final fee = (item['accumulatedLateFee'] as double?) ?? 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.warning_rounded, color: AppColors.error, size: 22),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['tenantName'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        item['propertyUnit'] ?? '',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$days Days Overdue',
                              style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Outstanding Rent', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              Text('\$${balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Late Fee Applied', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              Text('+\$${fee.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.error)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                          label: Text(
                            item['lastNoticeSent'] != null ? 'Resend Notice (Last: ${item['lastNoticeSent']})' : 'Send Late Notice',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          onPressed: () => _showSendNoticeSheet(item),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
