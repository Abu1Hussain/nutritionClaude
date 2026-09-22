import '../data/app_data.dart';
import '../models/food_item.dart';
import '../models/meal.dart';

MealTotals _sumIngredientNutrients(List<MealIngredientResult> ingredients) {
  double calories = 0, protein = 0, carbs = 0, fat = 0, sugar = 0, satFat = 0;
  bool missingCal = false, missingP = false, missingC = false, missingF = false, missingS = false, missingSf = false;

  for (final ing in ingredients) {
    final food = ing.food;
    final grams = ing.grams;
    if (food == null || grams == null) {
      missingCal = missingP = missingC = missingF = missingS = missingSf = true;
      continue;
    }
    if (food.calories == null) {
      missingCal = true;
    } else {
      calories += food.calories! * grams / 100;
    }
    if (food.protein == null) {
      missingP = true;
    } else {
      protein += food.protein! * grams / 100;
    }
    if (food.carbs == null) {
      missingC = true;
    } else {
      carbs += food.carbs! * grams / 100;
    }
    if (food.fat == null) {
      missingF = true;
    } else {
      fat += food.fat! * grams / 100;
    }
    if (food.sugar == null) {
      missingS = true;
    } else {
      sugar += food.sugar! * grams / 100;
    }
    if (food.satFat == null) {
      missingSf = true;
    } else {
      satFat += food.satFat! * grams / 100;
    }
  }

  double? round1(double v) => (v * 10).round() / 10;

  return MealTotals(
    calories: missingCal ? null : round1(calories),
    protein: missingP ? null : round1(protein),
    carbs: missingC ? null : round1(carbs),
    fat: missingF ? null : round1(fat),
    sugar: missingS ? null : round1(sugar),
    satFat: missingSf ? null : round1(satFat),
  );
}

Meal _buildMeal(String type, double mealCalories, Map<int, FoodItem> foodById, MealRecipeSpec recipe) {
  final ingredients = recipe.ingredients.map((spec) {
    final food = foodById[spec.foodId];
    final kcalPer100 = food?.calories;
    int? grams;
    if (kcalPer100 != null && kcalPer100 > 0) {
      final targetKcal = mealCalories * spec.share;
      grams = (targetKcal * 100 / kcalPer100).round();
      if (grams < 1) grams = 1;
    }
    return MealIngredientResult(name: spec.label, grams: grams, food: food);
  }).toList();

  return Meal(
    type: type,
    name: recipe.name,
    dailyPercentage: 0, // set by caller
    ingredients: ingredients,
    totals: _sumIngredientNutrients(ingredients),
  );
}

/// Builds the meal plan from an explicit percentage split (fractions of
/// [dailyCalories] that sum to 1.0) and an explicit recipe choice per meal
/// type. Pass [mealPctNoDessert] or [mealPctWithDessert] for the default
/// split, or a user-edited split from [AppState.currentMealPercentages].
/// Pass [AppState.effectiveRecipes] for [selectedRecipes] so the plan
/// reflects the user's swapped/learned choices and never violates a
/// stated allergy.
List<Meal> generateMealPlan(
  int dailyCalories,
  bool includeDessert,
  Map<int, FoodItem> foodById,
  Map<String, double> percentages,
  Map<String, MealRecipeSpec> selectedRecipes,
) {
  final order = includeDessert ? ['breakfast', 'lunch', 'dinner', 'dessert'] : ['breakfast', 'lunch', 'dinner'];

  return order.map((type) {
    final pct = percentages[type]!;
    final mealCalories = dailyCalories * pct;
    final recipe = selectedRecipes[type]!;
    final meal = _buildMeal(type, mealCalories, foodById, recipe);
    return Meal(
      type: meal.type,
      name: meal.name,
      dailyPercentage: pct,
      ingredients: meal.ingredients,
      totals: meal.totals,
    );
  }).toList();
}
