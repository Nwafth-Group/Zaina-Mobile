import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../data/models/wallet_model.dart';
import '../cubit/cubit.dart';
import '../widgets/filter_sgeet.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() =>
      _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  WalletFilter _activeFilter = WalletFilter.all;
  String? _fromDate;
  String? _toDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      appBar: AppBar(
        
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('transactions'.tr(),
            style: const TextStyle(
               fontSize: 18,
              fontWeight: FontWeight.w700, color: ZienaColors.textPrimary,
            )),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: ZienaColors.primary),
            onPressed: _openFilter,
          ),
        ],
      ),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator(
                color: ZienaColors.primary, strokeWidth: 2));
          }

          final transactions = state is WalletLoaded
              ? state.data.transactions
              : <WalletTransaction>[];

          if (transactions.isEmpty && state is WalletLoaded) {
            return _buildEmpty();
          }

          return RefreshIndicator(
            color: ZienaColors.primary,
            onRefresh: () => context.read<WalletCubit>().fetchWallet(
              filter: _activeFilter,
              fromDate: _fromDate,
              toDate: _toDate,
            ),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: transactions.length,
              itemBuilder: (_, i) =>
                  _TransactionTile(tx: transactions[i]),
            ),
          );
        },
      ),
    );
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(
        activeFilter: _activeFilter,
        fromDate: _fromDate,
        toDate: _toDate,
        onApply: (filter, from, to) {
          setState(() {
            _activeFilter = filter;
            _fromDate = from;
            _toDate   = to;
          });
          context.read<WalletCubit>().fetchWallet(
            filter: filter,
            fromDate: from,
            toDate: to,
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90, height: 90,
          decoration: const BoxDecoration(
              color: ZienaColors.bg2, shape: BoxShape.circle),
          child: const Icon(Icons.receipt_long_outlined,
              color: ZienaColors.primary, size: 40),
        ),
        const SizedBox(height: 16),
        Text('no_transactions'.tr(),
            style: const TextStyle(
               fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ZienaColors.textPrimary,
            )),
        const SizedBox(height: 6),
        Text('try_different_filter'.tr(),
            style: const TextStyle(
               fontSize: 13,
              color: ZienaColors.textSecondary,
            )),
      ],
    ));
  }
}

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
