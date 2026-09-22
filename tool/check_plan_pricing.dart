// Dependency-free pricing contract checks: dart tool/check_plan_pricing.dart
import '../lib/models/box_plan.dart';
import '../lib/models/recipe_box.dart';

void main() {
  var checks = 0;
  void check(bool value, String message) {
    if (!value) throw StateError(message);
    checks++;
  }

  const monthly = BoxQuote(plan: BoxPlan.monthly, count: 20, subtotal: 128000);
  check(monthly.total == 115200, 'Monthly total uses 10% discount.');
  check(monthly.delivery == 0, 'Monthly delivery threshold.');
  const day = BoxQuote(plan: BoxPlan.day, count: 3, subtotal: 16000);
  check(day.total == 17000, 'Day bundle adds one delivery.');
  const weekly = BoxQuote(plan: BoxPlan.weekly, count: 5, subtotal: 32000);
  check(weekly.discount == 1600, 'Weekly discount is 5%.');
  const incomplete = BoxQuote(plan: BoxPlan.weekly, count: 4, subtotal: 25600);
  check(
    !incomplete.complete && incomplete.discount == 0,
    'Incomplete bundles have no discount.',
  );
  const empty = BoxQuote(plan: BoxPlan.single, count: 0, subtotal: 0);
  check(empty.total == 0, 'Empty baskets have no delivery fee.');
  for (final subtotal in [19999, 20000]) {
    final quote = BoxQuote(plan: BoxPlan.single, count: 3, subtotal: subtotal);
    check(
      quote.delivery == (subtotal < 20000 ? 1000 : 0),
      'Free delivery boundary.',
    );
  }
  check(
    BoxPlan.monthly.slots * 4 == BoxPlan.monthly.boxes,
    'Monthly schedule repeats four weeks.',
  );
  check(kitchenKit.length == 4, 'All four measuring tools are listed.');
  check(
    recipeBoxes.map((b) => b.id).toSet().length == recipeBoxes.length,
    'Unique recipe IDs.',
  );
  check(
    recipeBoxes.any((b) => b.category == 'Breakfast'),
    'Full day includes a breakfast choice.',
  );
  for (final box in recipeBoxes) {
    check(
      box.priceFils > 0 && box.steps.isNotEmpty && box.ingredients.isNotEmpty,
      'Complete recipe: ${box.id}',
    );
  }
  print('$checks pricing and catalog checks passed.');
}
