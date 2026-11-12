enum VerificationStatus { unverified, pending, verified, rejected, approved }

extension VerificationStatusExt on VerificationStatus {
  static VerificationStatus fromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'pending':  return VerificationStatus.pending;
      case 'verified': return VerificationStatus.verified;
      case 'rejected': return VerificationStatus.rejected;
      case 'approved': return VerificationStatus.approved;
      default:         return VerificationStatus.unverified;
    }
  }

  bool get needsVerification =>
      this == VerificationStatus.unverified ||
          this == VerificationStatus.rejected;

  bool get isVerified => this == VerificationStatus.verified;
  bool get isPending  => this == VerificationStatus.pending;
}

class UserProfile {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final VerificationStatus verificationStatus;
  final String? rejectionReason;
  final String mobileNumber;
  final String? email;
  final String? image;
  final String? idNumber;
  final String? updatedAt;
  final String? gender;
  final double? walletBalance;
  final String? preferredLanguage;

  const UserProfile({
    required this.id,
    this.firstName,
    this.lastName,
    this.fullName,
    required this.verificationStatus,
    this.rejectionReason,
    required this.mobileNumber,
    this.email,
    this.image,
    this.idNumber,
    this.updatedAt,
    this.gender,
    this.walletBalance,
    this.preferredLanguage,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data')
        ? json['data'] as Map<String, dynamic>
        : json;
    return UserProfile(
      id: data['id'],
      firstName: data['first_name'],
      lastName: data['last_name'],
      fullName: data['full_name'],
      gender: data['gender'],
      verificationStatus: VerificationStatusExt.fromString(
          data['verification_status']),
      rejectionReason: data['rejection_reason'],
      mobileNumber: data['mobile_number'] ?? '',
      email: data['email'],
      image: data['image'],
      idNumber: data['id_number']?.toString(),
      updatedAt: data['updated_at']?.toString(),
      walletBalance: data['wallet_balance'] != null
          ? double.tryParse(data['wallet_balance'].toString())
          : null,
      preferredLanguage: data['preferred_language'],
    );
  }

  /// Cache key for the avatar. Changes whenever the profile is updated, so
  /// a newly uploaded image shows immediately even if the server keeps the
  /// same image URL (CachedNetworkImage would otherwise keep the old file).
  String? get imageCacheKey =>
      image == null ? null : '$image#${updatedAt ?? ''}';

  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) return fullName!;
    final parts = [firstName, lastName]
        .where((p) => p != null && p.isNotEmpty)
        .join(' ');
    return parts.isNotEmpty ? parts : mobileNumber;
  }

  String get initials {
    if (fullName != null && fullName!.trim().isNotEmpty) {
      final parts = fullName!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return fullName![0].toUpperCase();
    }
    return mobileNumber.isNotEmpty ? mobileNumber[0] : 'U';
  }
}