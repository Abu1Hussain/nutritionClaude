/// A single food record from the USDA SR Legacy reference dataset.
/// All nutrient values are per 100 g of the edible portion. A null value
/// means the nutrient was not reported for that food -- it is not zero.
class FoodItem {
  final int id;
  final String name;
  final String category;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final double? sugar;
  final double? satFat;

  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sugar,
    required this.satFat,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    double? num_(dynamic v) => v == null ? null : (v as num).toDouble();
    return FoodItem(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown food',
      category: json['category'] as String? ?? '',
      calories: num_(json['calories']),
      protein: num_(json['protein']),
      carbs: num_(json['carbs']),
      fat: num_(json['fat']),
      sugar: num_(json['sugar']),
      satFat: num_(json['satFat']),
    );
  }
}
