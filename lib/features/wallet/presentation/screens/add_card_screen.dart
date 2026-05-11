import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../cubit/cubit.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _nameCtrl      = TextEditingController();
  final _numberCtrl    = TextEditingController();
  final _expiryCtrl    = TextEditingController();
  final _cvcCtrl       = TextEditingController();
  bool _isSaving       = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvcCtrl.dispose();
    super.dispose();
  }

  String _detectBrand(String number) {
    final n = number.replaceAll(' ', '');
    if (n.startsWith('4')) return 'VISA';
    if (n.startsWith('5') || n.startsWith('2')) return 'MASTERCARD';
    if (n.startsWith('3')) return 'AMEX';
    return 'VISA';
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    final number = _numberCtrl.text.replaceAll(' ', '');
    final lastFour = number.length >= 4
        ? number.substring(number.length - 4)
        : number;
    final brand = _detectBrand(number);

    final success = await context.read<CardsCubit>().addCard(
      cardToken:      'tok_${DateTime.now().millisecondsSinceEpoch}',
      lastFour:       lastFour,
      brand:          brand,
      cardHolderName: _nameCtrl.text.trim(),
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CardsCubit, CardsState>(
      listener: (context, state) {
        if (state is CardsError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: ZienaColors.error,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: ZienaColors.white,
        appBar: AppBar(
          backgroundColor: ZienaColors.white, elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: ZienaColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('add_card'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              )),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel('cardholder_name'.tr()),
                const SizedBox(height: 8),
                _buildField(
                  ctrl: _nameCtrl,
                  hint: 'Mohammad',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'this_field_required'.tr()
                      : null,
                ),
                const SizedBox(height: 16),

                _fieldLabel('card_number'.tr()),
                const SizedBox(height: 8),
                _buildField(
                  ctrl: _numberCtrl,
                  hint: '5898 5555 7777 8297',
                  keyboardType: TextInputType.number,
                  suffix: ValueListenableBuilder(
                    valueListenable: _numberCtrl,
                    builder: (_, v, __) => Text(
                      _detectBrand(v.text),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1F71),
                      ),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _CardNumberFormatter(),
                  ],
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'this_field_required'.tr();
                    }
                    if (v.replaceAll(' ', '').length < 16) {
                      return 'invalid_card_number'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('expiration_date'.tr()),
                      const SizedBox(height: 8),
                      _buildField(
                        ctrl: _expiryCtrl,
                        hint: '02/24',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _ExpiryFormatter(),
                        ],
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'this_field_required'.tr()
                            : null,
                      ),
                    ],
                  )),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('cvc'.tr()),
                      const SizedBox(height: 8),
                      _buildField(
                        ctrl: _cvcCtrl,
                        hint: '875',
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) => (v == null || v.length < 3)
                            ? 'this_field_required'.tr()
                            : null,
                      ),
                    ],
                  )),
                ]),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZienaColors.primary,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                        : Text('add_card'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600, color: ZienaColors.textPrimary,
      ));

  Widget _buildField({
    required TextEditingController ctrl,
    required String hint,
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
      style: const TextStyle(
          fontSize: 14,
          color: ZienaColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontSize: 13,
            color: ZienaColors.textHint),
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
            ? Padding(
            padding: const EdgeInsets.only(right: 12),
            child: suffix)
            : null,
        suffixIconConstraints:
        const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
      validator: validator,
    );
  }
}

// ── Card formatters ───────────────────────────────────────────────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue newVal) {
    final digits = newVal.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return TextEditingValue(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue newVal) {
    final digits = newVal.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 4; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return TextEditingValue(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}