import 'dart:ui';

class VisitScheduleItem {
  final String visitDate; // "yyyy-MM-dd"
  final String visitDay; // localized day name from server, e.g. "الخميس"
  final String startTime; // "HH:mm"
  final String endTime; // "HH:mm"
  final int duration; // hours
  final String visitStatus;

  const VisitScheduleItem({
    required this.visitDate,
    required this.visitDay,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.visitStatus,
  });

  factory VisitScheduleItem.fromJson(Map<String, dynamic> json) {
    return VisitScheduleItem(
      visitDate: json['visit_date'] ?? '',
      visitDay: json['visit_day'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      duration: json['duration'] ?? 0,
      visitStatus: json['visit_status'] ?? '',
    );
  }
}

class BookingCardDetails {
  final String contractNumberRequest;
  final String startDayAndDate;
  final int duration;
  final String status;
  final String visitType;
  final double amount;
  final String currency;

  const BookingCardDetails({
    required this.contractNumberRequest,
    required this.startDayAndDate,
    required this.duration,
    required this.status,
    required this.visitType,
    required this.amount,
    required this.currency,
  });

  factory BookingCardDetails.fromJson(Map<String, dynamic> json) {
    final priceAndCurrency =
        json['price_and_currency'] as Map<String, dynamic>? ?? {};
    return BookingCardDetails(
      contractNumberRequest: json['contract_number_request'] ?? '',
      startDayAndDate: json['start_day_and_date'] ?? '',
      duration: json['duration'] ?? 0,
      status: json['status'] ?? '',
      visitType: json['visit_type'] ?? '',
      amount: (priceAndCurrency['amount'] as num?)?.toDouble() ?? 0,
      currency: priceAndCurrency['currency'] ?? '',
    );
  }
}

class BookingModel {
  final int id; // booking_id
  final String bookingReference;
  final String serviceName;
  final String serviceDate; // "yyyy-MM-dd"
  final String startTime; // "HH:mm"
  final String endTime; // "HH:mm"
  final String expectedArrivalTime;
  final String firstScheduleDate; // "yyyy-MM-dd"
  final String firstScheduleDateFormatted; // localized, e.g. "الخميس, 30 Jul 2026"
  final String bookingStatus; // "Upcoming" | "In Service" | "Completed" | "Cancelled"
  final String visitType; // "single_visit" | "three_visits_per_week"
  final List<VisitScheduleItem> visitSchedule;
  final double totalAmount;
  final String currencyCode;
  final BookingCardDetails? cardDetails;

  const BookingModel({
    required this.id,
    required this.bookingReference,
    required this.serviceName,
    required this.serviceDate,
    required this.startTime,
    required this.endTime,
    required this.expectedArrivalTime,
    required this.firstScheduleDate,
    required this.firstScheduleDateFormatted,
    required this.bookingStatus,
    required this.visitType,
    required this.visitSchedule,
    required this.totalAmount,
    required this.currencyCode,
    required this.cardDetails,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['booking_id'] ?? 0,
      bookingReference: json['booking_reference'] ?? '',
      serviceName: json['service_name'] ?? '',
      serviceDate: json['service_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      expectedArrivalTime: json['expected_arrival_time'] ?? '',
      firstScheduleDate: json['first_schedule_date'] ?? '',
      firstScheduleDateFormatted: json['first_schedule_date_formatted'] ?? '',
      bookingStatus: json['booking_status'] ?? 'Upcoming',
      visitType: json['visit_type'] ?? 'single_visit',
      visitSchedule: (json['visit_schedule'] as List<dynamic>? ?? [])
          .map((e) => VisitScheduleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      currencyCode: json['currency_code'] ?? '',
      cardDetails: json['card_details'] != null
          ? BookingCardDetails.fromJson(json['card_details'] as Map<String, dynamic>)
          : null,
    );
  }

  BookingStatusEnum get statusEnum {
    final normalized = bookingStatus.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
    switch (normalized) {
      case 'upcoming':
        return BookingStatusEnum.upcoming;
      case 'inservice':
        return BookingStatusEnum.inService;
      case 'completed':
        return BookingStatusEnum.completed;
      case 'cancelled':
      case 'canceled':
        return BookingStatusEnum.cancelled;
      default:
        return BookingStatusEnum.upcoming;
    }
  }

  bool get isMultiVisit => visitType == 'three_visits_per_week';

  /// Reuses the existing 'single_visit' / '3_days_per_week' localization
  /// keys (already added for the service-booking flow) rather than adding
  /// new duplicate ones — the API's "three_visits_per_week" just maps to
  /// the same '3_days_per_week' key used elsewhere in the app.
  String get visitTypeLabelKey => isMultiVisit ? '3_days_per_week' : 'single_visit';

  /// Day-of-month for the date panel, e.g. "30".
  String get dateDay {
    final date = DateTime.tryParse(firstScheduleDate);
    return date != null ? '${date.day}' : '';
  }

  static const _monthShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  /// 3-letter month for the date panel, e.g. "Jul".
  String get dateMonth {
    final date = DateTime.tryParse(firstScheduleDate);
    return date != null ? _monthShort[date.month - 1] : '';
  }

  /// "6:30 PM"-style 12-hour time for the date panel.
  String get timeLabel {
    final parts = startTime.split(':');
    if (parts.length < 2) return startTime;
    int hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1].padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute $period';
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

  /// Exact query-param values confirmed for GET /customer/bookings?status=...
  /// Note the mixed casing is intentional — this is what the API expects.
  String get apiValue {
    switch (this) {
      case BookingStatusEnum.all: return '';
      case BookingStatusEnum.upcoming: return 'Upcoming';
      case BookingStatusEnum.inService: return 'inService';
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