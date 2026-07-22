import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';

class LandlordChatbotScreen extends ConsumerStatefulWidget {
  const LandlordChatbotScreen({super.key});

  @override
  ConsumerState<LandlordChatbotScreen> createState() => _LandlordChatbotScreenState();
}

class _ChatMessage {
  final String sender; // 'user' or 'ai'
  final String text;
  final DateTime timestamp;

  _ChatMessage({required this.sender, required this.text, required this.timestamp});
}

class _LandlordChatbotScreenState extends ConsumerState<LandlordChatbotScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isSending = false;

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      sender: 'ai',
      text: 'Hello! I am your PropAdmin Landlord Assistant. Ask me anything about your properties, active tenants, collected rent, or pending maintenance!',
      timestamp: DateTime.now(),
    ),
  ];

  final List<String> _quickPills = [
    'Rent collected this month?',
    'Pending maintenance?',
    'Total active properties?',
    'Tenants overview',
  ];

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isSending) return;

    final userMsg = text.trim();
    _msgCtrl.clear();

    setState(() {
      _messages.add(_ChatMessage(sender: 'user', text: userMsg, timestamp: DateTime.now()));
      _isSending = true;
    });

    _scrollToBottom();

    try {
      final resp = await ApiClient().dio.post('/ai/landlord-chat', data: {'message': userMsg});
      final reply = resp.data['reply']?.toString() ?? 'I could not process that request. Please try again.';

      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(sender: 'ai', text: reply, timestamp: DateTime.now()));
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            sender: 'ai',
            text: 'Sorry, I ran into an issue connecting to the AI backend service. Please check your network or try again.',
            timestamp: DateTime.now(),
          ));
        });
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.smart_toy_rounded, size: 18, color: Colors.white),
            ),
            SizedBox(width: 10),
            Text(
              'AI Landlord Assistant',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat message history
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg.sender == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 16),
                        ),
                        boxShadow: [
                          if (!isUser)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: isUser ? Colors.white : AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_isSending)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text('Analyzing portfolio data...', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                  ],
                ),
              ),

            // Quick suggestion pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: _quickPills.map((pill) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(pill, style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onPressed: () => _sendMessage(pill),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Bottom text input bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: AppColors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      decoration: InputDecoration(
                        hintText: 'Ask your AI assistant...',
                        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
                        filled: true,
                        fillColor: AppColors.inputBg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _sendMessage(_msgCtrl.text),
                    icon: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 20,
                      child: Icon(Icons.send_rounded, size: 18, color: Colors.white),
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
