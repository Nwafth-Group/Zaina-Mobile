import 'package:flutter/material.dart';

class ServiceZoneCoordinateModel {
  final double lat;
  final double lng;

  const ServiceZoneCoordinateModel({
    required this.lat,
    required this.lng,
  });

  factory ServiceZoneCoordinateModel.fromJson(Map<String, dynamic> json) {
    return ServiceZoneCoordinateModel(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}

class ServiceZoneModel {
  final int id;
  final String name;
  final String governorate;
  final String city;
  final List<ServiceZoneCoordinateModel> polygonCoordinates;
  final String status;
  final String createdAt;

  const ServiceZoneModel({
    required this.id,
    required this.name,
    required this.governorate,
    required this.city,
    required this.polygonCoordinates,
    required this.status,
    required this.createdAt,
  });

  factory ServiceZoneModel.fromJson(Map<String, dynamic> json) {
    return ServiceZoneModel(
      id: json['id'],
      name: json['name'] ?? '',
      governorate: json['governorate'] ?? '',
      city: json['city'] ?? '',
      polygonCoordinates:
      (json['polygon_coordinates'] as List<dynamic>? ?? [])
          .map((e) => ServiceZoneCoordinateModel.fromJson(e))
          .toList(),
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class AddressModel {
  final int id;

  // Nullable: an address may not have a matched service zone yet
  // (e.g. brand-new addresses, or ones outside all zones).
  final int? serviceZoneId;
  final ServiceZoneModel? serviceZone;
  final String? serviceZoneName;

  final double? latitude;
  final double? longitude;

  final String formattedAddress;

  // Nullable: the API sends these as null when it hasn't derived them
  // (e.g. no matched service zone yet).
  final String? city;
  final String? governorate;
  final String? country;

  final String label;
  final String street;
  final String? buildingName;
  final String? buildingNo;
  final String? floor;
  final String? floorNo;
  final String? apartmentNo;

  final String contactName;
  final String phoneNumber;
  final String? secondaryPhone;
  final String? notes;

  final bool isDefault;
  final bool isServiceable;

  final String createdAt;
  final String updatedAt;

  const AddressModel({
    required this.id,
    this.serviceZoneId,
    this.serviceZone,
    this.serviceZoneName,
    this.latitude,
    this.longitude,
    required this.formattedAddress,
    this.city,
    this.governorate,
    this.country,
    required this.label,
    required this.street,
    this.buildingName,
    this.buildingNo,
    this.floor,
    this.floorNo,
    this.apartmentNo,
    required this.contactName,
    required this.phoneNumber,
    this.secondaryPhone,
    this.notes,
    required this.isDefault,
    required this.isServiceable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      serviceZoneId: json['service_zone_id'] as int?,
      serviceZone: json['service_zone'] != null
          ? ServiceZoneModel.fromJson(json['service_zone'])
          : null,
      serviceZoneName: json['service_zone_name'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      formattedAddress: json['formatted_address'] ?? '',
      city: json['city'] as String?,
      governorate: json['governorate'] as String?,
      country: json['country'] as String?,
      label: json['label'] ?? '',
      street: json['street'] ?? '',
      buildingName: json['building_name'],
      buildingNo: json['building_no'],
      floor: json['floor'],
      floorNo: json['floor_no'],
      apartmentNo: json['apartment_no'],
      contactName: json['contact_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      secondaryPhone: json['secondary_phone'],
      notes: json['notes'],
      isDefault: json['is_default'] == true || json['is_default'] == 1,
      isServiceable:
      json['is_serviceable'] == true || json['is_serviceable'] == 1,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  /// Example: "القاهرة، مدينة نصر". Falls back to the formatted address
  /// when no governorate/city has been derived yet (no service zone match).
  String get shortAddress {
    final gov = governorate ?? '';
    final c = city ?? '';
    if (gov.isNotEmpty && c.isNotEmpty) {
      return '$gov، $c';
    }
    if (c.isNotEmpty) return c;
    if (gov.isNotEmpty) return gov;
    return formattedAddress;
  }

  /// Example: "Abbas El Akkad Street / Building 24 / Ap 12"
  String get oneLiner {
    final parts = <String>[];

    if (street.isNotEmpty) {
      parts.add(street);
    }

    if (buildingNo?.isNotEmpty == true) {
      parts.add('Building $buildingNo');
    }

    if (apartmentNo?.isNotEmpty == true) {
      parts.add('Ap $apartmentNo');
    }

    return parts.join(' / ');
  }

  IconData get icon {
    switch (label.toLowerCase()) {
      case 'work':
      case 'office':
        return Icons.work_outline_rounded;
      default:
        return Icons.home_outlined;
    }
  }
}

class AddressResponseModel {
  final List<AddressModel> items;

  const AddressResponseModel({
    required this.items,
  });

  factory AddressResponseModel.fromJson(Map<String, dynamic> json) {
    return AddressResponseModel(
      items: (json['data']?['items'] as List<dynamic>? ?? [])
          .map((e) => AddressModel.fromJson(e))
          .toList(),
    );
  }
}