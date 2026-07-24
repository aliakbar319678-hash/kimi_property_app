import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class DiscussionsListScreen extends StatefulWidget {
  const DiscussionsListScreen({super.key});

  @override
  State<DiscussionsListScreen> createState() => _DiscussionsListScreenState();
}

class _DiscussionsListScreenState extends State<DiscussionsListScreen> {
  final List<Map<String, dynamic>> _topics = [
    {
      'id': 'topic-1',
      'title': 'Best local plumbers in Seattle?',
      'category': 'Maintenance',
      'author': 'Sarah Jenkins',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&q=80',
      'time': '2h ago',
      'replies': 14,
    },
    {
      'id': 'topic-2',
      'title': 'Handling pet deposits for new tenants',
      'category': 'Legal',
      'author': 'Mike O\'Connor',
      'avatar': 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=100&q=80',
      'time': '5h ago',
      'replies': 8,
    },
    {
      'id': 'topic-3',
      'title': 'Smart locks vs traditional keys - opinions?',
      'category': 'General',
      'author': 'Elena Rodriguez',
      'avatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&q=80',
      'time': '1d ago',
      'replies': 22,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Community Discussions', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewTopicSheet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Topic', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _topics.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final t = _topics[index];
          final catColor = _getCategoryColor(t['category']);
          return InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/discussion_thread', arguments: t);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t['category'],
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: catColor),
                        ),
                      ),
                      Text(t['time'], style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t['title'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(t['avatar']),
                          ),
                          const SizedBox(width: 8),
                          Text(t['author'], style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text('${t['replies']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        ],
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Maintenance':
        return Colors.orange;
      case 'Legal':
        return Colors.red;
      case 'Financial':
        return Colors.green;
      default:
        return AppColors.secondary;
    }
  }

  void _showNewTopicSheet() {
    String selectedCategory = 'General';
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Create New Topic', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 24),
                    const Text('Topic Title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Enter topic title',
                        filled: true,
                        fillColor: AppColors.scaffoldBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Maintenance', 'Legal', 'General', 'Financial'].map((cat) {
                        final isSelected = selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setModalState(() => selectedCategory = cat);
                          },
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          backgroundColor: AppColors.scaffoldBg,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Details / Content', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: contentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe your topic...',
                        filled: true,
                        fillColor: AppColors.scaffoldBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (titleController.text.trim().isEmpty) return;
                          setState(() {
                            _topics.insert(0, {
                              'id': DateTime.now().millisecondsSinceEpoch.toString(),
                              'title': titleController.text.trim(),
                              'category': selectedCategory,
                              'author': 'You (Landlord)',
                              'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&q=80',
                              'time': 'Just now',
                              'replies': 0,
                            });
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text('Post Topic', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
