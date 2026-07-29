import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class DirectCommunicationDialog extends StatefulWidget {
  final String recipientName;

  const DirectCommunicationDialog({super.key, required this.recipientName});

  @override
  State<DirectCommunicationDialog> createState() => _DirectCommunicationDialogState();
}

class _DirectCommunicationDialogState extends State<DirectCommunicationDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _applyTemplate(String title, String body) {
    setState(() {
      _subjectCtrl.text = title;
      _messageCtrl.text = body;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        height: 550,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quick Message', style: AppTextStyles.headlineMedium),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 8),
            Text('To: ${widget.recipientName}', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textHint,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(icon: Icon(Icons.sms), text: 'SMS'),
                Tab(icon: Icon(Icons.email), text: 'Email'),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Templates', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    label: const Text('Payment Reminder'),
                    onPressed: () => _applyTemplate('Rent Reminder', 'Hi ${widget.recipientName}, just a friendly reminder that your rent is due soon. Let us know if you have questions!'),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: const Text('Maintenance Notice'),
                    onPressed: () => _applyTemplate('Maintenance Notice', 'Hi ${widget.recipientName}, we will have maintenance visiting the property tomorrow between 10 AM and 2 PM.'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildForm(showSubject: false),
                  _buildForm(showSubject: true),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message sent successfully!')));
              },
              child: const Text('Send Message', style: AppTextStyles.buttonText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm({required bool showSubject}) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSubject) ...[
            const Text('Subject', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _subjectCtrl,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: 'Enter subject...',
              ),
            ),
            const SizedBox(height: 16),
          ],
          const Text('Message', style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _messageCtrl,
            maxLines: 5,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: 'Type your message here...',
            ),
          ),
        ],
      ),
    );
  }
}
