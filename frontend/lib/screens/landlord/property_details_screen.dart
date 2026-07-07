import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/provider/landlord_state.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class LandlordPropertyDetailsScreen extends ConsumerWidget {
  const LandlordPropertyDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(landlordProvider);
    final notifier = ref.read(landlordProvider.notifier);

    // Retreive the property from arguments
    final Property property =
        ModalRoute.of(context)!.settings.arguments as Property? ??
        state.properties.first;

    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image & Header Overlay
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: h * 0.35,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(property.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: h * 0.35,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Custom Header
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          property.name,
                          style: TextStyle(
                            fontSize: w * 0.045,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.more_vert_rounded,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Occupancy Badge over image
                Positioned(
                  bottom: 20,
                  left: pad,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Occupancy',
                          style: TextStyle(
                            fontSize: w * 0.026,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(property.occupancyRate * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: w * 0.045,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Location
                  Text(
                    property.name,
                    style: TextStyle(
                      fontSize: w * 0.06,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: h * 0.005),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        property.address,
                        style: TextStyle(
                          fontSize: w * 0.032,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: h * 0.03),

                  // Management Actions Grid
                  Text(
                    'Management Actions',
                    style: TextStyle(
                      fontSize: w * 0.042,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: h * 0.015),
                  Row(
                    children: [
                      _buildActionCard(
                        icon: Icons.add_circle_outline_rounded,
                        label: 'Add Unit',
                        onTap: () => _showAddUnitDialog(context, notifier),
                        w: w,
                      ),
                      SizedBox(width: w * 0.03),
                      _buildActionCard(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        onTap: () {},
                        w: w,
                      ),
                      SizedBox(width: w * 0.03),
                      _buildActionCard(
                        icon: Icons.monetization_on_outlined,
                        label: 'Fees',
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/landlord_financial_overview',
                        ),
                        w: w,
                      ),
                    ],
                  ),

                  SizedBox(height: h * 0.035),

                  // Unit Status List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Unit Status',
                        style: TextStyle(
                          fontSize: w * 0.042,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: w * 0.032,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: h * 0.015),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.units.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final unit = state.units[idx];
                      Color badgeColor;
                      switch (unit.status.toLowerCase()) {
                        case 'occupied':
                          badgeColor = Colors.green;
                          break;
                        case 'vacant':
                          badgeColor = Colors.orange;
                          break;
                        default:
                          badgeColor = AppColors.secondary;
                      }

                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: w * 0.04,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.scaffoldBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.meeting_room_rounded,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(width: w * 0.03),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      unit.name,
                                      style: TextStyle(
                                        fontSize: w * 0.038,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      unit.status == 'Occupied'
                                          ? unit.tenantName
                                          : 'Available',
                                      style: TextStyle(
                                        fontSize: w * 0.03,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                unit.status,
                                style: TextStyle(
                                  fontSize: w * 0.028,
                                  fontWeight: FontWeight.w700,
                                  color: badgeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  SizedBox(height: h * 0.035),

                  // Amenities
                  Text(
                    'Amenities',
                    style: TextStyle(
                      fontSize: w * 0.042,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: h * 0.015),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildAmenityChip('Luxury Pool', Icons.pool_rounded, w),
                      _buildAmenityChip(
                        '24/7 Gym',
                        Icons.fitness_center_rounded,
                        w,
                      ),
                      _buildAmenityChip(
                        'Parking',
                        Icons.local_parking_rounded,
                        w,
                      ),
                      _buildAmenityChip(
                        'Maintenance Included',
                        Icons.build_outlined,
                        w,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required double w,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: w * 0.03,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmenityChip(String name, IconData icon, double w) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.secondary, size: 16),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: w * 0.03,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUnitDialog(BuildContext context, LandlordNotifier notifier) {
    final nameController = TextEditingController();
    final rentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Add New Unit',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Unit Name (e.g. Unit 104)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: rentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Monthly Rent (\$)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    rentController.text.isNotEmpty) {
                  final newUnit = Unit(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    status: 'Vacant',
                    tenantName: '',
                    rent: double.tryParse(rentController.text) ?? 1000.0,
                    amenities: ['Maintenance'],
                  );
                  notifier.addUnit(newUnit);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
