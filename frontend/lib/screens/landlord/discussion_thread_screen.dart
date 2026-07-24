import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class DiscussionThreadScreen extends StatefulWidget {
  const DiscussionThreadScreen({super.key});

  @override
  State<DiscussionThreadScreen> createState() => _DiscussionThreadScreenState();
}

class _DiscussionThreadScreenState extends State<DiscussionThreadScreen> {
  final TextEditingController _replyController = TextEditingController();

  final List<Map<String, dynamic>> _comments = [
    {
      'id': 'c1',
      'author': 'David Kim',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&q=80',
      'text': 'I highly recommend Seattle Plumbing Co. They fixed a major leak for me last week quickly.',
      'time': '1h ago',
    },
    {
      'id': 'c2',
      'author': 'Sarah Jenkins',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&q=80',
      'text': 'Thanks David! Do you know what their emergency rates look like?',
      'time': '45m ago',
      'isOp': true,
    },
    {
      'id': 'c3',
      'author': 'Amanda Lee',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80',
      'text': 'Usually around \$150/hr for after hours. They are very reliable though.',
      'time': '10m ago',
    },
  ];

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _sendReply() {
    if (_replyController.text.trim().isEmpty) return;
    setState(() {
      _comments.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'author': 'You (Landlord)',
        'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&q=80',
        'text': _replyController.text.trim(),
        'time': 'Just now',
        'isOp': false,
      });
      _replyController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // Topic is passed as an argument
    final topic = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {
      'title': 'Discussion Thread',
      'category': 'General',
      'author': 'Unknown',
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&q=80',
      'time': '1h ago',
    };

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Thread', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Original Post
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(topic['avatar']),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(topic['author'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(topic['time'], style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(topic['category'], style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(topic['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                const Text('Hi everyone, I am looking for recommendations for a solid plumber. Anyone have a contact they trust?', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
              ],
            ),
          ),
          const Divider(height: 1),
          // Comments List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _comments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final c = _comments[index];
                final isOp = c['isOp'] == true;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(c['avatar']),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(c['author'], style: TextStyle(fontWeight: isOp ? FontWeight.w800 : FontWeight.w600, fontSize: 13, color: isOp ? AppColors.primary : AppColors.textPrimary)),
                              if (isOp) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                  child: const Text('OP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ),
                              ],
                              const SizedBox(width: 8),
                              Text(c['time'], style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12).copyWith(topLeft: const Radius.circular(2)),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(c['text'], style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      decoration: InputDecoration(
                        hintText: 'Add a reply...',
                        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
                        filled: true,
                        fillColor: AppColors.scaffoldBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _sendReply,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
