import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class LmsCoursesScreen extends StatelessWidget {
  const LmsCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Academy & LMS', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Recommended Courses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildCourseCard(
            context,
            title: 'Property Management 101',
            category: 'Basics',
            duration: '2h 15m',
            progress: 0.6,
            imageUrl: 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=300&q=80',
          ),
          const SizedBox(height: 16),
          _buildCourseCard(
            context,
            title: 'Legal Compliance in Rentals',
            category: 'Legal',
            duration: '1h 45m',
            progress: 0.0,
            imageUrl: 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=300&q=80',
          ),
          const SizedBox(height: 16),
          _buildCourseCard(
            context,
            title: 'Advanced Tenant Screening',
            category: 'Screening',
            duration: '45m',
            progress: 1.0,
            imageUrl: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=300&q=80',
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, {required String title, required String category, required String duration, required double progress, required String imageUrl}) {
    return InkWell(
      onTap: () {
        if (progress == 1.0) {
          Navigator.pushNamed(context, '/lms_quiz');
        } else {
          Navigator.pushNamed(context, '/lms_lesson');
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(imageUrl, height: 140, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                      Text(duration, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Progress', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.scaffoldBg,
                      color: progress == 1.0 ? Colors.green : AppColors.primary,
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
