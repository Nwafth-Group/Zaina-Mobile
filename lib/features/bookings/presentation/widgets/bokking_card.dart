import 'package:easy_localization/easy_localization.dart' show StringTranslateExtension;
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/model/booking_model.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const BookingCard({super.key, required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = booking.statusEnum;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: ZienaColors.bg2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ZienaColors.primary.withOpacity(0.35)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Date panel ───────────────────────────────────────────────
              Container(
                width: 84,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: const BoxDecoration(
                  color: ZienaColors.primary,
                  borderRadius: BorderRadiusDirectional.horizontal(
                      start: Radius.circular(18)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${booking.dateMonth} ${booking.dateDay}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.timeLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Details ──────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Category label — the API doesn't return a service
                      // category, so this is a static label for now (every
                      // booking today is an hourly service).
                      Text(
                        'Hourly Services'.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ZienaColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.serviceName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: ZienaColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.bookmark_outline_rounded,
                              size: 13, color: status.color),
                          const SizedBox(width: 4),
                          Text(
                            status.label.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: status.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          _AssetIcon(
                            asset: 'assets/images/rn.png',
                            color: ZienaColors.primary.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking.bookingReference,
                            style: TextStyle(
                              fontSize: 12,
                              color: ZienaColors.primary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          _AssetIcon(
                            asset: booking.isMultiVisit
                                ? 'assets/images/calendar3.png'
                                : 'assets/images/calendar1.png',
                            color: ZienaColors.primary.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking.visitTypeLabelKey.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              color: ZienaColors.primary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small tinted asset icon, used for the ref/visit-type rows.
class _AssetIcon extends StatelessWidget {
  final String asset;
  final Color color;
  const _AssetIcon({required this.asset, required this.color});

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: Image.asset(asset, width: 13, height: 13),
    );
  }
}