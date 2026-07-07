import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class AISmartAssistantScreen extends StatefulWidget {
  const AISmartAssistantScreen({super.key});

  @override
  State<AISmartAssistantScreen> createState() => _AISmartAssistantScreenState();
}

class _AISmartAssistantScreenState extends State<AISmartAssistantScreen> {
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'ai',
      'text':
          "Good morning John. I've analyzed your portfolio today. You have 3 leases expiring within 30 days and 2 maintenance tickets flagged as high priority. How would you like to proceed?",
      'time': 'Just now',
    },
  ];
  final _controller = TextEditingController();

  void _submitQuery() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'sender': 'user',
          'text': _controller.text.trim(),
          'time': 'Just now',
        });
        _messages.add({
          'sender': 'ai',
          'text':
              'Checking properties data... Based on your inquiry, Sunset Apartments currently has the highest maintenance expense at SAR 1,200 this month. I recommend reviewing vendor contracts.',
          'time': 'Just now',
        });
      });
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'AI Smart Assistant',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: pad,
                vertical: h * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assistant Avatar representation
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.smart_toy_rounded,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'T&L Portfolio Assistant',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'Powered by AI Analytics',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: h * 0.04),

                  // Messages list
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _messages.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, idx) {
                      final msg = _messages[idx];
                      final isAI = msg['sender'] == 'ai';

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isAI) ...[
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.smart_toy_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: isAI
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isAI
                                        ? AppColors.white
                                        : AppColors.primary,
                                    borderRadius: BorderRadius.circular(16),
                                    border: isAI
                                        ? Border.all(color: AppColors.border)
                                        : null,
                                  ),
                                  child: Text(
                                    msg['text'],
                                    style: TextStyle(
                                      color: isAI
                                          ? AppColors.textPrimary
                                          : Colors.white,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg['time'],
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isAI) ...[
                            const SizedBox(width: 10),
                            const CircleAvatar(
                              radius: 14,
                              backgroundImage: NetworkImage(
                                'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&q=80',
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),

                  SizedBox(height: h * 0.03),

                  // Recommendations Chips
                  const Text(
                    'Suggestions',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSuggestionChip('Tell me about the occupancy rate'),
                      _buildSuggestionChip('Lease Expiry Analysis'),
                      _buildSuggestionChip('Generate Rent Report'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Search Field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: AppColors.white),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _submitQuery(),
                      decoration: InputDecoration(
                        hintText: 'Ask anything...',
                        fillColor: AppColors.scaffoldBg,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _submitQuery,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
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

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () {
        _controller.text = text;
        _submitQuery();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
