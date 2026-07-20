class ApiConstants {
  // ── Base URL ────────────────────────────────────────────────────────────────
  // Use your computer's local network IP so a real phone on the same WiFi can
  // reach the backend. Change this if your IP changes.
  static const String baseUrl = 'http://192.168.1.14:5000/api/v1';

  // ── Auth ────────────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';

  // ── Users / Profile ─────────────────────────────────────────────────────────
  static const String userProfile = '/users/profile';
  static const String usersTenants = '/users/tenants';
  static const String updateProfile = '/users/me/profile';
  static const String onboardingStep = '/users/me/onboarding';

  // ── Properties ──────────────────────────────────────────────────────────────
  static const String properties = '/properties';
  static const String propertySearch = '/properties/search';
  static const String savedProperties = '/properties/saved/me';

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

  // ── Finance ─────────────────────────────────────────────────────────────────
  static const String financeDashboard = '/finance/dashboard';
  static const String initiatePayment = '/finance/payments/initiate';
  static const String vendorEarnings = '/finance/vendor/earnings';
  static const String generateInvoice = '/finance/invoices';

  // ── Maintenance ─────────────────────────────────────────────────────────────
  static const String workOrders = '/maintenance/work-orders';
  static const String maintenanceBids = '/maintenance/bids';
  static const String vendorJobs = '/maintenance/vendor/jobs';

  // Dynamic maintenance routes
  // GET  /maintenance/work-orders/{id}
  // GET  /maintenance/work-orders/{id}/bids
  // POST /maintenance/work-orders/{id}/bids
  // POST /maintenance/bids/{id}/accept
  // PUT  /maintenance/work-orders/{id}/status

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

  // ── Helper: build maintenance URL ────────────────────────────────────────────
  static String workOrderById(String id) => '/maintenance/work-orders/$id';
  static String workOrderBids(String id) => '/maintenance/work-orders/$id/bids';
  static String workOrderStatus(String id) =>
      '/maintenance/work-orders/$id/status';
  static String bidAccept(String bidId) => '/maintenance/bids/$bidId/accept';
}
