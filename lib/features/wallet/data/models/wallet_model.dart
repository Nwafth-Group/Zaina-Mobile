import 'package:flutter/material.dart';

class WalletTransaction {
  final int id;
  final String type; // credit | debit
  final double amount;
  final String title;
  final String? referenceId;
  final String createdAt;
  final String time;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.title,
    this.referenceId,
    required this.createdAt,
    required this.time,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      type: json['type'] ?? 'debit',
      amount: (json['amount'] as num).toDouble(),
      title: json['title'] ?? '',
      referenceId: json['reference_id'],
      createdAt: json['created_at'] ?? '',
      time: json['time'] ?? '',
    );
  }

  bool get isCredit => type == 'credit';
}

class WalletData {
  final double availableBalance;
  final String currency;
  final List<WalletTransaction> transactions;

  const WalletData({
    required this.availableBalance,
    required this.currency,
    required this.transactions,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return WalletData(
      availableBalance: (data['available_balance'] as num).toDouble(),
      currency: data['currency'] ?? 'EGP',
      transactions: (data['transactions'] as List<dynamic>? ?? [])
          .map((e) => WalletTransaction.fromJson(e))
          .toList(),
    );
  }
}

class CardModel {
  final int id;
  final String cardHolderName;
  final String brand;
  final String displayNumber;
  final bool isDefault;

  const CardModel({
    required this.id,
    required this.cardHolderName,
    required this.brand,
    required this.displayNumber,
    required this.isDefault,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      cardHolderName: json['card_holder_name'] ?? '',
      brand: json['brand'] ?? 'VISA',
      displayNumber: json['display_number'] ?? '',
      isDefault: json['is_default'] == true,
    );
  }

  IconData get brandIcon {
    switch (brand.toUpperCase()) {
      case 'MASTERCARD':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }
}

enum WalletFilter { all, today, last7Days, last30Days, custom }

extension WalletFilterExt on WalletFilter {
  String get apiValue {
    switch (this) {
      case WalletFilter.today:      return 'today';
      case WalletFilter.last7Days:  return 'last_7_days';
      case WalletFilter.last30Days: return 'last_30_days';
      case WalletFilter.custom:     return 'custom';
      default:                      return '';
    }
  }

  String get label {
    switch (this) {
      case WalletFilter.today:      return 'Today';
      case WalletFilter.last7Days:  return 'Last 7 Days';
      case WalletFilter.last30Days: return 'Last 30 Days';
      case WalletFilter.custom:     return 'Custom Range';
      default:                      return 'All';
    }
  }
}