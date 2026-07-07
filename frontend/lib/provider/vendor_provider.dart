import 'package:flutter_riverpod/legacy.dart';
import 'vendor_state.dart';

class VendorNotifier extends StateNotifier<VendorState> {
  VendorNotifier() : super(const VendorState()) {
    _loadInitialData();
  }

  void _loadInitialData() {
    final defaultAvailableJobs = [
      const VendorWorkOrder(
        id: 'job_find_1',
        title: 'Kitchen Sink Leak',
        description:
            'Water is leaking from the hot water line under the kitchen sink. Requires gasket replacement and pipe inspection.',
        propertyName: 'Sunset Apartments',
        unitName: 'Unit 402',
        tenantName: 'John Smith',
        priority: 'High',
        status: 'Request',
        category: 'Plumbing',
        date: 'May 26, 2026',
        timeSlot: '2:00 PM - 4:00 PM',
        accessInstructions: 'Tenant will be home, please ring bell.',
        address: 'Sunset Apartments, Unit 402',
        latitude: 47.6062,
        longitude: -122.3321,
        bidAmount: 350.0,
      ),
      const VendorWorkOrder(
        id: 'job_find_2',
        title: 'AC Maintenance (2 Units)',
        description:
            'Annual servicing for two central AC split systems. Needs filter cleaning and refrigerant level check.',
        propertyName: 'Green Valley Condos',
        unitName: 'Unit B-12',
        tenantName: 'David Miller',
        priority: 'Medium',
        status: 'Request',
        category: 'HVAC',
        date: 'May 28, 2026',
        timeSlot: '10:00 AM - 12:00 PM',
        accessInstructions: 'Gate code 4821. Key in lockbox.',
        address: '821 Valley Dr, Bellevue',
        latitude: 47.6101,
        longitude: -122.3421,
        bidAmount: 200.0,
      ),
      const VendorWorkOrder(
        id: 'job_find_3',
        title: 'Wall Painting - Bathroom',
        description:
            'Scrape minor peeling paint and apply two coats of moisture-resistant semi-gloss paint in master bathroom.',
        propertyName: 'Maple Residency',
        unitName: 'Unit 4',
        tenantName: 'Sarah Jenkins',
        priority: 'Low',
        status: 'Request',
        category: 'General',
        date: 'May 29, 2026',
        timeSlot: '9:00 AM - 5:00 PM',
        accessInstructions: 'Coordinate with Sarah at (555) 765-4321.',
        address: '12 Valley Rd, Suite A',
        latitude: 47.5998,
        longitude: -122.3211,
        bidAmount: 950.0,
      ),
      const VendorWorkOrder(
        id: 'job_find_4',
        title: 'Fence Post Repair',
        description:
            'Two wooden fence posts in the backyard have rotted at the base and need replacement/re-setting in concrete.',
        propertyName: 'Eastside Duplex',
        unitName: 'Left Unit',
        tenantName: 'Robert Chen',
        priority: 'Medium',
        status: 'Request',
        category: 'General',
        date: 'June 01, 2026',
        timeSlot: '1:00 PM - 5:00 PM',
        accessInstructions: 'Side gate is unlocked. Job is entirely outdoors.',
        address: '1482 112th Ave NE, Bellevue',
        latitude: 47.6205,
        longitude: -122.3150,
        bidAmount: 250.0,
      ),
    ];

    final defaultActiveJobs = [
      const VendorWorkOrder(
        id: 'job_act_1',
        title: 'Unit 402 Water Leak',
        description:
            'Water leaking behind the washing machine valve. High priority leakage causing drywall dampness.',
        propertyName: 'Sunset Apartments',
        unitName: 'Unit 402',
        tenantName: 'John Smith',
        priority: 'High',
        status: 'Assigned',
        category: 'Plumbing',
        date: 'Friday, May 29',
        timeSlot: '2:30 PM - 4:30 PM',
        accessInstructions:
            'Call tenant John (555-123-4567) 30 minutes before arrival. Key with landlord if unanswered.',
        address: 'Sunset Apartments, Unit 402',
        latitude: 47.6062,
        longitude: -122.3321,
        bidAmount: 350.0,
      ),
      const VendorWorkOrder(
        id: 'job_act_2',
        title: 'Unit 105 AC Repair',
        description:
            'AC blowing hot air. Tenant reports compressor makes loud clicking noise and won\'t turn on.',
        propertyName: 'Sunset Apartments',
        unitName: 'Unit 105',
        tenantName: 'Michael Chang',
        priority: 'Emergency',
        status: 'In-Progress',
        category: 'HVAC',
        date: 'Today, May 25',
        timeSlot: '10:00 AM - 12:00 PM',
        accessInstructions:
            'Landlord will meet on-site. Master key is at the leasing office.',
        address: 'Sunset Apartments, Unit 105',
        latitude: 47.6065,
        longitude: -122.3315,
        bidAmount: 450.0,
      ),
      const VendorWorkOrder(
        id: 'job_act_3',
        title: 'Toilet Installation',
        description:
            'Install brand new American Standard round toilet in guest bathroom. Old toilet already removed.',
        propertyName: 'Maple Residency',
        unitName: 'Unit 4',
        tenantName: 'Sarah Jenkins',
        priority: 'Medium',
        status: 'Completed',
        category: 'Plumbing',
        date: 'May 15, 2026',
        timeSlot: '2:00 PM - 4:00 PM',
        accessInstructions: 'Tenant will open the door.',
        address: '12 Valley Rd, Suite A',
        latitude: 47.5998,
        longitude: -122.3211,
        bidAmount: 240.0,
        durationOnSite: 5400, // 1.5 hours
      ),
    ];

    final defaultBids = [
      const VendorBid(
        id: 'bid_1',
        title: 'Kitchen Sink Leak',
        category: 'Plumbing',
        description: 'Repair leaking hot water line under kitchen sink.',
        address: 'Sunset Apartments, Unit 402',
        price: 350.0,
        status: 'Pending',
        dateSubmitted: 'Today, 11:30 AM',
        scopeChecklist: ['Labor & Inspection', 'Pipe Fittings & Gaskets'],
        landlordMessage: 'I have the parts in stock and can visit this week.',
      ),
      const VendorBid(
        id: 'bid_2',
        title: 'Outlet Installation',
        category: 'Electrical',
        description: 'Install 2 new GFCI outlets in the kitchen back wall.',
        address: 'Maple Residency, Unit 4',
        price: 275.0,
        status: 'Accepted',
        dateSubmitted: 'Yesterday, 4:15 PM',
        scopeChecklist: ['Labor', 'Materials & Conduit', 'Electrical Permit'],
        landlordMessage:
            'Price covers all parts, wiring, and premium GFCI outlets.',
      ),
      const VendorBid(
        id: 'bid_3',
        title: 'Cabinet Door Repair',
        category: 'General',
        description: 'Re-align and repair 4 kitchen cabinet hinges.',
        address: 'Green Valley Condos, Unit B-12',
        price: 180.0,
        status: 'Rejected',
        dateSubmitted: 'May 18, 2026',
        scopeChecklist: ['Labor', 'Hinge hardware'],
        landlordMessage: 'Can complete in 1 hour.',
      ),
    ];

    final defaultPayments = [
      const VendorPayment(
        id: 'pay_1',
        invoiceNumber: 'INV-8954',
        amount: 350.00,
        date: 'Oct 24, 2025',
        status: 'Paid',
        jobTitle: 'Kitchen Leak Repair',
      ),
      const VendorPayment(
        id: 'pay_2',
        invoiceNumber: 'INV-8210',
        amount: 120.00,
        date: 'Oct 19, 2025',
        status: 'Paid',
        jobTitle: 'Light Fixture Replace',
      ),
      const VendorPayment(
        id: 'pay_3',
        invoiceNumber: 'INV-9021',
        amount: 450.00,
        date: 'Nov 05, 2025',
        status: 'Paid',
        jobTitle: 'AC Compressor Install',
      ),
      const VendorPayment(
        id: 'pay_4',
        invoiceNumber: 'INV-9204',
        amount: 620.00,
        date: 'Dec 12, 2025',
        status: 'Paid',
        jobTitle: 'Drywall Repair & Painting',
      ),
    ];

    state = VendorState(
      profile: const VendorProfile(isOnboarded: false),
      availableJobs: defaultAvailableJobs,
      activeJobs: defaultActiveJobs,
      bids: defaultBids,
      payments: defaultPayments,
      earnings: 8540.0,
      pendingPayments: 1348.0,
      completedPayments: 7208.0,
      rating: 4.8,
      jobsCount: 248,
      onTimeRate: 96.0,
      responseTime: "18 Mins",
    );
  }

  // Complete Onboarding
  void submitOnboarding(VendorProfile profileData) {
    state = state.copyWith(profile: profileData.copyWith(isOnboarded: true));
  }

  // Submit Bid on a job
  void submitBid(
    String jobId,
    double price,
    List<String> scope,
    String message,
  ) {
    // Find the available job to copy details
    final job = state.availableJobs.firstWhere(
      (j) => j.id == jobId,
      orElse: () => const VendorWorkOrder(
        id: 'unknown',
        title: 'General Maintenance',
        description: '',
        propertyName: '',
        unitName: '',
        tenantName: '',
        priority: 'Medium',
        status: 'Request',
        category: 'General',
        date: '',
        timeSlot: '',
        accessInstructions: '',
        address: '',
        bidAmount: 0.0,
      ),
    );

    final newBid = VendorBid(
      id: 'bid_${DateTime.now().millisecondsSinceEpoch}',
      title: job.title,
      category: job.category,
      description: job.description,
      address: job.address,
      price: price,
      status: 'Pending',
      dateSubmitted: 'Just now',
      scopeChecklist: scope,
      landlordMessage: message,
    );

    // Remove job from available list and add bid
    final updatedAvailable = state.availableJobs
        .where((j) => j.id != jobId)
        .toList();

    state = state.copyWith(
      availableJobs: updatedAvailable,
      bids: [newBid, ...state.bids],
    );
  }

  // Update Work Order Status
  void updateWorkOrderStatus(String jobId, String status) {
    final updatedActive = state.activeJobs.map((j) {
      if (j.id == jobId) {
        // If completing, we record the elapsed check-in time as duration on site
        int duration = j.durationOnSite;
        if (status == 'Completed' && state.checkedInJobId == jobId) {
          duration = state.elapsedSeconds;
        }
        return j.copyWith(status: status, durationOnSite: duration);
      }
      return j;
    }).toList();

    // If completed, update financial stats
    double newEarnings = state.earnings;
    double newCompleted = state.completedPayments;
    final List<VendorPayment> updatedPayments = [...state.payments];

    if (status == 'Completed') {
      final completedJob = state.activeJobs.firstWhere((j) => j.id == jobId);
      newEarnings += completedJob.bidAmount;
      newCompleted += completedJob.bidAmount;

      // Add to payment history
      final newPayment = VendorPayment(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        invoiceNumber: 'INV-${1000 + state.payments.length + 1}',
        amount: completedJob.bidAmount,
        date: 'Today',
        status: 'Paid',
        jobTitle: completedJob.title,
      );
      updatedPayments.insert(0, newPayment);

      // Clean up clock-in if this job was active
      if (state.checkedInJobId == jobId) {
        state = state.copyWith(
          checkedIn: false,
          checkedInJobId: null,
          elapsedSeconds: 0,
        );
      }
    }

    state = state.copyWith(
      activeJobs: updatedActive,
      earnings: newEarnings,
      completedPayments: newCompleted,
      payments: updatedPayments,
    );
  }

  // Clock In for GPS Check-In
  void clockIn(String jobId) {
    final nowStr =
        "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";

    // Update job status to 'In-Progress'
    final updatedActive = state.activeJobs.map((j) {
      if (j.id == jobId) {
        return j.copyWith(status: 'In-Progress', checkInTime: nowStr);
      }
      return j;
    }).toList();

    state = state.copyWith(
      activeJobs: updatedActive,
      checkedIn: true,
      checkedInJobId: jobId,
      elapsedSeconds: 0,
    );
  }

  // Clock Out
  void clockOut() {
    if (state.checkedInJobId != null) {
      final jobId = state.checkedInJobId!;
      // Mark it as In-Progress (just checked out of site) or we can prompt to complete
      final updatedActive = state.activeJobs.map((j) {
        if (j.id == jobId) {
          return j.copyWith(durationOnSite: state.elapsedSeconds);
        }
        return j;
      }).toList();

      state = state.copyWith(
        activeJobs: updatedActive,
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
