import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';

class VerificationRejectedScreen extends StatefulWidget {
  const VerificationRejectedScreen({super.key});

  @override
  State<VerificationRejectedScreen> createState() => _VerificationRejectedScreenState();
}

class _VerificationRejectedScreenState extends State<VerificationRejectedScreen> {
  bool _isFetchingReason = true;
  String? _rejectionReason;

  @override
  void initState() {
    super.initState();
    _fetchRejectionReason();
  }

  /// Fetch the real admin-provided rejection reason from the server
  Future<void> _fetchRejectionReason() async {
    try {
      final res = await ApiClient().dio.get(ApiConstants.me);
      if (res.statusCode == 200) {
        final data = res.data['data'];
        final reason = data['rejection_reason'] as String?;
        if (mounted) {
          setState(() {
            _rejectionReason = (reason != null && reason.isNotEmpty) ? reason : null;
            _isFetchingReason = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isFetchingReason = false);
    }
  }

  void _openResubmitModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResubmitSheet(
        rejectionReason: _rejectionReason,
        onSuccess: () {
          Navigator.pushReplacementNamed(context, '/account_status');
        },
      ),
    );
  }

  /// Properly clear token and navigate to login
  Future<void> _handleLogout() async {
    await ApiClient().clearToken();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 90,
              ),
              const SizedBox(height: 24),
              const Text(
                'Verification Rejected',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your verification request was rejected by the admin. Please review the reason below and upload the corrected documents/photos.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // ── Rejection Reason Box ───────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                ),
                child: _isFetchingReason
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline, color: AppColors.error, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _rejectionReason != null
                                    ? 'Rejection Reason:'
                                    : 'Note:',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _rejectionReason ??
                                'Ensure your legal name matches your ID exactly and the uploaded documents are clear and legible.',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.error,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 36),

              // ── Resubmit Button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _openResubmitModal,
                  icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  label: const Text(
                    'Resubmit Documents / Photo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/support_chat'),
                  icon: const Icon(Icons.headset_mic_rounded,
                      size: 20, color: AppColors.secondary),
                  label: const Text(
                    'Contact Support',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: AppColors.secondary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Log Out Button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _handleLogout,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Resubmit Documents & Photo Sheet ──────────────────────────────────────────
class _ResubmitSheet extends StatefulWidget {
  final String? rejectionReason;
  final VoidCallback onSuccess;
  const _ResubmitSheet({this.rejectionReason, required this.onSuccess});

  @override
  State<_ResubmitSheet> createState() => _ResubmitSheetState();
}

class _ResubmitSheetState extends State<_ResubmitSheet> {
  File? _selectedDoc;
  File? _selectedPhoto;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickDocument() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      setState(() => _selectedDoc = File(file.path));
    }
  }

  Future<void> _capturePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (photo != null) {
      setState(() => _selectedPhoto = File(photo.path));
    }
  }

  Future<void> _submitResubmission() async {
    if (_selectedDoc == null && _selectedPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a document or capture a photo to resubmit.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. Upload files if present
      if (_selectedDoc != null) {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(_selectedDoc!.path, filename: 'resubmitted_doc.jpg'),
        });
        await ApiClient().dio.post('/uploads/generic', data: formData);
      }

      if (_selectedPhoto != null) {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(_selectedPhoto!.path, filename: 'resubmitted_photo.jpg'),
        });
        await ApiClient().dio.post('/uploads/generic', data: formData);
      }

      // 2. Update profile / KYC status to reviewing in backend
      try {
        await ApiClient().dio.put(
          ApiConstants.updateProfile,
          data: {
            'kyc_status': 'reviewing',
            'notes': 'Resubmitted updated documents and photos.',
          },
        );
      } catch (_) {}

      if (!mounted) return;
      Navigator.pop(context); // Close sheet
      widget.onSuccess(); // Redirect to /account_status
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resubmission failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 20),
            const Text(
              'Resubmit Required Items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.rejectionReason ?? 'Please upload legibly scanned document or take a live photo.',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // Option 1: Upload Document from Gallery
            const Text('Document Upload (PDF / Gallery)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDocument,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _selectedDoc != null ? AppColors.secondary : AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedDoc != null ? Icons.check_circle_rounded : Icons.photo_library_rounded,
                      color: _selectedDoc != null ? AppColors.secondary : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedDoc != null
                            ? 'Selected: ${_selectedDoc!.path.split('/').last}'
                            : 'Choose Document / Image from Gallery',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _selectedDoc != null ? FontWeight.bold : FontWeight.normal,
                          color: _selectedDoc != null ? AppColors.secondary : AppColors.textHint,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Option 2: Live Camera Photo
            const Text('Live Camera Photo (ID Front / Selfie)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _capturePhoto,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _selectedPhoto != null ? AppColors.secondary : AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedPhoto != null ? Icons.check_circle_rounded : Icons.camera_alt_rounded,
                      color: _selectedPhoto != null ? AppColors.secondary : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedPhoto != null
                            ? 'Captured: ${_selectedPhoto!.path.split('/').last}'
                            : 'Take Photo with Camera',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _selectedPhoto != null ? FontWeight.bold : FontWeight.normal,
                          color: _selectedPhoto != null ? AppColors.secondary : AppColors.textHint,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Resubmission Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _submitResubmission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isUploading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Resubmission',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

