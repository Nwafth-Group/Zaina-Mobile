import 'package:zeina/features/home/data/model/service_model.dart';

class BannerModel {
  final int id;
  final String? link;
  final String? image;

  BannerModel({required this.id, required this.link, this.image});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    print("jsonnnn $json");
    return BannerModel(
      id: json['id'],
      link: json['link'],
      // JSON shows "media" as list, adjust based on your actual media parsing logic
      image: json['image'],
    );
  }
}

class CategoryModel {
  final int id;
  final String nameAr;
  final String nameEn;
  final String? image;
  final bool? hasSubcategories;
  final String status;

  const CategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.image,
    this.hasSubcategories,
    required this.status,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    print("cccccc ");

    return CategoryModel(
      id: json['id'],
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      image: json['image'],
      hasSubcategories: json['has_subcategories'],
      status: json['status'] ?? 'active',
    );
  }

  String localizedName(String langCode) =>
      langCode == 'ar' ? nameAr : nameEn;
}

class PaginatedCategories {
  final List<CategoryModel> items;
  final int currentPage;
  final int lastPage;
  final int total;

  const PaginatedCategories({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  factory PaginatedCategories.fromJson(Map<String, dynamic> json) {
    print("yyyyy ");
    final data = json['data'] as Map<String, dynamic>;
    final meta = data['meta'] as Map<String, dynamic>? ?? {};
    return PaginatedCategories(
      items: (data['items'] as List<dynamic>? ?? [])
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
      currentPage: meta['current_page'] ?? 1,
      lastPage: meta['last_page'] ?? 1,
      total: meta['total'] ?? 0,
    );
  }
}

class UpcomingAppointment {
  final int id;
  final String bookingRef;
  final String serviceNameAr;
  final String serviceNameEn;
  final String? image;
  final String price;
  final String currency;
  final String status;
  final String durationText;
  final String dateDay;
  final String dateMonth;
  final String time;

  const UpcomingAppointment({
    required this.id,
    required this.bookingRef,
    required this.serviceNameAr,
    required this.serviceNameEn,
    this.image,
    required this.price,
    required this.currency,
    required this.status,
    required this.durationText,
    required this.dateDay,
    required this.dateMonth,
    required this.time,
  });

  factory UpcomingAppointment.fromJson(Map<String, dynamic> json) {
    return UpcomingAppointment(
      id: json['id'] ?? 0,
      bookingRef: json['booking_ref'] ?? '',
      serviceNameAr: json['service_name_ar'] ?? '',
      serviceNameEn: json['service_name_en'] ?? '',
      image: json['image'],
      price: json['price'] ?? '0',
      currency: json['currency'] ?? 'EGP',
      status: json['status'] ?? '',
      durationText: json['duration_text'] ?? '',
      dateDay: json['date_day'] ?? '',
      dateMonth: json['date_month'] ?? '',
      time: json['time'] ?? '',
    );
  }

  String localizedName(String langCode) =>
      langCode == 'ar' ? serviceNameAr : serviceNameEn;
}

class HomeData {
  final List<BannerModel> banners;
  final List<CategoryModel> categories;
  final List<ServiceModel> popularServices;
  final UpcomingAppointment? upcomingAppointment;

  HomeData({
    required this.banners,
    required this.categories,
    required this.popularServices,
    this.upcomingAppointment,
  });
}
