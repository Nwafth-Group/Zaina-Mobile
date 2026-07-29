
class CoverageModel {
  final bool hasAddress;
  final bool isCovered;

  CoverageModel({required this.hasAddress, required this.isCovered});

  factory CoverageModel.fromJson(Map<String, dynamic> json) {
    return CoverageModel(
      hasAddress: json['has_address'] ?? false,
      isCovered: json['is_covered'] ?? false,
    );
  }

  bool get isValid => hasAddress && isCovered;
}