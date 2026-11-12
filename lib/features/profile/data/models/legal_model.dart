import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

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

class ReportHistoryItem {
  final int id;
  final String? oldStatus;
  final String newStatus;
  final String? note;
  final String createdAt;

  const ReportHistoryItem({
    required this.id,
    this.oldStatus,
    required this.newStatus,
    this.note,
    required this.createdAt,
  });

  factory ReportHistoryItem.fromJson(Map<String, dynamic> j) =>
      ReportHistoryItem(
        id: j['id'],
        oldStatus: j['old_status'],
        newStatus: j['new_status'] ?? '',
        note: j['note'],
        createdAt: j['created_at'] ?? '',
      );

  Color get statusColor => ReportModel.colorForStatus(newStatus);

  String get statusLabel => ReportModel.labelForStatus(newStatus);

  DateTime? get _createdAtDate => DateTime.tryParse(createdAt);

  /// e.g. "14 Jul 2026 • 02:51 PM" — month/AM-PM in the app language.
  String formattedDateTime(String locale) {
    final d = _createdAtDate;
    if (d == null) return createdAt;
    return DateFormat('d MMM yyyy • hh:mm a', locale).format(d);
  }
}

class ReportModel {
  final int id;
  final int bookingId;
  final String bookingRef;
  final int customerId;
  final String reason;
  final String? description;
  final String status; // submitted | under_review | resolved
  final String serviceName;
  final List<ReportHistoryItem> history;
  final String createdAt;
  final String updatedAt;

  const ReportModel({
    required this.id,
    required this.bookingId,
    required this.bookingRef,
    required this.customerId,
    required this.reason,
    this.description,
    required this.status,
    required this.serviceName,
    required this.history,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> j) => ReportModel(
    id: j['id'],
    bookingId: j['booking_id'] ?? 0,
    bookingRef: j['booking_ref'] ?? '',
    customerId: j['customer_id'] ?? 0,
    reason: j['reason'] ?? '',
    description: j['description'],
    status: j['status'] ?? 'submitted',
    serviceName: j['service_name'] ?? '',
    // History arrives newest-first (see sample payload: id 3 has the
    // latest created_at, listed first) — relied on by `statusDescription`
    // below to find the latest note, and by the history timeline UI.
    history: (j['history'] as List<dynamic>? ?? [])
        .map((e) => ReportHistoryItem.fromJson(e))
        .toList(),
    createdAt: j['created_at'] ?? '',
    updatedAt: j['updated_at'] ?? '',
  );

  // ── Status helpers ──────────────────────────────────────────────────
  // Static so ReportHistoryItem (whose `newStatus`/`oldStatus` are their
  // own independent status strings) can reuse the same color/label rules
  // as the report's own top-level `status`.

  static Color colorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return const Color(0xFFFF9800);
      case 'under_review':
        return const Color(0xFF2196F3);
      case 'resolved':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  static String labelForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 'report_status_submitted'.tr();
      case 'under_review':
        return 'report_status_under_review'.tr();
      case 'resolved':
        return 'report_status_resolved'.tr();
      default:
        return status;
    }
  }

  static int stepForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 0;
      case 'under_review':
        return 1;
      case 'resolved':
        return 2;
      default:
        return 0;
    }
  }

  Color get statusColor => colorForStatus(status);
  String get statusLabel => labelForStatus(status);
  int get statusStep => stepForStatus(status);

  // The API only sends `reason` as a snake_case code (e.g. "wrong_charges").
  // Map it to the matching translation key and localize it.
  String get reasonLabel {
    const reasonsDesc = [
      ('worker_didnt_show_up', 'worker_no_show'),
      ('late_arrival', 'late_arrival'),
      ('poor_service_quality', 'poor_quality'),
      ('wrong_charges', 'wrong_charges'),
      ('other', 'other'),
    ];

    if (reason.trim().isEmpty) return '';

    // r.$1 is the API's reason code, r.$2 is the translation key.
    final match = reasonsDesc.firstWhere(
          (r) => r.$1 == reason,
      orElse: () => (reason, reason),
    );
    return match.$2.tr();
  }

  // `service_name` sometimes carries a variant in parentheses, e.g.
  // "Hospitality Worker (Hourly)". Split that into a small category label
  // ("Hourly Services") and a clean title ("Hospitality Worker") to match
  // the two-line card layout. Falls back to the raw name if there's no
  // parenthetical part.
  String get serviceCategory {
    final match = RegExp(r'\(([^)]+)\)').firstMatch(serviceName);
    return match != null ? '${match.group(1)} Services' : '';
  }

  String get serviceTitle {
    final stripped = serviceName.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
    return stripped.isEmpty ? serviceName : stripped;
  }

  DateTime? get _createdAtDate => DateTime.tryParse(createdAt);
  DateTime? get _updatedAtDate => DateTime.tryParse(updatedAt);

  /// Short label for the list tile's date strip, e.g. "Jan 10".
  String shortDateLabel(String locale) {
    final d = _createdAtDate;
    return d == null ? '' : DateFormat('MMM d', locale).format(d);
  }

  /// Long label for the detail screen, e.g. "20 Nov 2026".
  String longCreatedAtLabel(String locale) {
    final d = _createdAtDate;
    return d == null ? createdAt : DateFormat('d MMM yyyy', locale).format(d);
  }

  String longUpdatedAtLabel(String locale) {
    final d = _updatedAtDate;
    return d == null ? updatedAt : DateFormat('d MMM yyyy', locale).format(d);
  }

  /// Whether the report was updated after it was submitted, so the detail
  /// screen only shows a "Last Update" row when there's actually one.
  bool get hasUpdate => updatedAt.isNotEmpty && updatedAt != createdAt;

  /// Message shown inside the status box on the detail screen. Prefers, in
  /// order: an explicit `description` from the API, the note on the most
  /// recent history entry, then a generic per-status fallback.
  String get statusDescription {
    if (description != null && description!.trim().isNotEmpty) {
      return description!.trim();
    }
    if (history.isNotEmpty) {
      final latestNote = history.first.note;
      if (latestNote != null && latestNote.trim().isNotEmpty) {
        return latestNote.trim();
      }
    }
    switch (status.toLowerCase()) {
      case 'submitted':
        return 'report_desc_submitted'.tr();
      case 'under_review':
        return 'report_desc_under_review'.tr();
      case 'resolved':
        return 'report_desc_resolved'.tr();
      default:
        return '';
    }
  }
}