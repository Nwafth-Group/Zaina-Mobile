
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
  final String expectedArrivalTime;

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
    required this.expectedArrivalTime
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
      expectedArrivalTime: json['expected_arrival_time'] ?? ''
    );
  }

  String localizedName(String langCode) =>
      langCode == 'ar' ? serviceNameAr : serviceNameEn;
}

class HomeData {
  final List<BannerModel> banners;
  final UpcomingAppointment? upcomingAppointment;

  HomeData({
    required this.banners,
    this.upcomingAppointment,
  });
}
