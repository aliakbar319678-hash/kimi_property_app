import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_user_avatar.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_mock_map.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

// Premium Unsplash room images for searching properties
const List<String> _searchPropertyImages = [
  'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=800&q=80',
  'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80',
  'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&q=80',
];

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

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
            icon: Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
              size: w * 0.065,
            ),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          SizedBox(width: w * 0.02),
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // -- Map Background & Pins --
            SizedBox(
              height: h * 0.45,
              child: Stack(
                children: [
                  const TLMockMap(initialZoom: 1.0, showZoomControls: false),
                  Positioned(
                    top: h * 0.02,
                    right: w * 0.04,
                    child: Column(
                      children: [
                        _mapActionButton(Icons.my_location, w),
                        SizedBox(height: h * 0.015),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.add,
                                  color: AppColors.primary,
                                  size: w * 0.05,
                                ),
                                onPressed: () { Navigator.pushNamed(context, '/filter'); },
                              ),
                              Container(
                                height: 1,
                                width: w * 0.06,
                                color: AppColors.border,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.remove,
                                  color: AppColors.primary,
                                  size: w * 0.05,
                                ),
                                onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Map View...'))); },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(top: h * 0.2, left: w * 0.3, child: _mapPin(w, true)),
                  Positioned(top: h * 0.15, left: w * 0.5, child: _mapPin(w, false)),
                  Positioned(top: h * 0.25, left: w * 0.7, child: _mapPin(w, true)),
                ],
              ),
            ),

            // -- Bottom Content Area --
            Container(
              margin: EdgeInsets.only(top: h * 0.38),
              decoration: const BoxDecoration(
                color: AppColors.scaffoldBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: h * 0.06,
                  ), // Space for overlapping search bar
                  // -- Header --
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Properties in\nSeattle',
                              style: TextStyle(
                                fontSize: w * 0.06,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '128 results found',
                              style: TextStyle(
                                fontSize: w * 0.035,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: w * 0.03,
                            vertical: h * 0.01,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.secondary),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.sort,
                                color: AppColors.secondary,
                                size: w * 0.04,
                              ),
                              SizedBox(width: w * 0.015),
                              Text(
                                'Price: Low to High',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: w * 0.03,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: h * 0.02),

                  // -- List --
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return _buildPropertyCard(context, w, h, index);
                    },
                  ),
                ],
              ),
            ),

            // -- Floating Search Bar --
            Positioned(
              top: h * 0.35, // Overlaps map and bottom sheet
              left: w * 0.05,
              right: w * 0.05,
              child: Container(
                height: h * 0.07,
                padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: AppColors.secondary,
                      size: w * 0.06,
                    ),
                    SizedBox(width: w * 0.03),
                    Expanded(
                      child: Text(
                        'Seattle, WA',
                        style: TextStyle(
                          fontSize: w * 0.04,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/filter');
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            color: AppColors.secondary,
                            size: w * 0.05,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Filters',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                              fontSize: w * 0.035,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget _mapActionButton(IconData icon, double w) {
    return Container(
      padding: EdgeInsets.all(w * 0.025),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.primary, size: w * 0.055),
    );
  }

  Widget _mapPin(double w, bool isLarge) {
    final size = isLarge ? w * 0.1 : w * 0.07;
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.home_work_outlined,
            color: AppColors.white,
            size: size * 0.5,
          ),
        ),
        Container(width: 2, height: size * 0.4, color: AppColors.primary),
      ],
    );
  }

  Widget _buildPropertyCard(BuildContext context, double w, double h, int index) {
    return _PropertyCard(w: w, h: h, index: index);
  }
}

class _PropertyCard extends StatefulWidget {
  final double w;
  final double h;
  final int index;

  const _PropertyCard({required this.w, required this.h, required this.index});

  @override
  State<_PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<_PropertyCard> {
  bool _isFavorite = false;

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Saved to Favorites' : 'Removed from Favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/property_details'),
      child: Container(
      margin: EdgeInsets.only(bottom: widget.h * 0.025),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  _searchPropertyImages[widget.index % _searchPropertyImages.length],
                  height: widget.h * 0.22,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: widget.h * 0.22,
                    color: AppColors.inputBg,
                    child: const Icon(
                      Icons.image_outlined,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: _toggleFavorite,
                  child: Container(
                    padding: EdgeInsets.all(widget.w * 0.02),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isFavorite ? AppColors.error : AppColors.textSecondary,
                      size: widget.w * 0.05,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.w * 0.03,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Apartment',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: widget.w * 0.03,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Details
          Padding(
            padding: EdgeInsets.all(widget.w * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Skyline View Lofts',
                      style: TextStyle(
                        fontSize: widget.w * 0.045,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '\$2,450',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w800,
                              fontSize: widget.w * 0.045,
                            ),
                          ),
                          TextSpan(
                            text: '/mo',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: widget.w * 0.03,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: widget.h * 0.01),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppColors.textHint,
                      size: widget.w * 0.04,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Downtown, Seattle',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: widget.w * 0.035,
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
    );
  }
}
