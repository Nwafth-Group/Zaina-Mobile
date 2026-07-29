import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/core/theme/theme.dart';
import 'package:zeina/features/services/data/model/service_model.dart';
import 'package:zeina/features/services/data/model/visit_type_model.dart';
import 'package:zeina/features/services/presentation/cubit/services_cubit.dart';
import 'package:zeina/injection_container.dart';


/// Call this to show the "choose visit type" sheet for a given service.
/// [onVisitTypeSelected] fires with the chosen [VisitTypeModel] — hook your
/// navigation to the next booking step (date/time/worker selection) there.
Future<void> showVisitTypeSheet({
  required BuildContext context,
  required ServiceModel service,
  required void Function(VisitTypeModel type) onVisitTypeSelected,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider(
      create: (_) => sl<VisitTypesCubit>()..fetchVisitTypes(service.id),
      child: VisitTypeBottomSheet(
        service: service,
        onVisitTypeSelected: onVisitTypeSelected,
      ),
    ),
  );
}

class VisitTypeBottomSheet extends StatefulWidget {
  final ServiceModel service;
  final void Function(VisitTypeModel type) onVisitTypeSelected;

  const VisitTypeBottomSheet({
    super.key,
    required this.service,
    required this.onVisitTypeSelected,
  });

  @override
  State<VisitTypeBottomSheet> createState() => _VisitTypeBottomSheetState();
}

class _VisitTypeBottomSheetState extends State<VisitTypeBottomSheet> {
  // Tracks which row is currently highlighted/selected by the user's tap.
  VisitTypeEnum? _selectedType;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: const BoxDecoration(
          color: ZienaColors.bg1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ZienaColors.greyBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<VisitTypesCubit, VisitTypesState>(
              builder: (context, state) {
                if (state is VisitTypesLoading || state is VisitTypesInitial) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(color: ZienaColors.primary),
                  );
                }
                if (state is VisitTypesError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      state.message,
                      style: const TextStyle(color: ZienaColors.error),
                    ),
                  );
                }
                final types = (state as VisitTypesLoaded).types;
                return Column(
                  children: [
                    for (int i = 0; i < types.length; i++) ...[
                      _VisitTypeRow(
                        visitType: types[i],
                        // Highlight only whichever row the user actually tapped.
                        highlighted: _selectedType == types[i].type,
                        onTap: () {
                          setState(() => _selectedType = types[i].type);
                          Navigator.pop(context);
                          widget.onVisitTypeSelected(types[i]);
                        },
                      ),
                      if (i != types.length - 1) const SizedBox(height: 10),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _VisitTypeRow extends StatelessWidget {
  final VisitTypeModel visitType;
  final bool highlighted;
  final VoidCallback onTap;

  const _VisitTypeRow({
    required this.visitType,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = highlighted ? ZienaColors.primary : Colors.transparent;
    final fgColor = highlighted ? ZienaColors.white : ZienaColors.primary;
    final textColor = highlighted ? ZienaColors.white : ZienaColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: highlighted
                ? null
                : Border.all(color: ZienaColors.primary.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              ColorFiltered(
                colorFilter: ColorFilter.mode(fgColor, BlendMode.srcIn),
                child: Image.asset(
                  visitType.type.iconAsset,
                  width: 20,
                  height: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  visitType.type.labelKey.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              if (visitType.hasDiscount)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    '-${visitType.discount}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: fgColor,
                    ),
                  ),
                ),
              Icon(Icons.chevron_right, color: fgColor),
            ],
          ),
        ),
      ),
    );
  }
}