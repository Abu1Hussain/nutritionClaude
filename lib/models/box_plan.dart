/// Sample commercial terms. All prices are integer Bahraini fils.
enum BoxPlan {
  single('وجبة واحدة', 'جرّب سفرة على راحتك', 1, 1, 0),
  day('يوم كامل', 'فطور وغداء وعشاء', 3, 1, 0),
  weekly('اشتراك أسبوعي', 'وجبة يوميًا • ٥ أيام', 5, 1, 5),
  monthly('اشتراك شهري', '٥ وجبات أسبوعيًا • ٤ أسابيع', 20, 4, 10);

  const BoxPlan(
    this.title,
    this.subtitle,
    this.boxes,
    this.deliveries,
    this.discountPercent,
  );
  final String title, subtitle;
  final int boxes, deliveries, discountPercent;
  bool get isSubscription => this == weekly || this == monthly;
  int get slots => this == monthly ? 5 : boxes;
}

const kitchenKit = [
  'ملاعق قياس',
  'سكوب للمقادير',
  'ميزان حرارة للطعام',
  'ميزان طعام',
];
const kitchenKitDescription =
    'طقم البداية يشمل ملاعق قياس، سكوب، ميزان حرارة للطعام وميزان طعام. يُرسل مرة واحدة مع أول توصيل في الباقة.';

/// One pricing policy shared by plan previews, the basket and order snapshots.
/// [subtotal] is before discounts; free delivery starts at BD 20 per cycle.
class BoxQuote {
  final BoxPlan plan;
  final int count, subtotal;
  const BoxQuote({
    required this.plan,
    required this.count,
    required this.subtotal,
  });
  bool get complete => plan == BoxPlan.single || count == plan.boxes;
  int get discount => complete ? subtotal * plan.discountPercent ~/ 100 : 0;
  int get delivery =>
      count == 0 || subtotal >= 20000 ? 0 : 1000 * plan.deliveries;
  int get total => subtotal - discount + delivery;
}
