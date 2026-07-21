import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/provider/landlord_state.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';

class EditPropertyScreen extends ConsumerStatefulWidget {
  const EditPropertyScreen({super.key});

  @override
  ConsumerState<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends ConsumerState<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  late Property _property;
  bool _initialized = false;

  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  String _selectedType = 'apartment';
  String _countryCode = 'US';
  final Set<String> _selectedAmenities = {};
  bool _isSubmitting = false;

  // Image picking
  Uint8List? _pickedImageBytes;
  String? _pickedFileName;

  static const _propertyTypes = [
    ('apartment', 'Apartment', Icons.apartment_rounded),
    ('house', 'House', Icons.house_rounded),
    ('commercial', 'Commercial', Icons.store_rounded),
    ('loft', 'Loft', Icons.roofing_rounded),
    ('studio', 'Studio', Icons.meeting_room_rounded),
  ];

  static const _amenityOptions = [
    ('parking', 'Parking', Icons.local_parking_rounded),
    ('gym', 'Gym', Icons.fitness_center_rounded),
    ('pool', 'Pool', Icons.pool_rounded),
    ('wifi', 'Wi-Fi', Icons.wifi_rounded),
    ('ac', 'A/C', Icons.ac_unit_rounded),
    ('laundry', 'Laundry', Icons.local_laundry_service_rounded),
    ('security', 'Security', Icons.security_rounded),
    ('elevator', 'Elevator', Icons.elevator_rounded),
    ('pet_friendly', 'Pet Friendly', Icons.pets_rounded),
    ('furnished', 'Furnished', Icons.chair_rounded),
    ('balcony', 'Balcony', Icons.balcony_rounded),
    ('storage', 'Storage', Icons.storage_rounded),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is Property) {
        _property = arg;
        _nameCtrl.text = _property.name;
        _descCtrl.text = _property.description;
        _priceCtrl.text = _property.monthlyRent > 0 ? _property.monthlyRent.toStringAsFixed(0) : '';
        _selectedType = _property.type.isNotEmpty ? _property.type.toLowerCase() : 'apartment';

        // Parse address parts if available
        final addressParts = _property.address.split(', ');
        if (addressParts.isNotEmpty) _addressCtrl.text = addressParts[0];
        if (addressParts.length > 1) _cityCtrl.text = addressParts[1];
        if (addressParts.length > 2) _stateCtrl.text = addressParts[2];

        _selectedAmenities.addAll(_property.amenities.map((a) => a.toLowerCase()));
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _postalCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          setState(() {
            _pickedImageBytes = file.bytes;
            _pickedFileName = file.name;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  Future<void> _submitEdit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(landlordProvider.notifier);

      final payload = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'type': _selectedType,
        if (_addressCtrl.text.trim().isNotEmpty) 'addressLine1': _addressCtrl.text.trim(),
        if (_cityCtrl.text.trim().isNotEmpty) 'city': _cityCtrl.text.trim(),
        if (_stateCtrl.text.trim().isNotEmpty) 'stateProvince': _stateCtrl.text.trim(),
        if (_postalCtrl.text.trim().isNotEmpty) 'postalCode': _postalCtrl.text.trim(),
        'countryCode': _countryCode,
        'description': _descCtrl.text.trim(),
        'amenities': _selectedAmenities.toList(),
        if (_priceCtrl.text.trim().isNotEmpty) 'price': double.tryParse(_priceCtrl.text.trim()) ?? 0.0,
      };

      await notifier.updateProperty(_property.id, payload);

      // Upload image if a new image was picked
      if (_pickedImageBytes != null && _pickedFileName != null) {
        await notifier.uploadPropertyImage(_property.id, _pickedImageBytes!, _pickedFileName!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Property updated successfully! ?'),
          backgroundColor: Color(0xFF27AE60),
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update property: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 16),
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      );

  Widget _field(
    String hint,
    TextEditingController ctrl, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool required = true,
  }) =>
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
        ),
        validator: validator ??
            (v) {
              if (required && (v == null || v.trim().isEmpty)) return 'This field is required';
              return null;
            },
      );

  Widget _sectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Property', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload Card
              _sectionCard(
                title: 'Property Image',
                icon: Icons.image_rounded,
                children: [
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 1.5),
                        image: _pickedImageBytes != null
                            ? DecorationImage(image: MemoryImage(_pickedImageBytes!), fit: BoxFit.cover)
                            : (_property.imageUrl.startsWith('http')
                                ? DecorationImage(image: NetworkImage(_property.imageUrl), fit: BoxFit.cover)
                                : null),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _pickedImageBytes != null ? 'Change Picked Image' : 'Upload New Image',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Basic Info
              _sectionCard(
                title: 'Basic Information',
                icon: Icons.info_outline_rounded,
                children: [
                  _label('Property Name *'),
                  _field('Property Name', _nameCtrl),
                  _label('Monthly Rent (\$)'),
                  _field('e.g. 2500', _priceCtrl, keyboardType: TextInputType.number, required: false, validator: (_) => null),
                  _label('Description'),
                  _field('Property description', _descCtrl, maxLines: 3, required: false, validator: (_) => null),
                ],
              ),

              const SizedBox(height: 16),

              // Property Type
              _sectionCard(
                title: 'Property Type *',
                icon: Icons.category_rounded,
                children: [
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _propertyTypes.map((t) {
                      final isSelected = _selectedType == t.$1;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedType = t.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(t.$3, size: 16, color: isSelected ? AppColors.white : AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text(t.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? AppColors.white : AppColors.textPrimary)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Address
              _sectionCard(
                title: 'Address',
                icon: Icons.location_on_rounded,
                children: [
                  _label('Street Address'),
                  _field('Street Address', _addressCtrl, required: false, validator: (_) => null),
                  _label('City'),
                  _field('City', _cityCtrl, required: false, validator: (_) => null),
                  Row(
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _label('State / Province'),
                          _field('State', _stateCtrl, required: false, validator: (_) => null),
                        ]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _label('Postal Code'),
                          _field('Postal Code', _postalCtrl, keyboardType: TextInputType.number, required: false, validator: (_) => null),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Amenities
              _sectionCard(
                title: 'Amenities',
                icon: Icons.star_outline_rounded,
                children: [
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _amenityOptions.map((a) {
                      final isSelected = _selectedAmenities.contains(a.$1);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (isSelected) {
                            _selectedAmenities.remove(a.$1);
                          } else {
                            _selectedAmenities.add(a.$1);
                          }
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.scaffoldBg,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 1.5 : 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(a.$3, size: 14, color: isSelected ? AppColors.primary : AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text(a.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                              if (isSelected) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
