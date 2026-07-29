import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_user_avatar.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/search_provider.dart';

class FilterScreen extends ConsumerWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchFilterProvider);
    final notif = ref.read(searchFilterProvider.notifier);
    
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            TLUserAvatar(radius: w * 0.045),
            SizedBox(width: w * 0.03),
            Text(
              'T&L',
              style: TextStyle(
                fontSize: w * 0.05,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: w * 0.065),
            onPressed: () { Navigator.pushNamed(context, '/notifications'); },
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: AppColors.textPrimary, size: w * 0.065),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: w * 0.02),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, h * 0.02, pad, h * 0.12), // Bottom padding for FAB
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Header --
            Text(
              'Filter Properties',
              style: TextStyle(
                fontSize: w * 0.06,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: h * 0.01),
            Text(
              'Customize your search to find the perfect match\nfor your lifestyle.',
              style: TextStyle(
                fontSize: w * 0.035,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),

            SizedBox(height: h * 0.04),

            // -- Monthly Rent --
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle('MONTHLY RENT', w),
                Text(
                  '\$${state.rentRange.start.toInt()} - \$${state.rentRange.end.toInt()}',
                  style: TextStyle(
                    fontSize: w * 0.045,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: h * 0.02),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: AppColors.secondary,
                inactiveTrackColor: AppColors.inputBg,
                thumbColor: AppColors.white,
                overlayColor: AppColors.secondary.withValues(alpha: 0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 4),
              ),
              child: RangeSlider(
                values: state.rentRange,
                min: 500,
                max: 8000,
                divisions: 75,
                onChanged: notif.updateRentRange,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$500', style: TextStyle(fontSize: w * 0.03, color: AppColors.textHint)),
                Text('\$8,000+', style: TextStyle(fontSize: w * 0.03, color: AppColors.textHint)),
              ],
            ),

            SizedBox(height: h * 0.04),

            // -- Bedrooms --
            _sectionTitle('BEDROOMS', w),
            SizedBox(height: h * 0.015),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Any', '2+', '3+', '4+'].map((opt) {
                return _selectionChip(w, opt, state.bedrooms == opt, () => notif.selectBedrooms(opt));
              }).toList(),
            ),

            SizedBox(height: h * 0.03),

            // -- Bathrooms --
            _sectionTitle('BATHROOMS', w),
            SizedBox(height: h * 0.015),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Any', '1+', '2+', '3+'].map((opt) {
                return _selectionChip(w, opt, state.bathrooms == opt, () => notif.selectBathrooms(opt));
              }).toList(),
            ),

            SizedBox(height: h * 0.04),

            // -- Search Radius --
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle('SEARCH RADIUS', w),
                Text(
                  'Within ${state.searchRadius.toInt()} KM',
                  style: TextStyle(
                    fontSize: w * 0.035,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: h * 0.02),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: AppColors.inputBg,
                inactiveTrackColor: AppColors.inputBg,
                thumbColor: AppColors.white,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
              ),
              child: Slider(
                value: state.searchRadius,
                min: 5,
                max: 50,
                onChanged: notif.updateRadius,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('5 KM', style: TextStyle(fontSize: w * 0.03, color: AppColors.textHint)),
                Text('50 KM', style: TextStyle(fontSize: w * 0.03, color: AppColors.textHint)),
              ],
            ),

            SizedBox(height: h * 0.04),

            // -- Move-in Date --
            _sectionTitle('MOVE-IN DATE', w),
            SizedBox(height: h * 0.015),
            Container(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.02),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Oct 15, 2023',
                    style: TextStyle(fontSize: w * 0.035, color: AppColors.textPrimary),
                  ),
                  Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: w * 0.05),
                ],
              ),
            ),

            SizedBox(height: h * 0.025),

            // -- Pets Allowed --
            Container(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.015),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.pets, color: AppColors.textSecondary, size: w * 0.05),
                  SizedBox(width: w * 0.03),
                  Expanded(
                    child: Text(
                      'Pets Allowed',
                      style: TextStyle(fontSize: w * 0.035, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                    ),
                  ),
                  Switch(
                    value: state.petsAllowed,
                    onChanged: notif.togglePets,
                    activeThumbColor: AppColors.white,
                    activeTrackColor: AppColors.secondary,
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.04),

            // -- Amenities --
            _sectionTitle('AMENITIES', w),
            SizedBox(height: h * 0.015),
            Wrap(
              spacing: w * 0.03,
              runSpacing: h * 0.015,
              children: ['AC', 'Balcony', 'Laundry', 'Gym', 'Parking'].map((am) {
                final isSelected = state.amenities.contains(am);
                return GestureDetector(
                  onTap: () => notif.toggleAmenity(am),
                  child: Container(
                    width: w * 0.42,
                    padding: EdgeInsets.symmetric(vertical: h * 0.015, horizontal: w * 0.03),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppColors.secondary : AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: w * 0.05,
                          height: w * 0.05,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.secondary : AppColors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: isSelected ? AppColors.secondary : AppColors.border),
                          ),
                          child: isSelected 
                            ? Icon(Icons.check, color: AppColors.white, size: w * 0.035)
                            : null,
                        ),
                        SizedBox(width: w * 0.03),
                        Text(
                          am,
                          style: TextStyle(
                            fontSize: w * 0.035,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: h * 0.04),

            // -- Image Banner --
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&q=80',
                    height: h * 0.15,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: h * 0.15,
                    width: double.infinity,
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                  Positioned(
                    bottom: h * 0.02,
                    left: w * 0.04,
                    child: Text(
                      'Found 142 matches in\nDowntown District',
                      style: TextStyle(
                        fontSize: w * 0.035,
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // -- Floating Bottom Action Bar --
      bottomSheet: Container(
        padding: EdgeInsets.symmetric(horizontal: pad, vertical: h * 0.02),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: notif.resetFilters,
              child: Text(
                'Reset All',
                style: TextStyle(
                  fontSize: w * 0.038,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D0D0D), // Almost black
                padding: EdgeInsets.symmetric(horizontal: w * 0.1, vertical: h * 0.018),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Apply Filters',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: w * 0.038,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, double w) {
    return Text(
      text,
      style: TextStyle(
        fontSize: w * 0.032,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _selectionChip(double w, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: w * 0.2,
        padding: EdgeInsets.symmetric(vertical: w * 0.025),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.secondary : AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: w * 0.035,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
