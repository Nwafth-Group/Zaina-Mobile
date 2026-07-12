import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../data/model/coverage_model.dart';
import '../../data/model/service_model.dart';
import '../../data/model/visit_type_model.dart';
import '../cubit/services_cubit.dart';
import '../widgets/coverage_error_dialog.dart';
import '../widgets/service_tile.dart';
import '../widgets/visit_type_bottom_sheet.dart';
import 'service_detail_screen.dart';
// Adjust this import to wherever AddressCubit + AddEditAddressScreen live in your project:
import '../../../home/presentation/cubit/address_cubit.dart';
import '../../../home/presentation/screens/add_edit_address_screen.dart';

class ServicesListScreen extends StatelessWidget {
  static const String routeName = '/services-list';

  /// API `type` query param — e.g. 'hourly' or 'other'.
  final String type;

  /// Localization key for the AppBar title — e.g. 'Hourly Services' / 'Other Services'.
  final String titleKey;

  const ServicesListScreen({
    super.key,
    required this.type,
    required this.titleKey,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ServicesCubit>()..fetchServices(type),
      child: _ServicesListView(titleKey: titleKey),
    );
  }
}

class _ServicesListView extends StatefulWidget {
  final String titleKey;
  const _ServicesListView({required this.titleKey});

  @override
  State<_ServicesListView> createState() => _ServicesListViewState();
}

class _ServicesListViewState extends State<_ServicesListView> {
  // Tracks which service is currently going through the coverage check —
  // used to highlight the tapped tile and show its inline spinner.
  int? _checkingServiceId;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;

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
          widget.titleKey.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ZienaColors.textPrimary,
          ),
        ),
      ),
      body: BlocBuilder<ServicesCubit, ServicesState>(
        builder: (context, state) {
          if (state is ServicesLoading || state is ServicesInitial) {
            return const Center(
              child: CircularProgressIndicator(color: ZienaColors.primary),
            );
          }
          if (state is ServicesError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: ZienaColors.error),
                ),
              ),
            );
          }

          final services = (state as ServicesLoaded).services;
          if (services.isEmpty) {
            return Center(
              child: Text(
                'no_services_found'.tr(),
                style: const TextStyle(color: ZienaColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              final isChecking = _checkingServiceId == service.id;
              return ServiceTile(
                name: service.localizedName(locale),
                imageUrl: service.image,
                // Highlighted while it's the one being tapped/checked.
                highlighted: isChecking,
                loading: isChecking,
                onTap: () => _onServiceTap(context, service),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _onServiceTap(BuildContext context, ServiceModel service) async {
    if (_checkingServiceId != null) return; // avoid double taps

    setState(() => _checkingServiceId = service.id);
    CoverageModel? coverage;
    String? errorMessage;

    try {
      coverage = await context.read<ServicesCubit>().checkCoverage(service.id);
    } catch (_) {
      errorMessage = 'err_generic'.tr();
    }

    if (!mounted) return;
    setState(() => _checkingServiceId = null);

    if (errorMessage != null) {
      showCoverageErrorDialog(context, message: errorMessage);
      return;
    }

    if (coverage!.hasAddress == false) {
      showCoverageErrorDialog(
        context,
        message: 'coverage_add_address_message'.tr(),
        actionLabel: 'add_address'.tr(),
        onAction: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AddressCubit>(),
                child: const AddEditAddressScreen(),
              ),
            ),
          );
        },
      );
      return;
    }

    if (coverage.isCovered == false) {
      showCoverageErrorDialog(
        context,
        message: 'coverage_not_covered_message'.tr(),
      );
      return;
    }

    // Both checks passed → proceed to visit-type selection.
    if (!context.mounted) return;
    showVisitTypeSheet(
      context: context,
      service: service,
      onVisitTypeSelected: (VisitTypeModel visitType) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailScreen(
              serviceId: service.id,
              visitType: visitType,
            ),
          ),
        );
      },
    );
  }
}