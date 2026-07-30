import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zeina/features/services/presentation/screens/hourly_services_list_screen.dart';
import '../../../../core/theme/theme.dart';

class ZienaServicesScreen extends StatelessWidget {
  static const String routeName = '/ziena-services';

  const ZienaServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      appBar: AppBar(
        backgroundColor: ZienaColors.bg1,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ziena_services'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ZienaColors.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            _ServiceCategoryRow(
              icon: Icons.access_time_rounded,
              label: 'Hourly Services'.tr(),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HourlyServicesListScreen(
                    type: 'hourly',
                    titleKey: 'Hourly Services',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ServiceCategoryRow(
              icon: Icons.bubble_chart_outlined,
              label: 'Other Services'.tr(),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HourlyServicesListScreen(
                    type: 'other',
                    titleKey: 'other_services',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single navigation row. Deliberately has no persistent "selected" state
/// — every row renders identically (white bg, pink border/icon/text); only
/// the tap ripple gives momentary feedback. Nothing defaults to the filled
/// pink "highlighted" look.
class _ServiceCategoryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ServiceCategoryRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: ZienaColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ZienaColors.primary.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Icon(icon, color: ZienaColors.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ZienaColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: ZienaColors.primary, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}