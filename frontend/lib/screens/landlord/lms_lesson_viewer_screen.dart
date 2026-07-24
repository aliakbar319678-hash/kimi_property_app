import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class LmsLessonViewerScreen extends StatelessWidget {
  const LmsLessonViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Lesson 1: Introduction', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Placeholder
            Container(
              height: 220,
              width: double.infinity,
              color: Colors.black87,
              child: const Center(
                child: Icon(Icons.play_circle_fill_rounded, size: 64, color: Colors.white70),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Understanding Property Management Basics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome to the first lesson of Property Management 101. In this lesson, we will cover the fundamental principles of managing a residential property.\n\nFirst, you must understand your local laws regarding tenant rights and landlord responsibilities. Ensuring compliance is the most important step before leasing out any unit.\n\nSecondly, establishing a clear line of communication with your tenants can resolve 90% of issues before they become major problems. Always document your interactions and maintain a professional tone.',
                    style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.textSecondary),
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
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lesson marked as complete!')));
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                      label: const Text('Mark as Complete', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
