import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/vendor_provider.dart';
import 'package:tenant_and_landlord_application/provider/vendor_state.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_appbar.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';

class VendorSubmitBidScreen extends ConsumerStatefulWidget {
  const VendorSubmitBidScreen({super.key});

  @override
  ConsumerState<VendorSubmitBidScreen> createState() => _VendorSubmitBidScreenState();
}

class _VendorSubmitBidScreenState extends ConsumerState<VendorSubmitBidScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _priceController;
  final _messageController = TextEditingController();
  
  bool _scopeLabor = true;
  bool _scopeMaterials = true;
  bool _scopeInspection = false;

  double _bidAmount = 350.0;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: _bidAmount.toStringAsFixed(0));
    _priceController.addListener(_onPriceChanged);
  }

  void _onPriceChanged() {
    final val = double.tryParse(_priceController.text);
    if (val != null) {
      setState(() {
        _bidAmount = val;
      });
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobId = ModalRoute.of(context)!.settings.arguments as String? ?? 'job_find_1';
    final state = ref.watch(vendorProvider);
    final notifier = ref.read(vendorProvider.notifier);

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    // Find job details
    final job = state.availableJobs.firstWhere(
      (j) => j.id == jobId,
      orElse: () => const VendorWorkOrder(
        id: '',
        title: 'Work Order',
        description: '',
        propertyName: '',
        unitName: '',
        tenantName: '',
        priority: 'Low',
        status: 'Request',
        category: 'General',
        date: '',
        timeSlot: '',
        accessInstructions: '',
        address: '',
        bidAmount: 350.0,
      ),
    );

    // Initial load setup for custom budget
    if (job.id.isNotEmpty && _priceController.text == '350' && job.bidAmount != 350) {
      _bidAmount = job.bidAmount;
      _priceController.text = _bidAmount.toStringAsFixed(0);
    }

    // Dynamic calculations
    final platformFee = _bidAmount * 0.05;
    final payoutEstimate = _bidAmount - platformFee;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const TLAppBar(
        showBack: true,
        subtitle: 'Submit Bid',
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(pad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Job Summary Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(pad),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.gavel_rounded, color: AppColors.secondary, size: w * 0.055),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.title,
                                    style: TextStyle(
                                      fontSize: w * 0.038,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${job.category} • ${job.propertyName}',
                                    style: TextStyle(
                                      fontSize: w * 0.028,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: h * 0.02),

                      // Bid Details Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(pad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bid Details',
                              style: TextStyle(
                                fontSize: w * 0.035,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Divider(color: AppColors.border, height: 20),
                            _buildFieldLabel('Proposed Price (\$)', w),
                            SizedBox(height: h * 0.008),
                            TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 16, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Enter a bid price';
                                }
                                if (double.tryParse(val) == null) {
                                  return 'Enter a valid number';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                prefixText: '\$ ',
                                prefixStyle: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: h * 0.02),

                      // Scope & Checklist Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(pad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scope & Checklist',
                              style: TextStyle(
                                fontSize: w * 0.035,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Divider(color: AppColors.border, height: 20),
                            _buildCheckboxItem(
                              title: 'Labor only',
                              value: _scopeLabor,
                              onChanged: (val) => setState(() => _scopeLabor = val ?? false),
                              w: w,
                            ),
                            _buildCheckboxItem(
                              title: 'Labor + Materials',
                              value: _scopeMaterials,
                              onChanged: (val) => setState(() => _scopeMaterials = val ?? false),
                              w: w,
                            ),
                            _buildCheckboxItem(
                              title: 'Inspection only',
                              value: _scopeInspection,
                              onChanged: (val) => setState(() => _scopeInspection = val ?? false),
                              w: w,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: h * 0.02),

                      // Message Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(pad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Message to Landlord', w),
                            SizedBox(height: h * 0.008),
                            TextFormField(
                              controller: _messageController,
                              maxLines: 3,
                              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                              decoration: const InputDecoration(
                                hintText: 'Describe your experience with this type of work, specific parts needed, etc.',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: h * 0.02),

                      // Bill Summary Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(pad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bill Summary',
                              style: TextStyle(
                                fontSize: w * 0.035,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Divider(color: AppColors.border, height: 20),
                            _buildSummaryRow('Requested Labor', '\$${(_bidAmount * 0.8).toStringAsFixed(2)}', w),
                            const SizedBox(height: 8),
                            _buildSummaryRow('Materials (Est.)', '\$${(_bidAmount * 0.2).toStringAsFixed(2)}', w),
                            const SizedBox(height: 8),
                            _buildSummaryRow('Platform Fee (5%)', '-\$${platformFee.toStringAsFixed(2)}', w, isNegative: true),
                            const Divider(color: AppColors.border, height: 20),
                            _buildSummaryRow(
                              'Total Estimate',
                              '\$${_bidAmount.toStringAsFixed(2)}',
                              w,
                              isBold: true,
                            ),
                            const SizedBox(height: 6),
                            _buildSummaryRow(
                              'Your Payout',
                              '\$${payoutEstimate.toStringAsFixed(2)}',
                              w,
                              isBold: true,
                              isPrimary: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: h * 0.04),
                    ],
                  ),
                ),
              ),
              
              // Bottom Submit Bar
              Container(
                padding: EdgeInsets.all(pad),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final res = await ApiClient().dio.get(ApiConstants.me);
                        if (res.statusCode == 200) {
                          final data = res.data['data'];
                          final kycStatus = data['kyc_status'] ?? 'unverified';
                          if (kycStatus != 'verified' && kycStatus != 'approved') {
                            if (!context.mounted) return;
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: AppColors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (ctx) => Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Account Verification Required',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Your vendor account is currently undergoing admin verification. You will be able to submit bids on work orders once your profile is approved by the Admin.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              side: const BorderSide(color: AppColors.border),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            child: const Text('Dismiss', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              Navigator.pushNamed(context, '/account_status');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            child: const Text('Check Status', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                            return;
                          }
                        }
                      } catch (_) {}

                      final List<String> scope = [];
                      if (_scopeLabor) scope.add('Labor');
                      if (_scopeMaterials) scope.add('Materials');
                      if (_scopeInspection) scope.add('Inspection');
                      
                      notifier.submitBid(
                        job.id,
                        _bidAmount,
                        scope,
                        _messageController.text,
                      );

                      if (!context.mounted) return;
                      final nav = Navigator.of(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Bid of \$${_bidAmount.toStringAsFixed(0)} submitted!'),
                          backgroundColor: const Color(0xFF2E7D32),
                        ),
                      );

                      // Pop details and this bid screen
                      nav.pop(); // Pops bid screen
                      nav.pop(); // Pops job details screen, returns to search
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, w * 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Submit Bid Proposal',
                    style: TextStyle(
                      fontSize: w * 0.038,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text, double w) {
    return Text(
      text,
      style: TextStyle(
        fontSize: w * 0.034,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildCheckboxItem({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required double w,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style: TextStyle(fontSize: w * 0.034, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
      ),
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: AppColors.secondary,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    double w, {
    bool isBold = false,
    bool isNegative = false,
    bool isPrimary = false,
  }) {
    Color textColor = AppColors.textPrimary;
    if (isNegative) textColor = AppColors.error;
    if (isPrimary) textColor = AppColors.secondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? w * 0.036 : w * 0.032,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? (isPrimary ? w * 0.045 : w * 0.038) : w * 0.032,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
