import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';

class TenantApplicationsScreen extends StatefulWidget {
  const TenantApplicationsScreen({super.key});

  @override
  State<TenantApplicationsScreen> createState() => _TenantApplicationsScreenState();
}

class _TenantApplicationsScreenState extends State<TenantApplicationsScreen> {
  bool _isLoading = true;
  List<dynamic> _applications = [];

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    try {
      final response = await ApiClient().dio.get('${ApiConstants.applications}/me');
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
          'My Applications',
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open_rounded, size: w * 0.15, color: AppColors.textHint),
                      SizedBox(height: w * 0.04),
                      Text(
                        'No applications yet.',
                        style: TextStyle(
                          fontSize: w * 0.04,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(w * 0.05),
                  itemCount: _applications.length,
                  itemBuilder: (context, index) {
                    final app = _applications[index];
                    final statusColor = _getStatusColor(app['approval_status']);
                    return Container(
                      margin: EdgeInsets.only(bottom: w * 0.04),
                      padding: EdgeInsets.all(w * 0.04),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                app['property_name'] ?? 'Property',
                                style: TextStyle(
                                  fontSize: w * 0.042,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  (app['approval_status'] ?? 'pending').toUpperCase(),
                                  style: TextStyle(
                                    fontSize: w * 0.028,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: w * 0.02),
                          Text(
                            'Unit: ${app['unit_number'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: w * 0.035,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: w * 0.03),
                          Text(
                            'Applied on: ${app['created_at']?.toString().substring(0, 10) ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: w * 0.032,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
