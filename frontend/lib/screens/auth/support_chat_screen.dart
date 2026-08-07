import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

/// Full-featured Support Chat screen.
/// Users can create tickets and chat with admin.
class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _tickets = [];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get('/tickets');
      if (res.statusCode == 200 && mounted) {
        final data = res.data['data'] as List? ?? [];
        setState(() {
          _tickets = data.cast<Map<String, dynamic>>();
        });
      }
    } catch (_) {
      // Catch errors silently
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openNewTicketDialog() {
    // One-ticket rule: if user already has an open ticket, open it directly
    final openTicket = _tickets.firstWhere(
      (t) => t['status'] == 'open' || t['status'] == 'in_progress',
      orElse: () => {},
    );

    if (openTicket.isNotEmpty) {
      // Navigate directly to existing open ticket
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _TicketChatScreen(ticket: openTicket),
        ),
      ).then((_) => _loadTickets());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You already have an open ticket. Opening it for you.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewTicketSheet(onCreated: _loadTickets),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Contact Support',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        // Refresh button removed — tickets reload automatically on return
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewTicketDialog,
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('New Ticket',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tickets.isEmpty
              ? _EmptyTicketsState(onNewTicket: _openNewTicketDialog, w: w)
              : ListView.separated(
                  padding: EdgeInsets.all(w * 0.04),
                  itemCount: _tickets.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _TicketCard(
                    ticket: _tickets[i],
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              _TicketChatScreen(ticket: _tickets[i]),
                        ),
                      );
                      _loadTickets();
                    },
                  ),
                ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyTicketsState extends StatelessWidget {
  final VoidCallback onNewTicket;
  final double w;
  const _EmptyTicketsState(
      {required this.onNewTicket, required this.w});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(w * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                size: 64,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Support Tickets',
              style: TextStyle(
                fontSize: w * 0.048,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Have an issue with your account? Create a support ticket and our admin team will respond as soon as possible.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: w * 0.036,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onNewTicket,
              icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
              label: const Text(
                'Create Your First Ticket',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ticket Card ───────────────────────────────────────────────────────────────
class _TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final VoidCallback onTap;
  const _TicketCard({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = ticket['status'] ?? 'open';
    final statusColor = _ticketStatusColor(status);
    final createdAt = ticket['created_at'] != null
        ? DateFormat('MMM d, y').format(DateTime.parse(ticket['created_at']))
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _ticketStatusIcon(status),
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket['title'] ?? 'Support Ticket',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ticket['description'] ?? 'No description',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status.toUpperCase().replaceAll('_', ' '),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        createdAt,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textHint),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── New Ticket Bottom Sheet ───────────────────────────────────────────────────
class _NewTicketSheet extends StatefulWidget {
  final VoidCallback onCreated;
  const _NewTicketSheet({required this.onCreated});

  @override
  State<_NewTicketSheet> createState() => _NewTicketSheetState();
}

class _NewTicketSheetState extends State<_NewTicketSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'kyc_verification';
  final String _priority = 'high';
  bool _isSubmitting = false;

  final _categories = [
    {'value': 'kyc_verification', 'label': 'KYC / Verification'},
    {'value': 'account_suspended', 'label': 'Account Suspended'},
    {'value': 'billing', 'label': 'Billing Issue'},
    {'value': 'technical', 'label': 'Technical Problem'},
    {'value': 'general', 'label': 'General Inquiry'},
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      final res = await ApiClient().dio.post('/tickets', data: {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'category': _category,
        'priority': _priority,
      });
      if (res.statusCode == 201 && mounted) {
        Navigator.pop(context);
        widget.onCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Support ticket created! We\'ll respond soon.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create ticket. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'New Support Ticket',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Describe your issue and our support team will respond shortly.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // Category
            const Text('Category',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _category,
              items: _categories
                  .map((c) => DropdownMenuItem(
                      value: c['value'],
                      child: Text(c['label']!,
                          style: const TextStyle(fontSize: 14))))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text('Subject',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                hintText: 'e.g. My account is suspended',
                hintStyle: const TextStyle(
                    fontSize: 14, color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            const Text('Description',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Describe your issue in detail. What happened? What were you trying to do?',
                hintStyle: const TextStyle(
                    fontSize: 13, color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Ticket',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ticket Chat Screen ────────────────────────────────────────────────────────
class _TicketChatScreen extends StatefulWidget {
  final Map<String, dynamic> ticket;
  const _TicketChatScreen({required this.ticket});

  @override
  State<_TicketChatScreen> createState() => _TicketChatScreenState();
}

class _TicketChatScreenState extends State<_TicketChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _myUserId;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    // ── Polling Timer (every 8 seconds to stay safely within rate limit) ──
    _pollTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _loadCommentsSilent();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Get my user id
      final meRes = await ApiClient().dio.get('/auth/me');
      if (meRes.statusCode == 200) {
        _myUserId = meRes.data['data']['id'];
      }
      await _loadCommentsSilent();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCommentsSilent() async {
    try {
      final res = await ApiClient().dio.get('/tickets/${widget.ticket['id']}');
      if (res.statusCode == 200 && mounted) {
        final ticketData = res.data['data'];
        final comments = (ticketData['comments'] ?? []) as List;
        final newComments = comments.cast<Map<String, dynamic>>();

        // Check if there are differences
        if (newComments.length != _comments.length ||
            (newComments.isNotEmpty && _comments.isNotEmpty &&
                newComments.last['id'] != _comments.last['id'])) {
          setState(() {
            _comments = newComments;
            _isLoading = false;
          });
          _scrollToBottom();
        }
      }
    } catch (_) {}
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

  Future<void> _sendMessage() async {
    final msg = _msgCtrl.text.trim();
    if (msg.isEmpty || _isSending) return;
    _msgCtrl.clear();

    // Optimistic insert so user sees message immediately in milliseconds
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticComment = {
      'id': tempId,
      'ticket_id': widget.ticket['id'],
      'sender_id': _myUserId,
      'sender_role': 'user',
      'message': msg,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    setState(() {
      _comments.add(optimisticComment);
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final res = await ApiClient().dio.post(
        '/tickets/${widget.ticket['id']}/comments',
        data: {'message': msg},
      );
      if (res.statusCode == 201 && mounted) {
        final newComment = res.data['data'] as Map<String, dynamic>;
        setState(() {
          final idx = _comments.indexWhere((c) => c['id'] == tempId);
          if (idx != -1) {
            _comments[idx] = newComment;
          }
          _isSending = false;
        });
        _scrollToBottom();
      } else if (mounted) {
        setState(() => _isSending = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sending failed. Please check connection.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile == null) return;
    
    setState(() => _isSending = true);
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(pickedFile.path, filename: pickedFile.name),
      });
      final res = await ApiClient().dio.post('/uploads/generic', data: formData);
      if (res.statusCode == 200 && mounted) {
        final url = res.data['data']['url'];
        
        final commentRes = await ApiClient().dio.post(
          '/tickets/${widget.ticket['id']}/comments',
          data: {'message': url},
        );
        if (commentRes.statusCode == 201 && mounted) {
          final newComment = commentRes.data['data'] as Map<String, dynamic>;
          setState(() {
            _comments.add(newComment);
            _isSending = false;
          });
          _scrollToBottom();
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.ticket['status'] ?? 'open';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary, // App primary color (not WhatsApp green)
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.ticket['title'] ?? 'Support Chat',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Support Team • ${status.replaceAll('_', ' ').toUpperCase()}',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        // Refresh button removed — auto-polls every 3 seconds
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.mark_chat_unread_outlined,
                                  size: 56, color: Color(0xFF8696A0)),
                              SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Start chatting with support team by typing a message below.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        itemCount: _comments.length,
                        itemBuilder: (_, i) {
                          final comment = _comments[i];
                          final isMe = _myUserId != null
                              ? (comment['sender_id'] == _myUserId)
                              : (comment['sender_role'] == 'user');
                          return _ChatBubble(
                            comment: comment,
                            isMe: isMe,
                          );
                        },
                      ),
          ),

          // WhatsApp Style Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            color: const Color(0xFFF0F2F5),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF54656F), size: 22),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF8696A0)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.primary, // App primary color for send button
                      shape: BoxShape.circle,
                    ),
                    child: _isSending
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chat Bubble ───────────────────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final Map<String, dynamic> comment;
  final bool isMe;
  const _ChatBubble({required this.comment, required this.isMe});

  bool _isImageUrl(String text) {
    final lower = text.toLowerCase();
    return lower.contains('http://') ||
        lower.contains('https://') ||
        lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.contains('/uploads/');
  }

  String _extractUrl(String text) {
    final lines = text.split('\n');
    for (final l in lines) {
      final trimmed = l.trim();
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return trimmed;
      }
    }
    return text.trim();
  }

  @override
  Widget build(BuildContext context) {
    final rawMessage = (comment['message'] ?? '').toString();
    final isImage = _isImageUrl(rawMessage);
    final imageUrl = isImage ? _extractUrl(rawMessage) : null;
    
    // Parse UTC server timestamp and convert to device's local timezone (PKT)
    String createdAt = '';
    if (comment['created_at'] != null) {
      try {
        final parsedDate = DateTime.parse(comment['created_at'].toString()).toLocal();
        createdAt = DateFormat('h:mm a').format(parsedDate);
      } catch (_) {
        createdAt = '';
      }
    }

    // Staff/Admin member name
    final String staffName = (comment['sender_name'] != null && comment['sender_name'].toString().trim().isNotEmpty)
        ? comment['sender_name'].toString().trim()
        : (comment['sender_role'] == 'admin' || comment['sender_role'] == 'super_admin'
            ? 'Admin'
            : 'Support Staff');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF075E54).withValues(alpha: 0.15),
              backgroundImage: comment['sender_avatar'] != null && comment['sender_avatar'].toString().isNotEmpty
                  ? NetworkImage(comment['sender_avatar'])
                  : null,
              child: comment['sender_avatar'] == null || comment['sender_avatar'].toString().isEmpty
                  ? const Icon(Icons.headset_mic_rounded, size: 14, color: Color(0xFF075E54))
                  : null,
            ),
            const SizedBox(width: 6),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.76,
            ),
            child: Container(
              padding: isImage
                  ? const EdgeInsets.all(4)
                  : const EdgeInsets.fromLTRB(10, 7, 10, 5),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(2),
                  bottomRight: isMe ? const Radius.circular(2) : const Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Show Staff / Admin member name for incoming support messages
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            staffName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF075E54), // WhatsApp dark teal
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF075E54).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              (comment['sender_role'] ?? 'Staff').toString().toUpperCase(),
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF075E54),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Message text or Image
                  if (isImage && imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: 220,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            rawMessage,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF111B21)),
                          ),
                        ),
                        loadingBuilder: (_, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 220,
                            height: 160,
                            color: Colors.black12,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Text(
                      rawMessage,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: Color(0xFF111B21),
                        height: 1.3,
                      ),
                    ),

                  const SizedBox(height: 2),

                  // Timestamp & Blue check mark for User messages
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        createdAt,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.done_all,
                          size: 15,
                          color: Color(0xFF53BDEB), // WhatsApp blue double tick
                        ),
                      ],
                    ],
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

// ── Helper functions ──────────────────────────────────────────────────────────
Color _ticketStatusColor(String status) {
  switch (status) {
    case 'open':
      return const Color(0xFF4DB2E6);
    case 'in_progress':
      return const Color(0xFFF39C12);
    case 'resolved':
      return const Color(0xFF2ECC71);
    case 'closed':
      return const Color(0xFF6B7A8D);
    default:
      return const Color(0xFF4DB2E6);
  }
}

IconData _ticketStatusIcon(String status) {
  switch (status) {
    case 'open':
      return Icons.chat_bubble_outline_rounded;
    case 'in_progress':
      return Icons.pending_actions_rounded;
    case 'resolved':
      return Icons.check_circle_rounded;
    case 'closed':
      return Icons.archive_rounded;
    default:
      return Icons.help_outline_rounded;
  }
}
