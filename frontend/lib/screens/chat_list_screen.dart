import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/screens_provider.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  static const _contacts = [
    (
      'https://i.pravatar.cc/100?img=1',
      'Jhon Smith',
      'Lorem Ipsum Dolor Sit Amet',
      '25 min',
      1,
      true,
      false,
    ),
    (
      'https://i.pravatar.cc/100?img=2',
      'Jhon Smith',
      'Lorem Ipsum Dolor Sit Amet',
      '25 min',
      1,
      true,
      false,
    ),
    (
      'https://i.pravatar.cc/100?img=3',
      'Jhon Smith',
      'Lorem Ipsum Dolor Sit Amet',
      '25 min',
      0,
      true,
      true,
    ),
    (
      'https://i.pravatar.cc/100?img=4',
      'Jhon Smith',
      'Lorem Ipsum Dolor Sit Amet',
      'Yesterday',
      0,
      false,
      false,
    ),
    (
      'https://i.pravatar.cc/100?img=5',
      'Jhon Smith',
      'Lorem Ipsum Dolor Sit Amet',
      '25 min',
      0,
      true,
      false,
    ),
    (
      'https://i.pravatar.cc/100?img=6',
      'Jhon Smith',
      'Lorem Ipsum Dolor Sit Amet',
      '25 min',
      0,
      true,
      false,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final state = ref.watch(chatListProvider);
    final notif = ref.read(chatListProvider.notifier);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          // ── Teal header ─────────────────────────
          Container(
            color: AppColors.primary,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + h * 0.01,
              left: w * 0.05,
              right: w * 0.05,
              bottom: h * 0.02,
            ),
            child: Column(
              children: [
                // top bar
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.white,
                        size: w * 0.06,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Chat',
                      style: TextStyle(
                        fontSize: w * 0.048,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(width: w * 0.06),
                  ],
                ),

                SizedBox(height: h * 0.02),

                // Search bar
                Container(
                  height: h * 0.056,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: w * 0.04),
                      Icon(
                        Icons.search_rounded,
                        size: w * 0.05,
                        color: AppColors.textHint,
                      ),
                      SizedBox(width: w * 0.025),
                      Expanded(
                        child: TextField(
                          onChanged: notif.updateSearch,
                          style: TextStyle(
                            fontSize: w * 0.036,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search for radisha...',
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
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── White body ──────────────────────────
          Expanded(
            child: Container(
              color: AppColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Online avatars row
                  Container(
                    height: h * 0.1,
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.04,
                      vertical: h * 0.015,
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6,
                      itemBuilder: (_, i) => Padding(
                        padding: EdgeInsets.only(right: w * 0.03),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: w * 0.08,
                              backgroundColor: AppColors.inputBg,
                              backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/100?img=${i + 10}',
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                width: w * 0.035,
                                height: w * 0.035,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2ECC71),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.white,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Divider(height: 1, color: AppColors.border),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.05,
                      vertical: h * 0.015,
                    ),
                    child: Text(
                      'Messages',
                      style: TextStyle(
                        fontSize: w * 0.042,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  // Messages list
                  Expanded(
                    child: ListView.separated(
                      itemCount: _contacts.length,
                      separatorBuilder: (_, _) =>
                          Divider(height: 1, color: AppColors.border),
                      itemBuilder: (_, i) {
                        final c = _contacts[i];
                        return _ChatTile(
                          imageUrl: c.$1,
                          name: c.$2,
                          lastMsg: c.$3,
                          time: c.$4,
                          unread: c.$5,
                          isOnline: c.$6,
                          isRead: c.$7,
                          w: w,
                          h: h,
                        );
                      },
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

class _ChatTile extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String lastMsg;
  final String time;
  final int unread;
  final bool isOnline;
  final bool isRead;
  final double w;
  final double h;

  const _ChatTile({
    required this.imageUrl,
    required this.name,
    required this.lastMsg,
    required this.time,
    required this.unread,
    required this.isOnline,
    required this.isRead,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/chat/detail'),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.05,
          vertical: h * 0.014,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: w * 0.065,
                  backgroundColor: AppColors.inputBg,
                  backgroundImage: NetworkImage(imageUrl),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: w * 0.033,
                      height: w * 0.033,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ECC71),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: w * 0.035),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: w * 0.037,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      if (isRead)
                        Padding(
                          padding: EdgeInsets.only(right: w * 0.015),
                          child: Icon(
                            Icons.done_all_rounded,
                            size: w * 0.038,
                            color: AppColors.secondary,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          lastMsg,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: w * 0.031,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: w * 0.02),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: w * 0.028,
                    color: AppColors.textHint,
                  ),
                ),
                SizedBox(height: 5),
                if (unread > 0)
                  Container(
                    width: w * 0.055,
                    height: w * 0.055,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2ECC71),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$unread',
                        style: TextStyle(
                          fontSize: w * 0.028,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(height: w * 0.055),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
