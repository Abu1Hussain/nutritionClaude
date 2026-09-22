import 'package:flutter_test/flutter_test.dart';
import 'package:nutrition_app/data/app_data.dart';
import 'package:nutrition_app/models/meal.dart';
import 'package:nutrition_app/services/app_state.dart';

String _dateKeyDaysAgo(int days) {
  final d = DateTime.now().subtract(Duration(days: days));
  return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

void main() {
  group('allergen filtering', () {
    test('a recipe with no conflicting allergens is used as-is', () {
      final appState = AppState();
      expect(appState.effectiveRecipe('breakfast')!.key, 'breakfast_oat_bowl');
      expect(appState.recipeFallbackApplied('breakfast'), isFalse);
      expect(appState.hasNoSafeOption('breakfast'), isFalse);
    });

    test('stating a conflicting allergy substitutes a safe alternative, never the conflicting one', () {
      final appState = AppState();
      appState.savePreferences(dislikes: const [], allergies: {Allergen.dairy, Allergen.treeNuts});

      // Default breakfast (oat bowl) contains dairy + tree nuts -> must be swapped.
      final effective = appState.effectiveRecipe('breakfast')!;
      expect(effective.allergens.any({Allergen.dairy, Allergen.treeNuts}.contains), isFalse);
      expect(effective.key, 'breakfast_veggie_eggs');
      expect(appState.recipeFallbackApplied('breakfast'), isTrue);
    });

    test('manually selecting a recipe that conflicts with a stated allergy is still blocked at generation time', () {
      final appState = AppState();
      appState.savePreferences(dislikes: const [], allergies: {Allergen.fish});
      // Force-select the fish-containing dinner option directly (bypassing the UI guard).
      appState.selectedRecipeKey['dinner'] = 'dinner_salmon_bulgur';

      final effective = appState.effectiveRecipe('dinner')!;
      expect(effective.allergens.contains(Allergen.fish), isFalse);
      expect(appState.recipeFallbackApplied('dinner'), isTrue);
    });

    test('effectiveRecipes never returns a recipe conflicting with any stated allergy, across all meal types', () {
      final appState = AppState();
      appState.savePreferences(dislikes: const [], allergies: Allergen.values.toSet());
      final recipes = appState.effectiveRecipes(true);
      for (final entry in recipes.entries) {
        final recipe = entry.value;
        if (recipe == null) continue; // no safe option -- handled by hasNoSafeOption, not a conflict
        expect(
          recipe.allergens.any(appState.allergies.contains),
          isFalse,
          reason: '${entry.key} resolved to ${recipe.key} which conflicts with a stated allergy',
        );
      }
    });

    test('when every option for a meal type conflicts, effectiveRecipe returns null rather than an unsafe pick', () {
      final appState = AppState();
      // Breakfast's two options are tagged {dairy, treeNuts} and {eggs, wheat};
      // stating all four leaves no safe breakfast in this demo's recipe set.
      appState.savePreferences(
        dislikes: const [],
        allergies: {Allergen.dairy, Allergen.treeNuts, Allergen.eggs, Allergen.wheat},
      );
      expect(appState.effectiveRecipe('breakfast'), isNull);
      expect(appState.hasNoSafeOption('breakfast'), isTrue);
      // Lunch/dinner/dessert each have an allergen-free option, so they're unaffected.
      expect(appState.hasNoSafeOption('lunch'), isFalse);
      expect(appState.hasNoSafeOption('dinner'), isFalse);
      expect(appState.hasNoSafeOption('dessert'), isFalse);
    });
  });

  group('smart 7-day default', () {
    test('does nothing before a full 7-day run of the same choice', () {
      final appState = AppState();
      for (int i = 1; i <= 6; i++) {
        appState.mealChoiceHistory[_dateKeyDaysAgo(i)] = {'breakfast': 'breakfast_veggie_eggs'};
      }
      appState.applySmartDefaultsIfNewDay();
      expect(appState.selectedRecipeKey['breakfast'], isNot('breakfast_veggie_eggs'));
    });

    test('adopts the recipe eaten on each of the last 7 days as the new default', () {
      final appState = AppState();
      for (int i = 1; i <= 7; i++) {
        appState.mealChoiceHistory[_dateKeyDaysAgo(i)] = {'breakfast': 'breakfast_veggie_eggs'};
      }
      appState.applySmartDefaultsIfNewDay();
      expect(appState.selectedRecipeKey['breakfast'], 'breakfast_veggie_eggs');
      expect(appState.effectiveRecipe('breakfast')!.key, 'breakfast_veggie_eggs');
    });

    test('a broken streak does not trigger the default', () {
      final appState = AppState();
      for (int i = 1; i <= 7; i++) {
        // Day 4 back breaks the streak.
        appState.mealChoiceHistory[_dateKeyDaysAgo(i)] = {
          'breakfast': i == 4 ? 'breakfast_oat_bowl' : 'breakfast_veggie_eggs',
        };
      }
      appState.applySmartDefaultsIfNewDay();
      expect(appState.selectedRecipeKey['breakfast'], isNot('breakfast_veggie_eggs'));
    });

    test('is idempotent for the same day and records a history entry for today', () {
      final appState = AppState();
      appState.applySmartDefaultsIfNewDay();
      final today = _dateKeyDaysAgo(0);
      expect(appState.mealChoiceHistory.containsKey(today), isTrue);
      final recordedBefore = Map<String, String>.from(appState.mealChoiceHistory[today]!);

      appState.setSelectedRecipe('breakfast', 'breakfast_veggie_eggs');
      appState.applySmartDefaultsIfNewDay(); // should no-op, already recorded today
      expect(appState.mealChoiceHistory[today]!['breakfast'], 'breakfast_veggie_eggs');
      expect(recordedBefore['breakfast'], isNot('breakfast_veggie_eggs'));
    });
  });

  group('sponsor deals', () {
    test('coupon supply is tracked via redemptions and blocks over-redemption', () {
      final appState = AppState();
      final deal = sponsorDeals.first;
      final reward = sponsoredRewards.firstWhere((r) => r.sponsorId == deal.id);

      // Give the user a huge coin balance by logging a lot of steps.
      appState.stepsLog['seed'] = 1000000000;
      expect(appState.coinBalance, greaterThan(reward.cost * (deal.couponsPerPeriod + 1)));

      for (int i = 0; i < deal.couponsPerPeriod; i++) {
        expect(appState.redeem(reward), isTrue, reason: 'redemption $i of ${deal.couponsPerPeriod} should succeed');
      }
      expect(appState.sponsorRemainingCoupons(deal), 0);
      expect(appState.redeem(reward), isFalse, reason: 'coupons are sold out for this period');
    });
  });
}
