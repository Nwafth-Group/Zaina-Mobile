import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/model/service_model.dart';

class ServiceResultCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const ServiceResultCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final name = service.localizedName(lang);
    final categoryName = service.localizedCategory(lang);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: ZienaColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ZienaColors.greyBorder, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Image ──────────────────────────────────────────────────────
            ClipRRect(
              borderRadius:
              const BorderRadius.horizontal(left: Radius.circular(16)),
              child: service.image != null
                  ? Image.network(
                service.image!,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagePlaceholder(),
              )
                  : _imagePlaceholder(),
            ),

            // ── Details ─────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    Text(
                      categoryName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: ZienaColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Name
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ZienaColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Rating
                    StarRating(rating: service.avgRating, size: 13),
                    const SizedBox(height: 4),
                    // Price
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                            '${service.price.pricePerHour.toStringAsFixed(0)} ${service.price.currency} ',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: ZienaColors.primary,
                            ),
                          ),
                          TextSpan(
                            text: _priceLabel(service.type),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: ZienaColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 90,
      height: 90,
      color: ZienaColors.bg3,
      child: const Icon(
        Icons.cleaning_services_rounded,
        color: ZienaColors.primary,
        size: 36,
      ),
    );
  }

  String _priceLabel(String type) {
    switch (type) {
      case 'hourly':
        return 'Per Hour';
      case 'moqema':
        return 'Resident';
      default:
        return 'Per Session';
    }
  }
}

// ── Reusable star rating ──────────────────────────────────────────────────────
class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool showNumber;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 16,
    this.showNumber = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          final full = i < rating.floor();
          final half = !full && i < rating && (rating - i) >= 0.5;
          return Icon(
            full
                ? Icons.star_rounded
                : half
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded,
            color: const Color(0xFFFFB800),
            size: size,
          );
        }),
        if (showNumber) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: size * 0.75,
              fontWeight: FontWeight.w600,
              color: ZienaColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}