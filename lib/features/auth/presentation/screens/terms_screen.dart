import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/constants.dart';
import '../../../../widgets/ziena_button.dart';

class TermsScreen extends StatelessWidget {
  static const String routeName = '/terms';
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('terms_title'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(3, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'clause'.tr() + ' ${i + 1}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: ZienaColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Viverra condimentum eget purpis in. Consectetur adipiscing elit morbi amet amet. In. Ipsum ornare tellus neque. Ullamcorper suspendisse semean leo phaseitta in sit semper sit. Amet quam placer sunt.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.7,
                          ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: ZienaColors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: ZienaButton(
          text: 'done'.tr(),
          onTap: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
