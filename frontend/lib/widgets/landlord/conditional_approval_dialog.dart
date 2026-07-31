import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class ConditionalTermsResult {
  final List<String> tags;
  final String note;

  ConditionalTermsResult({required this.tags, required this.note});
}

class ConditionalApprovalDialog extends StatefulWidget {
  const ConditionalApprovalDialog({super.key});

  static Future<ConditionalTermsResult?> show(BuildContext context) {
    return showDialog<ConditionalTermsResult>(
      context: context,
      builder: (ctx) => const ConditionalApprovalDialog(),
    );
  }

  @override
  State<ConditionalApprovalDialog> createState() => _ConditionalApprovalDialogState();
}

class _ConditionalApprovalDialogState extends State<ConditionalApprovalDialog> {
  bool _isLoadingTags = true;
  List<Map<String, String>> _availableTags = [
    {'id': 'higher_security_deposit', 'label': 'Higher Security Deposit Required'},
    {'id': 'cosigner_required', 'label': 'Co-signer / Guarantor Required'},
    {'id': 'additional_income_doc', 'label': 'Additional Income Documentation Needed'},
    {'id': 'secondary_screening', 'label': 'Conditional on Passing Secondary Screening'},
    {'id': 'short_term_lease_only', 'label': 'Short-Term Lease Only'},
    {'id': 'resolve_issues_first', 'label': 'Tenant Must Resolve Issues Before Move-In'},
  ];
  final Set<String> _selectedTags = {};
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMetaTags();
  }

  Future<void> _fetchMetaTags() async {
    try {
      final resp = await ApiClient().dio.get('/applications/meta/conditional-tags');
      if (resp.data['success'] == true && resp.data['data'] is List) {
        final List<dynamic> list = resp.data['data'];
        final fetched = list.map((item) {
          if (item is Map) {
            return {
              'id': (item['id'] ?? item['value'] ?? '').toString(),
              'label': (item['label'] ?? item['name'] ?? '').toString(),
            };
          }
          return {'id': item.toString(), 'label': item.toString()};
        }).toList();
        if (fetched.isNotEmpty && mounted) {
          setState(() {
            _availableTags = fetched;
            _isLoadingTags = false;
          });
          return;
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingTags = false);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.rule_rounded, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Conditional Approval',
              style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select approval conditions for tenant:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 10),
            if (_isLoadingTags)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTags.map((tag) {
                  final id = tag['id']!;
                  final label = tag['label']!;
                  final isSelected = _selectedTags.contains(id);
                  return FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedTags.add(id);
                        } else {
                          _selectedTags.remove(id);
                        }
                      });
                    },
                    selectedColor: Colors.orange.withValues(alpha: 0.2),
                    checkmarkColor: Colors.orange,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.orange.shade900 : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            const Text(
              'Additional Terms / Notes for Tenant',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _noteController,
              maxLines: 3,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Requires \$500 extra deposit and co-signer signature before lease generation.',
                hintStyle: const TextStyle(fontSize: 11, color: AppColors.textHint),
                fillColor: AppColors.inputBg,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            Navigator.pop(
              context,
              ConditionalTermsResult(
                tags: _selectedTags.toList(),
                note: _noteController.text.trim(),
              ),
            );
          },
          child: const Text('Confirm Conditional Approval', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
