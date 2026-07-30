import 'package:flutter/material.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import 'package:tenant_and_landlord_application/core/api_client.dart';
import 'package:tenant_and_landlord_application/core/api_constants.dart';

class TenantSavedPropertiesScreen extends StatefulWidget {
  const TenantSavedPropertiesScreen({super.key});

  @override
  State<TenantSavedPropertiesScreen> createState() => _TenantSavedPropertiesScreenState();
}

class _TenantSavedPropertiesScreenState extends State<TenantSavedPropertiesScreen> {
  List<dynamic> _savedProperties = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSavedProperties();
  }

  Future<void> _fetchSavedProperties() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final resp = await ApiClient().dio.get(ApiConstants.savedProperties);
      if (resp.data != null && resp.data['data'] is List) {
        setState(() {
          _savedProperties = resp.data['data'];
          _isLoading = false;
        });
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load saved properties: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _removeSavedProperty(String propertyId) async {
    try {
      // Toggle save route (POST /properties/:id/save) also unsaves if already saved
      await ApiClient().dio.post('/properties/$propertyId/save');
      setState(() {
        _savedProperties.removeWhere((p) => p['id'] == propertyId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property removed from saved.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove property: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(title: const Text('Saved Homes')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _savedProperties.isEmpty
                    ? const Center(
                        child: Text(
                          'No saved properties yet.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
                        itemCount: _savedProperties.length,
                        itemBuilder: (context, index) {
                          final prop = _savedProperties[index] as Map<String, dynamic>;
                          return _buildSavedPropertyCard(context, prop);
                        },
                      ),
      ),
    );
  }

  Widget _buildSavedPropertyCard(BuildContext context, Map<String, dynamic> prop) {
    final title = prop['name'] ?? prop['title'] ?? 'Unnamed Property';
    final location = prop['address_line1'] ?? prop['location'] ?? 'Unknown Address';
    final askRent = prop['asking_rent'] ?? prop['askingRent'] ?? 0.0;
    final images = prop['images'] as List<dynamic>? ?? [];
    final id = prop['id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  color: AppColors.inputBg,
                  child: images.isNotEmpty
                      ? Image.network(
                          images.first.toString(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image, color: AppColors.textHint, size: 40),
                          ),
                        )
                      : const Center(child: Icon(Icons.image, color: AppColors.textHint, size: 40)),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.favorite, color: AppColors.error),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.headlineMedium, overflow: TextOverflow.ellipsis, maxLines: 1),
                      const SizedBox(height: 4),
                      Text('\$${askRent.toString()}/mo', style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => _removeSavedProperty(id),
                  child: const Text('Remove', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
