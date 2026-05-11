import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../data/models/wallet_model.dart';
import '../cubit/cubit.dart';
import 'add_card_screen.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final _amountCtrl = TextEditingController();
  int? _selectedCardId;
  final _quickAmounts = [50, 100, 200, 500];

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _onAddMoney() {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) return;
    if (_selectedCardId == null) return;

    context.read<TopUpCubit>().topUp(
      amount: amount,
      paymentMethod: 'card',
      cardId: _selectedCardId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TopUpCubit, TopUpState>(
      listener: (context, state) {
        if (state is TopUpSuccess) {
          // Refresh wallet
          context.read<WalletCubit>().fetchWallet();
          _showSuccess(context);
        }
        if (state is TopUpError) {
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
          title: Text('add_money'.tr(),
              style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              )),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.tune_rounded,
                  color: ZienaColors.primary),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('transactions'.tr(),
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ZienaColors.textPrimary,
                  )),
              const SizedBox(height: 12),

              // Quick amount chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: _quickAmounts.map((a) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _amountCtrl.text = '$a'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: ZienaColors.bg1,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: ZienaColors.greyBorder, width: 0.8),
                        ),
                        child: Text('$a EGP',
                            style: const TextStyle(
                              fontFamily: 'Poppins', fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: ZienaColors.textPrimary,
                            )),
                      ),
                    ),
                  );
                }).toList()),
              ),
              const SizedBox(height: 16),

              // Amount field
              Text('or_enter_amount'.tr(),
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 13,
                    color: ZienaColors.textSecondary,
                  )),
              const SizedBox(height: 8),
              _AmountField(controller: _amountCtrl),
              const SizedBox(height: 24),

              // Payment method
              Text('payment_method'.tr(),
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ZienaColors.textPrimary,
                  )),
              const SizedBox(height: 12),

              // Cards list
              BlocConsumer<CardsCubit, CardsState>(
                listener: (context, state) {
                  if (state is CardAdded) {
                    context.read<CardsCubit>().fetchCards();
                  }
                  if (state is CardsError) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(state.message),
                      backgroundColor: ZienaColors.error,
                    ));
                  }
                },
                builder: (context, state) {
                  final cards = state is CardsLoaded
                      ? state.cards
                      : state is CardActionLoading
                      ? state.current
                      : context.read<CardsCubit>().cards;

                  return Column(children: [
                    ...cards.map((c) => _CardTile(
                      card: c,
                      isSelected: _selectedCardId == c.id,
                      onTap: () =>
                          setState(() => _selectedCardId = c.id),
                      onDelete: () =>
                          context.read<CardsCubit>().deleteCard(c.id),
                    )),

                    // Add card
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<CardsCubit>(),
                            child: const AddCardScreen(),
                          ),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: ZienaColors.bg1,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: ZienaColors.greyBorder, width: 0.8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_rounded,
                                color: ZienaColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Text('add_card'.tr(),
                                style: const TextStyle(
                                  fontFamily: 'Poppins', fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: ZienaColors.primary,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ]);
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      color: ZienaColors.white,
      child: BlocBuilder<TopUpCubit, TopUpState>(
        builder: (_, state) {
          final loading = state is TopUpLoading;
          return ElevatedButton(
            onPressed: (_selectedCardId != null && !loading) ? _onAddMoney : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: ZienaColors.primary,
              disabledBackgroundColor: ZienaColors.primary.withOpacity(0.4),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: loading
                ? const CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2)
                : Text('add_money'.tr(),
                style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 16,
                  fontWeight: FontWeight.w600, color: Colors.white,
                )),
          );
        },
      ),
    );
  }

  void _showSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: ZienaColors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 110, height: 110,
              decoration: const BoxDecoration(
                  color: ZienaColors.bg2, shape: BoxShape.circle),
              child: Stack(alignment: Alignment.center, children: [
                const Icon(Icons.notifications_active_rounded,
                    size: 55, color: ZienaColors.primary),
                Positioned(
                  bottom: 10, right: 10,
                  child: Container(
                    width: 28, height: 28,
                    decoration: const BoxDecoration(
                        color: ZienaColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 16),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            Text('success_title'.tr(),
                style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ZienaColors.textPrimary,
                )),
            const SizedBox(height: 8),
            Text('wallet_topped_up'.tr(),
                style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 13,
                  color: ZienaColors.textSecondary, height: 1.5,
                ),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // dialog
                Navigator.pop(context); // add money screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ZienaColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('done'.tr(),
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 15,
                    fontWeight: FontWeight.w600, color: Colors.white,
                  )),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Amount field ──────────────────────────────────────────────────────────────
class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  const _AmountField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ZienaColors.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZienaColors.greyBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(
            fontFamily: 'Poppins', fontSize: 15,
            color: ZienaColors.textPrimary, fontWeight: FontWeight.w500),
        decoration: const InputDecoration(
          hintText: '0.0 EGP',
          hintStyle: TextStyle(
              fontFamily: 'Poppins', fontSize: 15,
              color: ZienaColors.textHint),
          border: InputBorder.none,
          filled: false,
          contentPadding:
          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          isDense: true,
        ),
      ),
    );
  }
}

// ── Card tile ─────────────────────────────────────────────────────────────────
class _CardTile extends StatelessWidget {
  final CardModel card;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CardTile({
    required this.card,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? ZienaColors.bg2 : ZienaColors.bg1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? ZienaColors.primary : ZienaColors.greyBorder,
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Row(children: [
          // Brand icon
          Container(
            width: 44, height: 32,
            decoration: BoxDecoration(
              color: ZienaColors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: ZienaColors.greyBorder, width: 0.6),
            ),
            child: Center(
              child: Text(card.brand,
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1F71),
                  )),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(card.cardHolderName,
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ZienaColors.textPrimary,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(card.displayNumber,
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 12,
                    color: ZienaColors.textSecondary,
                  )),
            ],
          )),
          // Delete
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.delete_outline,
                color: ZienaColors.error, size: 20),
          ),
          const SizedBox(width: 10),
          // Radio
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? ZienaColors.primary : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? ZienaColors.primary
                    : ZienaColors.greyBorder,
                width: 2,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 12)
                : null,
          ),
        ]),
      ),
    );
  }
}