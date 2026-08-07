import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import '../core/api_client.dart';
import '../core/api_constants.dart';
import 'vendor_state.dart';

class VendorNotifier extends StateNotifier<VendorState> {
  VendorNotifier() : super(const VendorState()) {
    _loadInitialData();
  }

  void _loadInitialData() {
    loadProfile();
    loadStats();
    loadJobs();
    loadBids();
    loadPayments();
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  // ── 1. Load Vendor Profile (Onboarding Status) ───────────────────────────
  Future<void> loadProfile() async {
    try {
      final resp = await ApiClient().dio.get(ApiConstants.userProfile);
      final data = resp.data['data'] as Map<String, dynamic>? ?? {};
      final isCompleted = data['onboarding_completed'] == true;
      
      state = state.copyWith(
        profile: state.profile.copyWith(
          email: data['email']?.toString() ?? '',
          phone: data['phone']?.toString() ?? '',
          isOnboarded: isCompleted,
        ),
      );
    } catch (e) {
      debugPrint('[VendorNotifier] loadProfile error: $e');
    }
  }

  // ── 2. Load Vendor Stats ─────────────────────────────────────────────────
  Future<void> loadStats() async {
    try {
      final resp = await ApiClient().dio.get('/vendors/stats');
      final data = resp.data['data'] as Map<String, dynamic>? ?? {};
      final totalBids = (data['totalBids'] ?? 0) as int;
      final ratingRaw = data['averageRating'] ?? 0.0;
      final rating = ratingRaw is num ? ratingRaw.toDouble() : double.tryParse(ratingRaw.toString()) ?? 0.0;
      final earningsRaw = data['totalEarnings'] ?? 0.0;
      final earnings = earningsRaw is num ? earningsRaw.toDouble() : double.tryParse(earningsRaw.toString()) ?? 0.0;
      
      state = state.copyWith(
        rating: rating > 0 ? rating : 5.0,
        jobsCount: totalBids,
        earnings: earnings,
      );
    } catch (e) {
      debugPrint('[VendorNotifier] loadStats error: $e');
    }
  }

  // ── 3. Load Jobs (Available & Active) ────────────────────────────────────
  Future<void> loadJobs() async {
    state = state.copyWith(isLoading: true);
    try {
      final resp = await ApiClient().dio.get(ApiConstants.workOrders);
      final List<dynamic> rawList = (resp.data['data'] ?? []) as List<dynamic>;
      
      final List<VendorWorkOrder> available = [];
      final List<VendorWorkOrder> active = [];
      
      for (final item in rawList) {
        final m = item as Map<String, dynamic>;
        final status = (m['status'] ?? '').toString().toLowerCase();
        
        // Parse date
        String formattedDate = '';
        try {
          final rawDate = m['created_at']?.toString() ?? m['date']?.toString() ?? '';
          if (rawDate.isNotEmpty) {
            final dt = DateTime.tryParse(rawDate);
            if (dt != null) formattedDate = DateFormat('MMM dd, yyyy').format(dt);
          }
        } catch (_) {}

        final job = VendorWorkOrder(
          id: m['id']?.toString() ?? '',
          title: m['title']?.toString() ?? 'Work Order',
          description: m['description']?.toString() ?? '',
          propertyName: m['property_name']?.toString() ?? 'Unnamed Property',
          unitName: m['unit_number']?.toString() ?? m['unit_name']?.toString() ?? 'N/A',
          tenantName: m['tenant_name']?.toString() ?? 'Tenant',
          priority: _capitalize(m['priority']?.toString() ?? 'Medium'),
          status: _capitalize(status),
          category: _capitalize(m['category']?.toString() ?? 'General'),
          date: formattedDate,
          timeSlot: m['time_slot']?.toString() ?? 'Flexible',
          accessInstructions: m['access_instructions']?.toString() ?? 'None',
          address: m['address']?.toString() ?? m['property_name']?.toString() ?? 'On-Site',
          bidAmount: m['budget_max'] is num ? (m['budget_max'] as num).toDouble() : (m['final_amount'] is num ? (m['final_amount'] as num).toDouble() : double.tryParse((m['budget_max'] ?? m['final_amount'] ?? 0.0).toString()) ?? 0.0),
        );
        
        if (status == 'open') {
          available.add(job);
        } else {
          active.add(job);
        }
      }
      
      state = state.copyWith(
        availableJobs: available,
        activeJobs: active,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('[VendorNotifier] loadJobs error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // ── 4. Load Bids ─────────────────────────────────────────────────────────
  Future<void> loadBids() async {
    try {
      final resp = await ApiClient().dio.get('/vendors/my-bids');
      final List<dynamic> rawList = (resp.data['data'] ?? []) as List<dynamic>;
      
      final bids = rawList.map((item) {
        final m = item as Map<String, dynamic>;
        
        String dateSub = '';
        try {
          final raw = m['created_at']?.toString() ?? '';
          if (raw.isNotEmpty) {
            final dt = DateTime.tryParse(raw);
            if (dt != null) dateSub = DateFormat('MMM dd, hh:mm a').format(dt);
          }
        } catch (_) {}

        return VendorBid(
          id: m['id']?.toString() ?? '',
          title: m['work_order_title']?.toString() ?? 'Bid Proposal',
          category: _capitalize(m['category']?.toString() ?? 'General'),
          description: m['message']?.toString() ?? '',
          address: m['property_name']?.toString() ?? '',
          price: m['amount'] is num ? (m['amount'] as num).toDouble() : double.tryParse((m['amount'] ?? 0.0).toString()) ?? 0.0,
          status: _capitalize(m['status']?.toString() ?? 'Pending'),
          dateSubmitted: dateSub.isNotEmpty ? dateSub : 'Recently',
        );
      }).toList();
      
      state = state.copyWith(bids: bids);
    } catch (e) {
      debugPrint('[VendorNotifier] loadBids error: $e');
    }
  }

  // ── 5. Load Payments ─────────────────────────────────────────────────────
  Future<void> loadPayments() async {
    try {
      final resp = await ApiClient().dio.get(ApiConstants.vendorEarnings);
      final data = resp.data['data'] as Map<String, dynamic>? ?? {};
      final summary = data['summary'] as Map<String, dynamic>? ?? {};
      final List<dynamic> history = (data['history'] ?? []) as List<dynamic>;
      
      final payments = history.map((item) {
        final m = item as Map<String, dynamic>;
        
        String payDate = '';
        try {
          final raw = m['created_at']?.toString() ?? '';
          if (raw.isNotEmpty) {
            final dt = DateTime.tryParse(raw);
            if (dt != null) payDate = DateFormat('MMM dd, yyyy').format(dt);
          }
        } catch (_) {}

        return VendorPayment(
          id: m['id']?.toString() ?? '',
          invoiceNumber: m['reference_id']?.toString() ?? 'INV-${m['id']}',
          amount: m['amount'] is num ? (m['amount'] as num).toDouble() : double.tryParse((m['amount'] ?? 0.0).toString()) ?? 0.0,
          date: payDate.isNotEmpty ? payDate : 'Pending',
          status: _capitalize(m['status']?.toString() ?? 'Paid'),
          jobTitle: m['description']?.toString() ?? 'Payment Payout',
        );
      }).toList();
      
      state = state.copyWith(
        payments: payments,
        earnings: summary['total'] is num ? (summary['total'] as num).toDouble() : double.tryParse((summary['total'] ?? 0.0).toString()) ?? 0.0,
        completedPayments: summary['completed'] is num ? (summary['completed'] as num).toDouble() : double.tryParse((summary['completed'] ?? 0.0).toString()) ?? 0.0,
        pendingPayments: summary['pending'] is num ? (summary['pending'] as num).toDouble() : double.tryParse((summary['pending'] ?? 0.0).toString()) ?? 0.0,
      );
    } catch (e) {
      debugPrint('[VendorNotifier] loadPayments error: $e');
    }
  }

  // Complete Onboarding
  Future<void> submitOnboarding(VendorProfile profileData) async {
    state = state.copyWith(profile: profileData.copyWith(isOnboarded: true));
    try {
      await ApiClient().dio.post(
        ApiConstants.userOnboarding,
        data: {
          'step': 5,
          'business_name': profileData.businessName,
          'tax_id': profileData.taxId,
          'service_category': profileData.serviceCategory,
          'bank_name': profileData.bankName,
          'account_number': profileData.accountNumber,
        },
      );
    } catch (e) {
      debugPrint('[VendorNotifier] submitOnboarding API error: $e');
    }
  }

  // Submit Bid on a job
  Future<void> submitBid(
    String jobId,
    double price,
    List<String> scope,
    String message,
  ) async {
    try {
      await ApiClient().dio.post(
        '/maintenance/work-orders/$jobId/bids',
        data: {
          'amount': price,
          'estimatedDays': 3,
          'proposal': message,
          'currency': 'USD',
          'isFixedPrice': true,
        },
      );
      
      // Reload jobs & bids to update the app view
      loadJobs();
      loadBids();
    } catch (e) {
      debugPrint('[VendorNotifier] submitBid error: $e');
    }
  }

  // Update Work Order Status
  Future<void> updateWorkOrderStatus(String jobId, String status) async {
    try {
      // Mapping display status to DB enum status
      String dbStatus = status.toLowerCase();
      if (dbStatus == 'in-progress' || dbStatus == 'in_progress') {
        dbStatus = 'in_progress';
      }

      await ApiClient().dio.put(
        '/maintenance/work-orders/$jobId/status',
        data: {'status': dbStatus},
      );

      // Reload jobs & payments
      loadJobs();
      loadPayments();
      loadStats();
    } catch (e) {
      debugPrint('[VendorNotifier] updateWorkOrderStatus error: $e');
    }
  }

  // Clock In for GPS Check-In
  void clockIn(String jobId) {
    // Update locally or call clock-in API if available
    updateWorkOrderStatus(jobId, 'in_progress');

    state = state.copyWith(
      checkedIn: true,
      checkedInJobId: jobId,
      elapsedSeconds: 0,
    );
  }

  // Clock Out
  void clockOut() {
    if (state.checkedInJobId != null) {
      state = state.copyWith(
        checkedIn: false,
        checkedInJobId: null,
        elapsedSeconds: 0,
      );
    }
  }

  // Increment Clock timer
  void tickTimer() {
    if (state.checkedIn) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    }
  }

  // Set explicit timer value
  void setElapsedSeconds(int secs) {
    state = state.copyWith(elapsedSeconds: secs);
  }
}

final vendorProvider = StateNotifierProvider<VendorNotifier, VendorState>(
  (ref) => VendorNotifier(),
);
