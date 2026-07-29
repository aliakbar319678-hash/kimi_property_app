import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class TenantSavedPropertiesScreen extends StatelessWidget {
  const TenantSavedPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(title: const Text('Saved Homes')),
      body: SafeArea(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
          itemCount: 2,
          itemBuilder: (context, index) {
            return _buildSavedPropertyCard(context);
          },
        ),
      ),
    );
  }

  Widget _buildSavedPropertyCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  color: AppColors.inputBg,
                  child: const Center(child: Icon(Icons.image, color: AppColors.textHint, size: 40)),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.favorite, color: AppColors.error),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cozy Downtown Studio', style: AppTextStyles.headlineMedium, overflow: TextOverflow.ellipsis, maxLines: 1),
                      const SizedBox(height: 4),
                      const Text('\$1,800 / mo', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property removed from saved.'))); },
                  child: const Text('Remove', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
