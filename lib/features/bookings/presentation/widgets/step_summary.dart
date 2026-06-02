import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/custom_text_form_field.dart';
import '../../../../widgets/ziena_button.dart';
import '../../data/model/booking_flow_model.dart';
import '../cubit/booking_flow_cubit.dart';

class StepSummary extends StatefulWidget {
  const StepSummary({super.key});

  @override
  State<StepSummary> createState() => _StepSummaryState();
}

class _StepSummaryState extends State<StepSummary> {
  String _paymentMethod = 'cash';
  final _couponCtrl = TextEditingController();
  bool _couponApplied = false;
  double _couponDiscount = 0;

  // Mock address (replace with address picker)
  final int _addressId = 1;
  final String _addressLabel = 'Home';
  final String _addressDetail = 'Nasr City, Cairo\nAbbas El Akkad Street Building 24';

  @override
  void initState() {
    super.initState();
    // Set address in flow
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<BookingFlowCubit>();
      cubit.updateFlow(cubit.flow.copyWith(
        selectedAddressId: _addressId,
        selectedAddressLabel: _addressLabel,
        paymentMethod: _paymentMethod,
      ));
    });
  }

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    if (_couponCtrl.text.trim().isEmpty) return;
    // Mock: any coupon gives 10 EGP discount
    setState(() {
      _couponApplied = true;
      _couponDiscount = 10;
    });
    final cubit = context.read<BookingFlowCubit>();
    cubit.updateFlow(cubit.flow.copyWith(
      couponCode: _couponCtrl.text.trim(),
      couponDiscount: 10,
    ));
  }

  void _onBook() {
    context.read<BookingFlowCubit>().submitBooking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('book_now'.tr()),
      ),
      body: BlocBuilder<BookingFlowCubit, BookingFlowState>(
        builder: (context, state) {
          final flow = state.flow;

          if (flow == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Service header ──────────────────────────────────────
                    _ServiceHeader(flow: flow),
                    const SizedBox(height: 20),

                    // ── Date & time ─────────────────────────────────────────
                    _sectionTitle('date_and_time'.tr()),
                    const SizedBox(height: 10),
                    _InfoRow(
                      Icons.calendar_today_rounded,
                      flow.selectedDate != null
                          ? DateFormat('yyyy-MM-dd').format(DateTime.parse(flow.selectedDate!))
                          : '-',
                    ),
                    const SizedBox(height: 6),
                    _InfoRow(
                      Icons.access_time_rounded,
                      '${flow.selectedStartTime ?? '-'} - ${flow.selectedEndTime ?? '-'}',
                    ),
                    const SizedBox(height: 20),

                    // ── Payment method ──────────────────────────────────────
                    _sectionTitle('payment_method'.tr()),
                    const SizedBox(height: 10),
                    _buildPaymentOptions(flow),
                    const SizedBox(height: 20),

                    // ── Coupon ──────────────────────────────────────────────
                    _sectionTitle('coupon'.tr()),
                    const SizedBox(height: 10),
                    _buildCouponField(),
                    if (_couponApplied) ...[
                      const SizedBox(height: 8),
                      _CouponChip(
                        label: '10 EGP OFF',
                        code: _couponCtrl.text,
                        onRemove: () => setState(() {
                          _couponApplied = false;
                          _couponDiscount = 0;
                          _couponCtrl.clear();
                          final c = context.read<BookingFlowCubit>();
                          c.updateFlow(c.flow.copyWith(
                            couponCode: '',
                            couponDiscount: 0,
                          ));
                        }),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // ── Address ─────────────────────────────────────────────
                    _sectionTitle('address'.tr()),
                    const SizedBox(height: 10),
                    _AddressTile(
                      label: _addressLabel,
                      detail: _addressDetail,
                    ),
                    const SizedBox(height: 20),

                    // ── Contract / Terms ────────────────────────────────────
                    _sectionTitle('contract'.tr()),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: ZienaColors.bg1,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: ZienaColors.bg4.withOpacity(0.6)),
                      ),
                      child: Row(children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: ZienaColors.bg3,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.description_outlined,
                              color: ZienaColors.primary, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Text('terms_conditions'.tr(),
                            style: const TextStyle(
                               fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: ZienaColors.primary,
                            )),
                      ]),
                    ),

                    _buildBottomBar(context, flow, state)
                  ],
                ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentOptions(BookingFlowData flow) {
    final methods = [
      ('cash', 'Cash', Icons.money_rounded),
      ('wallet', 'Wallet', Icons.account_balance_wallet_outlined),
      ('card', 'Card', Icons.credit_card_rounded),
    ];
    return Column(
      children: methods.map((m) {
        final sel = _paymentMethod == m.$1;
        return GestureDetector(
          onTap: () {
            setState(() => _paymentMethod = m.$1);
            final c = context.read<BookingFlowCubit>();
            c.updateFlow(c.flow.copyWith(paymentMethod: m.$1));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: sel ? ZienaColors.bg2 : ZienaColors.bg1,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: sel ? ZienaColors.primary : ZienaColors.greyBorder,
                width: sel ? 1.5 : 0.8,
              ),
            ),
            child: Row(children: [
              Icon(m.$3,
                  color: sel ? ZienaColors.primary : ZienaColors.textSecondary,
                  size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(m.$2,
                  style: TextStyle(
                     fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: sel ? ZienaColors.primary : ZienaColors.textPrimary,
                  ))),
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sel ? ZienaColors.primary : Colors.transparent,
                  border: Border.all(
                      color: sel ? ZienaColors.primary : ZienaColors.greyBorder,
                      width: 2),
                ),
                child: sel
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : null,
              ),
            ]),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCouponField() {
    return Row(children: [
      Expanded(
        child: Expanded(
          child: CustomTextField(
            controller: _couponCtrl,
            hintText: 'enter_coupon'.tr(),
            fillColor: ZienaColors.bg1,
            borderColor: ZienaColors.greyBorder,
            contentPadding: EdgeInsets.zero,
            maxLines: 1,
            borderRadius: 15,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 12, right: 8),
              child: Icon(Icons.local_offer_outlined,
                  color: ZienaColors.primary, size: 18),
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      ZienaButton(
        text: 'apply'.tr(),
        onTap: _couponApplied ? null : _applyCoupon,
        width: 100,
        height: 50,
        disabledBackgroundColor: ZienaColors.greyBorder,
        disabledTextColor: Colors.white,
      ),
    ]);
  }

  Widget _buildBottomBar(
      BuildContext context, BookingFlowData flow, BookingFlowState state) {
    final loading = state.submitting;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
      decoration: BoxDecoration(
        color: ZienaColors.white,
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.07),
          blurRadius: 16, offset: const Offset(0, -4),
        )],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Price rows
        _PriceRow('subtotal'.tr(),
            '${flow.subtotal.toStringAsFixed(0)} ${flow.currency}', false),
        const SizedBox(height: 4),
        _PriceRow('service_vat'.tr(),
            '${flow.vat.toStringAsFixed(0)} ${flow.currency}', false),
        if (_couponDiscount > 0) ...[
          const SizedBox(height: 4),
          _PriceRow('coupon_discount'.tr(),
              '-${_couponDiscount.toStringAsFixed(0)} ${flow.currency}', false),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(color: ZienaColors.greyBorder, height: 1),
        ),
        _PriceRow('total'.tr(),
            '${flow.total.toStringAsFixed(0)} ${flow.currency}', true),
        const SizedBox(height: 14),
        ZienaButton(
          text: 'book_now'.tr(),
          isLoading: state.submitting,
          onTap: state.submitting ? null : _onBook,
          disabledBackgroundColor: ZienaColors.primary.withOpacity(0.5),
          disabledTextColor: Colors.white,
        ),
      ]),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(
         fontSize: 14,
        fontWeight: FontWeight.w700, color: ZienaColors.textPrimary,
      ));
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ServiceHeader extends StatelessWidget {
  final BookingFlowData flow;
  const _ServiceHeader({required this.flow});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ZienaColors.bg1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ZienaColors.greyBorder, width: 0.6),
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: flow.serviceImage != null
              ? Image.network(flow.serviceImage!,
              width: 60, height: 60, fit: BoxFit.cover)
              : Container(
              width: 60, height: 60, color: ZienaColors.bg3,
              child: const Icon(Icons.cleaning_services_rounded,
                  color: ZienaColors.primary, size: 28)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              flow.serviceName ?? '',
              style: const TextStyle(
                
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${flow.pricePerHour.toStringAsFixed(0)} ${flow.currency} × '
                  '${(flow.selectedDurationHours ?? 1).toString()} hrs × '
                  '${(flow.selectedWorkerCount ?? 1).toString()} worker',
              style: const TextStyle(
                 fontSize: 12,
                color: ZienaColors.textSecondary,
              ),
            ),
          ],
        )),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: ZienaColors.primary),
      const SizedBox(width: 8),
      Text(label,
          style: const TextStyle(
             fontSize: 13,
            color: ZienaColors.textPrimary,
          )),
    ]);
  }
}

class _AddressTile extends StatelessWidget {
  final String label, detail;
  const _AddressTile({required this.label, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ZienaColors.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZienaColors.greyBorder, width: 0.6),
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: ZienaColors.bg3,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.location_on_outlined,
              color: ZienaColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                   fontSize: 13,
                  fontWeight: FontWeight.w600, color: ZienaColors.textPrimary,
                )),
            const SizedBox(height: 2),
            Text(detail,
                style: const TextStyle(
                   fontSize: 11,
                  color: ZienaColors.textSecondary, height: 1.4,
                )),
          ],
        )),
      ]),
    );
  }
}

class _CouponChip extends StatelessWidget {
  final String label, code;
  final VoidCallback onRemove;
  const _CouponChip(
      {required this.label, required this.code, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ZienaColors.bg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ZienaColors.primary.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.local_offer_rounded,
            color: ZienaColors.primary, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(code,
                style: const TextStyle(
                   fontSize: 13,
                  fontWeight: FontWeight.w600, color: ZienaColors.primary,
                )),
            Text(label,
                style: const TextStyle(
                   fontSize: 11,
                  color: ZienaColors.textSecondary,
                )),
          ],
        )),
        GestureDetector(
          onTap: onRemove,
          child: Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
                color: ZienaColors.greyBorder, shape: BoxShape.circle),
            child: const Icon(Icons.close, size: 14,
                color: ZienaColors.textSecondary),
          ),
        ),
      ]),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool isTotal;
  const _PriceRow(this.label, this.value, this.isTotal);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          
          fontSize: isTotal ? 14 : 13,
          fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
          color: isTotal ? ZienaColors.textPrimary : ZienaColors.textSecondary,
        )),
        Text(value, style: TextStyle(
          
          fontSize: isTotal ? 15 : 13,
          fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
          color: isTotal ? ZienaColors.primary : ZienaColors.textSecondary,
        )),
      ],
    );
  }
}