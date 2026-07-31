import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';
import 'package:tenant_and_landlord_application/widgets/landlord/conditional_approval_dialog.dart';

class LandlordApplicationsScreen extends StatefulWidget {
  const LandlordApplicationsScreen({super.key});

  @override
  State<LandlordApplicationsScreen> createState() => _LandlordApplicationsScreenState();
}

class _LandlordApplicationsScreenState extends State<LandlordApplicationsScreen> {
  bool _isLoading = true;
  List<dynamic> _applications = [];

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    try {
      final response = await ApiClient().dio.get(ApiConstants.applications);
      final data = response.data;
      if (data['success'] == true) {
        if (mounted) {
          setState(() {
            _applications = data['data'] ?? [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateDecision(String appId, String decision, {ConditionalTermsResult? terms}) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      final targetStatus = decision == 'conditional' ? 'conditional_approval' : decision;

      final Map<String, dynamic> body = {'status': targetStatus};
      if (terms != null) {
        body['conditionalTerms'] = {
          'tags': terms.tags,
          'note': terms.note,
        };
      }

      final response = await ApiClient().dio.patch(
        '${ApiConstants.applications}/$appId/status',
        data: body,
      );

      if (mounted) Navigator.pop(context);

      if (response.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Application status updated to $targetStatus')));
        }
        _fetchApplications();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update decision')));
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showActionModal(BuildContext context, Map<String, dynamic> app) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Application Decision',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 15)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _updateDecision(app['id'], 'approved');
                  },
                  child: const Text('Approve & Create Lease',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 15)),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final terms = await ConditionalApprovalDialog.show(context);
                    if (terms != null) {
                      _updateDecision(app['id'], 'conditional', terms: terms);
                    }
                  },
                  child: const Text('Conditional Approval',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _updateDecision(app['id'], 'rejected');
                  },
                  child: const Text('Reject Application',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Keep Pending', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Opens a bottom sheet that navigates directly to the ScreeningDetailScreen
  /// if the application record includes a [screening_application_id] field,
  /// or prompts the landlord to paste a UUID as a stop-gap.
  ///
  /// ⚠️  Backend flag: [GET /applications/landlord] does not JOIN
  /// screening_applications, so no screening_application_id is returned.
  /// The backend team should add this join to remove the manual ID input.
  void _openScreeningReport(BuildContext context, Map<String, dynamic> app) {
    final directId = app['screening_application_id']?.toString() ?? app['id']?.toString() ?? '';
    if (directId.isNotEmpty) {
      Navigator.pushNamed(
        context,
        '/landlord_screening_detail',
        arguments: directId,
      );
      return;
    }

    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person_search_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'View Screening Report',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tenant: ${app['tenant_name'] ?? 'Unknown'}',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFFD97706).withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'Note: The applications list does not yet include the '
                  'screening application ID. Enter the UUID from the '
                  'screening_applications table, or ask the tenant for '
                  'their screening application ID.\n\n'
                  'Backend fix needed: JOIN applications with '
                  'screening_applications on tenant_id + property_id.',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF92400E),
                      height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Screening Application ID (UUID)',
                  hintText: 'e.g. 3fa85f64-5717-4562-b3fc-2c963f66afa6',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.fingerprint_rounded),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Open Screening Report'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final id = controller.text.trim();
                    if (id.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Please enter a screening application ID.'),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    Navigator.pushNamed(
                      context,
                      '/landlord_screening_detail',
                      arguments: id,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'conditional':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Tenant Applications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: w * 0.045,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _applications.isEmpty
              ? Center(
                  child: Text(
                    'No incoming applications.',
                    style: TextStyle(
                        fontSize: w * 0.04, color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(w * 0.05),
                  itemCount: _applications.length,
                  itemBuilder: (context, index) {
                    final app =
                        _applications[index] as Map<String, dynamic>;
                    final statusColor = _getStatusColor(
                        (app['approval_status'] ?? 'pending').toString());
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.only(bottom: w * 0.04),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.all(w * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  app['tenant_name'] ?? 'Unknown Tenant',
                                  style: TextStyle(
                                    fontSize: w * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    (app['approval_status'] ?? 'pending')
                                        .toString()
                                        .toUpperCase(),
                                    style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Property: ${app['property_name']} (Unit ${app['unit_number']})',
                              style: const TextStyle(
                                  color: AppColors.textSecondary),
                            ),
                            Text(
                              'Email: ${app['tenant_email']}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                if (app['approval_status'] == 'pending') ...[
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          _showActionModal(context, app),
                                      child:
                                          const Text('Review Decision'),
                                    ),
                                  ),
                                  SizedBox(width: w * 0.03),
                                ],
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(
                                        Icons.person_search_rounded,
                                        size: 16),
                                    label: const Text('Screening Report'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(
                                          color: AppColors.primary),
                                    ),
                                    onPressed: () =>
                                        _openScreeningReport(context, app),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
