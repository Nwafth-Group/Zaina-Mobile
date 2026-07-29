
class ServiceModel {
  final int id;
  final String nameAr;
  final String nameEn;
  final String? image;
  final String type; // "hourly" | "other" (as returned by API)

  ServiceModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.image,
    required this.type,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as int,
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      image: json['image'] as String?,
      type: json['type'] ?? '',
    );
  }

  String localizedName(String languageCode) {
    return languageCode == 'ar' ? nameAr : nameEn;
  }
}