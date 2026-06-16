import 'package:cached_network_image/cached_network_image.dart';
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
    final isRtl = Directionality.of(context) == TextDirection.rtl;    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: ZienaColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ZienaColors.greyBorder, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Image ──────────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadiusDirectional.horizontal(
                  start: Radius.circular(18)),
              child: booking.image != null
                  ? CachedNetworkImage(
                imageUrl: booking.image!,
                width: 110, height: 108, fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(width: 110, height: 108, color: ZienaColors.bg3),
                errorWidget: (_, _, _) => _imgFallback(),
              )
                  : _imgFallback(),
            ),

            // ── Details ────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.serviceName,
                        style: const TextStyle(
                           fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: ZienaColors.textPrimary,
                        )),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.price.toStringAsFixed(0)} ${booking.currency}',
                      style: const TextStyle(
                         fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ZienaColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _Chip(Icons.bookmark_outline_rounded,
                              status.label.tr(), status.color),
                          const SizedBox(width: 6),
                          _Chip(Icons.location_on_outlined,
                              booking.address?.label ?? 'Home',
                              ZienaColors.textSecondary),
                          const SizedBox(width: 6),
                          _Chip(Icons.access_time_rounded,
                              booking.duration,
                              ZienaColors.textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Date panel ─────────────────────────────────────────────────
            Container(
              width: 60, height: 108,
              decoration: const BoxDecoration(
                color: ZienaColors.primary,
                borderRadius: BorderRadiusDirectional.horizontal(
                    end: Radius.circular(18)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(booking.dateDay,
                      style: const TextStyle(
                         fontSize: 22,
                        fontWeight: FontWeight.w700, color: Colors.white,
                      )),
                  Text(booking.dateMonth,
                      style: const TextStyle(
                         fontSize: 12,
                        color: Colors.white70,
                      )),
                  const SizedBox(height: 6),
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(!isRtl?Icons.chevron_left:Icons.chevron_right,
                        color: Colors.white, size: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgFallback() => Container(
      width: 110, height: 108, color: ZienaColors.bg3,
      child: const Icon(Icons.cleaning_services_rounded,
          color: ZienaColors.primary, size: 38));
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: color),
      const SizedBox(width: 3),
      Text(label,
          style: TextStyle(
             fontSize: 10,
            color: color, fontWeight: FontWeight.w500,
          )),
    ]);
  }
}