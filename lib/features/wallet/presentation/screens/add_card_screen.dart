import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../injection_container.dart';
import '../../../../widgets/app_toast.dart';
import '../../../../widgets/custom_icon.dart';
import '../../../profile/presentation/cubit/cards_cubit.dart';

/// Full-screen "Add Card" form (per Figma) — POST customer/cards with
/// `card_token`, `last_four`, `card_brand`, `card_holder_name`.
///
/// Reusable from anywhere (checkout, My Cards, Add Money): open it with
/// [AddCardScreen.open], which resolves to `true` once the card is saved.
/// Pass the caller's [CardsCubit] so its list refreshes with the new card;
/// if the caller has none, a standalone one is used.
class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  static Future<bool> open(BuildContext context, {CardsCubit? cubit}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => cubit != null
            ? BlocProvider.value(value: cubit, child: const AddCardScreen())
            : BlocProvider(
                create: (_) => sl<CardsCubit>(),
                child: const AddCardScreen(),
              ),
      ),
    );
    return result ?? false;
  }

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvcCtrl = TextEditingController();
  bool _isSaving = false;

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
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    final number = _numberCtrl.text.replaceAll(' ', '');
    final lastFour =
        number.length >= 4 ? number.substring(number.length - 4) : number;

    final success = await context.read<CardsCubit>().addCard(
          // TODO: replace with the token from the payment gateway once
          // integrated — the raw card number must never be sent.
          cardToken: 'tok_${DateTime.now().millisecondsSinceEpoch}',
          lastFour: lastFour,
          brand: _detectBrand(number),
          cardHolderName: _nameCtrl.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isSaving = false);
    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return BlocListener<CardsCubit, CardsState>(
      listener: (context, state) {
        if (state is CardsError) AppToast.showError(context, state.message);
      },
      child: Scaffold(
        backgroundColor: ZienaColors.bg1,
        appBar: AppBar(
          backgroundColor: ZienaColors.bg1,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Transform.flip(
              flipX: isRtl,
              child: const AppIcon(HugeIcons.strokeRoundedArrowLeft02,
                  size: 26, width: 1.5, color: ZienaColors.textPrimary),
            ),
          ),
          title: Text(
            'add_card'.tr(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: ZienaColors.textPrimary,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel('cardholder_name'.tr()),
                _buildField(
                  ctrl: _nameCtrl,
                  hint: 'Mohammad',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'this_field_required'.tr()
                      : null,
                ),
                const SizedBox(height: 18),
                _fieldLabel('card_number'.tr()),
                _buildField(
                  ctrl: _numberCtrl,
                  hint: '5888 5555 7777 8297',
                  keyboardType: TextInputType.number,
                  // Card numbers always read left-to-right, even in Arabic.
                  textDirection: TextDirection.ltr,
                  suffix: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _numberCtrl,
                    builder: (_, v, _) => Text(
                      _detectBrand(v.text),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: ZienaColors.textSecondary,
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
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('expiration_date'.tr()),
                          _buildField(
                            ctrl: _expiryCtrl,
                            hint: '02/24',
                            keyboardType: TextInputType.number,
                            textDirection: TextDirection.ltr,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _ExpiryFormatter(),
                            ],
                            validator: validateCardExpiry,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('cvc'.tr()),
                          _buildField(
                            ctrl: _cvcCtrl,
                            hint: '896',
                            keyboardType: TextInputType.number,
                            textDirection: TextDirection.ltr,
                            maxLength: 4,
                            obscureText: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (v) => (v == null || v.length < 3)
                                ? 'this_field_required'.tr()
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Pinned to the bottom, as in Figma.
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZienaColors.primary,
                  disabledBackgroundColor:
                      ZienaColors.primary.withValues(alpha: 0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: ZienaColors.white, strokeWidth: 2),
                      )
                    : Text(
                        'add_card'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ZienaColors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: ZienaColors.textPrimary,
          ),
        ),
      );

  OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  Widget _buildField({
    required TextEditingController ctrl,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    TextDirection? textDirection,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? suffix,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      textDirection: textDirection,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 15, color: ZienaColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintTextDirection: textDirection,
        hintStyle: const TextStyle(fontSize: 15, color: ZienaColors.grey),
        filled: true,
        fillColor: ZienaColors.bg1,
        counterText: '',
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: _border(ZienaColors.bg4),
        enabledBorder: _border(ZienaColors.bg4),
        focusedBorder: _border(ZienaColors.primary, 1.5),
        errorBorder: _border(ZienaColors.error),
        focusedErrorBorder: _border(ZienaColors.error, 1.5),
        suffixIcon: suffix != null
            ? Padding(
                padding: const EdgeInsetsDirectional.only(end: 20),
                child: suffix,
              )
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