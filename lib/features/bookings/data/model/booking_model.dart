enum BookingStatus { all, upcoming, inService, completed, cancelled }

extension BookingStatusExt on BookingStatus {
  String get key {
    switch (this) {
      case BookingStatus.all: return 'all';
      case BookingStatus.upcoming: return 'upcoming';
      case BookingStatus.inService: return 'in_service';
      case BookingStatus.completed: return 'completed';
      case BookingStatus.cancelled: return 'cancelled';
    }
  }

  String get label {
    switch (this) {
      case BookingStatus.all: return 'All';
      case BookingStatus.upcoming: return 'Upcoming';
      case BookingStatus.inService: return 'In Service';
      case BookingStatus.completed: return 'Completed';
      case BookingStatus.cancelled: return 'Cancelled';
    }
  }
}

class BookingWorker {
  final String name;
  final double rating;
  final String? avatar;
  final String role;

  const BookingWorker({
    required this.name,
    required this.rating,
    this.avatar,
    required this.role,
  });
}

class BookingModel {
  final String id;
  final String serviceName;
  final String? serviceImage;
  final double price;
  final String currency;
  final BookingStatus status;
  final int day;
  final String month;
  final String location;
  final String address;
  final String city;
  final int durationHours;
  final String timeRange;
  final String dateFormatted;
  final List<String> importantNotes;
  final BookingWorker? worker;
  final double servicePriceBreakdown;
  final double serviceVat;

  const BookingModel({
    required this.id,
    required this.serviceName,
    this.serviceImage,
    required this.price,
    required this.currency,
    required this.status,
    required this.day,
    required this.month,
    required this.location,
    required this.address,
    required this.city,
    required this.durationHours,
    required this.timeRange,
    required this.dateFormatted,
    required this.importantNotes,
    this.worker,
    required this.servicePriceBreakdown,
    required this.serviceVat,
  });

  double get total => servicePriceBreakdown + serviceVat;

  static List<BookingModel> get mockList => [
    BookingModel(
      id: 'HC-S040631',
      serviceName: 'Home Cleaning',
      price: 2500,
      currency: 'EGP',
      status: BookingStatus.upcoming,
      day: 10,
      month: 'Nov',
      location: 'Home',
      address: 'Nasr City Abbas El Akkad Street Building 24',
      city: 'Nasr City, Cairo',
      durationHours: 3,
      timeRange: '10:00 AM - 01:00 PM',
      dateFormatted: '20 NOV, 2026',
      importantNotes: [
        'Estimation Visit Before 30 Min',
        'Reschedule Can Be Before One Day',
      ],
      worker: const BookingWorker(
        name: 'Rahman Hossain',
        rating: 4.4,
        role: 'Employee',
      ),
      servicePriceBreakdown: 120,
      serviceVat: 10,
    ),
    BookingModel(
      id: 'HC-S040632',
      serviceName: 'Home Cleaning',
      price: 2500,
      currency: 'EGP',
      status: BookingStatus.inService,
      day: 10,
      month: 'Nov',
      location: 'Home',
      address: 'Nasr City Abbas El Akkad Street Building 24',
      city: 'Nasr City, Cairo',
      durationHours: 3,
      timeRange: '10:00 AM - 01:00 PM',
      dateFormatted: '20 NOV, 2026',
      importantNotes: [
        'Estimation Visit Before 30 Min',
        'Reschedule Can Be Before One Day',
      ],
      worker: const BookingWorker(
        name: 'Rahman Hossain',
        rating: 4.4,
        role: 'Employee',
      ),
      servicePriceBreakdown: 120,
      serviceVat: 10,
    ),
    BookingModel(
      id: 'HC-S040633',
      serviceName: 'Home Cleaning',
      price: 2500,
      currency: 'EGP',
      status: BookingStatus.completed,
      day: 10,
      month: 'Nov',
      location: 'Home',
      address: 'Nasr City Abbas El Akkad Street Building 24',
      city: 'Nasr City, Cairo',
      durationHours: 3,
      timeRange: '10:00 AM - 01:00 PM',
      dateFormatted: '20 NOV, 2026',
      importantNotes: [
        'Estimation Visit Before 30 Min',
        'Reschedule Can Be Before One Day',
      ],
      worker: const BookingWorker(
        name: 'Rahman Hossain',
        rating: 4.4,
        role: 'Employee',
      ),
      servicePriceBreakdown: 120,
      serviceVat: 10,
    ),
    BookingModel(
      id: 'HC-S040634',
      serviceName: 'Home Cleaning',
      price: 2500,
      currency: 'EGP',
      status: BookingStatus.cancelled,
      day: 10,
      month: 'Nov',
      location: 'Home',
      address: 'Nasr City Abbas El Akkad Street Building 24',
      city: 'Nasr City, Cairo',
      durationHours: 3,
      timeRange: '10:00 AM - 01:00 PM',
      dateFormatted: '20 NOV, 2026',
      importantNotes: [
        'Estimation Visit Before 30 Min',
        'Reschedule Can Be Before One Day',
      ],
      worker: const BookingWorker(
        name: 'Rahman Hossain',
        rating: 4.4,
        role: 'Employee',
      ),
      servicePriceBreakdown: 120,
      serviceVat: 10,
    ),
  ];
}