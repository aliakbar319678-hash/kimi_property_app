import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class TenantLeaseScreen extends StatelessWidget {
  const TenantLeaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(title: const Text('My Lease')),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Skyline View Lofts - Unit 402', style: AppTextStyles.headlineMedium),
                    const SizedBox(height: 16),
                    _buildDetailRow('Start Date', 'Oct 1, 2023'),
                    _buildDetailRow('End Date', 'Sep 30, 2024'),
                    _buildDetailRow('Monthly Rent', '\$2,450.00'),
                    _buildDetailRow('Deposit Amount', '\$2,450.00'),
                    _buildDetailRow('Landlord', 'John Doe'),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(Icons.verified, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text('Lease Active', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text('Documents', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 20),
              _buildDocTile('Signed_Lease_Agreement.pdf', '2.4 MB'),
              const SizedBox(height: 12),
              _buildDocTile('House_Rules_2024.pdf', '1.1 MB'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value, 
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocTile(String title, String size) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: AppColors.error, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelMedium, overflow: TextOverflow.ellipsis),
                Text(size, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.download, color: AppColors.secondary),
        ],
      ),
    );
  }
}
