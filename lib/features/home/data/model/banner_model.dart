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

  CategoryModel({required this.id, required this.nameAr, required this.nameEn, this.image});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      nameAr: json['name_ar'],
      nameEn: json['name_en'],
      image: json['image'],
    );
  }
}

class HomeData {
  final List<BannerModel> banners;
  final List<CategoryModel> categories;
  final List<ServiceModel> popularServices;

  HomeData({required this.banners, required this.categories, required this.popularServices});
}