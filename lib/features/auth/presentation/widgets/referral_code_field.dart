

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme.dart';

/// "If you have a code, paste it here!" — an optional referral code
/// input, matching the screenshot. Caller owns the [controller] so it
/// can read `.text` directly when calling
/// `ProfileCubit.updateProfile(..., referralCode: controller.text)`.
class ReferralCodeField extends StatelessWidget {
  final TextEditingController controller;

  const ReferralCodeField({super.key, required this.controller});

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text != null && text.isNotEmpty) {
      controller.text = text.trim();
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'have_code_paste_here'.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ZienaColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: ZienaColors.bg1,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ZienaColors.primary.withOpacity(0.35)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: ZienaColors.bg3,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ZienaColors.textPrimary,
                    ),
                    cursorColor: ZienaColors.primary,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _pasteFromClipboard,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.content_paste_rounded,
                        color: ZienaColors.primary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}