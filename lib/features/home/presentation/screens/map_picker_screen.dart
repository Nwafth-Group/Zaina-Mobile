import 'dart:async';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zeina/core/utils/constants.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/ziena_button.dart';

class MapPickerScreen extends StatefulWidget {
  /// If provided (e.g. when editing an existing address), the map opens
  /// centered on this location instead of the user's current GPS position.
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;

  const MapPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  final _searchCtrl = TextEditingController();
  final _dio = Dio();

  // Fallback only — used if there's no saved address AND locating the
  // device fails (e.g. permission denied).
  static const LatLng _fallbackCenter = LatLng(24.7136, 46.6753);

  late LatLng _center;
  bool get _hasInitialLocation =>
      widget.initialLatitude != null && widget.initialLongitude != null;

  bool _locating = false;
  bool _searching = false;
  bool _isMoving = false;
  String _displayAddress = '';

  List<_SearchResult> _searchResults = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (_hasInitialLocation) {
      _center = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      _displayAddress = widget.initialAddress ?? '';
      if (_displayAddress.isNotEmpty) {
        _searchCtrl.text = _displayAddress;
      }
    } else {
      _center = _fallbackCenter;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
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
      await _mapController?.animateCamera(CameraUpdate.newLatLngZoom(ll, 15));
      setState(() => _center = ll);
      await _reverseGeocode(ll);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _reverseGeocode(LatLng ll) async {
    final url = 'https://maps.googleapis.com/maps/api/geocode/json';
    final params = {
      'latlng': '${ll.latitude},${ll.longitude}',
      'key': AppConstants.googleMapsApiKey,
    };
    debugPrint('=== Reverse geocode request ===');
    debugPrint('GET $url?latlng=${params['latlng']}&key=***');
    try {
      final res = await _dio.get(url, queryParameters: params);
      debugPrint('Reverse geocode HTTP status: ${res.statusCode}');
      debugPrint('Reverse geocode API status field: ${res.data['status']}');
      if (res.data['error_message'] != null) {
        debugPrint('Reverse geocode error_message: ${res.data['error_message']}');
      }
      final results = res.data['results'] as List<dynamic>? ?? [];
      debugPrint('Reverse geocode result count: ${results.length}');
      if (results.isNotEmpty) {
        final display = results.first['formatted_address'] as String? ?? '';
        debugPrint('Reverse geocode resolved address: $display');
        if (mounted) setState(() => _displayAddress = display);
      } else {
        debugPrint('Reverse geocode returned no results — _displayAddress stays empty.');
      }
    } catch (e) {
      debugPrint('Reverse geocode FAILED with exception: $e');
    }
    debugPrint('================================');
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
        final res = await _dio.get(
          'https://maps.googleapis.com/maps/api/geocode/json',
          queryParameters: {
            'address': query.trim(),
            'key': AppConstants.googleMapsApiKey,
          },
        );
        debugPrint('=== Search geocode: "$query" ===');
        debugPrint('API status field: ${res.data['status']}');
        if (res.data['error_message'] != null) {
          debugPrint('error_message: ${res.data['error_message']}');
        }
        final results = res.data['results'] as List<dynamic>? ?? [];
        debugPrint('Result count: ${results.length}');
        final list = results.map((e) {
          final loc = e['geometry']['location'];
          return _SearchResult(
            display: e['formatted_address'] as String,
            lat: (loc['lat'] as num).toDouble(),
            lon: (loc['lng'] as num).toDouble(),
          );
        }).toList();
        if (mounted) setState(() => _searchResults = list);
      } catch (e) {
        debugPrint('Search geocode FAILED with exception: $e');
        if (mounted) setState(() => _searchResults = []);
      } finally {
        if (mounted) setState(() => _searching = false);
      }
    });
  }

  Future<void> _selectSearchResult(_SearchResult r) async {
    final ll = LatLng(r.lat, r.lon);
    await _mapController?.animateCamera(CameraUpdate.newLatLngZoom(ll, 15));
    setState(() {
      _center = ll;
      _displayAddress = r.display;
      _searchCtrl.text = r.display;
      _searchResults = [];
    });
    FocusScope.of(context).unfocus();
  }

  void _onCameraMove(CameraPosition position) {
    _isMoving = true;
    _center = position.target;
  }

  void _onCameraIdle() {
    if (!_isMoving) return;
    _isMoving = false;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _reverseGeocode(_center);
    });
  }

  void _onContinue() {
    debugPrint('=== Map picker returning ===');
    debugPrint('lat: ${_center.latitude}, lng: ${_center.longitude}');
    debugPrint('_displayAddress at time of Continue: "$_displayAddress"');
    debugPrint('=============================');
    Navigator.pop(context, {
      'latitude': _center.latitude,
      'longitude': _center.longitude,
      // Sent to the API as `formatted_address` (from Google reverse geocoding).
      'formatted_address': _displayAddress,
      'display': _displayAddress.isNotEmpty
          ? _displayAddress
          : '${_center.latitude.toStringAsFixed(5)}, '
          '${_center.longitude.toStringAsFixed(5)}',
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final panelHeight =
        (_displayAddress.isNotEmpty ? 52.0 : 0.0) + 66 + bottomPadding + 28;

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
          // ── Google Map ─────────────────────────────────────────────────
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 15,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                if (!_hasInitialLocation) {
                  // No saved address to show — default to the user's
                  // current location instead of a hardcoded fallback.
                  _goToMyLocation();
                }
              },
              onCameraMove: _onCameraMove,
              onCameraIdle: _onCameraIdle,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
            ),
          ),

          // ── Center avatar pin (fixed overlay, map moves under it) ───────
          Center(
            child: IgnorePointer(
              child: Transform.translate(
                offset: Offset(0, -(36 / 2 + 6)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                    Container(
                      width: 2.5,
                      height: 12,
                      color: Colors.black87,
                    ),
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
          ),

          // ── Search bar + dropdown results ────────────────────────────────
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Column(
              children: [
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
                    Icon(Icons.search, color: ZienaColors.primary, size: 22),
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
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ZienaColors.primary,
                          ),
                        ),
                      ),
                  ]),
                ),
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

          // ── Crosshair / my-location FAB ─────────────────────────────────
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

          // ── Bottom panel: address + Continue button ──────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
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