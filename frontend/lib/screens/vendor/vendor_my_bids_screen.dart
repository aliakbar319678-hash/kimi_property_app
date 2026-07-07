import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/vendor_provider.dart';
import 'package:tenant_and_landlord_application/provider/vendor_state.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_appbar.dart';

class VendorMyBidsScreen extends ConsumerStatefulWidget {
  const VendorMyBidsScreen({super.key});

  @override
  ConsumerState<VendorMyBidsScreen> createState() => _VendorMyBidsScreenState();
}

class _VendorMyBidsScreenState extends ConsumerState<VendorMyBidsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vendorProvider);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    // Filter bids
    final pendingBids = state.bids.where((b) => b.status == 'Pending').toList();
    final acceptedBids = state.bids.where((b) => b.status == 'Accepted').toList();
    final rejectedBids = state.bids.where((b) => b.status == 'Rejected').toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const TLAppBar(
        subtitle: 'My Bids',
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tab Row
            Container(
              color: AppColors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.secondary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textHint,
                labelStyle: TextStyle(
                  fontSize: w * 0.035,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: w * 0.035,
                  fontWeight: FontWeight.normal,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Pending'),
                        const SizedBox(width: 4),
                        _buildBadge(pendingBids.length, AppColors.secondary, w),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Accepted'),
                        const SizedBox(width: 4),
                        _buildBadge(acceptedBids.length, const Color(0xFF2E7D32), w),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Rejected'),
                        const SizedBox(width: 4),
                        _buildBadge(rejectedBids.length, AppColors.error, w),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab View content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Pending list
                  pendingBids.isEmpty
                      ? _buildEmptyState('No pending bids. Go to Find Jobs to submit a proposal!', w)
                      : ListView.builder(
                          padding: EdgeInsets.all(pad),
                          itemCount: pendingBids.length,
                          itemBuilder: (context, index) => _buildBidCard(pendingBids[index], w, h),
                        ),
                  // Accepted list
                  acceptedBids.isEmpty
                      ? _buildEmptyState('No accepted bids at the moment.', w)
                      : ListView.builder(
                          padding: EdgeInsets.all(pad),
                          itemCount: acceptedBids.length,
                          itemBuilder: (context, index) => _buildBidCard(acceptedBids[index], w, h),
                        ),
                  // Rejected list
                  rejectedBids.isEmpty
                      ? _buildEmptyState('No rejected bids in history.', w)
                      : ListView.builder(
                          padding: EdgeInsets.all(pad),
                          itemCount: rejectedBids.length,
                          itemBuilder: (context, index) => _buildBidCard(rejectedBids[index], w, h),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(int count, Color color, double w) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          color: color,
          fontSize: w * 0.024,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String text, double w) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.gavel_rounded, color: AppColors.textHint, size: w * 0.15),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: w * 0.035,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidCard(VendorBid bid, double w, double h) {
    Color statusColor;
    switch (bid.status) {
      case 'Accepted':
        statusColor = const Color(0xFF2E7D32);
        break;
      case 'Rejected':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.secondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(w * 0.045),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Job Title & Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  bid.title,
                  style: TextStyle(
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bid.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: w * 0.026,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.005),
          Text(
            'Submitted: ${bid.dateSubmitted}',
            style: TextStyle(
              fontSize: w * 0.028,
              color: AppColors.textSecondary,
            ),
          ),
          const Divider(color: AppColors.border, height: 20),
          
          // Bid specs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Proposed Price',
                    style: TextStyle(
                      fontSize: w * 0.028,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${bid.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: w * 0.042,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bid.category,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: w * 0.028,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (bid.scopeChecklist.isNotEmpty) ...[
            Text(
              'Included Scope: ${bid.scopeChecklist.join(', ')}',
              style: TextStyle(
                fontSize: w * 0.03,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Footer action triggers
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (bid.status == 'Pending') ...[
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bid canceled successfully.')),
                    );
                  },
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text('Cancel Bid'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit feature coming soon.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Edit Proposal'),
                ),
              ],
              if (bid.status == 'Accepted') ...[
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to Active Jobs list in the shell
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Open the Jobs tab to find this work order ready for schedule!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today_rounded, size: 14),
                  label: const Text('Go to Active Jobs'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
              if (bid.status == 'Rejected') ...[
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bid proposal removed from view.')),
                    );
                  },
                  style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                  child: const Text('Dismiss'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
