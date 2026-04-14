class ServiceCategory {
  final int id;
  final String nameAr;
  final String nameEn;
  final String? image;

  const ServiceCategory({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.image,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'],
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      image: json['image'],
    );
  }
}

class ServiceFeature {
  final String ar;
  final String en;

  const ServiceFeature({required this.ar, required this.en});

  factory ServiceFeature.fromJson(Map<String, dynamic> json) {
    return ServiceFeature(ar: json['ar'] ?? '', en: json['en'] ?? '');
  }
}

class ServicePrice {
  final double basePrice;
  final double pricePerHour;
  final String currency;

  const ServicePrice({
    required this.basePrice,
    required this.pricePerHour,
    required this.currency,
  });

  factory ServicePrice.fromJson(Map<String, dynamic> json) {
    return ServicePrice(
      basePrice: (json['base_price'] as num).toDouble(),
      pricePerHour: (json['price_per_hour'] as num).toDouble(),
      currency: json['currency'] ?? 'EGP',
    );
  }
}

class ServiceModel {
  final int id;
  final ServiceCategory category;
  final String type; // hourly | both | moqema
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final List<ServiceFeature> features;
  final String status;
  final double avgRating;
  final String? image;
  final ServicePrice price;

  const ServiceModel({
    required this.id,
    required this.category,
    required this.type,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.features,
    required this.status,
    required this.avgRating,
    this.image,
    required this.price,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      category: ServiceCategory.fromJson(json['category']),
      type: json['type'] ?? 'hourly',
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      features: (json['features'] as List<dynamic>? ?? [])
          .map((f) => ServiceFeature.fromJson(f))
          .toList(),
      status: json['status'] ?? 'active',
      avgRating: double.tryParse(json['avg_rating']?.toString() ?? '0') ?? 0,
      image: json['image'],
      price: ServicePrice.fromJson(json['price']),
    );
  }

  String localizedName(String langCode) =>
      langCode == 'ar' ? nameAr : nameEn;

  String localizedDescription(String langCode) =>
      langCode == 'ar' ? descriptionAr : descriptionEn;

  String localizedCategory(String langCode) =>
      langCode == 'ar' ? category.nameAr : category.nameEn;
}

class SearchResponse {
  final bool isSuggestions;
  final List<String> suggestions;
  final List<ServiceModel> services;
  final int currentPage;
  final int lastPage;
  final int total;

  const SearchResponse({
    required this.isSuggestions,
    required this.suggestions,
    required this.services,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final isSugg = data['is_suggestions'] == true;

    List<ServiceModel> services = [];
    int currentPage = 1, lastPage = 1, total = 0;

    if (!isSugg && data['services'] is Map) {
      final servicesMap = data['services'] as Map<String, dynamic>;
      services = (servicesMap['data'] as List<dynamic>? ?? [])
          .map((s) => ServiceModel.fromJson(s))
          .toList();
      final meta = servicesMap['meta'] as Map<String, dynamic>? ?? {};
      currentPage = meta['current_page'] ?? 1;
      lastPage = meta['last_page'] ?? 1;
      total = meta['total'] ?? 0;
    }

    return SearchResponse(
      isSuggestions: isSugg,
      suggestions: (data['suggestions'] as List<dynamic>? ?? [])
          .map((s) => s.toString())
          .toList(),
      services: services,
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
    );
  }
}

// ── Review model (mock until API is ready) ───────────────────────────────────
class ReviewModel {
  final String name;
  final double rating;
  final String comment;
  final String timeAgo;

  const ReviewModel({
    required this.name,
    required this.rating,
    required this.comment,
    required this.timeAgo,
  });

  static List<ReviewModel> get mockReviews => const [
    ReviewModel(
        name: 'Keith Ralph P.',
        rating: 3.5,
        comment: 'Very clean and professional',
        timeAgo: '2 months ago'),
    ReviewModel(
        name: 'Dheeraj M.',
        rating: 4.0,
        comment: 'Very clean and professional',
        timeAgo: '2 months ago'),
    ReviewModel(
        name: 'Sara K.',
        rating: 5.0,
        comment: 'Excellent service, highly recommend!',
        timeAgo: '3 months ago'),
  ];
}
