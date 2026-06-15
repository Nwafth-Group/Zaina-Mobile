import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/ziena_button.dart';
import '../cubit/cards_cubit.dart';

class AddCardSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  const AddCardSheet({super.key, required this.onSuccess});

  @override
  State<AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<AddCardSheet> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvcCtrl    = TextEditingController();
  bool _isDefault   = false;
  bool _isSaving    = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvcCtrl.dispose();
    super.dispose();
  }

  String _detectBrand(String n) {
    final d = n.replaceAll(' ', '');
    if (d.startsWith('4'))      return 'VISA';
    if (d.startsWith('5') || d.startsWith('2')) return 'MASTERCARD';
    if (d.startsWith('3'))      return 'AMEX';
    return 'VISA';
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    final number   = _numberCtrl.text.replaceAll(' ', '');
    final lastFour = number.length >= 4
        ? number.substring(number.length - 4) : number;
    final brand    = _detectBrand(number);

    final success = await context.read<CardsCubit>().addCard(
      cardToken:      'tok_${DateTime.now().millisecondsSinceEpoch}',
      lastFour:       lastFour,
      brand:          brand,
      cardHolderName: _nameCtrl.text.trim(),
      isDefault:      _isDefault,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ZienaColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: ZienaColors.greyBorder,
                    borderRadius: BorderRadius.circular(2)),
              )),
              const SizedBox(height: 20),
              Center(child: Text('add_card'.tr(),
                  style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: ZienaColors.textPrimary,
                  ))),
              const SizedBox(height: 24),

              // Cardholder name
              _label('cardholder_name'.tr()),
              const SizedBox(height: 8),
              _buildField(ctrl: _nameCtrl, hint: 'Mohammad', required: true),
              const SizedBox(height: 16),

              // Card number
              _label('card_number'.tr()),
              const SizedBox(height: 8),
              _buildField(
                ctrl: _numberCtrl,
                hint: '5888 5555 7777 8297',
                keyboardType: TextInputType.number,
                suffix: ValueListenableBuilder(
                  valueListenable: _numberCtrl,
                  builder: (_, v, __) => Text(_detectBrand(v.text),
                      style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1F71),
                        fontStyle: FontStyle.italic,
                      )),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CardFormatter(),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'this_field_required'.tr();
                  if (v.replaceAll(' ', '').length < 16) {
                    return 'invalid_card_number'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Expiry + CVC
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('expiration_date'.tr()),
                    const SizedBox(height: 8),
                    _buildField(
                      ctrl: _expiryCtrl, hint: '02/24',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ExpiryFormatter(),
                      ],
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'this_field_required'.tr() : null,
                    ),
                  ],
                )),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('cvc'.tr()),
                    const SizedBox(height: 8),
                    _buildField(
                      ctrl: _cvcCtrl, hint: '896',
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => (v == null || v.length < 3)
                          ? 'this_field_required'.tr() : null,
                    ),
                  ],
                )),
              ]),
              const SizedBox(height: 16),

              // Set as default
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('set_as_default'.tr(),
                      style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500,
                        color: ZienaColors.textPrimary,
                      )),
                  Switch(
                    value: _isDefault,
                    onChanged: (v) => setState(() => _isDefault = v),
                    activeColor: ZienaColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              ZienaButton(
                text: 'add_card'.tr(),
                onTap: _isSaving ? null : _save,
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: ZienaColors.textPrimary,
      ));

  Widget _buildField({
    required TextEditingController ctrl,
    required String hint,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      style: const TextStyle(fontSize: 14, color: ZienaColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontSize: 13, color: ZienaColors.textHint),
        filled: true,
        fillColor: ZienaColors.bg1,
        counterText: '',
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
          borderSide: const BorderSide(
              color: ZienaColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ZienaColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
        isDense: true,
        suffixIcon: suffix != null
            ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix)
            : null,
        suffixIconConstraints:
        const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
      validator: validator ?? (required
          ? (v) => (v == null || v.trim().isEmpty)
          ? 'this_field_required'.tr() : null
          : null),
    );
  }
}

class _CardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue o, TextEditingValue n) {
    final d = n.text.replaceAll(' ', '');
    final b = StringBuffer();
    for (int i = 0; i < d.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) b.write(' ');
      b.write(d[i]);
    }
    final s = b.toString();
    return TextEditingValue(
        text: s,
        selection: TextSelection.collapsed(offset: s.length));
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue o, TextEditingValue n) {
    final d = n.text.replaceAll('/', '');
    final b = StringBuffer();
    for (int i = 0; i < d.length && i < 4; i++) {
      if (i == 2) b.write('/');
      b.write(d[i]);
    }
    final s = b.toString();
    return TextEditingValue(
        text: s,
        selection: TextSelection.collapsed(offset: s.length));
  }
}