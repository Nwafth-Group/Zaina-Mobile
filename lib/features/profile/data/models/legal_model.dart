import 'dart:ui';

class LegalSection {
  final int id;
  final String title;
  final String content;
  bool isExpanded;

  LegalSection({
    this.id = 0,
    required this.title,
    required this.content,
    this.isExpanded = false,
  });

  factory LegalSection.fromJson(Map<String, dynamic> j) => LegalSection(
    id: j['id'] ?? 0,
    title: j['title'] ?? '',
    content: j['content'] ?? '',
  );
}

class ReportModel {
  final int id;
  final String serviceName;
  final String? serviceImage;
  final String status; // submitted | under_review | resolved
  final String date;
  final String? lastUpdate;
  final String? statusMessage;
  final String? category;

  const ReportModel({
    required this.id,
    required this.serviceName,
    this.serviceImage,
    required this.status,
    required this.date,
    this.lastUpdate,
    this.statusMessage,
    this.category,
  });

  factory ReportModel.fromJson(Map<String, dynamic> j) => ReportModel(
    id: j['id'],
    serviceName: j['booking_ref'] ?? j['service_name'] ?? '',
    serviceImage: j['service_image'],
    status: j['status'] ?? 'submitted',
    date: j['created_at'] ?? j['date'] ?? '',
    lastUpdate: j['updated_at'] ?? j['last_update'],
    statusMessage: j['description'] ?? j['status_message'],
    category: j['reason'] ?? j['category'],
  );

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'submitted':    return const Color(0xFFFF9800);
      case 'under_review': return const Color(0xFF2196F3);
      case 'resolved':     return const Color(0xFF4CAF50);
      default:             return const Color(0xFF9E9E9E);
    }
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'submitted':    return 'Submitted';
      case 'under_review': return 'Under Review';
      case 'resolved':     return 'Resolved';
      default:             return status;
    }
  }

  int get statusStep {
    switch (status.toLowerCase()) {
      case 'submitted':    return 0;
      case 'under_review': return 1;
      case 'resolved':     return 2;
      default:             return 0;
    }
  }
}