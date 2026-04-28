import 'package:zeina_app/features/home/data/model/service_model.dart';

class BannerModel {
  final int id;
  final String title;
  final String description;
  final String? image;

  BannerModel({required this.id, required this.title, required this.description, this.image});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      // JSON shows "media" as list, adjust based on your actual media parsing logic
      image: (json['media'] as List).isNotEmpty ? json['media'][0]['url'] : null,
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

class HomeData {
  final List<BannerModel> banners;
  final List<CategoryModel> categories;
  final List<ServiceModel> popularServices;

  HomeData({required this.banners, required this.categories, required this.popularServices});
}