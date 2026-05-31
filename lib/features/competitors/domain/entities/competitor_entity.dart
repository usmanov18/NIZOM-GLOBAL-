import 'package:equatable/equatable.dart';

class CompetitorEntity extends Equatable {
  final String id;
  final String name;
  final int marketShare;
  final int avgPrice;
  final int ourPrice;
  final List<String> strengths;
  final List<String> weaknesses;

  const CompetitorEntity({
    required this.id,
    required this.name,
    required this.marketShare,
    required this.avgPrice,
    required this.ourPrice,
    required this.strengths,
    required this.weaknesses,
  });

  double get priceDifferencePercent {
    if (avgPrice == 0) return 0;
    return (ourPrice - avgPrice) / avgPrice * 100;
  }

  factory CompetitorEntity.fromJson(Map<String, dynamic> json) {
    return CompetitorEntity(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      marketShare: json['marketShare'] ?? json['market_share'] ?? 0,
      avgPrice: json['avgPrice'] ?? json['avg_price'] ?? 0,
      ourPrice: json['ourPrice'] ?? json['our_price'] ?? 0,
      strengths: List<String>.from(json['strengths'] ?? const []),
      weaknesses: List<String>.from(json['weaknesses'] ?? const []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'market_share': marketShare,
        'avg_price': avgPrice,
        'our_price': ourPrice,
        'strengths': strengths,
        'weaknesses': weaknesses,
      };

  @override
  List<Object?> get props => [id, name, marketShare, avgPrice, ourPrice];
}
