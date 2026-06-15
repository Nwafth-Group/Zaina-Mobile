import 'dart:ui';

import '../../../../core/utils/constants.dart';

class BookingAddress {
  final int id;
  final String label;
  final String areaName;
  final String cityName;
  final String street;
  final String building;
  final String floor;
  final String unit;
  final String? notes;

  const BookingAddress({
    required this.id,
    required this.label,
    required this.areaName,
    required this.cityName,
    required this.street,
    required this.building,
    required this.floor,
    required this.unit,
    this.notes,
  });

  factory BookingAddress.fromJson(Map<String, dynamic> json) {
    final area = json['area'] as Map<String, dynamic>? ?? {};
    final city = area['city'] as Map<String, dynamic>? ?? {};
    return BookingAddress(
      id: json['id'] ?? 0,
      label: json['label'] ?? 'Home',
      areaName: lng=='ar'?area['name_ar']:area['name_en'] ?? '',
      cityName: lng=='ar'?city['name_ar']:city['name_en'] ?? '',
      street: json['street'] ?? '',
      building: json['building'] ?? '',
      floor: json['floor'] ?? '',
      unit: json['unit'] ?? '',
      notes: json['notes'],
    );
  }

  String get fullAddress => '$areaName, $cityName\n$street, Building $building, Floor $floor';
}

class BookingWorkerModel {
  final int id;
  final String name;
  final String? nationality;
  final double? rating;
  final String? avatar;

  const BookingWorkerModel({
    required this.id,
    required this.name,
    this.nationality,
    this.rating,
    this.avatar,
  });

  factory BookingWorkerModel.fromJson(Map<String, dynamic> json) {
    return BookingWorkerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nationality: json['nationality'],
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      avatar: json['avatar'],
    );
  }
}

class BookingPriceSummary {
  final double subtotal;
  final double tax;
  final double discount;
  final double total;

  const BookingPriceSummary({
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
  });

  factory BookingPriceSummary.fromJson(Map<String, dynamic> json) {
    return BookingPriceSummary(
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }
}

class BookingModel {
  final int id;
  final int serviceId;
  final String bookingRef;
  final String status;
  final String serviceName;
  final String? image;
  final double price;
  final String currency;
  final String duration;
  final String dateDay;
  final String dateMonth;
  final String fullDate;
  final String timeSlot;
  final BookingAddress? address;
  final List<BookingWorkerModel>? worker;
  final BookingPriceSummary? priceSummary;
  final List<String> importantNotes;

  const BookingModel({
    required this.id,
    required this.serviceId,
    required this.bookingRef,
    required this.status,
    required this.serviceName,
    this.image,
    required this.price,
    required this.currency,
    required this.duration,
    required this.dateDay,
    required this.dateMonth,
    required this.fullDate,
    required this.timeSlot,
    this.address,
    this.worker,
    this.priceSummary,
    this.importantNotes = const [],
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    print("hhhhhh $json");
    return BookingModel(
      id: json['id'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      bookingRef: json['booking_ref'] ?? '',
      status: json['status'] ?? 'Upcoming',
      serviceName: json['service_name'] ?? '',
      image: json['image'].toString().startsWith('http://')?json['image']:json['image'].toString().replaceFirst('http:', 'http://'),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] ?? 'EGP',
      duration: json['duration'] ?? '',
      dateDay: json['date_day']?.toString() ?? '',
      dateMonth: json['date_month'] ?? '',
      fullDate: json['full_date'] ?? '',
      timeSlot: json['time_slot'] ?? '',
      address: json['address'] != null
          ? BookingAddress.fromJson(json['address'])
          : null,
      worker: json['workers'] != null
          ? List.of(json['workers']??[]).map((e)=> BookingWorkerModel.fromJson(e)).toList()
          : null,
      priceSummary: json['price_summary'] != null
          ? BookingPriceSummary.fromJson(json['price_summary'])
          : null,
      importantNotes: (json['important_notes'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  BookingStatusEnum get statusEnum {
    switch (status.toLowerCase()) {
      case 'upcoming': return BookingStatusEnum.upcoming;
      case 'in service':
      case 'in_service': return BookingStatusEnum.inService;
      case 'completed': return BookingStatusEnum.completed;
      case 'cancelled': return BookingStatusEnum.cancelled;
      default: return BookingStatusEnum.upcoming;
    }
  }
}

enum BookingStatusEnum { all, upcoming, inService, completed, cancelled }

extension BookingStatusExt on BookingStatusEnum {
  String get label {
    switch (this) {
      case BookingStatusEnum.all: return 'All';
      case BookingStatusEnum.upcoming: return 'Upcoming';
      case BookingStatusEnum.inService: return 'In Service';
      case BookingStatusEnum.completed: return 'Completed';
      case BookingStatusEnum.cancelled: return 'Cancelled';
    }
  }

  String get apiValue {
    switch (this) {
      case BookingStatusEnum.all: return '';
      case BookingStatusEnum.upcoming: return 'upcoming';
      case BookingStatusEnum.inService: return 'in_service';
      case BookingStatusEnum.completed: return 'completed';
      case BookingStatusEnum.cancelled: return 'cancelled';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatusEnum.upcoming: return const Color(0xFF2196F3);
      case BookingStatusEnum.inService: return const Color(0xFFFF9800);
      case BookingStatusEnum.completed: return const Color(0xFF4CAF50);
      case BookingStatusEnum.cancelled: return const Color(0xFFE53935);
      default: return const Color(0xFF9E9E9E);
    }
  }
}