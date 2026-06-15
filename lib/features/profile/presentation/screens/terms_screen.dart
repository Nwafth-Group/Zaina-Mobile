import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../cubit/legal_cubit.dart';
import '../widgets/legal_accordion.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LegalCubit(sl(), endpoint: 'customer/legal/terms-conditions')..fetch(),
      child: Scaffold(
        backgroundColor: ZienaColors.bg1,
        appBar: AppBar(
          backgroundColor: ZienaColors.bg1,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: ZienaColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'terms_and_conditions'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            ),
          ),
          centerTitle: false,
        ),
        body: BlocBuilder<LegalCubit, LegalState>(
          builder: (context, state) {
            if (state is LegalLoading) {
              return const Center(
                child: CircularProgressIndicator(color: ZienaColors.primary),
              );
            }
            if (state is LegalError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message,
                        style: const TextStyle(color: ZienaColors.textSecondary)),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.read<LegalCubit>().fetch(),
                      child: Text('retry'.tr(),
                          style: const TextStyle(color: ZienaColors.primary)),
                    ),
                  ],
                ),
              );
            }
            if (state is LegalLoaded) {
              return LegalAccordion(
                sections: state.sections,
                onToggle: (i) => context.read<LegalCubit>().toggle(i),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
