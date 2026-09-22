import 'food_item.dart';

/// Common allergens/intolerances used to tag recipes and filter the meal
/// plan. Kept as a fixed, safety-relevant list separate from free-text
/// "dislikes" (see [MealPreferences]).
enum Allergen { dairy, eggs, fish, shellfish, treeNuts, peanuts, wheat, soy }

extension AllergenLabel on Allergen {
  String get label {
    switch (this) {
      case Allergen.dairy:
        return 'Dairy';
      case Allergen.eggs:
        return 'Eggs';
      case Allergen.fish:
        return 'Fish';
      case Allergen.shellfish:
        return 'Shellfish';
      case Allergen.treeNuts:
        return 'Tree nuts';
      case Allergen.peanuts:
        return 'Peanuts';
      case Allergen.wheat:
        return 'Wheat/gluten';
      case Allergen.soy:
        return 'Soy';
    }
  }
}

class MealIngredientSpec {
  final int foodId;
  final String label;
  final double share; // fraction of the meal's calories, shares within a meal sum to 1.0

  const MealIngredientSpec({required this.foodId, required this.label, required this.share});
}

/// One selectable recipe for a given meal type (e.g. two different
/// breakfast options). [key] must be unique across all recipes.
class MealRecipeSpec {
  final String key;
  final String name;
  final Set<Allergen> allergens;
  final List<MealIngredientSpec> ingredients;

  const MealRecipeSpec({
    required this.key,
    required this.name,
    required this.allergens,
    required this.ingredients,
  });
}

class MealIngredientResult {
  final String name;
  final int? grams;
  final FoodItem? food;

  const MealIngredientResult({required this.name, required this.grams, required this.food});
}

class MealTotals {
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final double? sugar;
  final double? satFat;

  const MealTotals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sugar,
    required this.satFat,
  });
}

class Meal {
  final String type; // breakfast | lunch | dinner | dessert
  final String name;
  final double dailyPercentage;
  final List<MealIngredientResult> ingredients;
  final MealTotals totals;

  const Meal({
    required this.type,
    required this.name,
    required this.dailyPercentage,
    required this.ingredients,
    required this.totals,
  });
}
