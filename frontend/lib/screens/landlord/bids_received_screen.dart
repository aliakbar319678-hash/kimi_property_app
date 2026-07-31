import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class BidsReceivedScreen extends StatefulWidget {
  final String? jobId;

  const BidsReceivedScreen({super.key, this.jobId});

  @override
  State<BidsReceivedScreen> createState() => _BidsReceivedScreenState();
}

class _BidsReceivedScreenState extends State<BidsReceivedScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _job;
  List<dynamic> _bids = [];
  String? _effectiveJobId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_effectiveJobId == null) {
      final passedId = widget.jobId ?? ModalRoute.of(context)?.settings.arguments as String?;
      _effectiveJobId = passedId;
      if (_effectiveJobId != null) {
        _fetchJobBids(_effectiveJobId!);
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchJobBids(String jobId) async {
    try {
      final response = await ApiClient().dio.get('/jobs/$jobId/bids');
      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (mounted) {
          setState(() {
            _job = data['job'];
            _bids = data['bids'] ?? [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptBid(String bidId) async {
    if (_effectiveJobId == null) return;
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      final resp = await ApiClient().dio.patch('/jobs/$_effectiveJobId/bids/$bidId/accept');
      if (mounted) Navigator.pop(context);

      if (resp.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bid accepted! Job moved to in-progress.'), backgroundColor: Colors.green),
          );
        }
        _fetchJobBids(_effectiveJobId!);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept bid: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _rejectBid(String bidId) async {
    if (_effectiveJobId == null) return;
    try {
      final resp = await ApiClient().dio.patch('/jobs/$_effectiveJobId/bids/$bidId/reject');
      if (resp.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bid rejected.')),
          );
        }
        _fetchJobBids(_effectiveJobId!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject bid: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(_job?['title'] ?? 'Vendor Bids Received', style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Overview Card
                  if (_job != null) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(w * 0.04),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _job!['title']?.toString() ?? 'Job Posting',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: w * 0.04),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  (_job!['urgency'] ?? 'Standard').toString().toUpperCase(),
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _job!['description']?.toString() ?? '',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Budget: \$${_job!['budget_min'] ?? 0} - \$${_job!['budget_max'] ?? 0}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: h * 0.025),
                  ],

                  // Bids list title
                  Text(
                    'Vendor Bids (${_bids.length})',
                    style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: h * 0.015),

                  if (_bids.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(30),
                      alignment: Alignment.center,
                      child: const Text('No vendor bids submitted yet.', style: TextStyle(color: AppColors.textHint)),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _bids.length,
                      itemBuilder: (ctx, i) {
                        final b = _bids[i] as Map<String, dynamic>;
                        final vendor = b['vendor'] as Map<String, dynamic>? ?? {};
                        final status = b['status']?.toString().toLowerCase() ?? 'pending';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                    child: const Icon(Icons.build_rounded, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vendor['display_name']?.toString() ?? 'Vendor',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        Text(
                                          vendor['email']?.toString() ?? '',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${b['bid_amount']}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                ],
                              ),
                              if (b['proposal_notes'] != null && b['proposal_notes'].toString().isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  'Proposal: ${b['proposal_notes']}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                              const SizedBox(height: 14),
                              if (status == 'accepted')
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('ACCEPTED BID', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                )
                              else if (status == 'rejected')
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('REJECTED', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                                )
                              else
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _rejectBid(b['id'].toString()),
                                        child: const Text('Reject', style: TextStyle(color: Colors.red)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                        onPressed: () => _acceptBid(b['id'].toString()),
                                        child: const Text('Accept Bid', style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
