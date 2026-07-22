import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_mock_map.dart';

// Simple list of images for the carousel (replace with real URLs as needed)
const List<String> _detailImages = [
  'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800&q=80',
  'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&q=80',
  'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800&q=80',
];

class PropertyDetailsScreen extends ConsumerStatefulWidget {
  const PropertyDetailsScreen({super.key});

  @override
  ConsumerState<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends ConsumerState<PropertyDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final pad = w * 0.05; // standard horizontal padding



    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: w * 0.06),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'T&L',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: w * 0.05,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: AppColors.textSecondary, size: w * 0.055),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.favorite_border_rounded, color: AppColors.textSecondary, size: w * 0.055),
            onPressed: () {},
          ),
          SizedBox(width: w * 0.02),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: w * 0.04),
            // Image Carousel Slider
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _imageCarousel(),
              ),
            ),
            
            SizedBox(height: w * 0.05),
            
            // -- Title & Location --
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modern Loft at Skyline Heights',
                    style: TextStyle(
                      fontSize: w * 0.055,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: w * 0.02),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: w * 0.045),
                      SizedBox(width: w * 0.015),
                      Expanded(
                        child: Text(
                          '123 Metropolis Avenue, Suite 402,\nDowntown',
                          style: TextStyle(
                            fontSize: w * 0.035,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: w * 0.05),

            // -- Monthly Rent Banner --
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: w * 0.04),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8EEFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'MONTHLY RENT',
                      style: TextStyle(
                        fontSize: w * 0.032,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary.withValues(alpha: 0.8),
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: w * 0.01),
                    Text(
                      '\$1,200',
                      style: TextStyle(
                        fontSize: w * 0.06,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: w * 0.05),

            // -- Quick Info Row --
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: Row(
                children: [
                  _infoBox(w, Icons.bed_outlined, '2 Bed', 'Bedrooms'),
                  _infoDivider(w),
                  _infoBox(w, Icons.bathtub_outlined, '2 Bath', 'Bathrooms'),
                  _infoDivider(w),
                  _infoBox(w, Icons.square_foot_outlined, '1,200', 'Square Feet'),
                ],
              ),
            ),

            SizedBox(height: w * 0.06),

            // -- Availability Date --
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_outlined, color: AppColors.secondary, size: w * 0.045),
                  SizedBox(width: w * 0.02),
                  Text(
                    'Available: November 1, 2024',
                    style: TextStyle(
                      fontSize: w * 0.035,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: w * 0.06),

            // -- Property Description --
            _sectionContainer(
              w,
              'Property Description',
              Text(
                'Experience contemporary urban living in this beautifully designed 2-bedroom loft. Featuring an open-concept floor plan with soaring ceilings and premium finishes, this unit offers the perfect balance of luxury and functionality. The primary suite includes a private bath and walk-in closet, while the second bedroom is perfect for guests or a home office.',
                style: TextStyle(
                  fontSize: w * 0.036,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),

            // -- Apartment Amenities --
            _sectionContainer(
              w,
              'Apartment Amenities',
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 3.5,
                mainAxisSpacing: w * 0.03,
                crossAxisSpacing: w * 0.03,
                children: [
                  _amenityItem(w, Icons.wifi, 'High-speed\nInternet'),
                  _amenityItem(w, Icons.local_laundry_service_outlined, 'In-unit\nWasher/Dryer'),
                  _amenityItem(w, Icons.ac_unit, 'Central Air'),
                  _amenityItem(w, Icons.pets, 'Pet Friendly'),
                  _amenityItem(w, Icons.balcony_outlined, 'Private\nBalcony'),
                  _amenityItem(w, Icons.directions_car_outlined, 'Parking\nGarage'),
                ],
              ),
            ),

            // -- Location Map --
            _sectionContainer(
              w,
              'Location',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    SizedBox(
                      height: w * 0.5,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: const TLMockMap(
                          initialZoom: 1.2,
                          showZoomControls: false,
                        ),
                      ),
                    ),
                  SizedBox(height: w * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Skyline Heights District',
                            style: TextStyle(
                              fontSize: w * 0.038,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '92 Walk Score • 85 Transit Score',
                            style: TextStyle(
                              fontSize: w * 0.032,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Open in Maps ↗',
                        style: TextStyle(
                          fontSize: w * 0.032,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // -- Fees Breakdown --
            _sectionContainer(
              w,
              'Fees Breakdown',
              Column(
                children: [
                  _feeRow(w, 'Security Deposit', '\$1,200', false),
                  SizedBox(height: w * 0.03),
                  _feeRow(w, 'Monthly Utilities', '\$150', true, subtitle: 'Estimated average'),
                  SizedBox(height: w * 0.03),
                  _feeRow(w, 'Pet Rent', '\$50/mo', false),
                  SizedBox(height: w * 0.03),
                  _feeRow(w, 'Application Fee', '\$45', false),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: w * 0.04),
                    child: Divider(color: AppColors.border, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Move-In',
                        style: TextStyle(
                          fontSize: w * 0.04,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '\$2,445',
                        style: TextStyle(
                          fontSize: w * 0.045,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: w * 0.04),
                  Container(
                    padding: EdgeInsets.all(w * 0.035),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.verified_user_outlined, color: AppColors.secondary, size: w * 0.045),
                        SizedBox(width: w * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Guaranteed Price',
                                style: TextStyle(
                                  fontSize: w * 0.034,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Rent prices are locked for 24 hours after your application is started.',
                                style: TextStyle(
                                  fontSize: w * 0.028,
                                  color: AppColors.textSecondary,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // -- Ask Question --
            Padding(
              padding: EdgeInsets.all(pad),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(w * 0.05),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Have a question?',
                      style: TextStyle(
                        fontSize: w * 0.04,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: w * 0.02),
                    Text(
                      'Speak with our property management\nteam directly.',
                      style: TextStyle(
                        fontSize: w * 0.035,
                        color: AppColors.white.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: w * 0.05),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: w * 0.035),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Icon(Icons.chat_bubble_outline_rounded, size: w * 0.05),
                        label: Text(
                          'Ask Question',
                          style: TextStyle(
                            fontSize: w * 0.038,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/chat/detail'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: w * 0.25), // Padding for bottom nav
          ],
        ),
      ),

      // -- Bottom Navigation --
      bottomSheet: Container(
        padding: EdgeInsets.symmetric(horizontal: pad, vertical: w * 0.04),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite_border_rounded, color: AppColors.textSecondary, size: w * 0.06),
                SizedBox(height: 2),
                Text(
                  'Save',
                  style: TextStyle(
                    fontSize: w * 0.028,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(width: w * 0.05),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: w * 0.035),
                  side: BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  'Schedule Tour',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: w * 0.035,
                  ),
                ),
              ),
            ),
            SizedBox(width: w * 0.03),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: w * 0.035),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pushNamed(context, '/application_checkout'),
                child: Text(
                  'Apply to Unit',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: w * 0.035,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Simple carousel widget using PageView
  Widget _imageCarousel() {
    return const _CarouselStateful();
  }

  Widget _infoBox(double w, IconData icon, String title, String subtitle) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.secondary, size: w * 0.06),
          SizedBox(height: w * 0.02),
          Text(
            title,
            style: TextStyle(
              fontSize: w * 0.038,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: w * 0.03,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoDivider(double w) {
    return Container(
      height: w * 0.1,
      width: 1,
      color: AppColors.border,
    );
  }

  Widget _sectionContainer(double w, String title, Widget child) {
    return Container(
      margin: EdgeInsets.only(left: w * 0.05, right: w * 0.05, bottom: w * 0.05),
      padding: EdgeInsets.all(w * 0.05),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: w * 0.042,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: w * 0.04),
          child,
        ],
      ),
    );
  }

  Widget _amenityItem(double w, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(w * 0.02),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: w * 0.045),
        ),
        SizedBox(width: w * 0.02),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: w * 0.032,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _feeRow(double w, String title, String amount, bool hasSubtitle, {String subtitle = ''}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: w * 0.035,
                color: AppColors.textSecondary,
              ),
            ),
            if (hasSubtitle) ...[
              SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: w * 0.025,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ],
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: w * 0.038,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// Helper stateful widget for the carousel
class _CarouselStateful extends StatefulWidget {
  const _CarouselStateful();

  @override
  State<_CarouselStateful> createState() => _CarouselStatefulState();
}

class _CarouselStatefulState extends State<_CarouselStateful> {
  int _current = 0;
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        SizedBox(
          height: w * 0.6,
          child: PageView.builder(
            controller: _controller,
            itemCount: _detailImages.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (ctx, index) => Image.network(
              _detailImages[index],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        // Badge showing index / total
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.015),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_current + 1}/${_detailImages.length}',
              style: TextStyle(color: AppColors.white, fontSize: w * 0.03, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        // Indicator dots
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_detailImages.length, (i) => _dot(i == _current, w)),
          ),
        ),
      ],
    );
  }

  // Reusable dot widget used by the carousel
  Widget _dot(bool active, double w) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? w * 0.02 : w * 0.015,
      height: active ? w * 0.02 : w * 0.015,
      decoration: BoxDecoration(
        color: active ? AppColors.white : AppColors.white.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}
