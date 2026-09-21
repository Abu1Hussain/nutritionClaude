import 'package:flutter_test/flutter_test.dart';
import 'package:nutrition_app/data/app_data.dart';
import 'package:nutrition_app/models/food_item.dart';
import 'package:nutrition_app/models/meal.dart';
import 'package:nutrition_app/services/meal_planner.dart';

Map<String, MealRecipeSpec> _defaultRecipes(bool includeDessert) {
  final types = includeDessert ? ['breakfast', 'lunch', 'dinner', 'dessert'] : ['breakfast', 'lunch', 'dinner'];
  return {for (final t in types) t: defaultRecipeFor(t)};
}

/// A minimal food map covering exactly the ids referenced by mealRecipes,
/// so these tests don't depend on the real 7,793-item bundled dataset.
Map<int, FoodItem> _testFoods() {
  final data = <int, Map<String, double?>>{
    170887: {'calories': 56, 'protein': 5.73, 'carbs': 7.68, 'fat': 0.18, 'sugar': 7.68, 'satFat': 0.116},
    173904: {'calories': 379, 'protein': 13.2, 'carbs': 67.7, 'fat': 6.52, 'sugar': 0.99, 'satFat': 1.11},
    171711: {'calories': 57, 'protein': 0.74, 'carbs': 14.5, 'fat': 0.33, 'sugar': 9.96, 'satFat': 0.028},
    170567: {'calories': 579, 'protein': 21.2, 'carbs': 21.6, 'fat': 49.9, 'sugar': 4.35, 'satFat': 3.8},
    171477: {'calories': 165, 'protein': 31, 'carbs': 0, 'fat': 3.57, 'sugar': 0, 'satFat': 1.01},
    169704: {'calories': 123, 'protein': 2.74, 'carbs': 25.6, 'fat': 0.97, 'sugar': 0.24, 'satFat': 0.26},
    169967: {'calories': 35, 'protein': 2.38, 'carbs': 7.18, 'fat': 0.41, 'sugar': 1.39, 'satFat': 0.079},
    170287: {'calories': 83, 'protein': 3.08, 'carbs': 18.6, 'fat': 0.24, 'sugar': 0.1, 'satFat': 0.042},
    175168: {'calories': 206, 'protein': 22.1, 'carbs': 0, 'fat': 12.4, 'sugar': 0, 'satFat': 2.4},
    167762: {'calories': 32, 'protein': 0.67, 'carbs': 7.68, 'fat': 0.3, 'sugar': 4.89, 'satFat': 0.015},
    170273: {'calories': 598, 'protein': 7.79, 'carbs': 45.9, 'fat': 42.6, 'sugar': 24, 'satFat': 24.5},
  };
  return data.map((id, n) => MapEntry(
        id,
        FoodItem(
          id: id,
          name: 'food-$id',
          category: 'test',
          calories: n['calories'],
          protein: n['protein'],
          carbs: n['carbs'],
          fat: n['fat'],
          sugar: n['sugar'],
          satFat: n['satFat'],
        ),
      ));
}

void main() {
  final foods = _testFoods();

  test('plan without dessert has 3 meals whose percentages sum to 100%', () {
    final meals = generateMealPlan(2594, false, foods, mealPctNoDessert, _defaultRecipes(false));
    expect(meals.length, 3);
    expect(meals.map((m) => m.type), ['breakfast', 'lunch', 'dinner']);
    final pctSum = meals.fold(0.0, (sum, m) => sum + m.dailyPercentage);
    expect(pctSum, closeTo(1.0, 0.001));
  });

  test('plan with dessert has 4 meals whose percentages sum to 100%', () {
    final meals = generateMealPlan(2594, true, foods, mealPctWithDessert, _defaultRecipes(true));
    expect(meals.length, 4);
    expect(meals.last.type, 'dessert');
    final pctSum = meals.fold(0.0, (sum, m) => sum + m.dailyPercentage);
    expect(pctSum, closeTo(1.0, 0.001));
  });

  test('meal calorie totals are reasonably close to their allocation', () {
    final meals = generateMealPlan(2594, false, foods, mealPctNoDessert, _defaultRecipes(false));
    for (final meal in meals) {
      final target = 2594 * meal.dailyPercentage;
      expect(meal.totals.calories, isNotNull);
      expect((meal.totals.calories! - target).abs(), lessThan(target * 0.05));
    }
  });

  test('a missing ingredient nutrient is reported as null, not zero', () {
    final incompleteFoods = Map<int, FoodItem>.from(foods);
    incompleteFoods[170567] = const FoodItem(
      id: 170567,
      name: 'almonds-missing-sugar',
      category: 'test',
      calories: 579,
      protein: 21.2,
      carbs: 21.6,
      fat: 49.9,
      sugar: null, // not reported
      satFat: 3.8,
    );
    final meals = generateMealPlan(2594, false, incompleteFoods, mealPctNoDessert, _defaultRecipes(false));
    final lunch = meals.firstWhere((m) => m.type == 'lunch');
    expect(lunch.totals.sugar, isNull);
    expect(lunch.totals.protein, isNotNull); // other nutrients still computed
  });

  test('daily step target and coin conversion constants match spec', () {
    expect(dailyStepTarget, 5000);
    expect(stepsPerCoin, 1000);
  });
}
