import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/ziena_button.dart';
import '../../../auth/data/models/verification_model.dart';
import '../../../auth/presentation/cubit/verification_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;

  String? _selectedGender;
  String? _genderError;
  File? _pickedImage;
  bool _agreedToTerms = false;
  bool _isSaving = false;

  static const _genders = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _firstNameCtrl = TextEditingController(text: p.firstName ?? '');
    _lastNameCtrl  = TextEditingController(text: p.lastName  ?? '');
    _phoneCtrl     = TextEditingController(text: p.mobileNumber);
    _emailCtrl     = TextEditingController(text: p.email ?? '');
    _selectedGender = (p.gender?.isNotEmpty == true) ? p.gender : null;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: ZienaColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded,
                color: ZienaColors.primary),
            title: Text('camera'.tr(),
                style: const TextStyle(fontSize: 14)),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded,
                color: ZienaColors.primary),
            title: Text('gallery'.tr(),
                style: const TextStyle(fontSize: 14)),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ],
      )),
    );
    if (source == null) return;
    // Resized + re-encoded so camera photos stay well under the backend's
    // 4 MB limit (rule: nullable|image|mimes:jpeg,png,jpg,webp|max:4096).
    final picked = await ImagePicker().pickImage(
        source: source, imageQuality: 85, maxWidth: 1600, maxHeight: 1600);
    if (picked == null || !mounted) return;

    final error = await _validateProfileImage(File(picked.path));
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: ZienaColors.error,
      ));
      return;
    }
    setState(() => _pickedImage = File(picked.path));
  }

  static const _allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];
  static const _maxImageBytes = 4096 * 1024; // backend max:4096 (KB)

  /// Mirrors the backend rule so the user gets a clear message instead of
  /// a server 422. Returns a translated error, or null when valid.
  Future<String?> _validateProfileImage(File file) async {
    final ext = file.path.split('.').last.toLowerCase();
    if (!_allowedImageExtensions.contains(ext)) {
      return 'image_invalid_type'.tr();
    }
    if (await file.length() > _maxImageBytes) {
      return 'image_too_large'.tr();
    }
    return null;
  }

  Future<void> _save() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    final genderValid = _selectedGender != null;
    if (!genderValid) {
      setState(() => _genderError = 'please_select_gender'.tr());
    } else {
      setState(() => _genderError = null);
    }
    if (!formValid || !genderValid) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('please_agree_terms'.tr()),
        backgroundColor: ZienaColors.error,
      ));
      return;
    }
    setState(() => _isSaving = true);

    final success = await context.read<ProfileCubit>().updateProfile(
      firstName:   _firstNameCtrl.text.trim(),
      lastName:    _lastNameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      email:       _emailCtrl.text.trim(),
      gender:      _selectedGender ?? '',
      idNumber:    widget.profile.idNumber,
      image:       _pickedImage,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.read<ProfileCubit>().lastUpdateError ??
              'err_generic'.tr()),
          backgroundColor: ZienaColors.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      appBar: AppBar(
        backgroundColor: ZienaColors.bg1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('profile'.tr(),
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            )),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar ────────────────────────────────────────────────────
              Center(child: _buildAvatar()),
              const SizedBox(height: 28),

              // ── First Name ────────────────────────────────────────────────
              _fieldLabel('first_name'.tr()),
              const SizedBox(height: 8),
              _buildTextField(
                ctrl: _firstNameCtrl,
                hint: 'Saeed Ali',
                required: true,
              ),
              const SizedBox(height: 16),

              // ── Last Name ─────────────────────────────────────────────────
              _fieldLabel('last_name'.tr()),
              const SizedBox(height: 8),
              _buildTextField(
                ctrl: _lastNameCtrl,
                hint: 'Al-Omar',
                required: true,
              ),
              const SizedBox(height: 16),

              // ── Phone ─────────────────────────────────────────────────────
              _fieldLabel('phone_number'.tr()),
              const SizedBox(height: 8),
              _buildPhoneField(),
              const SizedBox(height: 16),

              // ── Email ─────────────────────────────────────────────────────
              _fieldLabel('email'.tr()),
              const SizedBox(height: 8),
              _buildTextField(
                ctrl: _emailCtrl,
                hint: 'saeed.alomar@gmail.com',
                keyboardType: TextInputType.emailAddress,
                required: true,
                isEmail: true,
              ),
              const SizedBox(height: 16),

              // ── Gender ────────────────────────────────────────────────────
              _fieldLabel('gender'.tr()),
              const SizedBox(height: 8),
              _buildGenderDropdown(),
              if (_genderError != null) ...[
                const SizedBox(height: 6),
                Text(_genderError!,
                    style: const TextStyle(
                        fontSize: 12, color: ZienaColors.error)),
              ],
              const SizedBox(height: 20),

              // ── Terms checkbox ────────────────────────────────────────────
              _buildTermsCheckbox(),
              const SizedBox(height: 28),

              // ── Buttons ───────────────────────────────────────────────────
              Row(children: [
                Expanded(child: ZienaButton(
                  text: 'save_button'.tr(),
                  onTap: _isSaving ? null : _save,
                  isLoading: _isSaving,
                )),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: const BorderSide(color: ZienaColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('cancel'.tr(),
                      style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600,
                        color: ZienaColors.primary,
                      )),
                )),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ── Avatar widget ────────────────────────────────────────────────────────
  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _pickImage,
      child: SizedBox(
        width: 100, height: 110,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _pickedImage != null
                  ? Image.file(_pickedImage!,
                  width: 100, height: 100, fit: BoxFit.cover)
                  : widget.profile.image != null
                  ? CachedNetworkImage(
                imageUrl: widget.profile.image!,
                cacheKey: widget.profile.imageCacheKey,
                width: 100, height: 100,
                fit: BoxFit.cover,
                placeholder: (_, __) => _avatarPlaceholder(),
                errorWidget: (_, __, ___) => _avatarPlaceholder(),
              )
                  : _avatarPlaceholder(),
            ),
            // Camera badge
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(
                  color: ZienaColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      width: 100, height: 100,
      decoration: BoxDecoration(
        color: ZienaColors.bg3,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(child: Text(
        widget.profile.initials,
        style: const TextStyle(
          fontSize: 30, fontWeight: FontWeight.w700,
          color: ZienaColors.primary,
        ),
      )),
    );
  }

  // ── Phone (read-only) ──────────────────────────────────────────────────────
  // The mobile number is the login identity (verified by OTP), so it's shown
  // as a plain read-only field styled like the others. It already carries
  // its country code, so no separate flag/code picker. Always LTR.
  Widget _buildPhoneField() {
    return _buildTextField(
      ctrl: _phoneCtrl,
      hint: '+20 100 000 0000',
      keyboardType: TextInputType.phone,
      readOnly: true,
      ltr: true,
    );
  }

  // ── Gender dropdown ────────────────────────────────────────────────────────
  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: ZienaColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZienaColors.greyBorder, width: 0.8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          hint: Text('select_gender'.tr(),
              style: const TextStyle(
                  fontSize: 13, color: ZienaColors.textHint)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: ZienaColors.textSecondary, size: 20),
          items: _genders.map((g) => DropdownMenuItem(
            value: g,
            child: Text(g.tr(), style: const TextStyle(fontSize: 14)),
          )).toList(),
          onChanged: (v) => setState(() {
            _selectedGender = v;
            _genderError = null;
          }),
          dropdownColor: ZienaColors.white,
          borderRadius: BorderRadius.circular(12),
          style: const TextStyle(
              fontSize: 14, color: ZienaColors.textPrimary),
        ),
      ),
    );
  }

  // ── Terms checkbox ─────────────────────────────────────────────────────────
  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 20, height: 20,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: _agreedToTerms ? ZienaColors.primary : Colors.transparent,
            border: Border.all(
              color: _agreedToTerms
                  ? ZienaColors.primary
                  : ZienaColors.greyBorder,
              width: 1.5,
            ),
          ),
          child: _agreedToTerms
              ? const Icon(Icons.check, color: Colors.white, size: 13)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(
          'agree_terms_privacy'.tr(),
          style: const TextStyle(
              fontSize: 12, color: ZienaColors.textSecondary, height: 1.4),
        )),
      ]),
    );
  }

  Widget _fieldLabel(String t) => Text(t,
      style: const TextStyle(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: ZienaColors.textPrimary,
      ));

  Widget _buildTextField({
    required TextEditingController ctrl,
    required String hint,
    bool required = false,
    bool isEmail = false,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    bool ltr = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      readOnly: readOnly,
      enableInteractiveSelection: !readOnly,
      textDirection: ltr ? TextDirection.ltr : null,
      textAlign: ltr && Directionality.of(context) == TextDirection.rtl
          ? TextAlign.end
          : TextAlign.start,
      style: TextStyle(
          fontSize: 14,
          color: readOnly ? ZienaColors.textSecondary : ZienaColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontSize: 13, color: ZienaColors.textHint),
        filled: true,
        fillColor: ZienaColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ZienaColors.greyBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: ZienaColors.greyBorder, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: readOnly
              ? const BorderSide(color: ZienaColors.greyBorder, width: 0.8)
              : const BorderSide(color: ZienaColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ZienaColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ZienaColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
        isDense: true,
      ),
      validator: (v) {
        if (required && (v == null || v.trim().isEmpty)) {
          return 'this_field_required'.tr();
        }
        if (isEmail && v != null && v.trim().isNotEmpty) {
          final emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
          if (!emailRegex.hasMatch(v.trim())) {
            return 'invalid_email'.tr();
          }
        }
        return null;
      },
    );
  }
}