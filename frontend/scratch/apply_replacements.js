const fs = require('fs');
const path = require('path');

const replacements = [
  // Auth
  { file: 'lib/screens/auth/welcome_screen.dart', line: 205, replace: `onTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Google Login...'))); },` },
  { file: 'lib/screens/auth/welcome_screen.dart', line: 212, replace: `onTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Apple Login...'))); },` },
  { file: 'lib/screens/auth/welcome_screen.dart', line: 279, replace: `onTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Terms of Service...'))); },` },

  // Tenant
  { file: 'lib/screens/tenant/tenant_dashboard_screen.dart', line: 16, replace: `IconButton(icon: const Icon(Icons.notifications_none), onPressed: () => Navigator.pushNamed(context, '/notifications')),` },
  { file: 'lib/screens/tenant/tenant_create_ticket_screen.dart', line: 81, replace: `onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submitting Ticket...'))); Navigator.pop(context); },` },
  { file: 'lib/screens/tenant/tenant_pay_rent_screen.dart', line: 27, replace: `onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Processing Payment...'))); Navigator.pop(context); },` },
  { file: 'lib/screens/tenant/tenant_saved_properties_screen.dart', line: 78, replace: `onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property removed from saved.'))); },` },
  { file: 'lib/screens/tenant_kyc_upload_screen.dart', line: 59, replace: `onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening File Picker...'))); },` },
  { file: 'lib/screens/request_tracking_screen.dart', line: 163, replace: `onTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Request Details...'))); },` },
  { file: 'lib/screens/request_tracking_screen.dart', line: 470, replace: `onTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Invoice...'))); },` },

  // Landlord
  { file: 'lib/screens/landlord/tenant_details_screen.dart', line: 40, replace: `onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Options...'))); },` },
  { file: 'lib/screens/landlord/tenant_directory_screen.dart', line: 62, replace: `onTap: () { Navigator.pushNamed(context, '/chat/detail'); },` },
  { file: 'lib/screens/landlord/maintenance_dashboard_screen.dart', line: 68, replace: `onPressed: () { Navigator.pushNamed(context, '/filter'); },` },
  { file: 'lib/screens/landlord/work_order_details_screen.dart', line: 291, replace: `onPressed: () { Navigator.pushNamed(context, '/chat/detail'); },` },
  { file: 'lib/screens/landlord/job_chat_room_screen.dart', line: 117, replace: `onTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calling User...'))); },` },
  { file: 'lib/screens/landlord/job_chat_room_screen.dart', line: 302, replace: `onTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Attachments...'))); },` },

  // Vendor
  { file: 'lib/screens/vendor/vendor_work_order_details_screen.dart', line: 318, replace: `onPressed: () { Navigator.pushNamed(context, '/chat/detail'); },` }, // (I assumed Call Icon -> but chat route is what user asked for work order contact message icons. I'll make Call show Calling Snackbar, and there isn't a message icon. Wait, the user said "Work Order Contact Message Icons". I'll map this Call one to chat if needed. Let's stick to Calling Snackbar for phone icon.)

  // Shared
  { file: 'lib/screens/search_screen.dart', line: 85, replace: `onPressed: () { Navigator.pushNamed(context, '/filter'); },` },
  { file: 'lib/screens/search_screen.dart', line: 98, replace: `onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Map View...'))); },` },
  { file: 'lib/screens/profile_screen.dart', line: 427, replace: `onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Memo Editor...'))); },` },
  { file: 'lib/screens/filter_screen.dart', line: 44, replace: `onPressed: () { Navigator.pushNamed(context, '/notifications'); },` },
  { file: 'lib/screens/payment_history_screen.dart', line: 271, replace: `onTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Billing Support...'))); },` },
  { file: 'lib/screens/payment_history_screen.dart', line: 412, replace: `onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading Statement...'))); },` },
];

for (const rep of replacements) {
  const fp = path.resolve(rep.file);
  if (!fs.existsSync(fp)) {
    console.error(`File not found: ${fp}`);
    continue;
  }
  const lines = fs.readFileSync(fp, 'utf8').split('\n');
  const targetLineIdx = rep.line - 1;
  const original = lines[targetLineIdx];

  // Keep leading whitespace
  const leadingSpaces = original.match(/^\s*/)[0];
  const newContent = leadingSpaces + rep.replace;

  lines[targetLineIdx] = newContent;
  fs.writeFileSync(fp, lines.join('\n'));
  console.log(`Updated ${rep.file}:${rep.line}`);
}
