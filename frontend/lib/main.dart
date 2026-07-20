import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Auth ────────────────────────────────────────────
import 'package:tenant_and_landlord_application/screens/auth/welcome_screen.dart';
import 'package:tenant_and_landlord_application/screens/auth/register_screen.dart';
import 'package:tenant_and_landlord_application/screens/auth/otp_screen.dart';

// ── Onboarding ──────────────────────────────────────
import 'package:tenant_and_landlord_application/screens/basic_profile_screen.dart';
import 'package:tenant_and_landlord_application/screens/employment_screen.dart';
import 'package:tenant_and_landlord_application/screens/preferences_screen.dart';

// ── Main Shell (Bottom Nav) ─────────────────────────
import 'package:tenant_and_landlord_application/screens/tenant_shell.dart';

// ── Standalone Screens ──────────────────────────────
import 'package:tenant_and_landlord_application/screens/home_dashboard_screen.dart';
import 'package:tenant_and_landlord_application/screens/property_details_screen.dart';

import 'package:tenant_and_landlord_application/screens/filter_screen.dart';
import 'package:tenant_and_landlord_application/screens/notification_screen.dart';
import 'package:tenant_and_landlord_application/screens/chat_list_screen.dart';
import 'package:tenant_and_landlord_application/screens/chat_details_screen.dart';
import 'package:tenant_and_landlord_application/screens/profile_screen.dart';
import 'package:tenant_and_landlord_application/screens/payment_history_screen.dart';
import 'package:tenant_and_landlord_application/screens/pay_rent_screen.dart';
import 'package:tenant_and_landlord_application/screens/lease_summary_screen.dart';
import 'package:tenant_and_landlord_application/screens/request_tracking_screen.dart';
import 'package:tenant_and_landlord_application/screens/maintenance_request_screen.dart';

// ── Theme ───────────────────────────────────────────
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

// ── Role Selection & Landlord Screens ───────────────
import 'package:tenant_and_landlord_application/screens/auth/role_selection_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/landlord_shell.dart';
import 'package:tenant_and_landlord_application/screens/landlord/property_details_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/tenant_details_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/create_work_order_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/work_order_details_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/post_job_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/bids_received_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/confirm_assignment_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/job_chat_room_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/lease_management_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/financial_overview_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/reports_analytics_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/ai_smart_assistant_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/add_property_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/lease_detail_screen.dart';

// ── Vendor Portal Screens ───────────────────────────
import 'package:tenant_and_landlord_application/screens/vendor/vendor_onboarding_screen.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_shell.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_work_order_details_screen.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_gps_checkin_screen.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_performance_screen.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_job_details_screen.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_submit_bid_screen.dart';


void main() {
  runApp(const ProviderScope(child: TLApp()));
}

class TLApp extends StatelessWidget {
  const TLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'T&L – Tenant & Landlord',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        // ── Auth ──────────────────────────────────
        '/': (_) => const RoleSelectionScreen(),
        '/welcome': (_) => const WelcomeScreen(),
        '/register': (_) => const RegisterScreen(),
        '/login': (_) => const RegisterScreen(),
        '/otp': (_) => const OtpScreen(),
        '/role_selection': (_) => const RoleSelectionScreen(),

        // ── Onboarding ────────────────────────────
        '/basic_profile': (_) => const BasicProfileScreen(),
        '/employment': (_) => const EmploymentScreen(),
        '/preferences': (_) => const PreferencesScreen(),

        // ── Main Shell (bottom nav) ───────────────
        '/home': (_) => const TenantShell(initialIndex: 0),
        '/search': (_) => const TenantShell(initialIndex: 1),
        '/payments': (_) => const TenantShell(initialIndex: 2),
        '/chat': (_) => const TenantShell(initialIndex: 3),
        '/profile': (_) => const TenantShell(initialIndex: 4),

        // ── Landlord Portal Routes ────────────────
        '/landlord_home': (_) => const LandlordShell(initialIndex: 0),
        '/landlord_properties': (_) => const LandlordShell(initialIndex: 1),
        '/landlord_tenants': (_) => const LandlordShell(initialIndex: 2),
        '/landlord_maintenance': (_) => const LandlordShell(initialIndex: 3),
        '/landlord_property_details': (_) => const LandlordPropertyDetailsScreen(),
        '/landlord_tenant_details': (_) => const LandlordTenantDetailsScreen(),
        '/landlord_create_work_order': (_) => const CreateWorkOrderScreen(),
        '/landlord_work_order_details': (_) => const WorkOrderDetailsScreen(),
        '/landlord_post_job': (_) => const PostJobScreen(),
        '/landlord_bids_received': (_) => const BidsReceivedScreen(),
        '/landlord_confirm_assignment': (_) => const ConfirmAssignmentScreen(),
        '/landlord_job_chat': (_) => const JobChatRoomScreen(),
        '/landlord_lease_management': (_) => const LeaseManagementScreen(),
        '/landlord_financial_overview': (_) => const FinancialOverviewScreen(),
        '/landlord_reports_analytics': (_) => const ReportsAnalyticsScreen(),
        '/landlord_ai_assistant': (_) => const AISmartAssistantScreen(),
        '/landlord_add_property': (_) => const AddPropertyScreen(),
        '/landlord_lease_detail': (_) => const LandlordLeaseDetailScreen(),

        // ── Vendor Portal Routes ──────────────────
        '/vendor_onboarding': (_) => const VendorOnboardingScreen(),
        '/vendor_home': (_) => const VendorShell(initialIndex: 0),
        '/vendor_work_order_details': (_) => const VendorWorkOrderDetailsScreen(),
        '/vendor_gps_checkin': (_) => const VendorGpsCheckinScreen(),
        '/vendor_performance': (_) => const VendorPerformanceScreen(),
        '/vendor_job_details': (_) => const VendorJobDetailsScreen(),
        '/vendor_submit_bid': (_) => const VendorSubmitBidScreen(),


        // ── Standalone (push on top of shell) ────
        '/property_details': (_) => const PropertyDetailsScreen(),
        '/filter': (_) => const FilterScreen(),
        '/notifications': (_) => const NotificationsScreen(),
        '/chat/detail': (_) => const ChatDetailScreen(),
        '/payment_history': (_) => const PaymentHistoryScreen(),
        '/pay_rent': (_) => const PayRentScreen(),
        '/lease_summary': (_) => const LeaseSummaryScreen(),
        '/request_tracking': (_) => const RequestTrackingScreen(),
        '/maintenance_request': (_) => const MaintenanceRequestScreen(),

        // ── Legacy aliases ────────────────────────
        '/home_dashboard': (_) => const HomeDashboardScreen(),
        '/profile_screen': (_) => const ProfileScreen(),
        '/chat_list': (_) => const ChatListScreen(),
      },
    );
  }
}
