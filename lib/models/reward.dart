class Reward {
  final String id;
  final String name;
  final String category;
  final int cost; // Fit Coins
  final String icon; // emoji
  final String? sponsorId; // links to a SponsorDeal, null for the standard catalog

  const Reward({
    required this.id,
    required this.name,
    required this.category,
    required this.cost,
    required this.icon,
    this.sponsorId,
  });
}

class Redemption {
  final String id;
  final String rewardId;
  final String name;
  final int cost;
  final DateTime timestamp;

  const Redemption({
    required this.id,
    required this.rewardId,
    required this.name,
    required this.cost,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'rewardId': rewardId,
        'name': name,
        'cost': cost,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Redemption.fromJson(Map<String, dynamic> json) => Redemption(
        id: json['id'] as String,
        rewardId: json['rewardId'] as String,
        name: json['name'] as String,
        cost: (json['cost'] as num).toInt(),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

/// A brand's paid sponsorship of a batch of in-app reward coupons for one
/// period (e.g. one calendar month). This is a local, unaudited prototype:
/// no real payment is processed and no real coupon codes are issued --
/// redemption just deducts Fit Coins and decrements the demo coupon count.
class SponsorDeal {
  final String id;
  final String companyName;
  final double feeAmount;
  final String feeCurrency;
  final int couponsPerPeriod;
  final DateTime startDate;
  final DateTime endDate;
  final String rewardId; // the Reward this sponsorship funds

  const SponsorDeal({
    required this.id,
    required this.companyName,
    required this.feeAmount,
    required this.feeCurrency,
    required this.couponsPerPeriod,
    required this.startDate,
    required this.endDate,
    required this.rewardId,
  });

  bool get isActive {
    final now = DateTime.now();
    return !now.isBefore(startDate) && !now.isAfter(endDate);
  }
}
