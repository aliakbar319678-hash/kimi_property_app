class ApiConstants {
  // ── Base URL ────────────────────────────────────────────────────────────────
  static const String baseUrl = 'http://192.168.1.10:5000/api/v1';
  static const String socketUrl = 'http://192.168.1.10:5000';

  // ── Auth ────────────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';

  // ── Users / Profile ─────────────────────────────────────────────────────────
  static const String userProfile = '/auth/me';
  static const String usersTenants = '/users/tenants';
  static const String updateProfile = '/users/me/profile';
  static const String onboardingStep = '/users/me/onboarding';

  // ── Properties ──────────────────────────────────────────────────────────────
  static const String properties = '/properties';
  static const String propertySearch = '/properties/search';
  static const String savedProperties = '/properties/saved/me';

  // ── Applications ────────────────────────────────────────────────────────────
  static const String applications = '/applications';

  // ── Screening ────────────────────────────────────────────────────────────────
  static String screeningApplication(String id) => '/screening/applications/$id';
  static String screeningCreditReport(String id) => '/screening/applications/$id/credit-report';
  static String screeningBackgroundCheck(String id) => '/screening/applications/$id/background-check';
  static String screeningDecision(String id) => '/screening/applications/$id/decision';

  // Dynamic property routes (use with string interpolation)
  // GET/PUT/DELETE /properties/{id}
  // GET/POST       /properties/{id}/units
  // PUT/DELETE     /properties/{id}/units/{unitId}

  // ── Leases ──────────────────────────────────────────────────────────────────
  static const String leases = '/leases';
  static const String leasesDashboard = '/leases/dashboard';
  static const String leasesExpiringSoon = '/leases/expiring-soon';

  // Dynamic lease routes (use with string interpolation)
  // POST /leases/{id}/renew
  // PUT  /leases/{id}/status
  // GET  /leases/{id}

  // ── AI ──────────────────────────────────────────────────────────────────────
  static const String aiChat = '/ai/chat';
  static const String aiLandlordChat = '/ai/landlord-chat';

  // ── Finance ─────────────────────────────────────────────────────────────────
  static const String financeDashboard = '/finance/dashboard';
  static const String initiatePayment = '/finance/payments/initiate';
  static const String vendorEarnings = '/finance/vendor/earnings';
  static const String generateInvoice = '/finance/invoices';
  static const String invoices = '/finance/invoices';
  static const String recordManualPayment = '/finance/invoices/record-manual';
  static const String payoutAccount = '/payouts/landlord/accounts';

  // ── Maintenance & Jobs ───────────────────────────────────────────────────────
  static const String workOrders = '/maintenance/work-orders';
  static const String maintenanceBids = '/maintenance/bids';
  static const String vendorJobs = '/maintenance/vendor/jobs';
  static const String jobs = '/jobs';

  // Dynamic maintenance routes
  static String workOrderById(String id) => '/maintenance/work-orders/$id';
  static String workOrderBids(String id) => '/maintenance/work-orders/$id/bids';
  static String bidAccept(String id) => '/maintenance/bids/$id/accept';
  static String workOrderStatus(String id) => '/maintenance/work-orders/$id/status';

  // ── Tenant ───────────────────────────────────────────────────────────────────
  static const String tenantActiveLease = '/tenant/active-lease';

  // ── Vendors ──────────────────────────────────────────────────────────────────
  static const String vendorDirectory = '/vendors/directory';

  // ── Uploads ──────────────────────────────────────────────────────────────────
  static const String uploadsAvatar = '/uploads/avatar';
  static String uploadsPropertyImage(String propertyId) =>
      '/uploads/property/$propertyId/image';
  static String uploadsWorkOrderPhoto(String workOrderId) =>
      '/uploads/work-order/$workOrderId/photo';

  // ── Notifications ────────────────────────────────────────────────────────────
  static const String notifications = '/notifications';
  static const String notificationsUnread = '/notifications/unread';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationRead(String id) => '/notifications/$id/read';

  // ── Chat ─────────────────────────────────────────────────────────────────────
  static const String chatRooms = '/chat/rooms';

  // ── Reports ──────────────────────────────────────────────────────────────────
  static const String reports = '/reports';

  // ── Helper: build property URL ───────────────────────────────────────────────
  static String property(String id) => '/properties/$id';
  static String propertyUnits(String propertyId) =>
      '/properties/$propertyId/units';
  static String propertyUnit(String propertyId, String unitId) =>
      '/properties/$propertyId/units/$unitId';

  // ── Helper: build lease URL ──────────────────────────────────────────────────
  static String leaseById(String id) => '/leases/$id';
  static String leaseRenew(String id) => '/leases/$id/renew';
  static String leaseStatus(String id) => '/leases/$id/status';
  static String leaseInspections(String id) => '/leases/$id/inspections';

  // ── Support Tickets ───────────────────────────────────────────────────────────
  static const String supportTickets = '/tickets';
  static String supportTicketById(String id) => '/tickets/$id';
  static String supportTicketComments(String id) => '/tickets/$id/comments';

}
