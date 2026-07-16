class PointsProgress {
  final String title;
  final int currentStep;
  final int targetStep;
  final int stepsRemaining;
  final bool isCompleted;
  final int rewardPoints;
  final String actionType;
  final String footerText;

  const PointsProgress({
    required this.title,
    required this.currentStep,
    required this.targetStep,
    required this.stepsRemaining,
    required this.isCompleted,
    required this.rewardPoints,
    required this.actionType,
    required this.footerText,
  });

  factory PointsProgress.fromJson(Map<String, dynamic> j) => PointsProgress(
    title: j['title'] ?? '',
    currentStep: j['current_step'] ?? 0,
    targetStep: j['target_step'] ?? 1,
    stepsRemaining: j['steps_remaining'] ?? 0,
    isCompleted: j['is_completed'] == true,
    rewardPoints: j['reward_points'] ?? 0,
    actionType: j['action_type'] ?? '',
    footerText: j['footer_text'] ?? '',
  );

  double get progress =>
      targetStep > 0 ? (currentStep / targetStep).clamp(0.0, 1.0) : 0;
}

class EarnPointsItem {
  final int id;
  final String title;
  final String subtitle;
  final String points;
  final String actionType;
  final String? actionLink;
  final String? ruleCategory;
  final bool isCompleted;

  const EarnPointsItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.actionType,
    this.actionLink,
    this.ruleCategory,
    required this.isCompleted,
  });

  factory EarnPointsItem.fromJson(Map<String, dynamic> j) => EarnPointsItem(
    id: j['id'],
    title: j['title'] ?? '',
    subtitle: j['subtitle'] ?? '',
    points: j['points'] ?? '',
    actionType: j['action_type'] ?? '',
    actionLink: j['action_link'],
    ruleCategory: j['rule_category'],
    isCompleted: j['is_completed'] == true,
  );

  /// Localization *key* — call `.tr()` on this at the UI layer so button
  /// text respects the current locale instead of being hardcoded English.
  String get actionLabel {
    switch (actionType) {
      case 'url':            return 'follow';
      case 'invite_friend':  return 'invite';
      case 'rate_service':   return 'rate_now';
      default:                return 'go';
    }
  }
}

class PointsHistoryItem {
  final int id;
  final String type; // earn | redeem | adjustment | ...
  final String? typeTranslate;
  final String title;
  final String amount;
  final String date;

  const PointsHistoryItem({
    required this.id,
    required this.type,
    this.typeTranslate,
    required this.title,
    required this.amount,
    required this.date,
  });

  factory PointsHistoryItem.fromJson(Map<String, dynamic> j) =>
      PointsHistoryItem(
        id: j['id'],
        type: j['type'] ?? 'earn',
        typeTranslate: j['type_translate'],
        title: j['title'] ?? '',
        amount: j['amount'] ?? '',
        date: j['date'] ?? '',
      );

  /// `type` can be "earn", "redeem", "adjustment", etc. — the API's
  /// `type` field isn't a reliable earn/spend signal on its own (an
  /// "adjustment" can be positive or negative), so we read the sign
  /// directly off `amount` instead (e.g. "+150 Pts" vs "-2000 Pts").
  bool get isEarn => !amount.trim().startsWith('-');
}

class PointsSummary {
  final int totalPoints;
  final String referralCode;
  final String? referralExpiresAt;
  final int referralCount;
  final int successfulReferralCount;
  final String googlePlayLink;
  final String appStoreLink;
  final String shareMessageAr;
  final String shareMessageEn;
  final List<PointsProgress> progressCards;
  final List<EarnPointsItem> earnPoints;
  final List<PointsHistoryItem> history;

  const PointsSummary({
    required this.totalPoints,
    required this.referralCode,
    this.referralExpiresAt,
    required this.referralCount,
    required this.successfulReferralCount,
    required this.googlePlayLink,
    required this.appStoreLink,
    required this.shareMessageAr,
    required this.shareMessageEn,
    required this.progressCards,
    required this.earnPoints,
    required this.history,
  });

  factory PointsSummary.fromJson(Map<String, dynamic> j) {
    final d = j.containsKey('data') ? j['data'] : j;
    return PointsSummary(
      totalPoints: d['total_points'] ?? 0,
      referralCode: d['referral_code'] ?? '',
      referralExpiresAt: d['referral_expires_at'],
      referralCount: d['referral_count'] ?? 0,
      successfulReferralCount: d['successful_referral_count'] ?? 0,
      googlePlayLink: d['google_play_link'] ?? '',
      appStoreLink: d['app_store_link'] ?? '',
      shareMessageAr: d['share_message_ar'] ?? '',
      shareMessageEn: d['share_message_en'] ?? '',
      // progress_card is a LIST in the real API (can be 0, 1, or many
      // cards — invite-friend progress, complete-booking progress, etc.)
      progressCards: (d['progress_card'] as List<dynamic>? ?? [])
          .map((e) => PointsProgress.fromJson(e))
          .toList(),
      earnPoints: (d['earn_points'] as List<dynamic>? ?? [])
          .map((e) => EarnPointsItem.fromJson(e))
          .toList(),
      history: (d['history'] as List<dynamic>? ?? [])
          .map((e) => PointsHistoryItem.fromJson(e))
          .toList(),
    );
  }

  /// Used after POST customer/points/generate-referral-code to swap in
  /// the new code/expiry without re-fetching (or losing) the rest of
  /// the summary.
  PointsSummary copyWith({
    String? referralCode,
    String? referralExpiresAt,
  }) {
    return PointsSummary(
      totalPoints: totalPoints,
      referralCode: referralCode ?? this.referralCode,
      referralExpiresAt: referralExpiresAt ?? this.referralExpiresAt,
      referralCount: referralCount,
      successfulReferralCount: successfulReferralCount,
      googlePlayLink: googlePlayLink,
      appStoreLink: appStoreLink,
      shareMessageAr: shareMessageAr,
      shareMessageEn: shareMessageEn,
      progressCards: progressCards,
      earnPoints: earnPoints,
      history: history,
    );
  }
}