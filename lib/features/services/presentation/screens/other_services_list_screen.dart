import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zeina/features/services/presentation/screens/other_services_detail_screen.dart';
import 'package:zeina/features/services/presentation/widgets/other_services/booking_bottom_sheet.dart';
import 'package:zeina/features/services/presentation/widgets/other_services/deep_cleaning_booking_sheet.dart';
import '../../../../core/theme/theme.dart';


/// UI-only version of the "Other Services" list screen.
/// No Bloc/Cubit, no API calls — just the static visual layout
/// matching the provided design. Replace _staticServices with
/// data from your ServicesCubit when wiring this up.

class _ServiceItemUi {
  final String nameKey;
  final String imageUrl;

  const _ServiceItemUi({required this.nameKey, required this.imageUrl});
}

const List<_ServiceItemUi> _staticServices = [
  _ServiceItemUi(
    nameKey: 'service_pedicure_manicure',
    imageUrl:
    'https://images.unsplash.com/photo-1632345031435-8727f6897d53',
  ),
  _ServiceItemUi(
    nameKey: 'service_deep_cleaning',
    imageUrl:
    'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=200',
  ),
];

class OtherServicesListScreenUi extends StatelessWidget {
  static const String routeName = '/other-services-ui';

  const OtherServicesListScreenUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      appBar: AppBar(
        backgroundColor: ZienaColors.bg1,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'other_services'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ZienaColors.textPrimary,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: _staticServices.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final service = _staticServices[index];
          // First tile shown "highlighted" like the reference screenshot.
          final bool highlighted = index == 0;
          return _OtherServiceTile(
            name: service.nameKey.tr(),
            imageUrl: service.imageUrl,
            highlighted: highlighted,
            onTap: () {
              if (service.nameKey == 'service_pedicure_manicure') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OtherServicesDetailScreen(
                      titleKey: 'service_pedicure_manicure',
                      descriptionKey: 'service_pedicure_manicure_description',
                      heroImageUrl:
                      'https://images.unsplash.com/photo-1632345031435-8727f6897d53',
                      includedKeys: const [
                        'pedicure_included_1',
                        'pedicure_included_2',
                        'pedicure_included_3',
                        'pedicure_included_4',
                      ],
                      onBookNow: (ctx) => showBookingSheet(ctx),
                    ),
                  ),
                );
              } else if (service.nameKey == 'service_deep_cleaning') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OtherServicesDetailScreen(
                      titleKey: 'service_deep_cleaning',
                      descriptionKey: 'service_deep_cleaning_description',
                      heroImageUrl:
                      'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800',
                      includedKeys: const [
                        'deep_cleaning_included_1',
                        'deep_cleaning_included_2',
                        'deep_cleaning_included_3',
                        'deep_cleaning_included_4',
                      ],
                      onBookNow: (ctx) => showDeepCleaningBookingSheet(ctx),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class _OtherServiceTile extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool highlighted;
  final VoidCallback onTap;

  const _OtherServiceTile({
    required this.name,
    required this.imageUrl,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ZienaColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ZienaColors.primary.withOpacity(0.35)),
          ),
          child: Row(
            children: [
              ClipOval(
                child: Image.network(
                  imageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ZienaColors.textPrimary,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: ZienaColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}