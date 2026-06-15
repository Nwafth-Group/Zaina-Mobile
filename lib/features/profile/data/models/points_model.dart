class PointsProgress {
  final String title;
  final int currentStep;
  final int targetStep;
  final int rewardPoints;
  final String footerText;

  const PointsProgress({
    required this.title,
    required this.currentStep,
    required this.targetStep,
    required this.rewardPoints,
    required this.footerText,
  });

  factory PointsProgress.fromJson(Map<String, dynamic> j) => PointsProgress(
    title: j['title'] ?? '',
    currentStep: j['current_step'] ?? 0,
    targetStep: j['target_step'] ?? 1,
    rewardPoints: j['reward_points'] ?? 0,
    footerText: j['footer_text'] ?? '',
  );

  double get progress =>
      targetStep > 0 ? currentStep / targetStep : 0;
}

class EarnPointsItem {
  final int id;
  final String title;
  final String subtitle;
  final String points;
  final String actionType;
  final String? actionLink;
  final bool isCompleted;

  const EarnPointsItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.actionType,
    this.actionLink,
    required this.isCompleted,
  });

  factory EarnPointsItem.fromJson(Map<String, dynamic> j) => EarnPointsItem(
    id: j['id'],
    title: j['title'] ?? '',
    subtitle: j['subtitle'] ?? '',
    points: j['points'] ?? '',
    actionType: j['action_type'] ?? '',
    actionLink: j['action_link'],
    isCompleted: j['is_completed'] == true,
  );

  String get actionLabel {
    switch (actionType) {
      case 'url':           return 'Follow';
      case 'invite_friend': return 'Invite';
      case 'rate_service':  return 'Rate Now';
      default:              return 'Go';
    }
  }
}

class PointsHistoryItem {
  final int id;
  final String type; // earn | redeem
  final String title;
  final String amount;
  final String date;

  const PointsHistoryItem({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
  });

  factory PointsHistoryItem.fromJson(Map<String, dynamic> j) =>
      PointsHistoryItem(
        id: j['id'],
        type: j['type'] ?? 'earn',
        title: j['title'] ?? '',
        amount: j['amount'] ?? '',
        date: j['date'] ?? '',
      );

  bool get isEarn => type == 'earn';
}

class PointsSummary {
  final int totalPoints;
  final PointsProgress progress;
  final List<EarnPointsItem> earnPoints;
  final List<PointsHistoryItem> history;

  const PointsSummary({
    required this.totalPoints,
    required this.progress,
    required this.earnPoints,
    required this.history,
  });

  factory PointsSummary.fromJson(Map<String, dynamic> j) {
    final d = j.containsKey('data') ? j['data'] : j;
    return PointsSummary(
      totalPoints: d['total_points'] ?? 0,
      progress: PointsProgress.fromJson(d['progress_card']),
      earnPoints: (d['earn_points'] as List<dynamic>? ?? [])
          .map((e) => EarnPointsItem.fromJson(e))
          .toList(),
      history: (d['history'] as List<dynamic>? ?? [])
          .map((e) => PointsHistoryItem.fromJson(e))
          .toList(),
    );
  }
}