import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/success_dialog.dart';
import '../../../../widgets/ziena_button.dart';
import '../../../wallet/data/models/wallet_model.dart';
import '../cubit/cards_cubit.dart';
import '../../../wallet/presentation/screens/add_card_screen.dart';

class MyCardsScreen extends StatefulWidget {
  const MyCardsScreen({super.key});

  @override
  State<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CardsCubit>().fetchCards();
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
        title: Text('my_card'.tr(),
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            )),
        centerTitle: false,
      ),
      body: BlocConsumer<CardsCubit, CardsState>(
        listener: (context, state) {
          if (state is CardsError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: ZienaColors.error,
            ));
          }
        },
        builder: (context, state) {
          final isLoading = state is CardsLoading;
          final isActionLoading = state is CardActionLoading;

          final cards = state is CardsLoaded
              ? state.cards
              : state is CardActionLoading
              ? state.current
              : context.read<CardsCubit>().cards;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator(
                color: ZienaColors.primary, strokeWidth: 2));
          }

          return Stack(children: [
            Column(children: [
              Expanded(
                child: cards.isEmpty
                    ? _buildEmpty()
                    : _buildCardsList(context, cards),
              ),

              // ── Add Card button ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                child: ZienaButton(
                  text: 'add_card'.tr(),
                  onTap: () => _openAddCard(context),
                ),
              ),
            ]),

            if (isActionLoading)
              Container(
                color: Colors.black.withOpacity(0.08),
                child: const Center(child: CircularProgressIndicator(
                    color: ZienaColors.primary, strokeWidth: 2)),
              ),
          ]);
        },
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Illustration
        SizedBox(
          width: 220, height: 220,
          child: CustomPaint(painter: _CardIllustrationPainter()),
        ),
        const SizedBox(height: 8),
        Text('add_payment_method'.tr(),
            style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            ), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text('payment_method_desc'.tr(),
            style: const TextStyle(
                fontSize: 13, color: ZienaColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center),
      ]),
    ));
  }

  // ── Cards list ─────────────────────────────────────────────────────────────
  Widget _buildCardsList(BuildContext context, List<CardModel> cards) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('payment_method'.tr(),
              style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600,
                color: ZienaColors.textPrimary,
              )),
          const SizedBox(height: 12),
          Expanded(child: ListView.separated(
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _CardTile(
              card: cards[i],
              onDelete: () => _confirmDelete(context, cards[i].id),
            ),
          )),
        ],
      ),
    );
  }

  Future<void> _openAddCard(BuildContext context) async {
    final added = await AddCardScreen.open(
      context,
      cubit: context.read<CardsCubit>(),
    );
    if (!added || !context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => SuccessDialog(
        title: 'card_added_title'.tr(),
        message: 'card_added_desc'.tr(),
        buttonText: 'done'.tr(),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int cardId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        title: Text('delete_card'.tr(),
            style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text('delete_card_confirm'.tr(),
            style: const TextStyle(color: ZienaColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr(),
                style: const TextStyle(color: ZienaColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CardsCubit>().deleteCard(cardId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ZienaColors.error, elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('delete'.tr(),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Card tile ─────────────────────────────────────────────────────────────────
class _CardTile extends StatelessWidget {
  final CardModel card;
  final VoidCallback onDelete;

  const _CardTile({required this.card, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isMastercard = card.brand.toUpperCase() == 'MASTERCARD';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ZienaColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZienaColors.greyBorder, width: 0.5),
      ),
      child: Row(children: [
        // Brand icon
        _BrandBadge(brand: card.brand),
        const SizedBox(width: 14),

        // Number
        Expanded(child: Text(
          card.displayNumber,
          style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500,
            color: ZienaColors.textPrimary,
          ),
        )),

        // Menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz,
              color: ZienaColors.primary, size: 22),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          onSelected: (v) {
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                const Icon(Icons.edit_outlined,
                    size: 16, color: ZienaColors.textSecondary),
                const SizedBox(width: 8),
                Text('edit'.tr(),
                    style: const TextStyle(fontSize: 14)),
              ]),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                const Icon(Icons.delete_outline,
                    size: 16, color: ZienaColors.error),
                const SizedBox(width: 8),
                Text('delete'.tr(),
                    style: TextStyle(
                        fontSize: 14, color: ZienaColors.error)),
              ]),
            ),
          ],
        ),
      ]),
    );
  }
}

// ── Brand badge ───────────────────────────────────────────────────────────────
class _BrandBadge extends StatelessWidget {
  final String brand;
  const _BrandBadge({required this.brand});

  @override
  Widget build(BuildContext context) {
    final isMastercard = brand.toUpperCase() == 'MASTERCARD';
    if (isMastercard) {
      return SizedBox(
        width: 40, height: 26,
        child: Stack(children: [
          Positioned(left: 0, child: Container(
            width: 24, height: 24,
            decoration: const BoxDecoration(
                color: Color(0xFFEB001B), shape: BoxShape.circle),
          )),
          Positioned(left: 12, child: Container(
            width: 24, height: 24,
            decoration: const BoxDecoration(
                color: Color(0xFFF79E1B), shape: BoxShape.circle),
          )),
        ]),
      );
    }
    // VISA text
    return const Text('VISA',
        style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w900,
          color: Color(0xFF1A1F71),
          fontStyle: FontStyle.italic,
        ));
  }
}

// ── Empty state illustration painter ─────────────────────────────────────────
class _CardIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Background blob
    final blobPaint = Paint()..color = const Color(0xFFFFECEF);
    final blobPath = Path()
      ..addOval(Rect.fromCenter(
          center: Offset(cx - 10, cy + 10), width: 170, height: 150));
    canvas.drawPath(blobPath, blobPaint);

    // Wallet body
    final walletPaint = Paint()..color = const Color(0xFFF45B8C);
    final wallet = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 60, cy - 30, 120, 80),
      const Radius.circular(14),
    );
    canvas.drawRRect(wallet, walletPaint);

    // Wallet flap
    final flapPaint = Paint()..color = const Color(0xFFD94A78);
    final flap = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 60, cy - 30, 120, 28),
      const Radius.circular(14),
    );
    canvas.drawRRect(flap, flapPaint);

    // Wallet clasp circle
    canvas.drawCircle(Offset(cx, cy - 16),
        12, Paint()..color = const Color(0xFFFF8FA3));
    canvas.drawCircle(Offset(cx, cy - 16),
        6, Paint()..color = const Color(0xFFD94A78));

    // Card sticking out
    final cardPaint = Paint()..color = Colors.white;
    final card = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 8, cy - 56, 70, 44),
      const Radius.circular(8),
    );
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-0.3);
    canvas.translate(-cx, -cy);
    canvas.drawRRect(card, cardPaint);

    // Card stripe
    canvas.drawRect(
      Rect.fromLTWH(cx - 8, cy - 44, 70, 10),
      Paint()..color = const Color(0xFFFFBEC8),
    );
    canvas.restore();

    // Hand outline (simplified)
    final handPaint = Paint()
      ..color = const Color(0xFFF45B8C).withOpacity(0.15)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final hand = Path()
      ..moveTo(cx - 50, cy + 60)
      ..cubicTo(cx - 60, cy + 30, cx - 20, cy + 20, cx, cy + 40)
      ..cubicTo(cx + 20, cy + 60, cx + 50, cy + 50, cx + 55, cy + 30);
    canvas.drawPath(hand, handPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}