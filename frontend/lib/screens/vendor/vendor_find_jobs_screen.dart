import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/vendor_provider.dart';
import 'package:tenant_and_landlord_application/provider/vendor_state.dart';
import 'package:tenant_and_landlord_application/widgets/common/tl_appbar.dart';

class VendorFindJobsScreen extends ConsumerStatefulWidget {
  const VendorFindJobsScreen({super.key});

  @override
  ConsumerState<VendorFindJobsScreen> createState() =>
      _VendorFindJobsScreenState();
}

class _VendorFindJobsScreenState extends ConsumerState<VendorFindJobsScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vendorProvider);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    // Filters
    final categories = [
      'All',
      'Nearby',
      'Urgent',
      'Plumbing',
      'HVAC',
      'General',
    ];

    // Filter available jobs
    final filteredJobs = state.availableJobs.where((job) {
      // 1. Category Filter
      if (_selectedCategory == 'Plumbing' && job.category != 'Plumbing') {
        return false;
      }
      if (_selectedCategory == 'HVAC' && job.category != 'HVAC') return false;
      if (_selectedCategory == 'General' && job.category != 'General') {
        return false;
      }

      if (_selectedCategory == 'Urgent' &&
          job.priority != 'Emergency' &&
          job.priority != 'High') {
        return false;
      }

      if (_selectedCategory == 'Nearby') {
        // Simulating nearby as jobs within 3 miles (let's say jobs 1 and 2 are nearby)
        if (job.id != 'job_find_1' && job.id != 'job_find_2') return false;
      }

      // 2. Search query filter
      if (_searchQuery.isNotEmpty) {
        final title = job.title.toLowerCase();
        final desc = job.description.toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!title.contains(query) && !desc.contains(query)) return false;
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: TLAppBar(
        title: 'Find Jobs',
        leading: Icon(
          Icons.menu_rounded,
          size: w * 0.065,
          color: AppColors.textPrimary,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input area
            Container(
              color: AppColors.white,
              padding: EdgeInsets.fromLTRB(pad, 12, pad, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search plumbing, electrical, HVAC...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: AppColors.textHint,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  fillColor: AppColors.scaffoldBg,
                  filled: true,
                ),
              ),
            ),

            // Horizontal Categories Scroll
            Container(
              color: AppColors.white,
              height: w * 0.14,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: pad - 6, vertical: 8),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.inputBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textSecondary,
                          fontSize: w * 0.032,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Jobs Count Indicator
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 16, pad, 8),
              child: Text(
                '${filteredJobs.length} Available Jobs',
                style: TextStyle(
                  fontSize: w * 0.034,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // Listings List View
            Expanded(
              child: filteredJobs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            color: AppColors.textHint,
                            size: w * 0.12,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No matching jobs found.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: w * 0.035,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: pad),
                      itemCount: filteredJobs.length,
                      itemBuilder: (context, index) {
                        return _buildAvailableJobCard(
                          filteredJobs[index],
                          w,
                          h,
                          context,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableJobCard(
    VendorWorkOrder job,
    double w,
    double h,
    BuildContext context,
  ) {
    Color priorityColor;
    switch (job.priority) {
      case 'Emergency':
        priorityColor = AppColors.error;
        break;
      case 'High':
        priorityColor = Colors.orange;
        break;
      case 'Medium':
        priorityColor = AppColors.secondary;
        break;
      default:
        priorityColor = Colors.grey;
    }

    // Mock distance for layout representation
    String distanceStr = '1.2 miles away';
    if (job.id == 'job_find_2') distanceStr = '2.5 miles away';
    if (job.id == 'job_find_3') distanceStr = '4.0 miles away';
    if (job.id == 'job_find_4') distanceStr = '8.5 miles away';

    // Budget range mock
    String budgetRange = '\$300 - \$400';
    if (job.id == 'job_find_2') budgetRange = '\$150 - \$250';
    if (job.id == 'job_find_3') budgetRange = '\$800 - \$1,200';
    if (job.id == 'job_find_4') budgetRange = '\$200 - \$300';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(w * 0.045),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: TextStyle(
                    fontSize: w * 0.042,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job.priority,
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: w * 0.026,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.005),
          Text(
            job.propertyName,
            style: TextStyle(
              fontSize: w * 0.03,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            job.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: w * 0.032,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const Divider(color: AppColors.border, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    budgetRange,
                    style: TextStyle(
                      fontSize: w * 0.042,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${job.category} • $distanceStr',
                    style: TextStyle(
                      fontSize: w * 0.028,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/vendor_job_details',
                    arguments: job.id,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(100, 38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: w * 0.03,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
