
class ReviewCustomerModel {
  final int id;
  final String firstName;
  final String lastName;

  ReviewCustomerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory ReviewCustomerModel.fromJson(Map<String, dynamic> json) {
    return ReviewCustomerModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}

class ReviewModel {
  final int id;
  final int rating;
  final String comment;
  final ReviewCustomerModel customer;
  final String bookingRef;
  final String createdSince;

  ReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.customer,
    required this.bookingRef,
    required this.createdSince,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      customer: ReviewCustomerModel.fromJson(
          json['customer'] as Map<String, dynamic>? ?? {}),
      bookingRef: json['booking_ref'] ?? '',
      createdSince: json['created_since'] ?? '',
    );
  }
}