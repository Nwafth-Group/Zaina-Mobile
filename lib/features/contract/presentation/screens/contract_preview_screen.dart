import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../../core/theme/theme.dart';

/// Displays the PDF bytes fetched from `customer/bookings/contract-preview`
/// with the built-in print/share controls that [PdfPreview] already
/// provides (no extra download UI needed). The endpoint returns an actual
/// PDF file directly, so no HTML→PDF conversion step is needed here.
class ContractPreviewScreen extends StatelessWidget {
  final Uint8List pdfBytes;
  const ContractPreviewScreen({super.key, required this.pdfBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      appBar: AppBar(
        backgroundColor: ZienaColors.bg1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('contract'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            )),
      ),
      body: PdfPreview(
        build: (format) async => pdfBytes,
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: ZienaColors.primary),
        ),
      ),
    );
  }
}