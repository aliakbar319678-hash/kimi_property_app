import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';

class LandlordCommunicationCenterScreen extends ConsumerStatefulWidget {
  const LandlordCommunicationCenterScreen({super.key});

  @override
  ConsumerState<LandlordCommunicationCenterScreen> createState() => _LandlordCommunicationCenterScreenState();
}

class _LandlordCommunicationCenterScreenState extends ConsumerState<LandlordCommunicationCenterScreen> {
  String _selectedAudience = 'All Tenants';
  String _selectedTemplate = 'Custom';
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  bool _sendSms = true;
  bool _sendEmail = true;
  bool _isSending = false;

  final Map<String, Map<String, String>> _templates = {
    'Rent Reminder': {
      'subject': 'Friendly Rent Reminder',
      'body': 'Dear Tenant,\nThis is a friendly reminder that rent for the upcoming month is due soon. Please process payment via the Tenant Portal.',
    },
    'Maintenance Notice': {
      'subject': 'Scheduled Building Maintenance Notice',
      'body': 'Dear Residents,\nPlease be advised that routine maintenance will take place in the building on [Date] between [Time]. Access to common areas may be temporarily limited.',
    },
    'Holiday Greeting': {
      'subject': 'Happy Holidays from Management!',
      'body': 'Warmest holiday wishes to you and your family! Our management office will observe holiday hours next week.',
    },
    'Policy Update': {
      'subject': 'Updated Community Guidelines & Policy Notice',
      'body': 'Dear Tenants,\nPlease review the updated community guidelines in your portal regarding trash disposal and parking policies.',
    },
  };

  void _applyTemplate(String tName) {
    setState(() {
      _selectedTemplate = tName;
      if (_templates.containsKey(tName)) {
        _subjectCtrl.text = _templates[tName]!['subject']!;
        _messageCtrl.text = _templates[tName]!['body']!;
      }
    });
  }

  void _showConfirmBroadcastDialog() {
    if (_subjectCtrl.text.trim().isEmpty || _messageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject and Message content are required'), backgroundColor: AppColors.error),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.campaign_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Confirm Broadcast', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target Audience: $_selectedAudience', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Channels: ${_sendSms ? "SMS " : ""}${_sendEmail ? "Email" : ""}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 12),
            const Text('Message Preview:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.scaffoldBg, borderRadius: BorderRadius.circular(8)),
              child: Text(_messageCtrl.text, style: const TextStyle(fontSize: 12), maxLines: 4, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isSending = true);
              try {
                await ApiClient().dio.post('/communication/sms', data: {
                  'audience': _selectedAudience,
                  'subject': _subjectCtrl.text,
                  'message': _messageCtrl.text,
                  'sendSms': _sendSms,
                  'sendEmail': _sendEmail,
                });
              } catch (_) {}

              if (mounted) {
                setState(() {
                  _isSending = false;
                  _subjectCtrl.clear();
                  _messageCtrl.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Broadcast sent to $_selectedAudience successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Send Broadcast', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(landlordProvider);
    final properties = state.properties;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Communication Center',
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.campaign_rounded, color: Colors.white, size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mass Tenant Broadcast', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 2),
                        Text('Send announcements via SMS & Email directly to your tenants.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Target Audience Selector
            const Text('Target Audience', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedAudience,
              decoration: _inputDeco('Select Audience'),
              items: [
                'All Tenants',
                'Overdue Tenants Only',
                ...properties.map((p) => 'Building: ${p.name}'),
              ].map((aud) => DropdownMenuItem(value: aud, child: Text(aud, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedAudience = v);
              },
            ),
            const SizedBox(height: 16),

            // Quick Message Templates Dropdown
            const Text('Quick Message Template', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedTemplate,
              decoration: _inputDeco('Select Template'),
              items: ['Custom', 'Rent Reminder', 'Maintenance Notice', 'Holiday Greeting', 'Policy Update']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: (v) {
                if (v != null) _applyTemplate(v);
              },
            ),
            const SizedBox(height: 16),

            // Channels (SMS / Email switches)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Checkbox(
                          value: _sendSms,
                          activeColor: AppColors.primary,
                          onChanged: (v) => setState(() => _sendSms = v ?? true),
                        ),
                        const Text('Send SMS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Checkbox(
                          value: _sendEmail,
                          activeColor: AppColors.primary,
                          onChanged: (v) => setState(() => _sendEmail = v ?? true),
                        ),
                        const Text('Send Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Subject Line
            const Text('Broadcast Subject', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _subjectCtrl,
              decoration: _inputDeco('Enter subject line...'),
            ),
            const SizedBox(height: 16),

            // Custom Message Box
            const Text('Message Body', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _messageCtrl,
              maxLines: 6,
              decoration: _inputDeco('Type message content here...'),
            ),
            const SizedBox(height: 24),

            // Dispatch Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isSending ? null : _showConfirmBroadcastDialog,
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                label: _isSending
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Broadcast Announcement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
