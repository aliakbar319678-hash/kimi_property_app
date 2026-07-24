import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class LmsQuizCertificateScreen extends StatefulWidget {
  const LmsQuizCertificateScreen({super.key});

  @override
  State<LmsQuizCertificateScreen> createState() => _LmsQuizCertificateScreenState();
}

class _LmsQuizCertificateScreenState extends State<LmsQuizCertificateScreen> {
  bool _quizCompleted = false;
  int _selectedAnswer = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(_quizCompleted ? 'Certificate' : 'Course Quiz', style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _quizCompleted ? _buildCertificate() : _buildQuiz(),
    );
  }

  Widget _buildQuiz() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Question 1 of 5', style: TextStyle(fontSize: 14, color: AppColors.textHint, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          const Text('What is the maximum allowed time to return a security deposit in most jurisdictions?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 24),
          _buildQuizOption(0, '14 Days'),
          _buildQuizOption(1, '30 Days'),
          _buildQuizOption(2, '60 Days'),
          _buildQuizOption(3, 'It varies, but typically 14-30 days.'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedAnswer != -1 ? AppColors.primary : AppColors.border,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (_selectedAnswer != -1) {
                  setState(() => _quizCompleted = true);
                }
              },
              child: const Text('Submit Answer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuizOption(int index, String text) {
    final isSelected = _selectedAnswer == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedAnswer = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.white,
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? AppColors.primary : AppColors.textHint),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: AppColors.textPrimary))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificate() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium_rounded, size: 100, color: Colors.amber),
            const SizedBox(height: 24),
            const Text('Congratulations!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            const Text('You have successfully completed\n"Property Management 101"', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber, width: 2),
                boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 5)],
              ),
              child: Column(
                children: [
                  const Text('CERTIFICATE OF COMPLETION', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  const Text('Awarded to', style: TextStyle(fontSize: 13, color: AppColors.textHint)),
                  const SizedBox(height: 4),
                  const Text('Jane Doe', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text('Issued on: ${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text('Download Certificate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
