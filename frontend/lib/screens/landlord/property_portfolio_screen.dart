import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';

import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class PropertyPortfolioScreen extends ConsumerStatefulWidget {
  const PropertyPortfolioScreen({super.key});

  @override
  ConsumerState<PropertyPortfolioScreen> createState() =>
      _PropertyPortfolioScreenState();
}

class _PropertyPortfolioScreenState
    extends ConsumerState<PropertyPortfolioScreen> {
  String _selectedTab = 'All';
  String _searchQuery = '';

  Color _approvalColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'rejected': return AppColors.error;
      default: return AppColors.secondary;
    }
  }

  String _approvalLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return 'Approved';
      case 'rejected': return 'Rejected';
      default: return 'Pending';
    }
  }

  IconData _approvalIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Icons.verified_rounded;
      case 'rejected': return Icons.cancel_rounded;
      default: return Icons.hourglass_empty_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(landlordProvider);
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.05;

    final filteredProperties = state.properties.where((prop) {
      final matchesSearch =
          prop.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          prop.address.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;
      switch (_selectedTab) {
        case 'Pending': return prop.verificationStatus.toLowerCase() == 'pending';
        case 'Approved': return prop.verificationStatus.toLowerCase() == 'approved';
        case 'Rejected': return prop.verificationStatus.toLowerCase() == 'rejected';
        default: return true;
      }
    }).toList();

    final pendingCount  = state.properties.where((p) => p.verificationStatus == 'pending').length;
    final approvedCount = state.properties.where((p) => p.verificationStatus == 'approved').length;
    final rejectedCount = state.properties.where((p) => p.verificationStatus == 'rejected').length;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/landlord_add_property'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Property', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: pad, vertical: h * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Portfolio', style: TextStyle(fontSize: w * 0.06, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/landlord_reports_analytics'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        const Icon(Icons.bar_chart_rounded, color: AppColors.white, size: 16),
                        SizedBox(width: w * 0.015),
                        Text('Reports', style: TextStyle(fontSize: w * 0.028, fontWeight: FontWeight.w600, color: AppColors.white)),
                      ]),
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.02),
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search properties, areas...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
                  fillColor: AppColors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: h * 0.02),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _filterTab('All', state.properties.length, null, w),
                  const SizedBox(width: 8),
                  _filterTab('Pending', pendingCount, AppColors.secondary, w),
                  const SizedBox(width: 8),
                  _filterTab('Approved', approvedCount, Colors.green, w),
                  const SizedBox(width: 8),
                  _filterTab('Rejected', rejectedCount, AppColors.error, w),
                ]),
              ),
              SizedBox(height: h * 0.025),
              if (state.isLoading)
                const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 48), child: CircularProgressIndicator()))
              else if (filteredProperties.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: h * 0.05),
                    child: Column(children: [
                      const Icon(Icons.home_work_outlined, size: 48, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text(_selectedTab == 'All' ? 'No properties found' : 'No $_selectedTab properties',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      const Text('Tap \'+Add Property\' below to get started.',
                          style: TextStyle(fontSize: 12, color: AppColors.textHint), textAlign: TextAlign.center),
                    ]),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredProperties.length,
                  separatorBuilder: (_, __) => SizedBox(height: h * 0.025),
                  itemBuilder: (context, index) {
                    final prop = filteredProperties[index];
                    final aColor = _approvalColor(prop.verificationStatus);
                    final aLabel = _approvalLabel(prop.verificationStatus);
                    final aIcon  = _approvalIcon(prop.verificationStatus);
                    return GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/landlord_property_details', arguments: prop),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                child: Container(
                                  width: double.infinity,
                                  height: h * 0.22,
                                  decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(prop.imageUrl), fit: BoxFit.cover)),
                                ),
                              ),
                              Positioned(
                                top: 12, left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(10)),
                                  child: Text('${(prop.occupancyRate * 100).toInt()}% Occupied',
                                      style: TextStyle(fontSize: w * 0.028, fontWeight: FontWeight.w600, color: AppColors.white)),
                                ),
                              ),
                              Positioned(
                                top: 12, right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: aColor.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(10)),
                                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                                    Icon(aIcon, size: 12, color: AppColors.white),
                                    const SizedBox(width: 4),
                                    Text(aLabel, style: TextStyle(fontSize: w * 0.028, fontWeight: FontWeight.w700, color: AppColors.white)),
                                  ]),
                                ),
                              ),
                            ]),
                            Padding(
                              padding: EdgeInsets.all(w * 0.04),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(prop.name, style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                                    Text('\$${prop.monthlyRent.toStringAsFixed(0)}/mo', style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                                  ],
                                ),
                                SizedBox(height: h * 0.005),
                                Text(prop.address, style: TextStyle(fontSize: w * 0.03, color: AppColors.textSecondary)),
                                if (prop.verificationStatus == 'rejected' && (prop.rejectionReason?.isNotEmpty ?? false)) ...[
                                  SizedBox(height: h * 0.01),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(alpha: 0.07),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                                    ),
                                    child: Row(children: [
                                      const Icon(Icons.info_outline_rounded, size: 13, color: AppColors.error),
                                      const SizedBox(width: 6),
                                      Expanded(child: Text(prop.rejectionReason!, style: TextStyle(fontSize: w * 0.028, color: AppColors.error))),
                                    ]),
                                  ),
                                ],
                                Divider(height: h * 0.02, color: AppColors.border),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Units: ${prop.totalUnits}  |  Vacant: ${prop.vacantUnits}',
                                        style: TextStyle(fontSize: w * 0.03, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                    const Row(children: [
                                      Text('Manage', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                      Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                                    ]),
                                  ],
                                ),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              SizedBox(height: h * 0.03),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(w * 0.05),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF1B3D6B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.insights_rounded, color: AppColors.white, size: 24),
                  ),
                  SizedBox(width: w * 0.04),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Portfolio Insight', style: TextStyle(fontSize: w * 0.038, fontWeight: FontWeight.w700, color: AppColors.white)),
                      const SizedBox(height: 2),
                      Builder(builder: (context) {
                        final total = state.properties.fold<int>(0, (s, p) => s + p.totalUnits);
                        final occ = '${(state.occupancyRate * 100).toInt()}%';
                        return Text('Average occupancy across $total units is $occ.',
                            style: TextStyle(fontSize: w * 0.03, color: AppColors.white.withValues(alpha: 0.8), height: 1.4));
                      }),
                    ]),
                  ),
                ]),
              ),
              SizedBox(height: h * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterTab(String label, int count, Color? color, double w) {
    final isSelected = _selectedTab == label;
    final activeColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? activeColor : AppColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: TextStyle(fontSize: w * 0.032, fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.textPrimary)),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.white.withValues(alpha: 0.25) : (color ?? AppColors.primary).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$count', style: TextStyle(
                fontSize: w * 0.025, fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.white : (color ?? AppColors.primary),
              )),
            ),
          ],
        ]),
      ),
    );
  }
}
