import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/home_dashboard_provider.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/provider/tenant_lease_provider.dart';
class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  String _avatarUrl = '';
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final resp = await ApiClient().dio.get('/auth/me');
      final data = resp.data['data'] as Map<String, dynamic>? ?? {};
      if (mounted) {
        setState(() {
          _avatarUrl = data['avatar_url']?.toString() ?? '';
          _userName = data['legal_first_name']?.toString() ?? data['display_name']?.toString() ?? 'User';
        });
      }
    } catch (e) {
      debugPrint('Failed to load profile for dashboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeDashboardProvider);
    final notif = ref.read(homeDashboardProvider.notifier);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top AppBar ───────────────────────────
            Container(
              color: AppColors.white,
              padding: EdgeInsets.symmetric(
                horizontal: pad,
                vertical: h * 0.015,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.white,
                          title: const Text('Exit Tenant Portal', style: TextStyle(fontWeight: FontWeight.bold)),
                          content: const Text('Do you want to logout and switch to another portal?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context); // Close dialog
                                await ApiClient().clearToken();
                                if (context.mounted) {
                                  Navigator.pushNamedAndRemoveUntil(context, '/role_selection', (route) => false);
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                              child: const Text('Exit', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: w * 0.05,
                      backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                      backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                      child: _avatarUrl.isEmpty ? Icon(Icons.person, size: w * 0.06, color: AppColors.secondary) : null,
                    ),
                  ),
                  SizedBox(width: w * 0.025),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back,',
                        style: TextStyle(
                          fontSize: w * 0.032,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _userName.isEmpty ? 'Loading...' : _userName,
                        style: TextStyle(
                          fontSize: w * 0.048,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/notifications'),
                    child: Icon(
                      Icons.notifications_outlined,
                      size: w * 0.065,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: AppColors.white,
                      padding: EdgeInsets.fromLTRB(pad, 0, pad, h * 0.018),
                      child: Column(
                        children: [
                          // Search bar
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/search'),
                            child: Container(
                              height: h * 0.058,
                              decoration: BoxDecoration(
                                color: AppColors.inputBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: w * 0.04),
                                  Icon(
                                    Icons.search_rounded,
                                    size: w * 0.05,
                                    color: AppColors.textHint,
                                  ),
                                  SizedBox(width: w * 0.03),
                                  Text(
                                    'Search for your next home...',
                                    style: TextStyle(
                                      fontSize: w * 0.036,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: h * 0.015),

                          // Filter chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: ['Price', 'Beds', 'Location']
                                  .map(
                                    (label) => Padding(
                                      padding: EdgeInsets.only(
                                        right: w * 0.025,
                                      ),
                                      child: _FilterChip(
                                        label: label,
                                        selected: state.selectedFilter == label,
                                        onTap: () => notif.selectFilter(label),
                                        w: w,
                                        icon: label == 'Price'
                                            ? Icons.attach_money_rounded
                                            : label == 'Beds'
                                            ? Icons.bed_outlined
                                            : Icons.location_on_outlined,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(pad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'My Activity',
                                style: TextStyle(
                                  fontSize: w * 0.052,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/tenant_applications'),
                                child: Text(
                                  'My Applications',
                                  style: TextStyle(
                                    fontSize: w * 0.034,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: h * 0.015),
                          _ActiveLeaseWidget(w: w, h: h),
                          SizedBox(height: h * 0.03),
                          _RecentActivityList(w: w, h: h),

                          // Featured Listings
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Featured Listings',
                                    style: TextStyle(
                                      fontSize: w * 0.052,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Curated properties based on your preference',
                                    style: TextStyle(
                                      fontSize: w * 0.031,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushReplacementNamed(context, '/search'),
                                child: Text(
                                  'View all',
                                  style: TextStyle(
                                    fontSize: w * 0.034,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: h * 0.02),

                          // Premium card
                          _FeaturedCard(
                            imageUrl:
                                'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&q=80',
                            isPremium: true,
                            title: 'Skyline Vista Residence',
                            price: '\$4,500/mo',
                            address: '1200 Broadway, New York, NY',
                            beds: '3',
                            baths: '2',
                            sqft: '1,450',
                            w: w,
                            h: h,
                          ),

                          SizedBox(height: h * 0.018),

                          // Regular card
                          _FeaturedCard(
                            imageUrl:
                                'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80',
                            isPremium: false,
                            title: 'The Brickwork Lofts',
                            price: '\$2,800/mo',
                            address: 'Brooklyn, NY',
                            beds: '1',
                            baths: '1',
                            sqft: '780',
                            w: w,
                            h: h,
                            priceColor: AppColors.secondary,
                          ),

                          SizedBox(height: h * 0.03),

                          // Saved Properties
                          Text(
                            'Saved Properties',
                            style: TextStyle(
                              fontSize: w * 0.052,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Keep track of homes you like',
                            style: TextStyle(
                              fontSize: w * 0.031,
                              color: AppColors.textSecondary,
                            ),
                          ),

                          SizedBox(height: h * 0.015),

                          // Saved list
                          ...[
                            (
                              'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=200&q=80',
                              'Cozy Studio Central',
                              '\$2,100/mo',
                              '1',
                              '1',
                            ),
                            (
                              'https://images.unsplash.com/photo-1416331108676-a22ccb276e35?w=200&q=80',
                              'Garden View Manor',
                              '\$3,400/mo',
                              '2',
                              '2',
                            ),
                            (
                              'https://images.unsplash.com/photo-1486325212027-8081e485255e?w=200&q=80',
                              'The Glass House',
                              '\$5,200/mo',
                              '3',
                              '3',
                            ),
                          ].map(
                            (p) => Padding(
                              padding: EdgeInsets.only(bottom: h * 0.012),
                              child: _SavedPropertyCard(
                                imageUrl: p.$1,
                                title: p.$2,
                                price: p.$3,
                                beds: p.$4,
                                baths: p.$5,
                                w: w,
                                h: h,
                              ),
                            ),
                          ),

                          SizedBox(height: h * 0.02),
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
}

// ── Filter chip ───────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double w;
  final IconData icon;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.w,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.04,
          vertical: w * 0.022,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: w * 0.038,
              color: selected ? AppColors.white : AppColors.textSecondary,
            ),
            SizedBox(width: w * 0.015),
            Text(
              label,
              style: TextStyle(
                fontSize: w * 0.033,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatefulWidget {
  final String imageUrl;
  final bool isPremium;
  final String title;
  final String price;
  final String address;
  final String beds;
  final String baths;
  final String sqft;
  final double w;
  final double h;
  final Color? priceColor;

  const _FeaturedCard({
    required this.imageUrl,
    required this.isPremium,
    required this.title,
    required this.price,
    required this.address,
    required this.beds,
    required this.baths,
    required this.sqft,
    required this.w,
    required this.h,
    this.priceColor,
  });

  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard> {
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
      onTap: () {
        Navigator.pushNamed(context, '/property_details');
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.07),
              blurRadius: 14,
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
                    widget.imageUrl,
                    height: widget.h * 0.24,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: widget.h * 0.24,
                      color: AppColors.inputBg,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ),
                if (widget.isPremium)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.w * 0.03,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'PREMIUM',
                        style: TextStyle(
                          fontSize: widget.w * 0.025,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          letterSpacing: 0.8,
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
                      width: widget.w * 0.09,
                      height: widget.w * 0.09,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: widget.w * 0.045,
                        color: _isFavorite ? AppColors.error : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.all(widget.w * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: widget.w * 0.042,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        widget.price,
                        style: TextStyle(
                          fontSize: widget.w * 0.042,
                          fontWeight: FontWeight.w700,
                          color: widget.priceColor ?? AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: widget.h * 0.006),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: widget.w * 0.035,
                        color: AppColors.textHint,
                      ),
                      SizedBox(width: 3),
                      Text(
                        widget.address,
                        style: TextStyle(
                          fontSize: widget.w * 0.031,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: widget.h * 0.012),
                  Row(
                    children: [
                      _PropStat(
                        icon: Icons.bed_outlined,
                        value: widget.beds,
                        label: 'Beds',
                        w: widget.w,
                      ),
                      SizedBox(width: widget.w * 0.06),
                      _PropStat(
                        icon: Icons.bathtub_outlined,
                        value: widget.baths,
                        label: 'Baths',
                        w: widget.w,
                      ),
                      SizedBox(width: widget.w * 0.06),
                      _PropStat(
                        icon: Icons.straighten_rounded,
                        value: widget.sqft,
                        label: 'sqft',
                        w: widget.w,
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

class _PropStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final double w;

  const _PropStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.w,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: w * 0.038, color: AppColors.textSecondary),
        SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: w * 0.034,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(fontSize: w * 0.03, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ── Saved property row card ───────────────────
class _SavedPropertyCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String beds;
  final String baths;
  final double w;
  final double h;

  const _SavedPropertyCard({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.beds,
    required this.baths,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/property_details'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: AppColors.secondary, width: 3)),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 8),
          ],
        ),
        child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(11),
              bottomLeft: Radius.circular(11),
            ),
            child: Image.network(
              imageUrl,
              width: w * 0.25,
              height: w * 0.22,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: w * 0.25,
                height: w * 0.22,
                color: AppColors.inputBg,
              ),
            ),
          ),
          SizedBox(width: w * 0.03),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: w * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: w * 0.036,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: w * 0.033,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.bed_outlined,
                        size: w * 0.035,
                        color: AppColors.textHint,
                      ),
                      SizedBox(width: 3),
                      Text(
                        beds,
                        style: TextStyle(
                          fontSize: w * 0.03,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: w * 0.04),
                      Icon(
                        Icons.bathtub_outlined,
                        size: w * 0.035,
                        color: AppColors.textHint,
                      ),
                      SizedBox(width: 3),
                      Text(
                        baths,
                        style: TextStyle(
                          fontSize: w * 0.03,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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
}

class _ActiveLeaseWidget extends ConsumerWidget {
  final double w;
  final double h;
  const _ActiveLeaseWidget({required this.w, required this.h});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaseAsync = ref.watch(tenantLeaseProvider);

    return leaseAsync.when(
      data: (lease) {
        if (lease.leaseId.isEmpty) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(w * 0.05),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textHint.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.home_work_outlined,
                  size: w * 0.12,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
                SizedBox(height: h * 0.015),
                Text(
                  'No Active Rent Agreement',
                  style: TextStyle(
                    fontSize: w * 0.045,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: h * 0.01),
                Text(
                  'You currently don\'t have any active lease or rental agreements. Explore our properties to find your next home!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: w * 0.035,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: h * 0.025),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/search');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: h * 0.015),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Explore Properties',
                      style: TextStyle(
                        fontSize: w * 0.038,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Container(
          padding: EdgeInsets.all(w * 0.04),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Active Lease', style: TextStyle(color: Colors.white70, fontSize: w * 0.035)),
              SizedBox(height: h * 0.01),
              Text(
                '${lease.propertyName} - Unit ${lease.unitName}',
                style: TextStyle(color: Colors.white, fontSize: w * 0.045, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: h * 0.01),
              Text(
                'Rent: \$${lease.rentAmount.toStringAsFixed(0)} / month',
                style: TextStyle(color: Colors.white, fontSize: w * 0.035),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const Center(child: Text('Error loading lease')),
    );
  }
}

class _RecentActivityList extends ConsumerWidget {
  final double w;
  final double h;
  const _RecentActivityList({required this.w, required this.h});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeAsync = ref.watch(tenantFinanceProvider);
    return financeAsync.when(
      data: (finance) {
        final raw = finance['recentActivity'];
        if (raw == null || raw is! List || raw.isEmpty) {
          return const SizedBox.shrink();
        }
        final activityList = raw;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: w * 0.052,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/payment_history'),
                  child: Text(
                    'View all',
                    style: TextStyle(
                      fontSize: w * 0.034,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: h * 0.015),
            ...activityList.take(3).map((p) {
              final amt = p['amount_paid'] ?? p['amount_due'] ?? 0;
              final isLate = p['status'] == 'late';
              return Container(
                margin: EdgeInsets.only(bottom: h * 0.012),
                padding: EdgeInsets.all(w * 0.04),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 8),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: w * 0.1,
                      height: w * 0.1,
                      decoration: BoxDecoration(
                        color: isLate ? const Color(0xFFE74C3C).withValues(alpha: 0.1) : AppColors.secondary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isLate ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                        color: isLate ? const Color(0xFFE74C3C) : AppColors.secondary,
                        size: w * 0.05,
                      ),
                    ),
                    SizedBox(width: w * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rent Payment', style: TextStyle(fontSize: w * 0.038, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          Text(p['created_at'] != null ? 'Paid on ${p['created_at'].toString().split('T')[0]}' : '', style: TextStyle(fontSize: w * 0.029, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Text(
                      '\$${double.parse(amt.toString()).toStringAsFixed(2)}',
                      style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.w700, color: isLate ? const Color(0xFFE74C3C) : AppColors.textPrimary),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: h * 0.03),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

