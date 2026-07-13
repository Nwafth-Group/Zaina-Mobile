import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/features/bookings/data/model/booking_detail_model.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/ziena_button.dart';
import '../cubit/bookings_cubit.dart';

class ReviewSheet extends StatefulWidget {
  final BookingDetailModel booking;
  const ReviewSheet({super.key, required this.booking});

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  int _serviceRating = 0;
  final _serviceCommentCtrl = TextEditingController();
  bool _isSubmitting = false;

  // Per-worker ratings: workerId -> {rating, comment}
  late final Map<int, Map<String, dynamic>> _workerRatings;

  @override
  void initState() {
    super.initState();
    _workerRatings = {
      for (final w in widget.booking.workers)
        w.id: {'rating': 0, 'comment': TextEditingController()},
    };
  }

  @override
  void dispose() {
    _serviceCommentCtrl.dispose();
    for (final v in _workerRatings.values) {
      (v['comment'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  bool get _canSubmit =>
      _serviceRating > 0 &&
          _workerRatings.values.every((v) => (v['rating'] as int) > 0) &&
          !_isSubmitting;

  Future<void> _submit() async {
    if (!_canSubmit) return;

    final workers = _workerRatings.entries.map((e) => {
      'worker_id': e.key,
      'rating': e.value['rating'] as int,
      'comment': (e.value['comment'] as TextEditingController).text.trim(),
    }).toList();

    setState(() => _isSubmitting = true);
    try {
      await context.read<BookingDetailCubit>().submitReview(
        bookingId: widget.booking.id,
        serviceRating: _serviceRating,
        serviceComment: _serviceCommentCtrl.text.trim(),
        workers: workers,
      );
      if (!mounted) return;
      // Signal success via the pop value — the caller (still mounted after
      // this sheet closes) shows the success dialog, rather than this sheet
      // trying to show one from its own about-to-be-disposed context.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final message = e is String ? e : 'err_generic'.tr();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: ZienaColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ZienaColors.bg1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: ZienaColors.greyBorder,
                  borderRadius: BorderRadius.circular(2)),
            )),
            const SizedBox(height: 20),
            Center(child: Text('rate_your_experience'.tr(),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: ZienaColors.textPrimary,
                ))),
            const SizedBox(height: 20),

            // ── Service rating ──────────────────────────────────────────
            Text('service_rate'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ZienaColors.textPrimary,
                )),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ZienaColors.bg1,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ZienaColors.greyBorder, width: 0.6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias, // Clip the child
                      child: Image.network(
                        widget.booking.image,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: ZienaColors.bg3,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.cleaning_services_rounded,
                              color: ZienaColors.primary,
                              size: 22,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(widget.booking.serviceName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ZienaColors.textPrimary,
                          )),
                      _StarRow(
                        rating: _serviceRating,
                        onRate: (r) => setState(() => _serviceRating = r),
                      ),
                    ]),
                  ]),
                  const SizedBox(height: 10),
                  _FeedbackField(ctrl: _serviceCommentCtrl),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Worker ratings ──────────────────────────────────────────
            if (widget.booking.workers.isNotEmpty) ...[
              Text('worker_rate'.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ZienaColors.textPrimary,
                  )),
              const SizedBox(height: 12),
              ...widget.booking.workers.map(_workerRatingCard),
              const SizedBox(height: 20),
            ],

            // ── Submit ──────────────────────────────────────────────────
            ZienaButton(
              text: 'submit_review'.tr(),
              onTap: _canSubmit ? _submit : null,
              isLoading: _isSubmitting,
              disabledBackgroundColor: ZienaColors.primary.withOpacity(0.4),
              disabledTextColor: Colors.white,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _workerRatingCard(BookingDetailWorker worker) {
    final data = _workerRatings[worker.id]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ZienaColors.bg1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ZienaColors.greyBorder, width: 0.6),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle, color: ZienaColors.bg3,
                border: Border.all(
                    color: ZienaColors.primary.withOpacity(0.2), width: 1.5),
              ),
              clipBehavior: Clip.antiAlias, // Clip the child
              child: Image.network(
                worker.image,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    alignment: Alignment.center,
                    child: const Icon(Icons.person, color: ZienaColors.primary, size: 22)
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(worker.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ZienaColors.textPrimary,
                  )),
              _StarRow(
                rating: data['rating'] as int,
                onRate: (r) => setState(() => data['rating'] = r),
              ),
            ]),
          ]),
          const SizedBox(height: 10),
          _FeedbackField(ctrl: data['comment'] as TextEditingController),
        ]),
      ),
    );
  }
}

// ── Star row widget ───────────────────────────────────────────────────────────
class _StarRow extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRate;
  const _StarRow({required this.rating, required this.onRate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) => GestureDetector(
        onTap: () => onRate(i + 1),
        child: Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          color: const Color(0xFFFFB800),
          size: 22,
        ),
      )),
    );
  }
}

// ── Feedback text field ───────────────────────────────────────────────────────
class _FeedbackField extends StatelessWidget {
  final TextEditingController ctrl;
  const _FeedbackField({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ZienaColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ZienaColors.greyBorder),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: 2,
        style: const TextStyle(fontSize: 13, color: ZienaColors.textPrimary),
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.all(10),
          hintText: 'write_feedback_optional'.tr(),
          hintStyle: const TextStyle(fontSize: 13, color: ZienaColors.textHint),
        ),
      ),
    );
  }
}