# Graph Report - c:\all projects\tenant-and-landlord-application-master\tenant-and-landlord-application-master  (2026-07-04)

## Corpus Check
- 167 files · ~95,613 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1363 nodes · 2005 edges · 94 communities (90 shown, 4 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Windows Platform Layer|Windows Platform Layer]]
- [[_COMMUNITY_iOSmacOS Cocoa Embedding|iOS/macOS Cocoa Embedding]]
- [[_COMMUNITY_Vendor State Management|Vendor State Management]]
- [[_COMMUNITY_Payment & Lease Management|Payment & Lease Management]]
- [[_COMMUNITY_Landlord & Home Dashboard State|Landlord & Home Dashboard State]]
- [[_COMMUNITY_App Entry & GoRouter|App Entry & GoRouter]]
- [[_COMMUNITY_Landlord State Data Model|Landlord State Data Model]]
- [[_COMMUNITY_Custom Painters & Animations|Custom Painters & Animations]]
- [[_COMMUNITY_Shared Screen Helpers|Shared Screen Helpers]]
- [[_COMMUNITY_Vendor Onboarding Screen|Vendor Onboarding Screen]]
- [[_COMMUNITY_LinuxGTK Platform Layer|Linux/GTK Platform Layer]]
- [[_COMMUNITY_Landlord Bid Management|Landlord Bid Management]]
- [[_COMMUNITY_App Theme & Styling|App Theme & Styling]]
- [[_COMMUNITY_User Profile Provider|User Profile Provider]]
- [[_COMMUNITY_Auth State (Freezed)|Auth State (Freezed)]]
- [[_COMMUNITY_Vendor GPS & Job Details|Vendor GPS & Job Details]]
- [[_COMMUNITY_Shared Screen State|Shared Screen State]]
- [[_COMMUNITY_Common UI Widgets|Common UI Widgets]]
- [[_COMMUNITY_Preferences Screen|Preferences Screen]]
- [[_COMMUNITY_Maintenance Request Screen|Maintenance Request Screen]]
- [[_COMMUNITY_Employment Provider|Employment Provider]]
- [[_COMMUNITY_Home Dashboard Screen|Home Dashboard Screen]]
- [[_COMMUNITY_Payment Maintenance State|Payment Maintenance State]]
- [[_COMMUNITY_Vendor Shell Navigation|Vendor Shell Navigation]]
- [[_COMMUNITY_OTP Auth Screen|OTP Auth Screen]]
- [[_COMMUNITY_Search & Filter Provider|Search & Filter Provider]]
- [[_COMMUNITY_Employment Screen|Employment Screen]]
- [[_COMMUNITY_Create Work Order|Create Work Order]]
- [[_COMMUNITY_Notifications Screen|Notifications Screen]]
- [[_COMMUNITY_Vendor Bid Submission|Vendor Bid Submission]]
- [[_COMMUNITY_Chat Details Screen|Chat Details Screen]]
- [[_COMMUNITY_Basic Profile Screen|Basic Profile Screen]]
- [[_COMMUNITY_AI Smart Assistant|AI Smart Assistant]]
- [[_COMMUNITY_Auth Provider & API Core|Auth Provider & API Core]]
- [[_COMMUNITY_Welcome Screen|Welcome Screen]]
- [[_COMMUNITY_Home Dashboard & Search|Home Dashboard & Search]]
- [[_COMMUNITY_Property Details Screen|Property Details Screen]]
- [[_COMMUNITY_API Client Core|API Client Core]]
- [[_COMMUNITY_Landlord Maintenance Dashboard|Landlord Maintenance Dashboard]]
- [[_COMMUNITY_Chat List Screen|Chat List Screen]]
- [[_COMMUNITY_Payment History Screen|Payment History Screen]]
- [[_COMMUNITY_Landlord Shell Navigation|Landlord Shell Navigation]]
- [[_COMMUNITY_Tenant Directory|Tenant Directory]]
- [[_COMMUNITY_Windows Runner Main|Windows Runner Main]]
- [[_COMMUNITY_Landlord Post Job|Landlord Post Job]]
- [[_COMMUNITY_Tenant Shell Navigation|Tenant Shell Navigation]]
- [[_COMMUNITY_Freezed State Patterns|Freezed State Patterns]]
- [[_COMMUNITY_Landlord Financial Overview|Landlord Financial Overview]]
- [[_COMMUNITY_Auth Register Screen|Auth Register Screen]]
- [[_COMMUNITY_Maintenance Provider Actions|Maintenance Provider Actions]]
- [[_COMMUNITY_Vendor Billing Screen|Vendor Billing Screen]]
- [[_COMMUNITY_Vendor Find Jobs|Vendor Find Jobs]]
- [[_COMMUNITY_Vendor My Bids|Vendor My Bids]]
- [[_COMMUNITY_Vendor Work Orders|Vendor Work Orders]]
- [[_COMMUNITY_TL AppBar Widget|TL AppBar Widget]]
- [[_COMMUNITY_TL Input Field Widget|TL Input Field Widget]]
- [[_COMMUNITY_Web Manifest & PWA|Web Manifest & PWA]]
- [[_COMMUNITY_Post Job & Property State|Post Job & Property State]]
- [[_COMMUNITY_Screen Settings Provider|Screen Settings Provider]]
- [[_COMMUNITY_Landlord Job Chat Room|Landlord Job Chat Room]]
- [[_COMMUNITY_Property Portfolio Screen|Property Portfolio Screen]]
- [[_COMMUNITY_Request Tracking & Profile State|Request Tracking & Profile State]]
- [[_COMMUNITY_Onboarding Progress Bar|Onboarding Progress Bar]]
- [[_COMMUNITY_API Constants|API Constants]]
- [[_COMMUNITY_Profile & Notifications Screen|Profile & Notifications Screen]]
- [[_COMMUNITY_Landlord Reports & Analytics|Landlord Reports & Analytics]]
- [[_COMMUNITY_Search Filter Screen|Search Filter Screen]]
- [[_COMMUNITY_Role Selection Screen|Role Selection Screen]]
- [[_COMMUNITY_Vendor Dashboard Screen|Vendor Dashboard Screen]]
- [[_COMMUNITY_Android Plugin Registration|Android Plugin Registration]]
- [[_COMMUNITY_iOS LLDB Debug Helper|iOS LLDB Debug Helper]]
- [[_COMMUNITY_Chat Detail Routes|Chat Detail Routes]]
- [[_COMMUNITY_Bottom Navigation Bar|Bottom Navigation Bar]]
- [[_COMMUNITY_Welcome Auth State|Welcome Auth State]]
- [[_COMMUNITY_Lease Summary State|Lease Summary State]]
- [[_COMMUNITY_Maintenance Request State|Maintenance Request State]]
- [[_COMMUNITY_Payment History State|Payment History State]]
- [[_COMMUNITY_Pay Rent State|Pay Rent State]]
- [[_COMMUNITY_Chat Detail State|Chat Detail State]]
- [[_COMMUNITY_Chat List State|Chat List State]]
- [[_COMMUNITY_Notifications State|Notifications State]]
- [[_COMMUNITY_User Profile State|User Profile State]]
- [[_COMMUNITY_Bid Data Model|Bid Data Model]]
- [[_COMMUNITY_OTP Auth State|OTP Auth State]]
- [[_COMMUNITY_Chat Message Model|Chat Message Model]]
- [[_COMMUNITY_Property Data Model|Property Data Model]]
- [[_COMMUNITY_Tenant Data Model|Tenant Data Model]]
- [[_COMMUNITY_Android MainActivity|Android MainActivity]]
- [[_COMMUNITY_iOS Flutter Export Env|iOS Flutter Export Env]]
- [[_COMMUNITY_macOS Flutter Export Env|macOS Flutter Export Env]]
- [[_COMMUNITY_NullString Node|Null/String Node]]

## God Nodes (most connected - your core abstractions)
1. `landlordProvider` - 28 edges
2. `vendorProvider` - 25 edges
3. `Win32Window` - 22 edges
4. `MessageHandler` - 12 edges
5. `FlutterWindow` - 10 edges
6. `Create` - 10 edges
7. `WndProc` - 10 edges
8. `MessageHandler` - 9 edges
9. `_MyApplication` - 7 edges
10. `OnCreate` - 7 edges

## Surprising Connections (you probably didn't know these)
- `build` --references--> `landlordProvider`  [EXTRACTED]
  lib/screens/landlord/confirm_assignment_screen.dart → lib/provider/landlord_provider.dart
- `build` --references--> `landlordProvider`  [EXTRACTED]
  lib/screens/landlord/create_work_order_screen.dart → lib/provider/landlord_provider.dart
- `build` --references--> `landlordProvider`  [EXTRACTED]
  lib/screens/landlord/job_chat_room_screen.dart → lib/provider/landlord_provider.dart
- `_sendMessage` --references--> `landlordProvider`  [EXTRACTED]
  lib/screens/landlord/job_chat_room_screen.dart → lib/provider/landlord_provider.dart
- `build` --references--> `landlordProvider`  [EXTRACTED]
  lib/screens/landlord/reports_analytics_screen.dart → lib/provider/landlord_provider.dart

## Import Cycles
- None detected.

## Communities (94 total, 4 thin omitted)

### Community 0 - "Windows Platform Layer"
Cohesion: 0.06
Nodes (53): PluginRegistry, Point, RECT, Size, unique_ptr, RegisterPlugins(), DartProject, HWND (+45 more)

### Community 1 - "iOS/macOS Cocoa Embedding"
Cohesion: 0.05
Nodes (31): Any, Cocoa, Flutter, flutter_secure_storage_darwin, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS (+23 more)

### Community 2 - "Vendor State Management"
Cohesion: 0.05
Nodes (47): _, _activeJobs, _availableJobs, _bids, businessName, category, checkInTime, class (+39 more)

### Community 3 - "Payment & Lease Management"
Cohesion: 0.05
Nodes (44): double w, h,, leaseSummaryProvider, payRentProvider, requestTrackingProvider, PaymentMethod, _AppBar, build, child (+36 more)

### Community 4 - "Landlord & Home Dashboard State"
Cohesion: 0.05
Nodes (38): landlord_state.dart, copyWith, HomeDashboardNotifier, HomeDashboardState, selectedFilter, selectFilter, addMemoToTenant, addUnit (+30 more)

### Community 5 - "App Entry & GoRouter"
Cohesion: 0.05
Nodes (36): build, main, TLApp, package:tenant_and_landlord_application/screens/auth/otp_screen.dart, package:tenant_and_landlord_application/screens/auth/register_screen.dart, package:tenant_and_landlord_application/screens/auth/role_selection_screen.dart, package:tenant_and_landlord_application/screens/auth/welcome_screen.dart, package:tenant_and_landlord_application/screens/basic_profile_screen.dart (+28 more)

### Community 6 - "Landlord State Data Model"
Cohesion: 0.07
Nodes (30): _, _amenities, _bids, _chatMessages, class, date, dateJoined, hashCode (+22 more)

### Community 7 - "Custom Painters & Animations"
Cohesion: 0.07
Nodes (28): Animation, AnimationController, CustomPainter, dart:math, double?, build, createState, dispose (+20 more)

### Community 8 - "Shared Screen Helpers"
Cohesion: 0.08
Nodes (27): _PropStat, _SavedPropertyCard, _FieldLabel, _InputField, _PreferenceCard, _ToggleBtn, badge, child (+19 more)

### Community 9 - "Vendor Onboarding Screen"
Cohesion: 0.07
Nodes (27): _accountController, _addressController, _agreeToTerms, _bankNameController, build, _buildCardContainer, _buildDocumentRow, _buildDropdownField (+19 more)

### Community 10 - "Linux/GTK Platform Layer"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 11 - "Landlord Bid Management"
Cohesion: 0.12
Nodes (20): build, build, ConfirmAssignmentScreen, _ConfirmAssignmentScreenState, createState, _includeTenant, build, LeaseManagementScreen (+12 more)

### Community 12 - "App Theme & Styling"
Cohesion: 0.07
Nodes (26): AppColors, AppTextStyles, AppTheme, bodyMedium, bodySmall, border, buttonText, darkBg (+18 more)

### Community 13 - "User Profile Provider"
Cohesion: 0.08
Nodes (24): basicProfileProvider, contactName, copyWith, dateOfBirth, emailAddress, emergencyPhone, fullLegalName, isLoading (+16 more)

### Community 14 - "Auth State (Freezed)"
Cohesion: 0.09
Nodes (22): _, class, fullName, hashCode, identical, null, operator, orElse (+14 more)

### Community 15 - "Vendor GPS & Job Details"
Cohesion: 0.12
Nodes (18): build, _formatDuration, VendorGpsCheckinScreen, build, VendorJobDetailsScreen, build, _buildMetricItem, VendorPerformanceScreen (+10 more)

### Community 16 - "Shared Screen State"
Cohesion: 0.10
Nodes (20): _, class, hashCode, identical, isTyping, null, operator, orElse (+12 more)

### Community 17 - "Common UI Widgets"
Cohesion: 0.10
Nodes (18): EdgeInsetsGeometry, build, isLoading, label, onTap, outlined, TLPrimaryButton, trailing (+10 more)

### Community 18 - "Preferences Screen"
Cohesion: 0.10
Nodes (20): preferencesProvider, build, h, hint, icon, label, leftLabel, leftSelected (+12 more)

### Community 19 - "Maintenance Request Screen"
Cohesion: 0.10
Nodes (20): build, _buildAppBar, _buildCancelButton, _buildDescriptionField, _buildDropdown, _buildEmergencyToggle, _buildLabel, _buildPhotoThumbnail (+12 more)

### Community 20 - "Employment Provider"
Cohesion: 0.11
Nodes (19): annualSalary, companyName, copyWith, employmentLength, EmploymentNotifier, employmentProvider, EmploymentState, isLoading (+11 more)

### Community 21 - "Home Dashboard Screen"
Cohesion: 0.10
Nodes (19): address, baths, beds, _FeaturedCard, _FilterChip, h, icon, imageUrl (+11 more)

### Community 22 - "Payment Maintenance State"
Cohesion: 0.11
Nodes (18): bool get, _, class, hashCode, identical, isDownloading, isLoading, issueType (+10 more)

### Community 23 - "Vendor Shell Navigation"
Cohesion: 0.11
Nodes (18): dart:async, build, createState, _currentIndex, dispose, initialIndex, _isBiddingMode, _pages (+10 more)

### Community 24 - "OTP Auth Screen"
Cohesion: 0.13
Nodes (17): FocusNode, otpProvider, build, controller, _controllers, createState, dispose, focusNode (+9 more)

### Community 25 - "Search & Filter Provider"
Cohesion: 0.12
Nodes (17): amenities, bathrooms, bedrooms, copyWith, petsAllowed, rentRange, resetFilters, SearchFilterNotifier (+9 more)

### Community 26 - "Employment Screen"
Cohesion: 0.11
Nodes (17): body, _DropdownField, _FieldLabel, hint, icon, iconColor, _InfoCard, _InputField (+9 more)

### Community 27 - "Create Work Order"
Cohesion: 0.12
Nodes (17): _accessController, build, _categories, createState, CreateWorkOrderScreen, _CreateWorkOrderScreenState, _descController, dispose (+9 more)

### Community 28 - "Notifications Screen"
Cohesion: 0.12
Nodes (16): actionLabel, body, _FilterChip, h, icon, iconBg, iconColor, label (+8 more)

### Community 29 - "Vendor Bid Submission"
Cohesion: 0.12
Nodes (15): FormState, _bidAmount, _buildCheckboxItem, _buildFieldLabel, _buildSummaryRow, createState, dispose, _formKey (+7 more)

### Community 30 - "Chat Details Screen"
Cohesion: 0.13
Nodes (15): chatDetailProvider, build, ChatDetailScreen, _ChatMessage, h, isMe, isTyping, _MessageBubble (+7 more)

### Community 31 - "Basic Profile Screen"
Cohesion: 0.12
Nodes (15): _DropdownField, _FieldLabel, hint, _InputField, items, keyboardType, maxLines, onChanged (+7 more)

### Community 32 - "AI Smart Assistant"
Cohesion: 0.15
Nodes (15): AISmartAssistantScreen, _AISmartAssistantScreenState, build, _buildSuggestionChip, _controller, createState, dispose, _messages (+7 more)

### Community 33 - "Auth Provider & API Core"
Cohesion: 0.13
Nodes (14): auth_state.dart, ../core/api_client.dart, ../core/api_constants.dart, resend, submit, toggleObscure, toggleTerms, updateDigit (+6 more)

### Community 34 - "Welcome Screen"
Cohesion: 0.13
Nodes (14): IconData, build, color, _dot, _FooterLink, icon, isApple, label (+6 more)

### Community 35 - "Home Dashboard & Search"
Cohesion: 0.14
Nodes (14): homeDashboardProvider, build, HomeDashboardScreen, build, _mapActionButton, _mapPin, _propertyCard, _searchPropertyImages (+6 more)

### Community 36 - "Property Details Screen"
Cohesion: 0.14
Nodes (14): _amenityItem, _CarouselStateful, _CarouselStatefulState, _controller, createState, _current, _detailImages, _dot (+6 more)

### Community 37 - "API Client Core"
Cohesion: 0.14
Nodes (13): api_constants.dart, Dio, FlutterSecureStorage, ApiClient, clearToken, dio, getToken, _instance (+5 more)

### Community 38 - "Landlord Maintenance Dashboard"
Cohesion: 0.15
Nodes (13): class, build, _buildTicketStatCard, createState, MaintenanceDashboardScreen, _MaintenanceDashboardScreenState, _selectedTab, build (+5 more)

### Community 39 - "Chat List Screen"
Cohesion: 0.14
Nodes (13): _ChatTile, _contacts, h, imageUrl, isOnline, isRead, lastMsg, name (+5 more)

### Community 40 - "Payment History Screen"
Cohesion: 0.17
Nodes (12): Color iconColor,, double w,, paymentHistoryProvider, build, h, iconBg, isLate, PaymentHistoryScreen (+4 more)

### Community 41 - "Landlord Shell Navigation"
Cohesion: 0.17
Nodes (12): build, createState, _currentIndex, initialIndex, initState, LandlordShell, _LandlordShellState, _pages (+4 more)

### Community 42 - "Tenant Directory"
Cohesion: 0.17
Nodes (12): build, build, createState, _searchQuery, _selectedTab, TenantDirectoryScreen, _TenantDirectoryScreenState, build (+4 more)

### Community 43 - "Windows Runner Main"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 44 - "Landlord Post Job"
Cohesion: 0.17
Nodes (11): _budgetController, build, _categories, createState, _descController, dispose, _priorities, _selectedCategory (+3 more)

### Community 45 - "Tenant Shell Navigation"
Cohesion: 0.17
Nodes (11): build, createState, _currentIndex, initialIndex, initState, _pages, package:tenant_and_landlord_application/screens/chat_list_screen.dart, package:tenant_and_landlord_application/screens/home_dashboard_screen.dart (+3 more)

### Community 46 - "Freezed State Patterns"
Cohesion: 0.18
Nodes (11): @freezed, LandlordStatePatterns, UnitPatterns, LandlordState, OtpState, LandlordNotifier, LandlordState, Unit (+3 more)

### Community 47 - "Landlord Financial Overview"
Cohesion: 0.29
Nodes (10): ConsumerWidget, landlordProvider, BidsReceivedScreen, build, _buildProgressBar, FinancialOverviewScreen, PortfolioDashboardScreen, LandlordPropertyDetailsScreen (+2 more)

### Community 48 - "Auth Register Screen"
Cohesion: 0.20
Nodes (10): registerProvider, build, _FieldLabel, RegisterScreen, text, w, package:tenant_and_landlord_application/provider/auth_provider.dart, package:tenant_and_landlord_application/widgets/common/tl_input_field.dart (+2 more)

### Community 49 - "Maintenance Provider Actions"
Cohesion: 0.18
Nodes (10): addPhoto, downloadLease, maintenanceRequestProvider, payNow, selectMethod, setDescription, setIssueType, submit (+2 more)

### Community 50 - "Vendor Billing Screen"
Cohesion: 0.22
Nodes (10): vendorProvider, build, _buildActionButton, _buildPaymentRow, _buildSplitCard, VendorBillingScreen, build, initState (+2 more)

### Community 51 - "Vendor Find Jobs"
Cohesion: 0.20
Nodes (10): build, _buildAvailableJobCard, createState, dispose, _searchController, _searchQuery, _selectedCategory, VendorFindJobsScreen (+2 more)

### Community 52 - "Vendor My Bids"
Cohesion: 0.20
Nodes (10): build, _buildBadge, _buildBidCard, _buildEmptyState, createState, dispose, initState, _tabController (+2 more)

### Community 53 - "Vendor Work Orders"
Cohesion: 0.20
Nodes (10): build, _buildCompletedJobCard, _buildEmptyState, createState, dispose, initState, _tabController, VendorWorkOrdersScreen (+2 more)

### Community 54 - "TL AppBar Widget"
Cohesion: 0.18
Nodes (10): build, leading, preferredSize, showBack, subtitle, title, TLAppBar, trailing (+2 more)

### Community 55 - "TL Input Field Widget"
Cohesion: 0.18
Nodes (10): build, helperText, hint, keyboardType, obscure, onChanged, prefixIcon, suffixIcon (+2 more)

### Community 56 - "Web Manifest & PWA"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 57 - "Post Job & Property State"
Cohesion: 0.27
Nodes (10): ConsumerState, ConsumerStatefulWidget, PostJobScreen, _PostJobScreenState, PropertyDetailsScreen, _PropertyDetailsScreenState, VendorShell, VendorShellState (+2 more)

### Community 58 - "Screen Settings Provider"
Cohesion: 0.20
Nodes (9): clearMessage, selectFilter, setLanguage, setTyping, toggleEmailReceipts, toggleSmartAlerts, updateMessage, updateSearch (+1 more)

### Community 59 - "Landlord Job Chat Room"
Cohesion: 0.25
Nodes (8): build, _controller, createState, dispose, JobChatRoomScreen, _JobChatRoomScreenState, _scrollController, _sendMessage

### Community 60 - "Property Portfolio Screen"
Cohesion: 0.25
Nodes (8): build, createState, PropertyPortfolioScreen, _PropertyPortfolioScreenState, _searchQuery, _selectedTab, Route /landlord_property_details, Route /landlord_reports_analytics

### Community 61 - "Request Tracking & Profile State"
Cohesion: 0.25
Nodes (8): RequestTrackingStatePatterns, BasicProfileNotifier, BasicProfileState, RequestTrackingNotifier, RequestTrackingState, _RequestTrackingState, RequestTrackingState, StateNotifier

### Community 62 - "Onboarding Progress Bar"
Cohesion: 0.25
Nodes (7): Color, build, OnboardingProgressBar, percentLabel, progress, stepLabel, stepTitle

### Community 63 - "API Constants"
Cohesion: 0.25
Nodes (7): ApiConstants, baseUrl, login, me, refresh, register, static const String

### Community 64 - "Profile & Notifications Screen"
Cohesion: 0.25
Nodes (8): notificationsProvider, profileProvider, build, NotificationsScreen, build, ProfileScreen, Route /payment_history, Route /request_tracking

### Community 65 - "Landlord Reports & Analytics"
Cohesion: 0.29
Nodes (7): build, _buildBreakdownRow, _buildExportButton, createState, ReportsAnalyticsScreen, _ReportsAnalyticsScreenState, _selectedFilter

### Community 66 - "Search Filter Screen"
Cohesion: 0.33
Nodes (6): searchFilterProvider, build, FilterScreen, _sectionTitle, _selectionChip, package:tenant_and_landlord_application/provider/search_provider.dart

### Community 67 - "Role Selection Screen"
Cohesion: 0.33
Nodes (6): build, _buildRoleCard, createState, RoleSelectionScreen, _RoleSelectionScreenState, _selectedRole

### Community 68 - "Vendor Dashboard Screen"
Cohesion: 0.29
Nodes (6): _buildMetricCard, _buildScheduleItem, VendorDashboardScreen, _buildJobCard, package:tenant_and_landlord_application/screens/vendor/vendor_shell.dart, Route /vendor_work_order_details

### Community 69 - "Android Plugin Registration"
Cohesion: 0.47
Nodes (4): GeneratedPluginRegistrant, String, FlutterEngine, Keep

### Community 70 - "iOS LLDB Debug Helper"
Cohesion: 0.33
Nodes (5): handle_new_rx_page(), __lldb_init_module(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages., SBDebugger, SBFrame

### Community 71 - "Chat Detail Routes"
Cohesion: 0.33
Nodes (6): chatListProvider, build, ChatListScreen, build, Route /chat/detail, Route /pay_rent

### Community 72 - "Bottom Navigation Bar"
Cohesion: 0.33
Nodes (5): build, onTap, selectedIndex, TLBottomNav, ValueChanged

### Community 73 - "Welcome Auth State"
Cohesion: 0.40
Nodes (5): WelcomeStatePatterns, WelcomeNotifier, WelcomeState, _WelcomeState, WelcomeState

### Community 74 - "Lease Summary State"
Cohesion: 0.40
Nodes (5): LeaseSummaryStatePatterns, LeaseSummaryState, LeaseSummaryNotifier, LeaseSummaryState, _LeaseSummaryState

### Community 75 - "Maintenance Request State"
Cohesion: 0.40
Nodes (5): MaintenanceRequestStatePatterns, MaintenanceRequestNotifier, MaintenanceRequestState, _MaintenanceRequestState, MaintenanceRequestState

### Community 76 - "Payment History State"
Cohesion: 0.40
Nodes (5): PaymentHistoryStatePatterns, PaymentHistoryNotifier, PaymentHistoryState, _PaymentHistoryState, PaymentHistoryState

### Community 77 - "Pay Rent State"
Cohesion: 0.40
Nodes (5): PayRentStatePatterns, PayRentNotifier, PayRentState, _PayRentState, PayRentState

### Community 78 - "Chat Detail State"
Cohesion: 0.40
Nodes (5): ChatDetailStatePatterns, ChatDetailState, ChatDetailNotifier, ChatDetailState, _ChatDetailState

### Community 79 - "Chat List State"
Cohesion: 0.40
Nodes (5): ChatListStatePatterns, ChatListState, ChatListNotifier, ChatListState, _ChatListState

### Community 80 - "Notifications State"
Cohesion: 0.40
Nodes (5): NotificationsStatePatterns, NotificationsNotifier, NotificationsState, _NotificationsState, NotificationsState

### Community 81 - "User Profile State"
Cohesion: 0.40
Nodes (5): ProfileStatePatterns, ProfileNotifier, ProfileState, _ProfileState, ProfileState

### Community 82 - "Bid Data Model"
Cohesion: 0.50
Nodes (4): Bid, BidPatterns, Bid, _Bid

### Community 83 - "OTP Auth State"
Cohesion: 0.50
Nodes (4): OtpStatePatterns, OtpNotifier, _OtpState, OtpState

### Community 84 - "Chat Message Model"
Cohesion: 0.50
Nodes (4): ChatMessagePatterns, _ChatMessage, ChatMessage, _ChatMessage

### Community 85 - "Property Data Model"
Cohesion: 0.50
Nodes (4): PropertyPatterns, Property, _Property, Property

### Community 86 - "Tenant Data Model"
Cohesion: 0.50
Nodes (4): TenantPatterns, Tenant, _Tenant, Tenant

## Knowledge Gaps
- **664 isolated node(s):** `flutter_export_environment.sh script`, `+registerWithRegistry`, `ApiClient`, `_instance`, `dio` (+659 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `PaymentMethod` connect `Payment & Lease Management` to `Payment Maintenance State`?**
  _High betweenness centrality (0.030) - this node is a cross-community bridge._
- **Why does `landlordProvider` connect `Landlord Financial Overview` to `Landlord Reports & Analytics`, `Landlord & Home Dashboard State`, `Landlord Maintenance Dashboard`, `Landlord Job Chat Room`, `Tenant Directory`, `Landlord Bid Management`, `Create Work Order`, `Property Portfolio Screen`?**
  _High betweenness centrality (0.012) - this node is a cross-community bridge._
- **Why does `vendorProvider` connect `Vendor Billing Screen` to `Role Selection Screen`, `Landlord & Home Dashboard State`, `Vendor Dashboard Screen`, `Vendor GPS & Job Details`, `Vendor Find Jobs`, `Vendor My Bids`, `Vendor Work Orders`, `Post Job & Property State`?**
  _High betweenness centrality (0.010) - this node is a cross-community bridge._
- **What connects `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `flutter_export_environment.sh script`, `+registerWithRegistry` to the rest of the system?**
  _665 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Windows Platform Layer` be split into smaller, more focused modules?**
  _Cohesion score 0.0597567424643046 - nodes in this community are weakly interconnected._
- **Should `iOS/macOS Cocoa Embedding` be split into smaller, more focused modules?**
  _Cohesion score 0.05230496453900709 - nodes in this community are weakly interconnected._
- **Should `Vendor State Management` be split into smaller, more focused modules?**
  _Cohesion score 0.05053191489361702 - nodes in this community are weakly interconnected._