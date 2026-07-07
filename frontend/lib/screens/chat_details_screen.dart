import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/screens_provider.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class _ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  final bool isTyping;
  const _ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.isTyping = false,
  });
}

class ChatDetailScreen extends ConsumerWidget {
  const ChatDetailScreen({super.key});

  static final _messages = [
    const _ChatMessage(
      text:
          "Hello! I've received your inquiry regarding the AC unit in 4B. The technician is scheduled for tomorrow at 10:00 AM. Does that work for you?",
      isMe: false,
      time: '10:14 AM',
    ),
    const _ChatMessage(
      text:
          "That works perfectly! I will be home to let them in. Should I provide a temporary access code as well just in case?",
      isMe: true,
      time: '10:15 AM',
    ),
    const _ChatMessage(
      text:
          "A temporary code would be great, just as a backup. I'll make sure the building security knows to expect the HVAC team. Also, have you noticed any leaks or just the cooling issue?",
      isMe: false,
      time: '10:17 AM',
    ),
    const _ChatMessage(text: '', isMe: false, time: '', isTyping: true),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final state = ref.watch(chatDetailProvider);
    final notif = ref.read(chatDetailProvider.notifier);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────
            Container(
              color: AppColors.white,
              padding: EdgeInsets.symmetric(
                horizontal: pad,
                vertical: h * 0.015,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.menu_rounded,
                        size: w * 0.06,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: w * 0.03),
                      Row(
                        children: [
                          Icon(
                            Icons.apartment_rounded,
                            size: w * 0.048,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: w * 0.015),
                          Text(
                            'T&L',
                            style: TextStyle(
                              fontSize: w * 0.046,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      CircleAvatar(
                        radius: w * 0.048,
                        backgroundImage: const NetworkImage(
                          'https://i.pravatar.cc/100?img=8',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: h * 0.015),
                  Text(
                    'Messages',
                    style: TextStyle(
                      fontSize: w * 0.065,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: h * 0.004),
                  Text(
                    'Conversations with your property managers',
                    style: TextStyle(
                      fontSize: w * 0.033,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                color: AppColors.white,
                margin: EdgeInsets.only(top: h * 0.01),
                child: Column(
                  children: [
                    // Landlord info bar
                    Container(
                      margin: EdgeInsets.all(pad * 0.8),
                      padding: EdgeInsets.all(pad * 0.9),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.07),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: w * 0.07,
                                backgroundImage: const NetworkImage(
                                  'https://i.pravatar.cc/100?img=8',
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  width: w * 0.033,
                                  height: w * 0.033,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2ECC71),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: w * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Marcus Thorne',
                                  style: TextStyle(
                                    fontSize: w * 0.04,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Property Manager • Unit 4B',
                                  style: TextStyle(
                                    fontSize: w * 0.031,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.phone_outlined,
                            size: w * 0.055,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: w * 0.04),
                          Icon(
                            Icons.more_vert_rounded,
                            size: w * 0.055,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),

                    // Messages
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: pad * 0.8),
                        itemCount: _messages.length + 1,
                        itemBuilder: (_, i) {
                          if (i == 0) {
                            return Center(
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: h * 0.015,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.04,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.inputBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'TODAY',
                                  style: TextStyle(
                                    fontSize: w * 0.028,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textHint,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            );
                          }
                          final msg = _messages[i - 1];
                          if (msg.isTyping) return _TypingBubble(w: w, h: h);
                          return _MessageBubble(msg: msg, w: w, h: h);
                        },
                      ),
                    ),

                    // Input bar
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: pad * 0.8,
                        vertical: h * 0.015,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: w * 0.1,
                            height: w * 0.1,
                            decoration: BoxDecoration(
                              color: AppColors.inputBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              size: w * 0.055,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: w * 0.025),
                          Container(
                            width: w * 0.1,
                            height: w * 0.1,
                            decoration: BoxDecoration(
                              color: AppColors.inputBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.image_outlined,
                              size: w * 0.055,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: w * 0.025),
                          Expanded(
                            child: Container(
                              height: w * 0.12,
                              padding: EdgeInsets.symmetric(
                                horizontal: w * 0.04,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.inputBg,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: TextField(
                                onChanged: notif.updateMessage,
                                style: TextStyle(
                                  fontSize: w * 0.036,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Type a message...',
                                  hintStyle: TextStyle(
                                    fontSize: w * 0.036,
                                    color: AppColors.textHint,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: w * 0.025),
                          GestureDetector(
                            onTap: () => notif.clearMessage(),
                            child: Container(
                              width: w * 0.12,
                              height: w * 0.12,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.send_rounded,
                                size: w * 0.055,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage msg;
  final double w;
  final double h;
  const _MessageBubble({required this.msg, required this.w, required this.h});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: h * 0.015),
      child: Row(
        mainAxisAlignment: msg.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isMe) ...[
            CircleAvatar(
              radius: w * 0.045,
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/100?img=8',
              ),
            ),
            SizedBox(width: w * 0.02),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: msg.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.045,
                    vertical: h * 0.014,
                  ),
                  decoration: BoxDecoration(
                    color: msg.isMe ? AppColors.primary : AppColors.inputBg,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(msg.isMe ? 18 : 4),
                      bottomRight: Radius.circular(msg.isMe ? 4 : 18),
                    ),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: w * 0.035,
                      color: msg.isMe ? AppColors.white : AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg.time,
                      style: TextStyle(
                        fontSize: w * 0.028,
                        color: AppColors.textHint,
                      ),
                    ),
                    if (msg.isMe) ...[
                      SizedBox(width: 4),
                      Icon(
                        Icons.done_all_rounded,
                        size: w * 0.035,
                        color: AppColors.secondary,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (msg.isMe) SizedBox(width: w * 0.02),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  final double w;
  final double h;
  const _TypingBubble({required this.w, required this.h});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: h * 0.015),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: w * 0.045,
            backgroundImage: const NetworkImage(
              'https://i.pravatar.cc/100?img=8',
            ),
          ),
          SizedBox(width: w * 0.02),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.05,
              vertical: h * 0.018,
            ),
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => Container(
                  width: w * 0.022,
                  height: w * 0.022,
                  margin: EdgeInsets.symmetric(horizontal: w * 0.008),
                  decoration: BoxDecoration(
                    color: AppColors.textHint,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
