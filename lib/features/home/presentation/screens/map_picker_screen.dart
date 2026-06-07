import 'dart:async';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/ziena_button.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final _mapController = MapController();
  final _searchCtrl    = TextEditingController();

  LatLng _center = const LatLng(24.7136, 46.6753);
  bool   _locating  = false;
  bool   _searching = false;
  String _displayAddress = '';

  List<_SearchResult> _searchResults = [];
  Timer? _debounce;

  @override
  void dispose() {
    _mapController.dispose();
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever ||
          perm == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('location_permission_denied'.tr())),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final ll = LatLng(pos.latitude, pos.longitude);
      _mapController.move(ll, 15);
      setState(() => _center = ll);
      await _reverseGeocode(ll);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _reverseGeocode(LatLng ll) async {
    try {
      final dio = Dio();
      final res = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': ll.latitude,
          'lon': ll.longitude,
          'format': 'json',
        },
        options: Options(headers: {'User-Agent': 'ZeinaApp/1.0'}),
      );
      final display = res.data['display_name'] as String? ?? '';
      if (mounted) setState(() => _displayAddress = display);
    } catch (_) {}
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 3) {
      setState(() => _searchResults = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      setState(() => _searching = true);
      try {
        final dio = Dio();
        final res = await dio.get(
          'https://nominatim.openstreetmap.org/search',
          queryParameters: {
            'q': query.trim(),
            'format': 'json',
            'limit': 5,
          },
          options: Options(headers: {'User-Agent': 'ZeinaApp/1.0'}),
        );
        final list = (res.data as List<dynamic>).map((e) => _SearchResult(
          display: e['display_name'] as String,
          lat: double.parse(e['lat'] as String),
          lon: double.parse(e['lon'] as String),
        )).toList();
        if (mounted) setState(() => _searchResults = list);
      } catch (_) {
        if (mounted) setState(() => _searchResults = []);
      } finally {
        if (mounted) setState(() => _searching = false);
      }
    });
  }

  void _selectSearchResult(_SearchResult r) {
    final ll = LatLng(r.lat, r.lon);
    _mapController.move(ll, 15);
    setState(() {
      _center          = ll;
      _displayAddress  = r.display;
      _searchCtrl.text = r.display;
      _searchResults   = [];
    });
    FocusScope.of(context).unfocus();
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    if (hasGesture) {
      setState(() => _center = camera.center);
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 800), () {
        _reverseGeocode(_center);
      });
    }
  }

  void _onContinue() {
    Navigator.pop(context, {
      'latitude':  _center.latitude,
      'longitude': _center.longitude,
      'area_id':   null,
      'display':   _displayAddress.isNotEmpty
          ? _displayAddress
          : '${_center.latitude.toStringAsFixed(5)}, '
            '${_center.longitude.toStringAsFixed(5)}',
    });
  }

  @override
  Widget build(BuildContext context) {
    // bottom panel height: address row (optional) + button + safe area
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final panelHeight   = (_displayAddress.isNotEmpty ? 52.0 : 0.0) + 66 + bottomPadding + 28;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'add_address'.tr(),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ZienaColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // ── OSM Map ────────────────────────────────────────────────────
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 15,
                onPositionChanged: _onMapPositionChanged,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.zeina.app',
                ),
              ],
            ),
          ),

          // ── Center avatar pin ──────────────────────────────────────────
          Center(
            child: Transform.translate(
              // shift up so the tip of the pin is at the exact center
              offset: Offset(0, -(36 / 2 + 6)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // circular frame
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black87, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.black87,
                    ),
                  ),
                  // stem
                  Container(
                    width: 2.5,
                    height: 12,
                    color: Colors.black87,
                  ),
                  // green dot at tip
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Search bar + dropdown results ──────────────────────────────
          Positioned(
            top: 12, left: 16, right: 16,
            child: Column(
              children: [
                // search bar
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(children: [
                    const SizedBox(width: 16),
                    Icon(Icons.search,
                        color: ZienaColors.primary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: ZienaColors.primary.withValues(alpha: 0.55),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: ZienaColors.textPrimary,
                        ),
                      ),
                    ),
                    if (_searching)
                      Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ZienaColors.primary,
                          ),
                        ),
                      ),
                  ]),
                ),

                // search results dropdown
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _searchResults.length,
                        separatorBuilder: (context, i) =>
                            const Divider(height: 1, indent: 16, endIndent: 16),
                        itemBuilder: (context, i) {
                          final r = _searchResults[i];
                          return ListTile(
                            dense: true,
                            leading: Icon(Icons.place_outlined,
                                color: ZienaColors.primary, size: 18),
                            title: Text(
                              r.display,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: ZienaColors.textPrimary,
                              ),
                            ),
                            onTap: () => _selectSearchResult(r),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Crosshair / my-location FAB ────────────────────────────────
          Positioned(
            bottom: panelHeight + 12,
            right: 16,
            child: GestureDetector(
              onTap: _goToMyLocation,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _locating
                    ? const Padding(
                        padding: EdgeInsets.all(13),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ZienaColors.primary,
                        ),
                      )
                    : const Icon(
                        Icons.gps_fixed_rounded,
                        color: ZienaColors.textPrimary,
                        size: 22,
                      ),
              ),
            ),
          ),

          // ── Bottom panel: address + Continue button ────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  20, 16, 20, bottomPadding > 0 ? bottomPadding : 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_displayAddress.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 15, color: ZienaColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _displayAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: ZienaColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ZienaButton(
                      text: 'continue'.tr(),
                      onTap: _onContinue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResult {
  final String display;
  final double lat;
  final double lon;
  const _SearchResult({
    required this.display,
    required this.lat,
    required this.lon,
  });
}
