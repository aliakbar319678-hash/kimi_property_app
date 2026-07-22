import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tenant_and_landlord_application/core/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/applications/landlord'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _applications = data['data'] ?? [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateDecision(String appId, String decision) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token == null) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/applications/$appId/decision'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'approval_status': decision,
        }),
      );

      Navigator.pop(context); // close loader

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Application marked as $decision')));
        _fetchApplications(); // refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update decision')));
      }
    } catch (e) {
      Navigator.pop(context); // close loader
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 15)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _updateDecision(app['id'], 'approved');
                  },
                  child: const Text('Approve & Create Lease', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 15)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _updateDecision(app['id'], 'conditional');
                  },
                  child: const Text('Conditional Approval', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 15)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _updateDecision(app['id'], 'rejected');
                  },
                  child: const Text('Reject Application', style: TextStyle(color: Colors.white, fontSize: 16)),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      case 'conditional': return Colors.orange;
      default: return Colors.blue;
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
                    style: TextStyle(fontSize: w * 0.04, color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(w * 0.05),
                  itemCount: _applications.length,
                  itemBuilder: (context, index) {
                    final app = _applications[index];
                    final statusColor = _getStatusColor(app['approval_status']);
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.only(bottom: w * 0.04),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.all(w * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    (app['approval_status'] ?? 'pending').toUpperCase(),
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Property: ${app['property_name']} (Unit ${app['unit_number']})', style: TextStyle(color: AppColors.textSecondary)),
                            Text('Email: ${app['tenant_email']}', style: TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(height: 12),
                            if (app['approval_status'] == 'pending')
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => _showActionModal(context, app),
                                  child: const Text('Review Decision'),
                                ),
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
