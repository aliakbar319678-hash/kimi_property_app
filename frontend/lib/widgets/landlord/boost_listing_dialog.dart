import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class BoostListingDialog extends StatefulWidget {
  final String propertyName;

  const BoostListingDialog({super.key, required this.propertyName});

  @override
  State<BoostListingDialog> createState() => _BoostListingDialogState();
}

class _BoostListingDialogState extends State<BoostListingDialog> {
  String _selectedTier = 'Premium';
  String _targetAudience = 'All Nearby Tenants';
  int _durationDays = 7;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Boost Listing', style: AppTextStyles.headlineMedium),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Promote ${widget.propertyName}', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 24),
          const Text('Select Tier', style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedTier,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            items: const [
              DropdownMenuItem(value: 'Basic', child: Text('Basic (Top of Search)')),
              DropdownMenuItem(value: 'Premium', child: Text('Premium (Homepage Banner)')),
              DropdownMenuItem(value: 'Featured Banner', child: Text('Featured Banner (Push Notification)')),
            ],
            onChanged: (val) => setState(() => _selectedTier = val!),
          ),
          const SizedBox(height: 16),
          const Text('Target Audience', style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _targetAudience,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            items: const [
              DropdownMenuItem(value: 'All Nearby Tenants', child: Text('All Nearby Tenants')),
              DropdownMenuItem(value: 'High Credit Score Only', child: Text('High Credit Score Only')),
              DropdownMenuItem(value: 'Students', child: Text('Students')),
            ],
            onChanged: (val) => setState(() => _targetAudience = val!),
          ),
          const SizedBox(height: 16),
          const Text('Duration', style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildDurationChip(7),
              const SizedBox(width: 8),
              _buildDurationChip(14),
              const SizedBox(width: 8),
              _buildDurationChip(30),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing boosted successfully!')));
            },
            child: const Text('Apply Boost', style: AppTextStyles.buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationChip(int days) {
    final isSelected = _durationDays == days;
    return ChoiceChip(
      label: Text('$days Days', style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary)),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.grey[200],
      onSelected: (selected) {
        if (selected) setState(() => _durationDays = days);
      },
    );
  }
}
