import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/provider/landlord_state.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class LandlordPropertyDetailsScreen extends ConsumerStatefulWidget {
  const LandlordPropertyDetailsScreen({super.key});

  @override
  ConsumerState<LandlordPropertyDetailsScreen> createState() =>
      _LandlordPropertyDetailsScreenState();
}

class _LandlordPropertyDetailsScreenState
    extends ConsumerState<LandlordPropertyDetailsScreen> {
  Property? _property;
  bool _deleteInProgress = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = ref.read(landlordProvider);
    final arg = ModalRoute.of(context)?.settings.arguments;
    _property = (arg is Property)
        ? arg
        : (state.properties.isNotEmpty ? state.properties.first : null);

    // Load real units from the backend
    if (_property != null && _property!.id.isNotEmpty) {
      Future.microtask(
          () => ref.read(landlordProvider.notifier).loadUnits(_property!.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(landlordProvider);
    final notifier = ref.read(landlordProvider.notifier);

    final propertyId = _property?.id;
    final property = propertyId != null 
        ? state.properties.firstWhere((p) => p.id == propertyId, orElse: () => _property!) 
        : null;

    if (property == null) {
      return const Scaffold(
        body: Center(child: Text('No property found')),
      );
    }

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
            // ─── Banner Image & Header Overlay ────────────────────────────
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: h * 0.35,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    image: property.imageUrl.startsWith('http')
                        ? DecorationImage(
                            image: NetworkImage(property.imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: !property.imageUrl.startsWith('http')
                      ? Center(
                          child: Icon(Icons.apartment_rounded, size: 72, color: AppColors.white.withValues(alpha: 0.5)),
                        )
                      : null,
                ),
                Container(
                  width: double.infinity,
                  height: h * 0.35,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withValues(alpha: 0.45), Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back
                        _circleBtn(Icons.arrow_back_rounded, () => Navigator.pop(context)),
                        Text(
                          property.name,
                          style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.w700, color: AppColors.white),
                        ),
                        // More options → delete
                        PopupMenuButton<String>(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
                          ),
                          onSelected: (v) async {
                            if (v == 'delete') {
                              final messenger = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(context);
                              _confirmDelete(context, notifier, property, messenger, navigator);
                            } else if (v == 'edit') {
                              Navigator.pushNamed(context, '/landlord_edit_property', arguments: property);
                            } else if (v == 'admin_test') {
                              _showAdminTestModal(context, notifier, property);
                            } else if (v == 'change_status') {
                              _showChangeStatusModal(context, notifier, property);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded, color: AppColors.primary, size: 18), SizedBox(width: 8), Text('Edit Property')])),
                            PopupMenuItem(value: 'change_status', child: Row(children: [Icon(Icons.sync_rounded, color: AppColors.primary, size: 18), SizedBox(width: 8), Text('Change Status')])),
                            PopupMenuItem(value: 'admin_test', child: Row(children: [Icon(Icons.admin_panel_settings_rounded, color: Colors.orange, size: 18), SizedBox(width: 8), Text('Admin Review (Test)', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))])),
                            PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_rounded, color: Colors.red, size: 18), SizedBox(width: 8), Text('Delete Property', style: TextStyle(color: Colors.red))])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Occupancy badge
                Positioned(
                  bottom: 20,
                  left: pad,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Occupancy', style: TextStyle(fontSize: w * 0.026, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                        Text('${(property.occupancyRate * 100).toInt()}%', style: TextStyle(fontSize: w * 0.045, color: AppColors.primary, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ─── Content ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & address
                  Text(property.name, style: TextStyle(fontSize: w * 0.06, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  SizedBox(height: h * 0.005),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(child: Text(property.address, style: TextStyle(fontSize: w * 0.032, color: AppColors.textSecondary))),
                    ],
                  ),

                  // Type badge + Approval status chip
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text(property.type.toUpperCase(), style: TextStyle(fontSize: w * 0.025, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.5)),
                      ),
                      const SizedBox(width: 8),
                      _approvalChip(property.verificationStatus, w),
                    ],
                  ),

                  // ── Rejection & Revision callout ────────────
                  if (property.verificationStatus == 'rejected' || property.verificationStatus == 'needs_revision' || property.verificationStatus == 'permanently_rejected') ...[
                    SizedBox(height: h * 0.02),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: property.verificationStatus == 'needs_revision' ? Colors.orange.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: property.verificationStatus == 'needs_revision' ? Colors.orange.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(property.verificationStatus == 'needs_revision' ? Icons.assignment_return_rounded : (property.verificationStatus == 'permanently_rejected' ? Icons.block_rounded : Icons.cancel_rounded), 
                                 color: property.verificationStatus == 'needs_revision' ? Colors.orange.shade800 : AppColors.error, size: 18),
                            const SizedBox(width: 8),
                            Text(property.verificationStatus == 'needs_revision' ? 'Admin Action Required' : (property.verificationStatus == 'permanently_rejected' ? 'Permanently Rejected' : 'Property Rejected'), 
                                 style: TextStyle(fontSize: w * 0.035, fontWeight: FontWeight.w700, color: property.verificationStatus == 'needs_revision' ? Colors.orange.shade800 : AppColors.error)),
                          ]),
                          if (property.resubmissionCount > 0) ...[
                            const SizedBox(height: 4),
                            Text('Resubmission #${property.resubmissionCount}', style: TextStyle(fontSize: w * 0.025, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                          ],
                          if (property.rejectionReason?.isNotEmpty ?? false) ...[
                            const SizedBox(height: 8),
                            Text('Reason: ${property.rejectionReason}', style: TextStyle(fontSize: w * 0.03, color: AppColors.textPrimary, height: 1.4)),
                          ],
                          if (property.requestedDocuments.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Requested Fixes/Documents:', style: TextStyle(fontSize: w * 0.03, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ...property.requestedDocuments.map((doc) => Padding(
                              padding: const EdgeInsets.only(top: 4, left: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(fontSize: 14)),
                                  Expanded(child: Text(doc.toString(), style: TextStyle(fontSize: w * 0.028, color: AppColors.textSecondary))),
                                ],
                              ),
                            )),
                          ],
                          if (property.verificationStatus != 'permanently_rejected') ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    await notifier.resubmitProperty(property.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property resubmitted successfully!'), backgroundColor: Colors.green));
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: property.verificationStatus == 'needs_revision' ? Colors.orange.shade600 : AppColors.error,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                                label: const Text('Quick Resubmit Appeal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                onPressed: () => Navigator.pushNamed(context, '/landlord_edit_property', arguments: property),
                                icon: const Icon(Icons.edit_rounded, color: AppColors.textSecondary, size: 16),
                                label: const Text('Edit Property Details first', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // ── Pending notice ────────────────────────────────────
                  if (property.verificationStatus == 'pending' || property.verificationStatus == 'resubmitted') ...[
                    SizedBox(height: h * 0.02),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.hourglass_empty_rounded, color: AppColors.secondary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(property.verificationStatus == 'resubmitted' ? 'Under Review: Resubmitted for admin approval.' : 'Awaiting admin approval. Tenants cannot see this property until it is approved.', style: TextStyle(fontSize: w * 0.028, color: AppColors.secondary, height: 1.4))),
                      ]),
                    ),
                  ],

                  SizedBox(height: h * 0.03),

                  // ─── Stats Row ─────────────────────────────────────────
                  Row(
                    children: [
                      _statPill(label: 'Total Units', value: '${property.totalUnits}', w: w),
                      _statPill(label: 'Occupied', value: '${property.occupiedUnits}', w: w, color: Colors.green),
                      _statPill(label: 'Vacant', value: '${property.vacantUnits}', w: w, color: Colors.orange),
                    ],
                  ),

                  SizedBox(height: h * 0.03),

                  // ─── Management Actions ────────────────────────────────
                  Text('Management Actions', style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  SizedBox(height: h * 0.015),
                  Row(
                    children: [
                      _buildActionCard(
                        icon: Icons.add_circle_outline_rounded,
                        label: 'Add Unit',
                        onTap: () => _showAddUnitDialog(context, notifier, property),
                        w: w,
                      ),
                      SizedBox(width: w * 0.03),
                      _buildActionCard(
                        icon: Icons.description_outlined,
                        label: 'Leases',
                        onTap: () => Navigator.pushNamed(context, '/landlord_lease_management'),
                        w: w,
                      ),
                      SizedBox(width: w * 0.03),
                      _buildActionCard(
                        icon: Icons.monetization_on_outlined,
                        label: 'Finance',
                        onTap: () => Navigator.pushNamed(context, '/landlord_financial_overview'),
                        w: w,
                      ),
                    ],
                  ),

                  SizedBox(height: h * 0.035),

                  // ─── Unit Status List ──────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Units', style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      if (state.isUnitsLoading) const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                    ],
                  ),
                  SizedBox(height: h * 0.015),

                  state.isUnitsLoading
                      ? const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                      : state.units.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(w * 0.05),
                              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                              child: Column(
                                children: [
                                  const Icon(Icons.meeting_room_outlined, size: 36, color: AppColors.textHint),
                                  const SizedBox(height: 8),
                                  Text('No units yet. Tap "Add Unit" to create one.', style: TextStyle(fontSize: w * 0.032, color: AppColors.textSecondary), textAlign: TextAlign.center),
                                ],
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.units.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (context, idx) {
                                final unit = state.units[idx];
                                Color badgeColor;
                                switch (unit.status.toLowerCase()) {
                                  case 'occupied': badgeColor = Colors.green; break;
                                  case 'vacant': badgeColor = Colors.orange; break;
                                  case 'maintenance': badgeColor = AppColors.error; break;
                                  default: badgeColor = AppColors.secondary;
                                }
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 14),
                                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(color: AppColors.scaffoldBg, borderRadius: BorderRadius.circular(12)),
                                            child: const Icon(Icons.meeting_room_rounded, color: AppColors.primary),
                                          ),
                                          SizedBox(width: w * 0.03),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(unit.name, style: TextStyle(fontSize: w * 0.038, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                              const SizedBox(height: 2),
                                              Text(
                                                unit.status.toLowerCase() == 'occupied' ? unit.tenantName : 'Available',
                                                style: TextStyle(fontSize: w * 0.03, color: AppColors.textSecondary),
                                              ),
                                              if (unit.bedrooms > 0 || unit.bathrooms > 0) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${unit.bedrooms > 0 ? "${unit.bedrooms}bd" : ""}${unit.bedrooms > 0 && unit.bathrooms > 0 ? " • " : ""}${unit.bathrooms > 0 ? "${unit.bathrooms}ba" : ""}${unit.squareFeet > 0 ? " • ${unit.squareFeet}sqft" : ""}',
                                                  style: TextStyle(fontSize: w * 0.026, color: AppColors.textHint),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                                                child: Text(unit.status, style: TextStyle(fontSize: w * 0.028, fontWeight: FontWeight.w700, color: badgeColor)),
                                              ),
                                              if (unit.rent > 0) ...[
                                                const SizedBox(height: 4),
                                                Text('\$${unit.rent.toStringAsFixed(0)}/mo', style: TextStyle(fontSize: w * 0.028, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(width: 6),
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textSecondary),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onSelected: (v) {
                                              if (v == 'edit') {
                                                _showEditUnitDialog(context, notifier, property, unit);
                                              } else if (v == 'delete') {
                                                _confirmDeleteUnit(context, notifier, property, unit);
                                              }
                                            },
                                            itemBuilder: (_) => const [
                                              PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, color: AppColors.primary, size: 18), SizedBox(width: 8), Text('Edit Unit')])),
                                              PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18), SizedBox(width: 8), Text('Delete Unit', style: TextStyle(color: Colors.red))])),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                  SizedBox(height: h * 0.035),

                  // ─── Amenities ─────────────────────────────────────────
                  if (property.amenities.isNotEmpty) ...[
                    Text('Amenities', style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    SizedBox(height: h * 0.015),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: property.amenities.map((a) => _buildAmenityChip(a, w)).toList(),
                    ),
                    SizedBox(height: h * 0.02),
                  ],

                  // ─── Description ───────────────────────────────────────
                  if (property.description.isNotEmpty) ...[
                    Text('Description', style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    SizedBox(height: h * 0.010),
                    Text(property.description, style: TextStyle(fontSize: w * 0.032, color: AppColors.textSecondary, height: 1.5)),
                    SizedBox(height: h * 0.02),
                  ],

                  SizedBox(height: h * 0.04),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.textPrimary),
        ),
      );

  Widget _statPill({required String label, required String value, required double w, Color? color}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.w800, color: color ?? AppColors.primary)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: w * 0.025, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({required IconData icon, required String label, required VoidCallback onTap, required double w}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: w * 0.03, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmenityChip(String name, double w) {
    final amenityIcons = <String, IconData>{
      'parking': Icons.local_parking_rounded, 'gym': Icons.fitness_center_rounded, 'pool': Icons.pool_rounded, 'wifi': Icons.wifi_rounded,
      'ac': Icons.ac_unit_rounded, 'laundry': Icons.local_laundry_service_rounded, 'security': Icons.security_rounded, 'elevator': Icons.elevator_rounded,
      'pet_friendly': Icons.pets_rounded, 'furnished': Icons.chair_rounded, 'balcony': Icons.balcony_rounded, 'storage': Icons.storage_rounded,
    };
    final icon = amenityIcons[name.toLowerCase()] ?? Icons.check_circle_outline_rounded;
    final displayName = name.replaceAll('_', ' ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: AppColors.border)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.secondary, size: 16),
          const SizedBox(width: 6),
          Text(displayName, style: TextStyle(fontSize: w * 0.03, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  // ─── Approval chip helper ─────────────────────────────────────────────────
  Widget _approvalChip(String status, double w) {
    Color color;
    IconData icon;
    String label;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        icon = Icons.verified_rounded;
        label = 'Approved';
        break;
      case 'rejected':
        color = AppColors.error;
        icon = Icons.cancel_rounded;
        label = 'Rejected';
        break;
      case 'needs_revision':
      case 'resubmitted':
        color = Colors.orange;
        icon = Icons.assignment_return_rounded;
        label = status.toLowerCase() == 'resubmitted' ? 'Resubmitted' : 'Needs Revision';
        break;
      case 'permanently_rejected':
        color = AppColors.error;
        icon = Icons.block_rounded;
        label = 'Permanently Rejected';
        break;
      default:
        color = AppColors.secondary;
        icon = Icons.hourglass_empty_rounded;
        label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: w * 0.025, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }

  // ─── Edit & Resubmit Sheet ────────────────────────────────────────────────
  // ignore: unused_element
  void _showEditResubmitSheet(BuildContext context, LandlordNotifier notifier, Property property) {
    final nameCtrl = TextEditingController(text: property.name);
    final descCtrl = TextEditingController(text: property.description);
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                const Text('Edit & Resubmit Property', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                const Text('Fix the issues below and tap Resubmit. Your property will go back to Pending review.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 20),

                const Text('Property Name *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(controller: nameCtrl, decoration: _deco('e.g. Sunset Apartments')),
                const SizedBox(height: 14),

                const Text('Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(controller: descCtrl, maxLines: 3, decoration: _deco('Describe your property...')),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      if (nameCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property name is required'), backgroundColor: AppColors.error));
                        return;
                      }
                      setSheetState(() => isLoading = true);
                      try {
                        await notifier.updateProperty(property.id, {
                          'name': nameCtrl.text.trim(),
                          if (descCtrl.text.trim().isNotEmpty) 'description': descCtrl.text.trim(),
                          'verificationStatus': 'pending',
                        });
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Property resubmitted for review ✅'),
                            backgroundColor: Color(0xFF27AE60),
                          ));
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
                        }
                      } finally {
                        if (ctx.mounted) setSheetState(() => isLoading = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: isLoading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('Resubmit for Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, LandlordNotifier notifier, Property property,
      [ScaffoldMessengerState? messenger, NavigatorState? navigator]) {
    final preMessenger = messenger ?? ScaffoldMessenger.of(context);
    final preNavigator = navigator ?? Navigator.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Property', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete "${property.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => preNavigator.pop(), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              preNavigator.pop(); // close dialog
              setState(() => _deleteInProgress = true);
              try {
                await notifier.deleteProperty(property.id);
                if (mounted) {
                  preMessenger.showSnackBar(const SnackBar(content: Text('Property deleted.'), backgroundColor: Color(0xFF27AE60)));
                  preNavigator.pop(); // go back to portfolio
                }
              } catch (e) {
                if (mounted) {
                  preMessenger.showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
                }
              } finally {
                if (mounted) setState(() => _deleteInProgress = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: _deleteInProgress ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddUnitDialog(BuildContext context, LandlordNotifier notifier, Property property) {
    final unitNumCtrl = TextEditingController();
    final rentCtrl = TextEditingController();
    final depositCtrl = TextEditingController();
    final bedsCtrl = TextEditingController();
    final bathsCtrl = TextEditingController();
    final sqftCtrl = TextEditingController();
    String status = 'vacant';
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                const Text('Add New Unit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 16),

                const Text('Unit Number *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(controller: unitNumCtrl, decoration: _deco('e.g. Unit 101 or Apt A')),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Monthly Rent (\$) *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6), TextField(controller: rentCtrl, keyboardType: TextInputType.number, decoration: _deco('1500'))])),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Deposit (\$)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6), TextField(controller: depositCtrl, keyboardType: TextInputType.number, decoration: _deco('3000'))])),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Beds', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6), TextField(controller: bedsCtrl, keyboardType: TextInputType.number, decoration: _deco('0'))])),
                    const SizedBox(width: 8),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Baths', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6), TextField(controller: bathsCtrl, keyboardType: TextInputType.number, decoration: _deco('0'))])),
                    const SizedBox(width: 8),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Sq.Ft.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6), TextField(controller: sqftCtrl, keyboardType: TextInputType.number, decoration: _deco('0'))])),
                  ],
                ),
                const SizedBox(height: 12),

                const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: _deco(''),
                  items: const [
                    DropdownMenuItem(value: 'vacant', child: Text('Vacant')),
                    DropdownMenuItem(value: 'occupied', child: Text('Occupied')),
                    DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                  ],
                  onChanged: (v) => setSheetState(() => status = v ?? 'vacant'),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (unitNumCtrl.text.trim().isEmpty || rentCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unit number and rent are required'), backgroundColor: AppColors.error));
                              return;
                            }
                            setSheetState(() => isLoading = true);
                            try {
                              final unit = Unit(
                                id: '',
                                name: unitNumCtrl.text.trim(),
                                status: status,
                                tenantName: '',
                                rent: double.tryParse(rentCtrl.text.trim()) ?? 0.0,
                                amenities: [],
                                bedrooms: int.tryParse(bedsCtrl.text.trim()) ?? 0,
                                bathrooms: int.tryParse(bathsCtrl.text.trim()) ?? 0,
                                squareFeet: int.tryParse(sqftCtrl.text.trim()) ?? 0,
                                depositAmount: double.tryParse(depositCtrl.text.trim()) ?? 0.0,
                              );
                              await notifier.addUnit(property.id, unit);
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unit added successfully! ✅'), backgroundColor: Color(0xFF27AE60)));
                              }
                            } catch (e) {
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
                              }
                            } finally {
                              if (ctx.mounted) setSheetState(() => isLoading = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: isLoading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('Add Unit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _deco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
        filled: true,
        fillColor: AppColors.scaffoldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      );

  void _showEditUnitDialog(BuildContext context, LandlordNotifier notifier, Property property, Unit unit) {
    final unitNumCtrl = TextEditingController(text: unit.name);
    final rentCtrl = TextEditingController(text: unit.rent > 0 ? unit.rent.toStringAsFixed(0) : '');
    final depositCtrl = TextEditingController(text: unit.depositAmount > 0 ? unit.depositAmount.toStringAsFixed(0) : '');
    final bedsCtrl = TextEditingController(text: unit.bedrooms > 0 ? unit.bedrooms.toString() : '');
    final bathsCtrl = TextEditingController(text: unit.bathrooms > 0 ? unit.bathrooms.toString() : '');
    final sqftCtrl = TextEditingController(text: unit.squareFeet > 0 ? unit.squareFeet.toString() : '');
    String status = unit.status.toLowerCase();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Text('Edit Unit - ${unit.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 16),

                const Text('Unit Number *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(controller: unitNumCtrl, decoration: _deco('e.g. Unit 101 or Apt A')),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Monthly Rent (\$) *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6), TextField(controller: rentCtrl, keyboardType: TextInputType.number, decoration: _deco('1500'))])),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Deposit (\$)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6), TextField(controller: depositCtrl, keyboardType: TextInputType.number, decoration: _deco('3000'))])),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Beds', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6), TextField(controller: bedsCtrl, keyboardType: TextInputType.number, decoration: _deco('0'))])),
                    const SizedBox(width: 8),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Baths', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6), TextField(controller: bathsCtrl, keyboardType: TextInputType.number, decoration: _deco('0'))])),
                    const SizedBox(width: 8),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Sq.Ft.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 6), TextField(controller: sqftCtrl, keyboardType: TextInputType.number, decoration: _deco('0'))])),
                  ],
                ),
                const SizedBox(height: 12),

                const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: ['vacant', 'occupied', 'maintenance', 'reserved'].contains(status) ? status : 'vacant',
                  decoration: _deco(''),
                  items: const [
                    DropdownMenuItem(value: 'vacant', child: Text('Vacant')),
                    DropdownMenuItem(value: 'occupied', child: Text('Occupied')),
                    DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                    DropdownMenuItem(value: 'reserved', child: Text('Reserved')),
                  ],
                  onChanged: (v) => setSheetState(() => status = v ?? 'vacant'),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (unitNumCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unit number is required'), backgroundColor: AppColors.error));
                              return;
                            }
                            setSheetState(() => isLoading = true);
                            try {
                              final data = <String, dynamic>{
                                'unitNumber': unitNumCtrl.text.trim(),
                                if (rentCtrl.text.trim().isNotEmpty) 'rentAmount': double.tryParse(rentCtrl.text.trim()) ?? 0.0,
                                if (depositCtrl.text.trim().isNotEmpty) 'depositAmount': double.tryParse(depositCtrl.text.trim()) ?? 0.0,
                                if (bedsCtrl.text.trim().isNotEmpty) 'bedrooms': int.tryParse(bedsCtrl.text.trim()) ?? 0,
                                if (bathsCtrl.text.trim().isNotEmpty) 'bathrooms': int.tryParse(bathsCtrl.text.trim()) ?? 0,
                                if (sqftCtrl.text.trim().isNotEmpty) 'squareFeet': int.tryParse(sqftCtrl.text.trim()) ?? 0,
                                'status': status,
                              };
                              await notifier.updateUnit(property.id, unit.id, data);
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unit updated successfully! ✅'), backgroundColor: Color(0xFF27AE60)));
                              }
                            } catch (e) {
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
                              }
                            } finally {
                              if (ctx.mounted) setSheetState(() => isLoading = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: isLoading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('Save Unit Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteUnit(BuildContext context, LandlordNotifier notifier, Property property, Unit unit) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Unit', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete "${unit.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                await notifier.deleteUnit(property.id, unit.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unit deleted successfully.'), backgroundColor: Color(0xFF27AE60)));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting unit: $e'), backgroundColor: AppColors.error));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── Admin Test Modal ───────────────────────────────────────────────────
  void _showAdminTestModal(BuildContext context, LandlordNotifier notifier, Property property) {
    final reasonCtrl = TextEditingController();
    final docsCtrl = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Icon(Icons.admin_panel_settings_rounded, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Admin Review (Test)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Simulate admin actions for the approval workflow.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 24),

                const Text('Rejection / Revision Reason', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(controller: reasonCtrl, decoration: _deco('e.g. Blurry images')),
                const SizedBox(height: 14),

                const Text('Requested Documents (JSON array)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(controller: docsCtrl, decoration: _deco('e.g. ["Title Deed", "Utility Bill"]')),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          setSheetState(() => isLoading = true);
                          try {
                            await notifier.adminApproveProperty(property.id);
                            if (ctx.mounted) Navigator.pop(ctx);
                          } catch (e) {
                            if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
                          }
                          if (ctx.mounted) setSheetState(() => isLoading = false);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Approve', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          setSheetState(() => isLoading = true);
                          try {
                            List<String> parsedDocs = [];
                            try {
                              if (docsCtrl.text.isNotEmpty) {
                                final decoded = jsonDecode(docsCtrl.text);
                                if (decoded is List) {
                                  parsedDocs = decoded.map((e) => e.toString()).toList();
                                }
                              }
                            } catch (_) { }
                            await notifier.adminRequestRevision(property.id, reasonCtrl.text, parsedDocs);
                            if (ctx.mounted) Navigator.pop(ctx);
                          } catch (e) {
                            if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
                          }
                          if (ctx.mounted) setSheetState(() => isLoading = false);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        child: const Text('Req Revision', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      setSheetState(() => isLoading = true);
                      try {
                        await notifier.adminPermanentReject(property.id, reasonCtrl.text);
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
                      }
                      if (ctx.mounted) setSheetState(() => isLoading = false);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                    child: const Text('Permanently Reject', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _showChangeStatusModal(BuildContext context, LandlordNotifier notifier, Property property) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Change Property Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...['available', 'rented', 'maintenance', 'archived'].map((status) {
                return ListTile(
                  title: Text(status.toUpperCase(), style: TextStyle(fontWeight: property.status == status ? FontWeight.bold : FontWeight.normal)),
                  trailing: property.status == status ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await notifier.updateProperty(property.id, {'status': status});
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $status'), backgroundColor: Colors.green));
                    }
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
