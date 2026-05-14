import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/custom_text_form_field.dart';
import '../../../../widgets/ziena_button.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final _searchCtrl = TextEditingController();
  // Mock selected location — replace with actual map pin
  final double _lat = 30.0444;
  final double _lng = 31.2357;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onContinue() {
    Navigator.pop(context, {
      'latitude': _lat,
      'longitude': _lng,
      'area_id': null, // resolve from reverse geocode in production
      'display': '${_lat.toStringAsFixed(4)}, ${_lng.toStringAsFixed(4)}',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.white,
      appBar: AppBar(
        backgroundColor: ZienaColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('add_address'.tr(),
            style: const TextStyle(
               fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            )),
      ),
      body: Stack(
        children: [
          // ── Map placeholder ─────────────────────────────────────────────
          Container(
            color: const Color(0xFFE8EDF0),
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.map_rounded, size: 80,
                    color: Colors.grey.withOpacity(0.35)),
                const SizedBox(height: 10),
                Text('install_google_maps'.tr(),
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.withOpacity(0.5))),
              ]),
            ),
          ),

          // Pin
          const Center(child: Icon(Icons.location_on_rounded,
              color: ZienaColors.primary, size: 48)),

          // ── Search overlay ──────────────────────────────────────────────
          Positioned(
            top: 12, left: 16, right: 16,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: ZienaColors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08),
                      blurRadius: 10, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(children: [
                const SizedBox(width: 14),
                const Icon(Icons.search, color: ZienaColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(child: CustomTextField(
                  controller: _searchCtrl,
                  hintText: 'search_location'.tr(),
                  border: 0,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                )),
              ]),
            ),
          ),

          // ── My-location FAB ─────────────────────────────────────────────
          Positioned(
            bottom: 90, right: 16,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: ZienaColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8)],
                ),
                child: const Icon(Icons.my_location_rounded,
                    color: ZienaColors.primary, size: 22),
              ),
            ),
          ),

          // ── Continue ────────────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
              color: ZienaColors.white,
              child: ZienaButton(
                text: 'continue'.tr(),
                onTap: _onContinue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}