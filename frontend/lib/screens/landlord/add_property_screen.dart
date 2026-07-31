import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tenant_and_landlord_application/provider/landlord_provider.dart';
import 'package:tenant_and_landlord_application/provider/landlord_state.dart';
import 'package:tenant_and_landlord_application/theme/apptheme.dart';
import '../../../theme/apptheme.dart';
import '../../../widgets/landlord/location_picker_dialog.dart';
import '../../../utils/country_data.dart';

class AddPropertyScreen extends ConsumerStatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  ConsumerState<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Step tracking ────────────────────────────────────────────────────────
  int _currentStep = 0; // 0 = property info, 1 = add first unit
  String? _createdPropertyId;

  // ── Image picking ────────────────────────────────────────────────────────
  Uint8List? _pickedImageBytes;
  String? _pickedFileName;

  // ── Property Controllers ─────────────────────────────────────────────────
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
  double? _latitude;
  double? _longitude;

  // ── Dynamic Property Controllers ─────────────────────────────────────────
  final _houseBedsCtrl = TextEditingController();
  final _houseBathsCtrl = TextEditingController();
  final _houseSqftCtrl = TextEditingController();
  final _houseYardCtrl = TextEditingController();

  String _commercialCategory = 'Office';
  final _commercialSqftCtrl = TextEditingController();
  final _commercialZoningCtrl = TextEditingController();

  final _aptTotalUnitsCtrl = TextEditingController();
  final _aptFloorCountCtrl = TextEditingController();

  // ── Unit Controllers (Apartment) ─────────────────────────────────────────
  final _unitNumberCtrl = TextEditingController();
  final _unitRentCtrl = TextEditingController();
  final _unitDepositCtrl = TextEditingController();
  final _unitBedsCtrl = TextEditingController();
  final _unitBathsCtrl = TextEditingController();
  final _unitSqftCtrl = TextEditingController();
  String _unitStatus = 'vacant';
  bool _isAddingUnit = false;
  bool _skipUnit = false;

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
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _postalCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _unitNumberCtrl.dispose();
    _unitRentCtrl.dispose();
    _unitDepositCtrl.dispose();
    _unitBedsCtrl.dispose();
    _unitBathsCtrl.dispose();
    _unitSqftCtrl.dispose();
    _houseBedsCtrl.dispose();
    _houseBathsCtrl.dispose();
    _houseSqftCtrl.dispose();
    _houseYardCtrl.dispose();
    _commercialSqftCtrl.dispose();
    _commercialZoningCtrl.dispose();
    _aptTotalUnitsCtrl.dispose();
    _aptFloorCountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      Map<String, dynamic> metadata = {};
      if (['house', 'loft', 'studio'].contains(_selectedType)) {
        metadata = {
          'bedrooms': int.tryParse(_houseBedsCtrl.text.trim()) ?? 0,
          'bathrooms': int.tryParse(_houseBathsCtrl.text.trim()) ?? 0,
          'square_feet': int.tryParse(_houseSqftCtrl.text.trim()) ?? 0,
          'yard_parking': _houseYardCtrl.text.trim(),
        };
      } else if (_selectedType == 'commercial') {
        metadata = {
          'category': _commercialCategory,
          'usable_sqft': int.tryParse(_commercialSqftCtrl.text.trim()) ?? 0,
          'zoning': _commercialZoningCtrl.text.trim(),
        };
      } else if (_selectedType == 'apartment') {
        metadata = {
          'total_units': int.tryParse(_aptTotalUnitsCtrl.text.trim()) ?? 0,
          'floor_count': int.tryParse(_aptFloorCountCtrl.text.trim()) ?? 0,
        };
      }

      _createdPropertyId = await ref.read(landlordProvider.notifier).createProperty(
            name: _nameCtrl.text.trim(),
            addressLine1: _addressCtrl.text.trim(),
            city: _cityCtrl.text.trim(),
            stateProvince: _stateCtrl.text.trim(),
            postalCode: _postalCtrl.text.trim(),
            countryCode: _countryCode,
            type: _selectedType,
            description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
            amenities: _selectedAmenities.toList(),
            price: double.tryParse(_priceCtrl.text.trim()),
            metadata: metadata,
            latitude: _latitude,
            longitude: _longitude,
          );

      if (_pickedImageBytes != null && _pickedFileName != null) {
        await ref.read(landlordProvider.notifier).uploadPropertyImage(
          _createdPropertyId!,
          _pickedImageBytes!,
          _pickedFileName!,
        );
      }

      if (mounted) {
        if (_selectedType != 'apartment') {
          // Bypass add unit step for single-entity properties
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Property created successfully! 🎉'),
            backgroundColor: Color(0xFF27AE60),
          ));
          Navigator.pop(context);
        } else {
          setState(() => _currentStep = 1);
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to create property: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitUnit() async {
    if (_skipUnit) {
      if (mounted) Navigator.pop(context);
      return;
    }
    if (_unitNumberCtrl.text.trim().isEmpty) {
      _showError('Please enter a unit number or tap "Skip".');
      return;
    }
    if (_unitRentCtrl.text.trim().isEmpty) {
      _showError('Please enter the monthly rent.');
      return;
    }

    setState(() => _isAddingUnit = true);
    try {
      final propertyId = _createdPropertyId ?? ref.read(landlordProvider).properties.first.id;
      final unit = Unit(
        id: '',
        name: _unitNumberCtrl.text.trim(),
        status: _unitStatus,
        tenantName: '',
        rent: double.tryParse(_unitRentCtrl.text.trim()) ?? 0.0,
        amenities: [],
        bedrooms: int.tryParse(_unitBedsCtrl.text.trim()) ?? 0,
        bathrooms: int.tryParse(_unitBathsCtrl.text.trim()) ?? 0,
        squareFeet: int.tryParse(_unitSqftCtrl.text.trim()) ?? 0,
        depositAmount: double.tryParse(_unitDepositCtrl.text.trim()) ?? 0.0,
      );
      await ref.read(landlordProvider.notifier).addUnit(propertyId, unit);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Property & unit created successfully! 🎉'),
          backgroundColor: Color(0xFF27AE60),
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showError('Unit creation failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isAddingUnit = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
    ));
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _pickedImageBytes = bytes;
          _pickedFileName = image.name;
        });
      }
    } on PlatformException catch (e) {
      if (mounted) _showError('Permission denied or error: ${e.message}');
    } catch (e) {
      if (mounted) _showError('Failed to pick image: $e');
    }
  }

  // ── Shared Widgets ────────────────────────────────────────────────────────
  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 16),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
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

  // ─── Step 1: Property Info ─────────────────────────────────────────────────
  Widget _buildPropertyStep(double w) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          _buildStepIndicator(),
          const SizedBox(height: 20),

          // Property Image Card
          _sectionCard(
            title: 'Property Image',
            icon: Icons.image_rounded,
            children: [
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border, width: 1.5),
                    image: _pickedImageBytes != null
                        ? DecorationImage(image: MemoryImage(_pickedImageBytes!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _pickedImageBytes != null ? 'Change Image' : 'Pick Property Image',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
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
              _field('e.g. Sunset Villas Block A', _nameCtrl, validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Property name is required';
                if (v.trim().length < 3) return 'Name must be at least 3 characters';
                return null;
              }),
              _label('Monthly Rent (\$)'),
              _field('e.g. 2500', _priceCtrl,
                  keyboardType: TextInputType.number,
                  required: false,
                  validator: (_) => null),
              _label('Description'),
              _field('Short description of the property (optional)', _descCtrl,
                  maxLines: 3, required: false, validator: (_) => null),
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
            title: 'Address & Map Location',
            icon: Icons.location_on_rounded,
            children: [
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final res = await LocationPickerDialog.show(
                      context,
                      initialLat: _latitude ?? 31.5204,
                      initialLng: _longitude ?? 74.3587,
                    );
                    if (res != null) {
                      setState(() {
                        _latitude = res.latitude;
                        _longitude = res.longitude;
                        if (res.addressLine1.isNotEmpty) {
                          _addressCtrl.text = res.addressLine1;
                        }
                        if (res.city.isNotEmpty) {
                          _cityCtrl.text = res.city;
                        }
                        if (res.stateProvince.isNotEmpty) {
                          _stateCtrl.text = res.stateProvince;
                        }
                        if (res.zipCode.isNotEmpty) {
                          _postalCtrl.text = res.zipCode;
                        }
                        if (res.country.isNotEmpty) {
                          if (CountryData.countries.containsKey(res.country)) {
                            _countryCode = res.country;
                          }
                        }
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Pin Location Set successfully!'),
                            backgroundColor: const Color(0xFF27AE60),
                          ),
                        );
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    side: BorderSide(color: _latitude != null ? const Color(0xFF27AE60) : AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(
                    _latitude != null ? Icons.check_circle_rounded : Icons.map_rounded,
                    color: _latitude != null ? const Color(0xFF27AE60) : AppColors.primary,
                  ),
                  label: Text(
                    _latitude != null
                        ? 'Location Set Successfully'
                        : 'Pick Pin Location on Map',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _latitude != null ? const Color(0xFF27AE60) : AppColors.primary,
                    ),
                  ),
                ),
              ),
              _label('Street Address *'),
              _field('123 Main Street', _addressCtrl),
              _label('City *'),
              _field('e.g. New York', _cityCtrl),
              Row(
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _label('State / Province *'),
                      _field('e.g. NY', _stateCtrl),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _label('Postal Code *'),
                      _field('e.g. 10001', _postalCtrl, keyboardType: TextInputType.number),
                    ]),
                  ),
                ],
              ),
              _label('Country'),
              DropdownButtonFormField<String>(
                value: _countryCode,
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                ),
                items: CountryData.countries.entries.map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text('${e.key} – ${e.value}', overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (v) => setState(() => _countryCode = v ?? 'US'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Dynamic Fields based on property type
          if (['house', 'loft', 'studio'].contains(_selectedType))
            _sectionCard(
              title: '$_selectedType Details',
              icon: Icons.home_rounded,
              children: [
                Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Bedrooms'), _field('e.g. 3', _houseBedsCtrl, keyboardType: TextInputType.number, required: false, validator: (_) => null)])),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Bathrooms'), _field('e.g. 2', _houseBathsCtrl, keyboardType: TextInputType.number, required: false, validator: (_) => null)])),
                  ],
                ),
                _label('Square Feet'),
                _field('e.g. 1500', _houseSqftCtrl, keyboardType: TextInputType.number, required: false, validator: (_) => null),
                _label('Yard / Parking Info'),
                _field('e.g. 2 car garage, fenced yard', _houseYardCtrl, required: false, validator: (_) => null),
              ],
            )
          else if (_selectedType == 'commercial')
            _sectionCard(
              title: 'Commercial Details',
              icon: Icons.storefront_rounded,
              children: [
                _label('Category'),
                DropdownButtonFormField<String>(
                  initialValue: _commercialCategory,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Office', child: Text('Office')),
                    DropdownMenuItem(value: 'Retail', child: Text('Retail')),
                    DropdownMenuItem(value: 'Industrial', child: Text('Industrial')),
                    DropdownMenuItem(value: 'Warehouse', child: Text('Warehouse')),
                  ],
                  onChanged: (v) => setState(() => _commercialCategory = v ?? 'Office'),
                ),
                const SizedBox(height: 12),
                _label('Usable Sq. Ft.'),
                _field('e.g. 5000', _commercialSqftCtrl, keyboardType: TextInputType.number, required: false, validator: (_) => null),
                _label('Zoning Code'),
                _field('e.g. C-1, M-2', _commercialZoningCtrl, required: false, validator: (_) => null),
              ],
            )
          else if (_selectedType == 'apartment')
            _sectionCard(
              title: 'Building Details',
              icon: Icons.apartment_rounded,
              children: [
                Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Total Units'), _field('e.g. 50', _aptTotalUnitsCtrl, keyboardType: TextInputType.number, required: false, validator: (_) => null)])),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Floor Count'), _field('e.g. 5', _aptFloorCountCtrl, keyboardType: TextInputType.number, required: false, validator: (_) => null)])),
                  ],
                ),
              ],
            ),

          if (['house', 'loft', 'studio', 'commercial', 'apartment'].contains(_selectedType))
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
                            Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
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

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitProperty,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              child: _isSubmitting
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_selectedType == 'apartment' ? 'Next: Add Unit' : 'Create Property', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Icon(_selectedType == 'apartment' ? Icons.arrow_forward_rounded : Icons.check_circle_rounded, size: 20),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─── Step 2: Add First Unit ────────────────────────────────────────────────
  Widget _buildUnitStep(double w) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepIndicator(),
        const SizedBox(height: 20),

        // Success banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF27AE60).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF27AE60).withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF27AE60), size: 20),
              SizedBox(width: 10),
              Expanded(child: Text('Property created! Now add your first unit.', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A7A40)))),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _sectionCard(
          title: 'Unit Details',
          icon: Icons.meeting_room_rounded,
          children: [
            _label('Unit Number *'),
            TextFormField(
              controller: _unitNumberCtrl,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: _fieldDeco('e.g. Unit 101 or Apt A'),
            ),
            _label('Monthly Rent (\$) *'),
            TextFormField(
              controller: _unitRentCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: _fieldDeco('e.g. 1500'),
            ),
            _label('Security Deposit (\$)'),
            TextFormField(
              controller: _unitDepositCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: _fieldDeco('e.g. 3000 (optional)'),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _label('Bedrooms'),
                    TextFormField(controller: _unitBedsCtrl, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary), decoration: _fieldDeco('0')),
                  ]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _label('Bathrooms'),
                    TextFormField(controller: _unitBathsCtrl, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary), decoration: _fieldDeco('0')),
                  ]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _label('Sq. Ft.'),
                    TextFormField(controller: _unitSqftCtrl, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary), decoration: _fieldDeco('0')),
                  ]),
                ),
              ],
            ),
            _label('Unit Status'),
            DropdownButtonFormField<String>(
              initialValue: _unitStatus,
              decoration: _fieldDeco('Select status'),
              items: const [
                DropdownMenuItem(value: 'vacant', child: Text('Vacant')),
                DropdownMenuItem(value: 'occupied', child: Text('Occupied')),
                DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                DropdownMenuItem(value: 'reserved', child: Text('Reserved')),
              ],
              onChanged: (v) => setState(() => _unitStatus = v ?? 'vacant'),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _skipUnit = true);
                  _submitUnit();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Skip for Now', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isAddingUnit ? null : _submitUnit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 2,
                ),
                child: _isAddingUnit
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Add Unit & Finish', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(2, (i) {
        final isActive = i == _currentStep;
        final isDone = i < _currentStep;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDone || isActive ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  i == 0 ? 'Property Info' : 'Add Unit',
                  style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? AppColors.primary : AppColors.textHint),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  InputDecoration _fieldDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _currentStep == 0 ? 'Add Property' : 'Add First Unit',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: 20),
          child: _currentStep == 0 ? _buildPropertyStep(w) : _buildUnitStep(w),
        ),
      ),
    );
  }
}
