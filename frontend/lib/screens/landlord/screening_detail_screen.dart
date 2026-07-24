import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

/// Data container for all three concurrent API fetches.
class _ScreeningPageData {
  final Map<String, dynamic> application;
  final Map<String, dynamic> creditReport;
  final Map<String, dynamic> backgroundCheck;
  const _ScreeningPageData({
    required this.application,
    required this.creditReport,
    required this.backgroundCheck,
  });
}

/// Landlord-facing screen to review a tenant screening application.
///
/// Route argument: [String] screeningApplicationId
///
/// Calls:
///   GET  /screening/applications/:id
///   GET  /screening/applications/:id/credit-report
///   GET  /screening/applications/:id/background-check
///   POST /screening/applications/:id/decision
class ScreeningDetailScreen extends ConsumerStatefulWidget {
  const ScreeningDetailScreen({super.key});

  @override
  ConsumerState<ScreeningDetailScreen> createState() =>
      _ScreeningDetailScreenState();
}

class _ScreeningDetailScreenState
    extends ConsumerState<ScreeningDetailScreen> {
  late String _screeningId;
  bool _initialised = false;

  bool _isLoading = true;
  String? _errorMessage;
  _ScreeningPageData? _data;

  bool _isDecisionLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialised) {
      _initialised = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      _screeningId = (args is String && args.isNotEmpty) ? args : '';
      if (_screeningId.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'No screening application ID was provided. Navigate here from a tenant application card.';
        });
      } else {
        _loadAll();
      }
    }
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final notifier = ref.read(landlordProvider.notifier);
    try {
      final results = await Future.wait([
        notifier.fetchScreeningApplication(_screeningId),
        notifier.fetchScreeningCreditReport(_screeningId),
        notifier.fetchScreeningBackgroundCheck(_screeningId),
      ]);
      if (mounted) {
        setState(() {
          _data = _ScreeningPageData(
            application: results[0],
            creditReport: results[1],
            backgroundCheck: results[2],
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _friendlyError(e.toString());
        });
      }
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('404')) return 'Screening application not found (404).';
    if (raw.contains('403') || raw.contains('401')) {
      return 'You do not have permission to view this screening record.';
    }
    if (raw.contains('SocketException') || raw.contains('connection')) {
      return 'Could not reach the server. Check your network connection.';
    }
    return 'Failed to load screening data. Please try again.';
  }

  Future<void> _postDecision(String decision) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '${decision == 'APPROVED' ? 'Approve' : 'Reject'} Screening?',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          decision == 'APPROVED'
              ? 'This will mark the screening application as APPROVED. The tenant will be notified.'
              : 'This will mark the screening application as REJECTED. The tenant will be notified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: decision == 'APPROVED'
                  ? const Color(0xFF1B8E4D)
                  : AppColors.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(decision == 'APPROVED' ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isDecisionLoading = true);
    try {
      await ref
          .read(landlordProvider.notifier)
          .postScreeningDecision(_screeningId, decision);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              decision == 'APPROVED'
                  ? 'Screening approved successfully.'
                  : 'Screening rejected.',
            ),
            backgroundColor:
                decision == 'APPROVED' ? const Color(0xFF1B8E4D) : AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        // Reload to reflect updated decision badge
        await _loadAll();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to update decision: ${_friendlyError(e.toString())}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDecisionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final pad = w * 0.05;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Screening Report',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading && _errorMessage == null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
              onPressed: _loadAll,
            ),
        ],
      ),
      body: _buildBody(w, h, pad),
    );
  }

  Widget _buildBody(double w, double h, double pad) {
    // ── Loading state ──────────────────────────────────────────────────────────
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading screening report\u2026',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    // ── Error state ────────────────────────────────────────────────────────────
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 56, color: AppColors.error.withValues(alpha: 0.7)),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadAll,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Loaded state ───────────────────────────────────────────────────────────
    final app = _data!.application;
    final credit = _data!.creditReport;
    final bg = _data!.backgroundCheck;
    final currentDecision =
        (app['decision'] ?? 'PENDING').toString().toUpperCase();
    final isPending = currentDecision == 'PENDING';

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: h * 0.025),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Application summary
          _SectionHeader(label: 'Application Overview'),
          SizedBox(height: h * 0.012),
          _AppSummaryCard(app: app, w: w),

          SizedBox(height: h * 0.025),

          // 2. Credit report
          _SectionHeader(label: 'Credit Report'),
          SizedBox(height: h * 0.012),
          _CreditReportCard(credit: credit, w: w),

          SizedBox(height: h * 0.025),

          // 3. Background check
          _SectionHeader(label: 'Background Check'),
          SizedBox(height: h * 0.012),
          _BackgroundCheckCard(bg: bg, w: w),

          SizedBox(height: h * 0.035),

          // 4. Decision section
          if (!isPending)
            _DecisionBanner(decision: currentDecision, w: w)
          else ...[
            Text(
              'Make a Decision',
              style: TextStyle(
                fontSize: w * 0.042,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: h * 0.014),
            if (_isDecisionLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Approve',
                      icon: Icons.check_circle_outline_rounded,
                      color: const Color(0xFF1B8E4D),
                      onTap: () => _postDecision('APPROVED'),
                    ),
                  ),
                  SizedBox(width: w * 0.04),
                  Expanded(
                    child: _ActionButton(
                      label: 'Reject',
                      icon: Icons.cancel_outlined,
                      color: AppColors.error,
                      onTap: () => _postDecision('REJECTED'),
                    ),
                  ),
                ],
              ),
          ],
          SizedBox(height: h * 0.04),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private reusable sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Text(
      label,
      style: TextStyle(
        fontSize: w * 0.042,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: w * 0.38,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '\u2014' : value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.05),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Application Summary Card ──────────────────────────────────────────────────
class _AppSummaryCard extends StatelessWidget {
  final Map<String, dynamic> app;
  final double w;
  const _AppSummaryCard({required this.app, required this.w});

  static double _safeDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  static String _formatDate(String raw) {
    if (raw.isEmpty) return '\u2014';
    try {
      final dt = DateTime.tryParse(raw);
      if (dt == null) return raw;
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final decision = (app['decision'] ?? 'PENDING').toString().toUpperCase();
    final statusColor = decision == 'APPROVED'
        ? const Color(0xFF1B8E4D)
        : decision == 'REJECTED'
            ? AppColors.error
            : const Color(0xFFD97706);

    final shortId = app['id']?.toString() ?? '';
    final displayId =
        shortId.length > 8 ? shortId.substring(0, 8) : shortId;

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person_search_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    displayId.isNotEmpty
                        ? 'App #$displayId\u2026'
                        : 'Application',
                    style: TextStyle(
                      fontSize: w * 0.038,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  decision,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Monthly Income',
            value: app['monthly_income'] != null
                ? '\$${_safeDouble(app['monthly_income']).toStringAsFixed(0)}/mo'
                : '\u2014',
          ),
          _InfoRow(
            label: 'Employment Status',
            value: _capitalize(
                app['employment_status']?.toString() ?? '\u2014'),
          ),
          _InfoRow(
            label: 'Property ID',
            value: app['property_id']?.toString() ?? '\u2014',
          ),
          _InfoRow(
            label: 'Applied On',
            value: _formatDate(app['created_at']?.toString() ?? ''),
          ),
        ],
      ),
    );
  }
}

// ── Credit Report Card ────────────────────────────────────────────────────────
class _CreditReportCard extends StatelessWidget {
  final Map<String, dynamic> credit;
  final double w;
  const _CreditReportCard({required this.credit, required this.w});

  @override
  Widget build(BuildContext context) {
    final score = (credit['score'] ?? 0) as num;
    final riskLevel = credit['riskLevel']?.toString() ?? '\u2014';
    final agency = credit['agency']?.toString() ?? '\u2014';
    final reportDate = credit['reportDate']?.toString() ?? '';

    final scoreColor = score >= 700
        ? const Color(0xFF1B8E4D)
        : score >= 600
            ? const Color(0xFFD97706)
            : AppColors.error;

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(Icons.bar_chart_rounded, color: scoreColor, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'Credit Score',
                style: TextStyle(
                  fontSize: w * 0.04,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                score.toString(),
                style: TextStyle(
                  fontSize: w * 0.07,
                  fontWeight: FontWeight.w800,
                  color: scoreColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Visual score bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ((score.toDouble() - 300) / (850 - 300)).clamp(0.0, 1.0),
              minHeight: 10,
              color: scoreColor,
              backgroundColor: AppColors.border,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('300 (Poor)',
                  style: TextStyle(fontSize: 11, color: AppColors.textHint)),
              Text('850 (Excellent)',
                  style: TextStyle(fontSize: 11, color: AppColors.textHint)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Risk Level',
            value: riskLevel,
            valueColor: riskLevel == 'Low'
                ? const Color(0xFF1B8E4D)
                : riskLevel.contains('High')
                    ? const Color(0xFFD97706)
                    : AppColors.error,
          ),
          _InfoRow(label: 'Reporting Agency', value: agency),
          _InfoRow(
            label: 'Report Date',
            value: reportDate.length >= 10
                ? reportDate.substring(0, 10)
                : (reportDate.isNotEmpty ? reportDate : '\u2014'),
          ),
        ],
      ),
    );
  }
}

// ── Background Check Card ─────────────────────────────────────────────────────
class _BackgroundCheckCard extends StatelessWidget {
  final Map<String, dynamic> bg;
  final double w;
  const _BackgroundCheckCard({required this.bg, required this.w});

  @override
  Widget build(BuildContext context) {
    final status = (bg['status'] ?? '\u2014').toString().toUpperCase();
    final agency = bg['agency']?.toString() ?? '\u2014';
    final details = bg['details'] as Map<String, dynamic>? ?? {};
    final hasCriminal = details['criminal_record'] == true;
    final evictions = (details['evictions'] ?? 0) as num;

    final statusColor = status == 'APPROVED'
        ? const Color(0xFF1B8E4D)
        : status == 'REJECTED'
            ? AppColors.error
            : const Color(0xFFD97706);

    final extraDetails = details.entries
        .where((e) => e.key != 'criminal_record' && e.key != 'evictions')
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.shield_outlined,
                    color: statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'Background Check',
                style: TextStyle(
                  fontSize: w * 0.04,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          _InfoRow(label: 'Agency', value: agency),
          _InfoRow(
            label: 'Criminal Record',
            value: hasCriminal ? 'Yes \u2013 Review Required' : 'None Found',
            valueColor: hasCriminal
                ? AppColors.error
                : const Color(0xFF1B8E4D),
          ),
          _InfoRow(
            label: 'Prior Evictions',
            value: evictions.toString(),
            valueColor: evictions > 0
                ? const Color(0xFFD97706)
                : const Color(0xFF1B8E4D),
          ),
          if (extraDetails.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Additional: $extraDetails',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Decision Banner (shown when already decided) ──────────────────────────────
class _DecisionBanner extends StatelessWidget {
  final String decision;
  final double w;
  const _DecisionBanner({required this.decision, required this.w});

  @override
  Widget build(BuildContext context) {
    final isApproved = decision == 'APPROVED';
    final color = isApproved ? const Color(0xFF1B8E4D) : AppColors.error;

    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.symmetric(horizontal: w * 0.05, vertical: w * 0.045),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isApproved
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isApproved ? 'Application Approved' : 'Application Rejected',
                  style: TextStyle(
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isApproved
                      ? 'This screening application has been marked as approved.'
                      : 'This screening application has been marked as rejected.',
                  style: TextStyle(
                      fontSize: 12, color: color.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: w * 0.04),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
