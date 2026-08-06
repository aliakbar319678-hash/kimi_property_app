import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';

// ── Auth ────────────────────────────────────────────
import 'package:tenant_and_landlord_application/screens/auth/welcome_screen.dart';
import 'package:tenant_and_landlord_application/screens/auth/verification_success_screen.dart';
import 'package:tenant_and_landlord_application/screens/auth/verification_rejected_screen.dart';
import 'package:tenant_and_landlord_application/screens/auth/register_screen.dart';
import 'package:tenant_and_landlord_application/screens/auth/login_screen.dart';
import 'package:tenant_and_landlord_application/screens/auth/otp_screen.dart';
import 'package:tenant_and_landlord_application/screens/auth/account_status_screen.dart';
import 'package:tenant_and_landlord_application/screens/auth/support_chat_screen.dart';

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
import 'package:tenant_and_landlord_application/screens/application_checkout_screen.dart';
import 'package:tenant_and_landlord_application/screens/tenant_applications_screen.dart';
import 'package:tenant_and_landlord_application/screens/tenant_kyc_upload_screen.dart';
import 'package:tenant_and_landlord_application/screens/tenant_screening_apply_screen.dart';

// ── Tenant Portal ───────────────────────────────────
import 'package:tenant_and_landlord_application/screens/tenant/tenant_dashboard_screen.dart';
import 'package:tenant_and_landlord_application/screens/tenant/tenant_pay_rent_screen.dart';
import 'package:tenant_and_landlord_application/screens/tenant/tenant_create_ticket_screen.dart';
import 'package:tenant_and_landlord_application/screens/tenant/tenant_lease_screen.dart';
import 'package:tenant_and_landlord_application/screens/tenant/tenant_saved_properties_screen.dart';

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

import 'package:tenant_and_landlord_application/screens/landlord/landlord_onboarding_screen.dart';

import 'package:tenant_and_landlord_application/screens/landlord/ai_smart_assistant_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/add_property_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/edit_property_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/lease_detail_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/landlord_applications_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/landlord_profile_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/landlord_payout_settings_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/landlord_chatbot_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/screening_detail_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/move_in_checklists_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/move_out_inspections_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/invoices_screen.dart';

import 'package:tenant_and_landlord_application/screens/landlord/vendor_directory_screen.dart';
import 'package:tenant_and_landlord_application/screens/landlord/calendar_screen.dart';




// ── Vendor Portal Screens ───────────────────────────
import 'package:tenant_and_landlord_application/screens/vendor/vendor_onboarding_screen.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_shell.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_work_order_details_screen.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_gps_checkin_screen.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_performance_screen.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_job_details_screen.dart';
import 'package:tenant_and_landlord_application/screens/vendor/vendor_submit_bid_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('=====================================================');
  debugPrint('FLUTTER API BASE URL IN USE: ${ApiConstants.baseUrl}');
  debugPrint('=====================================================');
  runApp(
    const ProviderScope(child: TLApp()));
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
        '/login': (_) => const LoginScreen(),
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

        // ── Tenant Portal Routes ──────────────────
        '/tenant_dashboard': (_) => const TenantDashboardScreen(),
        '/tenant_pay_rent': (_) => const TenantPayRentScreen(),
        '/tenant_create_ticket': (_) => const TenantCreateTicketScreen(),
        '/tenant_lease': (_) => const TenantLeaseScreen(),
        '/tenant_saved_properties': (_) => const TenantSavedPropertiesScreen(),

        // ── Landlord Portal Routes ────────────────
        '/landlord_onboarding': (_) => const LandlordOnboardingScreen(),
        '/verification_success': (_) => const VerificationSuccessScreen(),
        '/verification_rejected': (_) => const VerificationRejectedScreen(),
        '/landlord_pending_approval': (_) => const AccountStatusScreen(),
        '/account_status': (_) => const AccountStatusScreen(),
        '/support_chat': (_) => const SupportChatScreen(),
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

        '/landlord_profile': (_) => const LandlordProfileScreen(),
        '/landlord_ai_assistant': (_) => const AISmartAssistantScreen(),
        '/landlord_add_property': (_) => const AddPropertyScreen(),
        '/landlord_edit_property': (_) => const EditPropertyScreen(),
        '/landlord_lease_detail': (_) => const LandlordLeaseDetailScreen(),
        '/landlord_applications': (_) => const LandlordApplicationsScreen(),
        '/landlord_screening_detail': (_) => const ScreeningDetailScreen(),
        '/landlord_payout_settings': (_) => const LandlordPayoutSettingsScreen(),
        '/landlord_chatbot': (_) => const LandlordChatbotScreen(),
        '/landlord_move_in_checklists': (_) => const MoveInChecklistsScreen(),
        '/landlord_move_out_inspections': (_) => const MoveOutInspectionsScreen(),
        '/landlord_invoices': (_) => const LandlordInvoicesScreen(),

        '/landlord_vendor_directory': (_) => const LandlordVendorDirectoryScreen(),
        '/landlord_calendar': (_) => const LandlordCalendarScreen(),


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
        '/application_checkout': (_) => const ApplicationCheckoutScreen(),
        '/tenant_applications': (_) => const TenantApplicationsScreen(),
        '/my-applications': (_) => const TenantApplicationsScreen(),
        '/tenant_kyc_upload': (_) => const TenantKycUploadScreen(),
        '/tenant_screening_apply': (_) => const TenantScreeningApplyScreen(),

        // ── Legacy aliases ────────────────────────
        '/home_dashboard': (_) => const HomeDashboardScreen(),
        '/profile_screen': (_) => const ProfileScreen(),
        '/chat_list': (_) => const ChatListScreen(),
      },
    );
  }
}
