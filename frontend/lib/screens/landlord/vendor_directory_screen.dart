import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';

class LandlordVendorDirectoryScreen extends ConsumerStatefulWidget {
  const LandlordVendorDirectoryScreen({super.key});

  @override
  ConsumerState<LandlordVendorDirectoryScreen> createState() => _LandlordVendorDirectoryScreenState();
}

class _LandlordVendorDirectoryScreenState extends ConsumerState<LandlordVendorDirectoryScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = false;

  List<Map<String, dynamic>> _vendors = [
    {
      'id': 'v-101',
      'name': 'Apex Plumbing Services',
      'category': 'Plumbing',
      'rating': 4.9,
      'completedJobs': 42,
      'phone': '+1 (555) 234-5678',
      'email': 'apex.plumbing@example.com',
      'hourlyRate': 85.00,
    },
    {
      'id': 'v-102',
      'name': 'VoltMasters Electrical',
      'category': 'Electrical',
      'rating': 4.8,
      'completedJobs': 38,
      'phone': '+1 (555) 876-5432',
      'email': 'contact@voltmasters.com',
      'hourlyRate': 95.00,
    },
    {
      'id': 'v-103',
      'name': 'CoolBreeze HVAC Experts',
      'category': 'HVAC',
      'rating': 4.7,
      'completedJobs': 29,
      'phone': '+1 (555) 345-6789',
      'email': 'service@coolbreeze.com',
      'hourlyRate': 105.00,
    },
    {
      'id': 'v-104',
      'name': 'Precision Carpentry & Handyman',
      'category': 'Carpentry',
      'rating': 4.6,
      'completedJobs': 54,
      'phone': '+1 (555) 654-3210',
      'email': 'handyman.precision@example.com',
      'hourlyRate': 70.00,
    },
    {
      'id': 'v-105',
      'name': 'Sparkle Clean Pros',
      'category': 'Cleaning',
      'rating': 4.9,
      'completedJobs': 61,
      'phone': '+1 (555) 987-6543',
      'email': 'info@sparkleclean.com',
      'hourlyRate': 55.00,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchVendorDirectory();
  }

  Future<void> _fetchVendorDirectory() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient().dio.get('/vendor_advanced/directory');
      if (response.data != null && response.data['data'] is List) {
        final List<dynamic> raw = response.data['data'];
        final fetched = raw.map((item) => item as Map<String, dynamic>).toList();
        if (fetched.isNotEmpty && mounted) {
          setState(() {
            _vendors = fetched;
          });
        }
      }
    } catch (_) {
      // Keep rich fallback mock data
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredVendors {
    return _vendors.where((v) {
      final matchesSearch = (v['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (v['category'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || (v['category'] as String).toLowerCase() == _selectedCategory.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _showAddVendorSheet() {
    final nameCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final rateCtrl = TextEditingController();
    String category = 'Plumbing';
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.person_add_rounded, color: AppColors.primary, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Add / Invite Vendor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Vendor Name
                const Text('Vendor / Business Name *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nameCtrl,
                  decoration: _inputDeco('e.g. Master Plumbers Co.'),
                ),
                const SizedBox(height: 14),

                // Trade Category & Hourly Rate
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Trade Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: category,
                            decoration: _inputDeco('Category'),
                            items: const [
                              DropdownMenuItem(value: 'Plumbing', child: Text('Plumbing')),
                              DropdownMenuItem(value: 'Electrical', child: Text('Electrical')),
                              DropdownMenuItem(value: 'HVAC', child: Text('HVAC')),
                              DropdownMenuItem(value: 'Carpentry', child: Text('Carpentry')),
                              DropdownMenuItem(value: 'Cleaning', child: Text('Cleaning')),
                            ],
                            onChanged: (v) {
                              if (v != null) setSheetState(() => category = v);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Agreed Rate (\$/hr)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: rateCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDeco('85.00'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Email / Phone
                const Text('Email or Phone Number *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: contactCtrl,
                  decoration: _inputDeco('vendor@example.com or +1 555-0000'),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isSaving
                        ? null
                        : () async {
                            if (nameCtrl.text.trim().isEmpty || contactCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please fill Vendor Name and Contact Info'), backgroundColor: AppColors.error),
                              );
                              return;
                            }
                            setSheetState(() => isSaving = true);

                            final newVendor = {
                              'id': 'v-${_vendors.length + 101}',
                              'name': nameCtrl.text.trim(),
                              'category': category,
                              'rating': 5.0,
                              'completedJobs': 0,
                              'phone': contactCtrl.text.trim(),
                              'email': contactCtrl.text.trim(),
                              'hourlyRate': double.tryParse(rateCtrl.text) ?? 75.0,
                            };

                            setState(() {
                              _vendors.insert(0, newVendor);
                            });

                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${newVendor['name']} added to vendor directory!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                    child: isSaving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Add Vendor', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
      filled: true,
      fillColor: AppColors.scaffoldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Vendor Directory',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded, color: AppColors.primary),
            onPressed: _showAddVendorSheet,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddVendorSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add Vendor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(w * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search vendors by name or trade...',
                      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Category Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Plumbing', 'Electrical', 'HVAC', 'Carpentry', 'Cleaning'].map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedCategory = cat),
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            backgroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Vendor Cards List
                  _filteredVendors.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                          child: const Column(
                            children: [
                              Icon(Icons.engineering_outlined, size: 40, color: AppColors.textHint),
                              SizedBox(height: 8),
                              Text('No vendors match your search criteria', style: TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredVendors.length,
                          itemBuilder: (ctx, idx) {
                            final vendor = _filteredVendors[idx];
                            final double rating = (vendor['rating'] as num).toDouble();
                            final int jobs = (vendor['completedJobs'] as num).toInt();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(Icons.handyman_rounded, color: AppColors.primary, size: 22),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(vendor['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                                  const SizedBox(height: 2),
                                                  Text(vendor['category'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              rating.toStringAsFixed(1),
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amber),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('$jobs Jobs Completed', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                                      Text('\$${(vendor['hourlyRate'] as num).toStringAsFixed(0)}/hr', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: AppColors.primary),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                          ),
                                          icon: const Icon(Icons.phone_rounded, size: 16, color: AppColors.primary),
                                          label: const Text('Call', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Calling ${vendor['name']} (${vendor['phone']})...')),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                          ),
                                          icon: const Icon(Icons.chat_rounded, size: 16, color: Colors.white),
                                          label: const Text('Message', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                                          onPressed: () {
                                            Navigator.pushNamed(context, '/job_chat_room');
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
