import 'package:flutter/material.dart';

class AddressCityModel {
  final int id;
  final String nameAr;
  final String nameEn;

  const AddressCityModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  factory AddressCityModel.fromJson(Map<String, dynamic> json) {
    return AddressCityModel(
      id: json['id'],
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
    );
  }

  String localized(String lang) => lang == 'ar' ? nameAr : nameEn;
}

class AddressAreaModel {
  final int id;
  final String nameAr;
  final String nameEn;
  final AddressCityModel? city;

  const AddressAreaModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.city,
  });

  factory AddressAreaModel.fromJson(Map<String, dynamic> json) {
    return AddressAreaModel(
      id: json['id'],
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      city: json['city'] != null
          ? AddressCityModel.fromJson(json['city'])
          : null,
    );
  }

  String localized(String lang) => lang == 'ar' ? nameAr : nameEn;
}

class AddressModel {
  final int id;
  final AddressAreaModel? area;
  final String label;
  final String street;
  final String? buildingName;
  final String? buildingNo;
  final String? floor;
  final String? apartmentNo;
  final String contactName;
  final String phoneNumber;
  final String? secondaryPhone;
  final String? notes;
  final bool isDefault;
  final String? latitude;
  final String? longitude;

  const AddressModel({
    required this.id,
    this.area,
    required this.label,
    required this.street,
    this.buildingName,
    this.buildingNo,
    this.floor,
    this.apartmentNo,
    required this.contactName,
    required this.phoneNumber,
    this.secondaryPhone,
    this.notes,
    required this.isDefault,
    this.latitude,
    this.longitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      area: json['area'] != null
          ? AddressAreaModel.fromJson(json['area'])
          : null,
      label: json['label'] ?? 'Home',
      street: json['street'] ?? '',
      buildingName: json['building_name'],
      buildingNo: json['building_no'],
      floor: json['floor'],
      apartmentNo: json['apartment_no'],
      contactName: json['contact_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      secondaryPhone: json['secondary_phone'],
      notes: json['notes'],
      isDefault: json['is_default'] == true || json['is_default'] == 1,
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }

  /// "Riyadh, As Sulimaniyah"
  String shortAddress(String lang) {
    final city = area?.city?.localized(lang) ?? '';
    final areaName = area?.localized(lang) ?? '';
    if (city.isNotEmpty && areaName.isNotEmpty) return '$city, $areaName';
    return city.isNotEmpty ? city : areaName;
  }

  /// "Abbas El Akkad Street / Building 24 / Ap 12"
  String get oneLiner {
    final parts = <String>[];
    if (street.isNotEmpty) parts.add(street);
    if (buildingNo != null && buildingNo!.isNotEmpty) {
      parts.add('Building $buildingNo');
    }
    if (apartmentNo != null && apartmentNo!.isNotEmpty) {
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