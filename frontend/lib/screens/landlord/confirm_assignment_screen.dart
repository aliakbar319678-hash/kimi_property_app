import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/provider/landlord_state.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class ConfirmAssignmentScreen extends ConsumerStatefulWidget {
  const ConfirmAssignmentScreen({super.key});

  @override
  ConsumerState<ConfirmAssignmentScreen> createState() => _ConfirmAssignmentScreenState();
}

class _ConfirmAssignmentScreenState extends ConsumerState<ConfirmAssignmentScreen> {
  bool _includeTenant = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.05;

    // Retrieve arguments
    final Map<String, dynamic>? args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final WorkOrder? order = args?['order'];
    final Bid? bid = args?['bid'];

    if (order == null || bid == null) {
      return const Scaffold(body: Center(child: Text('Invalid arguments.')));
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Assign Job', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: pad, vertical: h * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm Assignment',
              style: TextStyle(fontSize: w * 0.055, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Review the details below to finalize the vendor booking.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),

            SizedBox(height: h * 0.035),

            // Vendor assignment summary card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(w * 0.05),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('VENDOR', style: TextStyle(fontSize: 10, color: AppColors.textHint, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        bid.vendorName,
                        style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const Icon(Icons.flash_on_rounded, color: Colors.amber, size: 20),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.border),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TOTAL AMOUNT', style: TextStyle(fontSize: 9, color: AppColors.textHint, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text('SAR ${bid.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('SCHEDULED FOR', style: TextStyle(fontSize: 9, color: AppColors.textHint, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(bid.time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.035),

            // Chat Room Members list
            Text(
              'Chat Room Members',
              style: TextStyle(
                fontSize: w * 0.04,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Select who will participate in the job coordination chat.',
              style: TextStyle(color: AppColors.textHint, fontSize: 11),
            ),

            SizedBox(height: h * 0.015),

            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('Landlord (Default Admin)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    value: true,
                    onChanged: null,
                    dense: true,
                    activeColor: AppColors.primary,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  CheckboxListTile(
                    title: Text('Vendor (${bid.vendorName})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    value: true,
                    onChanged: null,
                    dense: true,
                    activeColor: AppColors.primary,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  CheckboxListTile(
                    title: Text('Tenant (${order.tenantName})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    value: _includeTenant,
                    onChanged: (val) => setState(() => _includeTenant = val ?? true),
                    dense: true,
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textHint),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'You can add the tenant now or later.',
                    style: TextStyle(fontSize: w * 0.028, color: AppColors.textHint, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Action Buttons
            ElevatedButton(
              onPressed: () {
                // Update work order state: Assign vendor bid!
                ref.read(landlordProvider.notifier).assignBidToWorkOrder(order.id, bid);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/landlord_home',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, w * 0.13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Confirm & Assign Job', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
