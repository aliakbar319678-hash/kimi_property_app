import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';
import 'package:dio/dio.dart';

class ApplicationCheckoutScreen extends StatefulWidget {
  const ApplicationCheckoutScreen({super.key});

  @override
  State<ApplicationCheckoutScreen> createState() => _ApplicationCheckoutScreenState();
}

class _ApplicationCheckoutScreenState extends State<ApplicationCheckoutScreen> {
  bool _isLoading = false;

  Future<void> _submitApplication() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final propertyId = args?['propertyId'];
      final unitId = args?['unitId'];

      debugPrint('--- Application Submit API Payload ---');
      debugPrint('property_id: $propertyId');
      debugPrint('unit_id: $unitId');
      debugPrint('--------------------------------------');

      await ApiClient().dio.post(
        ApiConstants.applications,
        data: {
          'property_id': propertyId,
          'unit_id': unitId,
        },
      );
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Application Submitted!'),
            content: const Text('Your screening fee of \$50 has been processed. The landlord will review your application soon.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamedAndRemoveUntil(
                    context, 
                    '/my-applications', 
                    (route) => route.isFirst,
                  );
                },
                child: const Text('View My Applications'),
              ),
            ],
          ),
        );
      }
    } on DioException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit application. Please select a valid property and try again.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred. Please try again later.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final pad = w * 0.05;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final propertyName = args?['propertyName'] ?? 'Selected Property';
    final unitName = args?['unitName'] ?? 'Selected Unit';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Application & Screening',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(w * 0.05),
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
                    children: [
                      Container(
                        padding: EdgeInsets.all(w * 0.03),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.apartment_rounded, color: AppColors.primary, size: w * 0.08),
                      ),
                      SizedBox(width: w * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              propertyName,
                              style: TextStyle(
                                fontSize: w * 0.04,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              unitName,
                              style: TextStyle(
                                fontSize: w * 0.035,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: w * 0.05),
                  Divider(color: AppColors.border),
                  SizedBox(height: w * 0.05),
                  Text(
                    'Screening Fee',
                    style: TextStyle(
                      fontSize: w * 0.042,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: w * 0.02),
                  Text(
                    'A non-refundable screening fee is required to process your background and credit check.',
                    style: TextStyle(
                      fontSize: w * 0.035,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: w * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Due:',
                        style: TextStyle(
                          fontSize: w * 0.045,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '\$50.00',
                        style: TextStyle(
                          fontSize: w * 0.055,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: w * 0.06),
            Text(
              'Payment Method',
              style: TextStyle(
                fontSize: w * 0.042,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: w * 0.03),
            Container(
              padding: EdgeInsets.all(w * 0.04),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.credit_card_rounded, color: AppColors.primary, size: w * 0.06),
                  SizedBox(width: w * 0.03),
                  Expanded(
                    child: Text(
                      'Visa ending in 4242',
                      style: TextStyle(
                        fontSize: w * 0.038,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(Icons.check_circle_rounded, color: AppColors.primary, size: w * 0.05),
                ],
              ),
            ),
            SizedBox(height: w * 0.1),
            SizedBox(
              width: double.infinity,
              height: w * 0.14,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Pay \$50 & Submit Application',
                      style: TextStyle(
                        fontSize: w * 0.04,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
