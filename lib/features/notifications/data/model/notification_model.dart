class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? image;
  final bool isRead;
  final String createdAt;
  final int? bookingId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.image,
    required this.isRead,
    required this.createdAt,
    this.bookingId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      image: json['image'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] ?? '',
      bookingId: json['booking_id'],
    );
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id,
    title: title,
    body: body,
    image: image,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
    bookingId: bookingId,
  );
}
