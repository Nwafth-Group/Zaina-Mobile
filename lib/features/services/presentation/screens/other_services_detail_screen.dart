import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

/// UI-only, reusable "Service Details" screen (no Bloc/Cubit, no API
/// calls). Pass in the content for whichever service is being shown —
/// Pedicure & Manicure, Deep Cleaning, etc. — and hook up [onBookNow] to
/// open that service's own booking flow.

class ReviewUi {
  final String name;
  final double rating;
  final String timeAgoKey;
  final String commentKey;

  const ReviewUi({
    required this.name,
    required this.rating,
    required this.timeAgoKey,
    required this.commentKey,
  });
}

const List<ReviewUi> defaultReviews = [
  ReviewUi(
    name: 'Keith Ralph P.',
    rating: 4,
    timeAgoKey: 'review_time_2_months',
    commentKey: 'review_comment_clean_professional',
  ),
  ReviewUi(
    name: 'Dheeraj M.',
    rating: 4,
    timeAgoKey: 'review_time_2_months',
    commentKey: 'review_comment_clean_professional',
  ),
];

class ServiceDetailScreenUi extends StatelessWidget {
  static const String routeName = '/service-detail-ui';

  /// Localization key for the service's own title (e.g. 'service_deep_cleaning').
  final String titleKey;

  /// Localization key for the short description under the title.
  final String descriptionKey;

  /// Hero image shown at the top of the screen.
  final String heroImageUrl;

  /// Localization keys for the "What's Included" checklist rows.
  final List<String> includedKeys;

  /// Localization key for the small tag above the title and for the
  /// transparent app bar title — typically the parent category the user
  /// came from (e.g. 'other_services').
  final String appBarTitleKey;

  final List<ReviewUi> reviews;
  final double rating;

  /// Called with this screen's own [BuildContext] when "Book Now" is
  /// tapped — each service wires this to its own booking flow.
  final void Function(BuildContext context) onBookNow;

  const ServiceDetailScreenUi({
    super.key,
    required this.titleKey,
    required this.descriptionKey,
    required this.heroImageUrl,
    required this.includedKeys,
    required this.onBookNow,
    this.appBarTitleKey = 'other_services',
    this.reviews = defaultReviews,
    this.rating = 4.2,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      body: Column(
        children: [
          // Hero image with the transparent app bar overlaid on top.
          // Bounded height (SizedBox), so it always lays out correctly
          // regardless of screen size or how this screen is embedded.
          SizedBox(
            height: 320,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    heroImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: ZienaColors.bg3,
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: ZienaColors.white),
                          onPressed: () => Navigator.maybePop(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          appBarTitleKey.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ZienaColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content sheet — takes remaining height via Expanded, which
          // Flutter always resolves correctly inside a Column.
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                decoration: const BoxDecoration(
                  color: ZienaColors.bg1,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ZienaColors.greyBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  appBarTitleKey.tr(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: ZienaColors.primary,
                                  ),
                                ),
                                _RatingStars(rating: rating),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              titleKey.tr(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: ZienaColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              descriptionKey.tr(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: ZienaColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'whats_included'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: ZienaColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...includedKeys.map(
                                  (key) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: ZienaColors.primary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        key.tr(),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: ZienaColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'reviews'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: ZienaColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...reviews.map((review) => _ReviewTile(review: review)),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    // Pinned CTA
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => onBookNow(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ZienaColors.primary,
                            foregroundColor: ZienaColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'book_now'.tr(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  final double rating;

  const _RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    final int fullStars = rating.floor();
    final bool hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      children: [
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ZienaColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        ...List.generate(5, (index) {
          IconData icon;
          if (index < fullStars) {
            icon = Icons.star;
          } else if (index == fullStars && hasHalfStar) {
            icon = Icons.star_half;
          } else {
            icon = Icons.star_border;
          }
          return Icon(icon, size: 15, color: Colors.amber);
        }),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ReviewUi review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ZienaColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.more_horiz, size: 18, color: ZienaColors.grey),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              ...List.generate(
                5,
                    (index) => Icon(
                  index < review.rating ? Icons.star : Icons.star_border,
                  size: 14,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                review.timeAgoKey.tr(),
                style: const TextStyle(
                  fontSize: 11,
                  color: ZienaColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            review.commentKey.tr(),
            style: const TextStyle(
              fontSize: 13,
              color: ZienaColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}