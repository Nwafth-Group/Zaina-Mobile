import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../../../widgets/custom_text_form_field.dart';
import '../../../../widgets/ziena_button.dart';
import '../../data/model/address_model.dart';
import '../../data/model/filter_models.dart';
import '../cubit/address_cubit.dart';
import '../cubit/filter_cubit.dart';
import 'map_picker_screen.dart';

class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? editAddress;
  const AddEditAddressScreen({super.key, this.editAddress});

  @override
  State<AddEditAddressScreen> createState() =>
      _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _labelCtrl         = TextEditingController();
  final _streetCtrl        = TextEditingController();
  final _buildingNameCtrl  = TextEditingController();
  final _buildingNoCtrl    = TextEditingController();
  final _floorCtrl         = TextEditingController();
  final _apartmentNoCtrl   = TextEditingController();
  final _contactNameCtrl   = TextEditingController();
  final _phoneCtrl         = TextEditingController();
  final _secondaryPhoneCtrl= TextEditingController();
  final _notesCtrl         = TextEditingController();

  late final FilterCubit _filterCubit;

  bool   _isDefault     = false;
  bool   _isSaving      = false;

  // Location from map
  double? _latitude;
  double? _longitude;
  int?    _areaId;
  String? _selectedLocationDisplay;

  // Country / governorate / city / area selection
  LocationItem? _selectedCountry;
  LocationItem? _selectedGovernorate;
  LocationItem? _selectedCity;
  LocationItem? _selectedArea;

  bool get _isEdit => widget.editAddress != null;

  @override
  void initState() {
    super.initState();
    _filterCubit = sl<FilterCubit>()..loadCountries();
    if (_isEdit) _prefill(widget.editAddress!);
  }

  void _prefill(AddressModel a) {
    _labelCtrl.text      = a.label;
    _streetCtrl.text     = a.street;
    _buildingNameCtrl.text = a.buildingName ?? '';
    _buildingNoCtrl.text = a.buildingNo ?? '';
    _floorCtrl.text      = a.floor ?? '';
    _apartmentNoCtrl.text= a.apartmentNo ?? '';
    _contactNameCtrl.text= a.contactName;
    _phoneCtrl.text      = a.phoneNumber;
    _secondaryPhoneCtrl.text = a.secondaryPhone ?? '';
    _notesCtrl.text      = a.notes ?? '';
    _isDefault           = a.isDefault;
    _latitude  = double.tryParse(a.latitude ?? '');
    _longitude = double.tryParse(a.longitude ?? '');
    _areaId    = a.area?.id;
    if (a.area != null) {
      _selectedLocationDisplay = a.shortAddress('en');
      if (a.area!.city != null) {
        final c = a.area!.city!;
        _selectedCity = LocationItem(id: c.id, nameAr: c.nameAr, nameEn: c.nameEn);
        _filterCubit.loadAreas(c.id).then((_) {
          if (mounted) {
            setState(() {
              _selectedArea = LocationItem(
                id: a.area!.id,
                nameAr: a.area!.nameAr,
                nameEn: a.area!.nameEn,
              );
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _filterCubit.close();
    _labelCtrl.dispose();
    _streetCtrl.dispose();
    _buildingNameCtrl.dispose();
    _buildingNoCtrl.dispose();
    _floorCtrl.dispose();
    _apartmentNoCtrl.dispose();
    _contactNameCtrl.dispose();
    _phoneCtrl.dispose();
    _secondaryPhoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _openMap() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );
    if (result != null) {
      setState(() {
        _latitude  = result['latitude'];
        _longitude = result['longitude'];
        _areaId    = result['area_id'];
        _selectedLocationDisplay = result['display'];
      });
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final payload = <String, dynamic>{
      'label':           _labelCtrl.text.trim().isEmpty ? 'Home' : _labelCtrl.text.trim(),
      'street':          _streetCtrl.text.trim(),
      'building_name':   _buildingNameCtrl.text.trim(),
      'building_no':     _buildingNoCtrl.text.trim(),
      'floor':           _floorCtrl.text.trim(),
      'apartment_no':    _apartmentNoCtrl.text.trim(),
      'contact_name':    _contactNameCtrl.text.trim(),
      'phone_number':    _phoneCtrl.text.trim(),
      if (_secondaryPhoneCtrl.text.trim().isNotEmpty)
        'secondary_phone': _secondaryPhoneCtrl.text.trim(),
      if (_notesCtrl.text.trim().isNotEmpty)
        'notes': _notesCtrl.text.trim(),
      if (_isDefault) 'is_default': true,
      if (_areaId != null) 'area_id': _areaId,
      if (_latitude != null) 'latitude': _latitude,
      if (_longitude != null) 'longitude': _longitude,
    };

    final cubit = context.read<AddressCubit>();
    bool success;
    if (_isEdit) {
      success = await cubit.updateAddress(widget.editAddress!.id, payload);
    } else {
      success = await cubit.addAddress(payload);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              _isEdit ? 'address_updated'.tr() : 'address_added'.tr()),
          backgroundColor: ZienaColors.success,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'edit_address'.tr() : 'add_address'.tr(),
          style: const TextStyle(
            fontFamily: 'Poppins', fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ZienaColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Select from Map ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openMap,
                  icon: const Icon(Icons.location_on_rounded,
                      color: Colors.white, size: 18),
                  label: Text(
                    _selectedLocationDisplay ?? 'select_from_map'.tr(),
                    style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 14,
                      fontWeight: FontWeight.w600, color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZienaColors.primary,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Address Label ─────────────────────────────────────────────
              _buildTextField(
                label: 'address_label'.tr(),
                ctrl: _labelCtrl,
                hint: 'Home',
                required: true,
              ),

              // ── Country / Governorate + City / Area ───────────────────────
              BlocBuilder<FilterCubit, FilterState>(
                bloc: _filterCubit,
                builder: (context, state) {
                  final data = state is FilterLocationsLoaded
                      ? state.data
                      : state is FilterLocationsLoading
                          ? state.data
                          : _filterCubit.data;
                  final lang = context.locale.languageCode;
                  return Column(
                    children: [
                      // Country + Governorate row
                      Row(children: [
                        Expanded(child: _buildDropdown<int>(
                          hint: data.countriesLoading ? 'loading'.tr() : 'country'.tr(),
                          value: _selectedCountry?.id,
                          items: data.countries.map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.localized(lang),
                                style: const TextStyle(fontSize: 13)),
                          )).toList(),
                          onChanged: (id) {
                            if (id == null) return;
                            final country = data.countries.firstWhere((c) => c.id == id);
                            setState(() {
                              _selectedCountry    = country;
                              _selectedGovernorate = null;
                              _selectedCity       = null;
                              _selectedArea       = null;
                              _areaId             = null;
                            });
                            _filterCubit.loadGovernates(country.id);
                          },
                        )),
                        const SizedBox(width: 10),
                        Expanded(child: _buildDropdown<int>(
                          hint: data.governoratesLoading ? 'loading'.tr() : 'governorate'.tr(),
                          value: _selectedGovernorate?.id,
                          items: data.governorates.map((g) => DropdownMenuItem(
                            value: g.id,
                            child: Text(g.localized(lang),
                                style: const TextStyle(fontSize: 13)),
                          )).toList(),
                          onChanged: (id) {
                            if (id == null) return;
                            final gov = data.governorates.firstWhere((g) => g.id == id);
                            setState(() {
                              _selectedGovernorate = gov;
                              _selectedCity        = null;
                              _selectedArea        = null;
                              _areaId              = null;
                            });
                            _filterCubit.loadCities(governorateId: gov.id);
                          },
                        )),
                      ]),
                      const SizedBox(height: 10),
                      // City + Area row
                      Row(children: [
                        Expanded(child: _buildDropdown<int>(
                          hint: data.citiesLoading ? 'loading'.tr() : 'city'.tr(),
                          value: _selectedCity?.id,
                          items: data.cities.map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.localized(lang),
                                style: const TextStyle(fontSize: 13)),
                          )).toList(),
                          onChanged: (id) {
                            if (id == null) return;
                            final city = data.cities.firstWhere((c) => c.id == id);
                            setState(() {
                              _selectedCity = city;
                              _selectedArea = null;
                              _areaId = null;
                            });
                            _filterCubit.loadAreas(city.id);
                          },
                        )),
                        const SizedBox(width: 10),
                        Expanded(child: _buildDropdown<int>(
                          hint: data.areasLoading ? 'loading'.tr() : 'area'.tr(),
                          value: _selectedArea?.id,
                          items: data.areas.map((a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(a.localized(lang),
                                style: const TextStyle(fontSize: 13)),
                          )).toList(),
                          onChanged: (id) {
                            if (id == null) return;
                            final area = data.areas.firstWhere((a) => a.id == id);
                            setState(() {
                              _selectedArea = area;
                              _areaId = area.id;
                            });
                          },
                        )),
                      ]),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // ── Street ────────────────────────────────────────────────────
              _buildTextField(
                label: 'street_name'.tr(),
                ctrl: _streetCtrl,
                hint: 'Abbas El Akkad Street',
                required: true,
              ),

              // ── Building name ─────────────────────────────────────────────
              _buildTextField(
                label: 'building_name'.tr(),
                ctrl: _buildingNameCtrl,
                hint: 'Al Noor Building',
              ),

              // ── No / Floor / Apartment in one row ─────────────────────────
              Row(children: [
                Expanded(child: _buildTextField(
                  label: 'building_no'.tr(),
                  ctrl: _buildingNoCtrl,
                  hint: '24',
                  keyboardType: TextInputType.number,
                  required: true,
                )),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField(
                  label: 'floor_no'.tr(),
                  ctrl: _floorCtrl,
                  hint: '5',
                  keyboardType: TextInputType.number,
                )),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField(
                  label: 'apartment_no'.tr(),
                  ctrl: _apartmentNoCtrl,
                  hint: '12',
                )),
              ]),

              // ── Contact Name ──────────────────────────────────────────────
              _buildTextField(
                label: 'contact_name'.tr(),
                ctrl: _contactNameCtrl,
                hint: 'Saeed Ali Al-Omar',
                required: true,
              ),

              // ── Phone ─────────────────────────────────────────────────────
              _buildTextField(
                label: 'phone_number'.tr(),
                ctrl: _phoneCtrl,
                hint: '+201012345678',
                keyboardType: TextInputType.phone,
                required: true,
              ),

              // ── Secondary Phone ───────────────────────────────────────────
              _buildTextField(
                label: 'secondary_phone_optional'.tr(),
                ctrl: _secondaryPhoneCtrl,
                hint: '+201122334455',
                keyboardType: TextInputType.phone,
              ),

              // ── Notes ─────────────────────────────────────────────────────
              _buildTextField(
                label: 'notes'.tr(),
                ctrl: _notesCtrl,
                hint: 'Please call before arriving',
                maxLines: 2,
              ),

              // ── Default toggle ────────────────────────────────────────────
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: ZienaColors.bg1,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: ZienaColors.greyBorder, width: 0.6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('set_as_default'.tr(),
                        style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ZienaColors.textPrimary,
                        )),
                    Switch(
                      value: _isDefault,
                      onChanged: (v) => setState(() => _isDefault = v),
                      activeThumbColor: ZienaColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Save / Cancel ─────────────────────────────────────────────
              if (_isEdit)
                Row(children: [
                  Expanded(child: OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      side: const BorderSide(color: ZienaColors.greyBorder),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('cancel'.tr(),
                        style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: ZienaColors.textSecondary,
                        )),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _saveButton()),
                ])
              else
                _saveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: ZienaButton(
        text: _isEdit ? 'save'.tr() : 'save_address'.tr(),
        onTap: _isSaving ? null : _save,
        isLoading: _isSaving,
        disabledBackgroundColor: ZienaColors.primary.withOpacity(0.4),
      ),
    );
  }


  Widget _buildTextField({
    required String label,
    required TextEditingController ctrl,
    required String hint,
    bool required = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(label,
                style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ZienaColors.textPrimary,
                )),
            if (required)
              const Text(' *',
                  style: TextStyle(
                      color: ZienaColors.error, fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          CustomTextField(
            controller: ctrl,
            maxLines: maxLines,
            keyboardType: keyboardType,
            hintText: hint,
            fillColor: ZienaColors.bg1,
            borderColor: ZienaColors.greyBorder,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            validator: required
                ? (v) => (v == null || v.trim().isEmpty)
                    ? 'this_field_required'.tr()
                    : null
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: ZienaColors.bg1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ZienaColors.greyBorder, width: 0.8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Row(children: [
            const Icon(Icons.location_on_outlined,
                size: 15, color: ZienaColors.primary),
            const SizedBox(width: 6),
            Text(hint,
                style: const TextStyle(
                    fontSize: 13, color: ZienaColors.textHint)),
          ]),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: ZienaColors.textSecondary, size: 18),
          items: items,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13, color: ZienaColors.textPrimary),
          dropdownColor: ZienaColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

}