import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/widgets/signin_required_widget.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/shared_pref_helper.dart';
import '../../../../injection_container.dart';
import '../../../../widgets/custom_icon.dart';
import '../../data/models/wallet_model.dart';
import '../cubit/cubit.dart';
import 'add_money_screen.dart';
import 'all_transactions_screen.dart';

class WalletScreen extends StatefulWidget {
  final bool isLoggedIn;
  const WalletScreen({super.key, required this.isLoggedIn});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    print("hhhhh ${SharedPrefHelper.isLoggedIn()}");
    if (widget.isLoggedIn) {
      context.read<WalletCubit>().fetchWallet();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      body: SafeArea(
        child: widget.isLoggedIn ? _buildContent() : SignInRequiredWidget(tabKey: 'wallet'),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        if (state is WalletLoading) {
          return const Center(child: CircularProgressIndicator(
              color: ZienaColors.primary, strokeWidth: 2));
        }
        if (state is WalletError) {
          return _buildError(context, state.message);
        }
        if (state is WalletLoaded) {
          return RefreshIndicator(
            color: ZienaColors.primary,
            onRefresh: () => context.read<WalletCubit>().fetchWallet(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text('wallet'.tr(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: ZienaColors.textPrimary,
                      )),
                  const SizedBox(height: 20),

                  // Balance card
                  _BalanceCard(
                    balance: state.data.availableBalance,
                    currency: state.data.currency,
                    onAddMoney: () => _openAddMoney(context, state.data),
                  ),
                  const SizedBox(height: 24),

                  // Transactions header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('transactions'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ZienaColors.textPrimary,
                          )),
                      if (state.data.transactions.isNotEmpty)
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => sl<WalletCubit>()
                                  ..fetchWallet(),
                                child: const AllTransactionsScreen(),
                              ),
                            ),
                          ),
                          child: Text('see_all'.tr(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: ZienaColors.primary,
                              )),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Transaction list (preview: first 5)
                  if (state.data.transactions.isEmpty)
                    _buildNoTransactions()
                  else
                    ...state.data.transactions
                        .take(5)
                        .map((tx) => _TransactionTile(tx: tx)),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  void _openAddMoney(BuildContext context, WalletData data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<CardsCubit>()..fetchCards()),
            BlocProvider(create: (_) => sl<TopUpCubit>()),
            BlocProvider.value(value: context.read<WalletCubit>()),
          ],
          child: const AddMoneyScreen(),
        ),
      ),
    );
  }

  Widget _buildNoTransactions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(children: [
          Container(
            width: 120, height: 120,
            decoration: const BoxDecoration(
                color: ZienaColors.bg2, shape: BoxShape.circle),
            child: Stack(alignment: Alignment.center, children: [
              const Icon(Icons.receipt_long_outlined,
                  size: 58, color: ZienaColors.primary),
              Positioned(
                bottom: 16, right: 16,
                child: Container(
                  width: 28, height: 28,
                  decoration: const BoxDecoration(
                      color: ZienaColors.error, shape: BoxShape.circle),
                  child: const Icon(Icons.close,
                      color: Colors.white, size: 16),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Text('no_transactions'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ZienaColors.textPrimary,
              )),
          const SizedBox(height: 6),
          Text('no_transactions_desc'.tr(),
              style: const TextStyle(
                fontSize: 13,
                color: ZienaColors.textSecondary,
              ),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _buildError(BuildContext context, String msg) {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off_rounded,
            size: 60, color: ZienaColors.textHint),
        const SizedBox(height: 12),
        Text(msg, textAlign: TextAlign.center,
            style: const TextStyle(
                
                color: ZienaColors.textSecondary)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => context.read<WalletCubit>().fetchWallet(),
          style: ElevatedButton.styleFrom(
            backgroundColor: ZienaColors.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text('retry'.tr(),
              style: const TextStyle(
                  color: Colors.white)),
        ),
      ],
    ));
  }
}

// ── Balance Card ──────────────────────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  final double balance;
  final String currency;
  final VoidCallback onAddMoney;

  const _BalanceCard({
    required this.balance,
    required this.currency,
    required this.onAddMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ZienaColors.primary, ZienaColors.primaryDark],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ZienaColors.primary.withOpacity(0.35),
            blurRadius: 16, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('available_balance'.tr(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70, fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 8),
                Text(
                  '${balance.toStringAsFixed(2)} $currency',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700, color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
              ]),
            ),
            ImageAsset('assets/images/money.png', width:60, height: 60, fit: BoxFit.cover,)
          ]),
          GestureDetector(
            onTap: onAddMoney,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('add_money'.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600, color: Colors.white,
                      )),
                ),
              ]),
            ),
          ),

        ],
      ),
    );
  }
}

// ── Transaction tile ──────────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  final WalletTransaction tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.isCredit;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ZienaColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZienaColors.greyBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: [
        // Icon
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: isCredit
                ? ZienaColors.success.withOpacity(0.1)
                : ZienaColors.error.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCredit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            color: isCredit ? ZienaColors.success : ZienaColors.error,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),

        // Title + ref
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tx.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ZienaColors.textPrimary,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            if (tx.referenceId != null) ...[
              const SizedBox(height: 2),
              Text(tx.referenceId!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: ZienaColors.textSecondary,
                  )),
            ],
            const SizedBox(height: 2),
            Text(tx.createdAt,
                style: const TextStyle(
                  fontSize: 11,
                  color: ZienaColors.textHint,
                )),
          ],
        )),

        // Amount
        Text(
          '${isCredit ? '+' : '-'}${tx.amount.toStringAsFixed(0)} EGP',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isCredit ? ZienaColors.success : ZienaColors.error,
          ),
        ),
      ]),
    );
  }
}