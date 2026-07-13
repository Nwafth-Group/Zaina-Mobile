import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/features/services/data/model/booking_selection_data.dart';
import 'package:zeina/features/services/data/model/service_detail_model.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../../bookings/presentation/cubit/bookings_cubit.dart';
import '../../../home/presentation/cubit/address_cubit.dart';
import '../../../home/presentation/cubit/home_cubti.dart';
import '../../data/model/booking_validation_exception.dart';
import '../../data/model/booking_validation_model.dart';
import '../../data/model/visit_type_model.dart';
import '../../data/repository/services_repository.dart';
import '../widgets/coverage_error_dialog.dart';

enum _PaymentMethod { points, wallet, card }

extension on _PaymentMethod {
  String get apiValue {
    switch (this) {
      case _PaymentMethod.points:
        return 'points';
      case _PaymentMethod.wallet:
        return 'wallet';
      case _PaymentMethod.card:
        return 'card';
    }
  }
}

class CheckoutScreen extends StatefulWidget {
  static const String routeName = '/checkout';

  final ServiceDetailModel service;
  final BookingSelectionData selection;
  final BookingValidationModel validation;

  const CheckoutScreen({
    super.key,
    required this.service,
    required this.selection,
    required this.validation,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  _PaymentMethod _paymentMethod = _PaymentMethod.wallet;
  bool _agreedToTerms = false;

  final TextEditingController _couponController = TextEditingController();
  String? _couponError;
  bool _isValidatingCoupon = false;
  bool _isPaying = false;

  // Starts as the pricing passed in from the booking sheet; gets replaced
  // with a fresh result whenever a coupon is successfully applied.
  late BookingValidationModel _currentValidation;

  static const _weekdayShort = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  @override
  void initState() {
    super.initState();
    _currentValidation = widget.validation;
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  String _formatDays(List<DateTime> dates) {
    final names = dates.map((d) => _weekdayShort[d.weekday - 1]).toList();
    if (names.length <= 1) return names.join();
    return '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}';
  }

  String _formatTime12h(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return hhmm;
    int hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1].padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  bool get _canPay =>
      _agreedToTerms &&
          _couponError == null &&
          !_isValidatingCoupon &&
          !_isPaying;

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();

    // Cleared the field → revert to the original (no-coupon) pricing.
    if (code.isEmpty) {
      setState(() {
        _couponError = null;
        _currentValidation = widget.validation;
      });
      return;
    }

    setState(() => _isValidatingCoupon = true);
    try {
      final result = await sl<ServicesRepository>().validateBooking(
        serviceId: widget.service.id,
        visitType: widget.selection.visitType.type,
        addressId: widget.service.addressId,
        dates: widget.selection.selectedDates,
        startTime: widget.selection.shift.startLabel,
        workersCount: widget.selection.workerCount,
        preferredWorkerIds: widget.selection.preferredWorkerIds.isEmpty
            ? null
            : widget.selection.preferredWorkerIds,
        couponCode: code,
        duration: widget.selection.duration,
        workerGender: widget.selection.workerGender,
        numberOfChildren: widget.selection.numberOfChildren,
        childAgeGroupIds: widget.selection.childAgeGroupIds,
      );
      if (!mounted) return;
      setState(() {
        _currentValidation = result;
        _couponError = null;
        _isValidatingCoupon = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        // Invalid coupon → keep the last valid (no-coupon) pricing, but
        // block Pay until the field is cleared.
        _couponError =
        e is BookingValidationException ? e.displayMessage : 'invalid_coupon'.tr();
        _isValidatingCoupon = false;
      });
    }
  }

  Future<void> _handlePay() async {
    if (!_canPay) return;
    setState(() => _isPaying = true);
    try {
      await sl<ServicesRepository>().createBooking(
        serviceId: widget.service.id,
        addressId: widget.service.addressId,
        // Configurable-hourly services (Hospitality Worker, Babysitter —
        // both always set `duration`) send duration/etc. instead of
        // visitType; that payload shape has no visit_type field at all.
        // NOTE: keyed off `duration`, not `workerGender` — Babysitter also
        // has workerGender == null (no gender choice) but is still
        // configurable-hourly, so workerGender alone can't distinguish it
        // from the fixed-shift flow.
        visitType:
        widget.selection.duration == null ? widget.selection.visitType.type : null,
        dates: widget.selection.selectedDates,
        startTime: widget.selection.shift.startLabel,
        duration: widget.selection.duration,
        workerGender: widget.selection.workerGender,
        numberOfChildren: widget.selection.numberOfChildren,
        childAgeGroupIds: widget.selection.childAgeGroupIds,
        note: widget.selection.note,
        workerIds: _currentValidation.workerIds,
        paymentMethod: _paymentMethod.apiValue,
        couponCode: _couponController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _isPaying = false);
      // Both are globally provided (see ZienaApp's MultiBlocProvider), so the
      // Bookings screen and Home screen reflect the new booking immediately
      // once the user navigates there, without needing a manual pull-to-refresh.
      context.read<BookingsCubit>().fetchBookings(refresh: true);
      context.read<HomeCubit>().fetchHomeData();
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPaying = false);
      final message =
      e is BookingValidationException ? e.displayMessage : 'err_generic'.tr();
      showCoverageErrorDialog(context, message: message);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('booking_confirmed'.tr()),
        content: Text('booking_confirmed_desc'.tr()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text('done'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pricing = _currentValidation.pricing;
    final locale = context.locale.languageCode;
    final startLabel = _formatTime12h(widget.selection.shift.startLabel);
    final endLabel = _formatTime12h(widget.selection.shift.endLabel);

    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      appBar: AppBar(
        backgroundColor: ZienaColors.bg1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'checkout'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ZienaColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // ── Service summary ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ZienaColors.bg2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ZienaColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                _summaryRow('service', widget.service.localizedName(locale)),
                _summaryRow('duration', widget.selection.visitType.type.labelKey.tr()),
                if (widget.selection.selectedDates.length > 1)
                  _summaryRow('days', _formatDays(widget.selection.selectedDates)),
                _summaryRow('start_end_time', '$startLabel - $endLabel'),
                _summaryRow('service_cost',
                    '${pricing.subtotal.toStringAsFixed(0)} ${pricing.currency}'),
                if (widget.selection.visitType.hasDiscount)
                  _summaryRow('service_discount',
                      '${widget.selection.visitType.discount} %',
                      isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Address ───────────────────────────────────────────────────
          Text('address'.tr(), style: _sectionTitleStyle),
          const SizedBox(height: 8),
          BlocBuilder<AddressCubit, AddressState>(
            builder: (ctx, state) {
              final cubit = ctx.read<AddressCubit>();
              final def = cubit.list.isNotEmpty ? cubit.defaultAddress : null;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ZienaColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ZienaColors.greyBorder),
                ),
                child: Row(
                  children: [
                    _assetIconCircle('assets/images/addresses.png'),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            def != null
                                ? def.shortAddress(locale)
                                : 'no_addresses_yet'.tr(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: ZienaColors.textPrimary,
                            ),
                          ),
                          if (def != null)
                            Text(
                              def.oneLiner,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: ZienaColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // ── Coupon ────────────────────────────────────────────────────
          Text('coupon'.tr(), style: _sectionTitleStyle),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: ZienaColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _couponError != null
                    ? ZienaColors.error
                    : ZienaColors.greyBorder,
              ),
            ),
            child: Row(
              children: [
                _assetIconCircle('assets/images/enter_coupon.png'),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _applyCoupon(),
                    onChanged: (v) {
                      if (v.isEmpty) _applyCoupon();
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'enter_coupon'.tr(),
                      hintStyle: const TextStyle(
                          fontSize: 14, color: ZienaColors.textHint),
                    ),
                    style: const TextStyle(
                        fontSize: 14, color: ZienaColors.textPrimary),
                  ),
                ),
                if (_isValidatingCoupon)
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: ZienaColors.primary),
                    ),
                  )
                else
                  TextButton(
                    onPressed: _applyCoupon,
                    child: Text('apply'.tr()),
                  ),
              ],
            ),
          ),
          if (_couponError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                _couponError!,
                style: const TextStyle(fontSize: 12, color: ZienaColors.error),
              ),
            )
          else if (pricing.couponDiscountAmount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                'coupon_applied'.tr(),
                style: const TextStyle(
                    fontSize: 12,
                    color: ZienaColors.success,
                    fontWeight: FontWeight.w600),
              ),
            ),
          const SizedBox(height: 20),

          // ── Payment method ────────────────────────────────────────────
          Text('payment_method'.tr(), style: _sectionTitleStyle),
          const SizedBox(height: 8),
          _paymentTile(
            asset: 'assets/images/my_points.png',
            label: 'points'.tr(),
            method: _PaymentMethod.points,
          ),
          const SizedBox(height: 10),
          _paymentTile(
            asset: 'assets/images/wallet.png',
            label: 'wallet'.tr(),
            method: _PaymentMethod.wallet,
            // TODO: wire to WalletCubit's real balance field once its state
            // shape is confirmed — placeholder shown for now.
            trailing: 'wallet_balance_placeholder'.tr(),
          ),
          const SizedBox(height: 10),
          _paymentTile(
            asset: 'assets/images/card.png',
            label: 'my_card'.tr(),
            method: _PaymentMethod.card,
          ),
          const SizedBox(height: 20),

          // ── Booking summary ───────────────────────────────────────────
          Text('booking_summary'.tr(), style: _sectionTitleStyle),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ZienaColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ZienaColors.greyBorder),
            ),
            child: Column(
              children: [
                _priceRow('service_price',
                    '${pricing.subtotal.toStringAsFixed(0)} ${pricing.currency}'),
                _priceRow('service_vat',
                    '${pricing.tax.toStringAsFixed(0)} ${pricing.currency}'),
                if (pricing.discount > 0)
                  _priceRow('discount',
                      '${pricing.discount.toStringAsFixed(0)} ${pricing.currency}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('total'.tr(),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ZienaColors.primary)),
              Text(
                '${pricing.total.toStringAsFixed(0)} ${pricing.currency}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: ZienaColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Contract ──────────────────────────────────────────────────
          Text('contract'.tr(), style: _sectionTitleStyle),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ZienaColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ZienaColors.greyBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: ZienaColors.bg2,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.description_outlined,
                      color: ZienaColors.primary),
                ),
                const SizedBox(width: 10),
                Text('contract'.tr(),
                    style: const TextStyle(
                        fontSize: 14, color: ZienaColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _agreedToTerms,
                activeColor: ZienaColors.primary,
                onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
              ),
              Expanded(
                child: Text(
                  'agree_terms_conditions'.tr(),
                  style: const TextStyle(
                      fontSize: 13, color: ZienaColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canPay ? _handlePay : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ZienaColors.primary,
                disabledBackgroundColor: ZienaColors.greyBorder,
              ),
              child: _isPaying
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: ZienaColors.white),
              )
                  : Text('pay'.tr()),
            ),
          ),
        ],
      ),
    );
  }

  static const _sectionTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: ZienaColors.textPrimary,
  );

  Widget _assetIconCircle(String asset, {double size = 40}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: ZienaColors.bg2,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(
            ZienaColors.primary,
            BlendMode.srcIn,
          ),
          child: Image.asset(asset, width: size * 0.5, height: size * 0.5),
        ),
      ),
    );
  }

  Widget _summaryRow(String labelKey, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            labelKey.tr(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ZienaColors.primary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ZienaColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String labelKey, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(labelKey.tr(),
              style: const TextStyle(
                  fontSize: 13, color: ZienaColors.textSecondary)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ZienaColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _paymentTile({
    required String asset,
    required String label,
    required _PaymentMethod method,
    String? trailing,
  }) {
    final selected = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ZienaColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? ZienaColors.primary : ZienaColors.greyBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            _assetIconCircle(asset, size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ZienaColors.textPrimary)),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  trailing,
                  style: const TextStyle(
                      fontSize: 12, color: ZienaColors.textSecondary),
                ),
              ),
            Radio<_PaymentMethod>(
              value: method,
              groupValue: _paymentMethod,
              activeColor: ZienaColors.primary,
              onChanged: (v) => setState(() => _paymentMethod = v!),
            ),
          ],
        ),
      ),
    );
  }
}