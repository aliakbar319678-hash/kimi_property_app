import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class TenantKycUploadScreen extends StatelessWidget {
  const TenantKycUploadScreen({super.key});

  Widget _buildDocCard(BuildContext context, String title, String subtitle, String status, IconData icon) {
    Color statusColor;
    if (status == 'Verified') {
      statusColor = Colors.green;
    } else if (status == 'Pending') {
      statusColor = Colors.orange;
    } else {
      statusColor = AppColors.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.scaffoldBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 8),
              if (status != 'Verified')
                TextButton(
                  onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening File Picker...'))); },
                  child: const Text('Upload', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ],
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
        title: const Text('KYC Verification', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(w * 0.05),
        children: [
          const Text('Secure Document Upload', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Upload your documents to complete your tenant screening profile.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 24),
          _buildDocCard(
            context,
            'Government ID',
            'Passport, Driver’s License, or National ID',
            'Verified',
            Icons.badge_outlined,
          ),
          _buildDocCard(
            context,
            'Proof of Income',
            'Recent Pay Stubs or Bank Statements',
            'Pending',
            Icons.attach_money_rounded,
          ),
          _buildDocCard(
            context,
            'Background Check Auth',
            'Consent form for screening',
            'Required',
            Icons.fact_check_outlined,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(w * 0.05),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Documents submitted for review!')));
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            minimumSize: Size(double.infinity, w * 0.14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Submit for Verification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}
