import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/provider/landlord_state.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class LandlordTenantDetailsScreen extends ConsumerWidget {
  const LandlordTenantDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(landlordProvider);
    final notifier = ref.read(landlordProvider.notifier);

    // Retrieve selected tenant from arguments
    final Tenant tenant = ModalRoute.of(context)!.settings.arguments as Tenant? ??
        state.tenants.first;

    // Refresh tenant data from state to show newly added memos immediately
    final updatedTenant = state.tenants.firstWhere((t) => t.id == tenant.id, orElse: () => tenant);

    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Tenant Details', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: pad, vertical: h * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tenant Profile Header Card
            Container(
              padding: EdgeInsets.all(w * 0.05),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: w * 0.16,
                    height: w * 0.16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                          updatedTenant.id == 't1'
                              ? 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&q=80'
                              : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&q=80',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: w * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          updatedTenant.name,
                          style: TextStyle(
                            fontSize: w * 0.05,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: h * 0.004),
                        Text(
                          updatedTenant.unitName,
                          style: TextStyle(
                            fontSize: w * 0.032,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: h * 0.008),
                        Row(
                          children: [
                            const Icon(Icons.phone_rounded, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(
                              updatedTenant.contact,
                              style: TextStyle(
                                fontSize: w * 0.03,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.025),

            // Emergency Contact Section
            Text(
              'Emergency Contact',
              style: TextStyle(
                fontSize: w * 0.042,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: h * 0.012),
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
                  Text(
                    updatedTenant.emergencyContactName,
                    style: TextStyle(
                      fontSize: w * 0.036,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    updatedTenant.emergencyContactPhone,
                    style: TextStyle(
                      fontSize: w * 0.032,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.025),

            // Memos Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Memos',
                  style: TextStyle(
                    fontSize: w * 0.042,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAddMemoDialog(context, notifier, updatedTenant.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add_rounded, color: AppColors.secondary, size: 14),
                        SizedBox(width: 2),
                        Text(
                          'Add Memo',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: h * 0.012),
            if (updatedTenant.memos.isEmpty)
              const Text('No memos added yet.')
            else
              ...updatedTenant.memos.map((memo) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCFDFE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        memo,
                        style: TextStyle(
                          fontSize: w * 0.032,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  )),

            SizedBox(height: h * 0.03),

            // Actions Buttons
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/landlord_job_chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                minimumSize: Size(double.infinity, w * 0.13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Message Tenant', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: h * 0.012),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      minimumSize: Size(double.infinity, w * 0.13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Generate Notice', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                SizedBox(width: w * 0.03),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/landlord_lease_management'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      minimumSize: Size(double.infinity, w * 0.13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Renew Lease', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),

            SizedBox(height: h * 0.035),

            // Lease Agreement Box
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(w * 0.05),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lease Agreement',
                    style: TextStyle(
                      fontSize: w * 0.038,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: h * 0.015),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Monthly Rent', style: TextStyle(fontSize: w * 0.032, color: AppColors.textSecondary)),
                      Text('\$1,200/mo', style: TextStyle(fontSize: w * 0.036, fontWeight: FontWeight.w700, color: Colors.green)),
                    ],
                  ),
                  Divider(height: h * 0.025, color: AppColors.border),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Start Date', style: TextStyle(fontSize: w * 0.028, color: AppColors.textHint)),
                          const SizedBox(height: 2),
                          Text('Jan 15, 2024', style: TextStyle(fontSize: w * 0.032, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('End Date', style: TextStyle(fontSize: w * 0.028, color: AppColors.textHint)),
                          const SizedBox(height: 2),
                          Text('Dec 31, 2024', style: TextStyle(fontSize: w * 0.032, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.035),

            // Payment History List
            Text(
              'Payment History',
              style: TextStyle(
                fontSize: w * 0.042,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: h * 0.015),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, idx) {
                final months = ['March Rent', 'February Rent', 'January Rent'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.circle, size: 8, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(months[idx], style: TextStyle(fontSize: w * 0.035, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Text('\$1,200', style: TextStyle(fontSize: w * 0.035, fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: h * 0.03),

            // Documents List
            Text(
              'Documents',
              style: TextStyle(
                fontSize: w * 0.042,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: h * 0.015),
            _buildDocumentItem('Lease Agreement.pdf', '1.2 MB', w),
            const SizedBox(height: 10),
            _buildDocumentItem('Renter Insurance.pdf', '650 KB', w),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(String title, String size, double w) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error, size: 22),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: w * 0.034, fontWeight: FontWeight.w600)),
                  Text(size, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
                ],
              ),
            ],
          ),
          const Icon(Icons.download_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  void _showAddMemoDialog(BuildContext context, LandlordNotifier notifier, String tenantId) {
    final memoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Memo', style: TextStyle(fontWeight: FontWeight.w700)),
          content: TextField(
            controller: memoController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Enter notes...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (memoController.text.isNotEmpty) {
                  notifier.addMemoToTenant(tenantId, memoController.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
