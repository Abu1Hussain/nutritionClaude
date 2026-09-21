import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_data.dart';
import '../models/food_item.dart';
import '../models/meal.dart';
import '../models/nutrition_target.dart';
import '../services/app_state.dart';
import '../services/meal_planner.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/meal_preferences_form.dart';
import '../widgets/share_dialog.dart';

class MealPlanScreen extends StatelessWidget {
  final Map<int, FoodItem> foodById;
  const MealPlanScreen({super.key, required this.foodById});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, appState, _) {
      final p = context.palette;
      final t = appState.target;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Illustrative meal plan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              'An example three-meal structure sized to your most recently calculated calorie target.',
              style: TextStyle(color: p.textMuted),
            ),
            const SizedBox(height: 20),
            if (t == null)
              SectionCard(
                child: Text(
                  'Calculate your target in the Calculator section first. The meal plan will use your most '
                  'recently calculated result.',
                  style: TextStyle(color: p.textMuted),
                ),
              )
            else if (!appState.preferencesConfigured)
              MealPreferencesForm(
                initialDislikes: appState.dislikedFoods,
                initialAllergies: appState.allergies,
                onSave: (dislikes, allergies) =>
                    appState.savePreferences(dislikes: dislikes, allergies: allergies),
              )
            else
              _MealPlanContent(foodById: foodById, appState: appState, calories: t.calories),
          ],
        ),
      );
    });
  }
}

class _MealPlanContent extends StatelessWidget {
  final Map<int, FoodItem> foodById;
  final AppState appState;
  final int calories;

  const _MealPlanContent({required this.foodById, required this.appState, required this.calories});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final percentages = appState.currentMealPercentages();
    final recipesWithNulls = appState.effectiveRecipes(appState.dessertEnabled);
    final noSafeOptionTypes = recipesWithNulls.entries.where((e) => e.value == null).map((e) => e.key).toList();
    final safeRecipes = <String, MealRecipeSpec>{
      for (final e in recipesWithNulls.entries)
        if (e.value != null) e.key: e.value!,
    };
    final safePercentages = {for (final t in safeRecipes.keys) t: percentages[t]!};
    final meals = generateMealPlan(calories, appState.dessertEnabled, foodById, safePercentages, safeRecipes);
    final fallbackTypes =
        recipesWithNulls.keys.where(appState.recipeFallbackApplied).where((t) => !noSafeOptionTypes.contains(t)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('Daily calorie target', style: TextStyle(color: p.textMuted)),
                  const SizedBox(width: 10),
                  Text('${fmtInt(calories)} kcal',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800, color: p.accent, fontFamily: 'Outfit')),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Portions below adapt automatically to your latest calculation. Tap the pencil on a meal to '
                'edit its calories — the rest of the day rebalances automatically. Recalculate in the '
                'Calculator section to update the overall target.',
                style: TextStyle(color: p.textDim, fontSize: 12.5),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: appState.dessertEnabled,
                onChanged: (v) => appState.setDessertEnabled(v),
                title: const Text('Include optional dessert'),
              ),
              Wrap(
                spacing: 4,
                children: [
                  if (appState.hasCustomMealSplit)
                    TextButton(
                      key: const Key('reset-meal-split'),
                      onPressed: appState.resetMealPercentages,
                      child: const Text('Reset to default meal split'),
                    ),
                  TextButton(
                    onPressed: () => _openPreferencesDialog(context, appState),
                    child: const Text('Edit meal preferences'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (fallbackTypes.isNotEmpty) ...[
          const SizedBox(height: 12),
          NoticeBanner(
            kind: NoticeKind.warning,
            text: 'Switched ${fallbackTypes.map((t) => mealTypeLabels[t] ?? t).join(', ')} to a different '
                'recipe automatically because your usual choice conflicts with a stated allergy.',
          ),
        ],
        if (noSafeOptionTypes.isNotEmpty) ...[
          const SizedBox(height: 12),
          NoticeBanner(
            kind: NoticeKind.error,
            text: 'No ${noSafeOptionTypes.map((t) => mealTypeLabels[t] ?? t).join(', ')} recipe in this demo '
                "avoids all of your stated allergies, so it's left out below rather than shown unsafe. Your "
                'daily calorie total will fall short by that amount -- adjust your allergies or add your own '
                'meal in Foods/Meal Log instead.',
          ),
        ],
        const SizedBox(height: 20),
        LayoutBuilder(builder: (context, constraints) {
          final cols = responsiveColumns(constraints.maxWidth, desktop: 3, tablet: 2, mobile: 1);
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.72,
            children: [
              for (final m in meals)
                _MealCard(
                  meal: m,
                  onEdit: () => showEditMealCaloriesDialog(context, m, calories, appState),
                  onSwap: mealRecipeOptions[m.type]!.length > 1
                      ? () => _openSwapDialog(context, appState, m.type)
                      : null,
                ),
              for (final t in noSafeOptionTypes) _NoSafeOptionCard(mealType: t),
            ],
          );
        }),
        const SizedBox(height: 20),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your day at a glance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'Meal totals below reflect total sugar naturally present in foods -- a different measurement '
                'from the added-sugar limit shown in the Calculator section.',
                style: TextStyle(color: p.textMuted, fontSize: 12.5),
              ),
              const SizedBox(height: 12),
              _DayAtGlance(meals: meals, target: appState.target!),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Explore meals on Calo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                "Browse Calo's official menu, open or download the Calo application, copy your NutriVision "
                'targets, and manually enter appropriate targets into Calo where supported.',
                style: TextStyle(color: p.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton(
                    onPressed: () => launchUrl(Uri.parse(caloMenuUrl), mode: LaunchMode.externalApplication),
                    child: const Text('Open Calo menu'),
                  ),
                  OutlinedButton(
                    onPressed: () => launchUrl(Uri.parse(caloAppUrl), mode: LaunchMode.externalApplication),
                    child: const Text('Open Calo app'),
                  ),
                  OutlinedButton(
                    onPressed: () => showShareTargetsDialog(context, appState.target!),
                    child: const Text('Copy my targets'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'External service — no automatic account connection or data synchronization. NutriVision '
                'is not affiliated with Calo. No personal or nutrition data is sent automatically.',
                style: TextStyle(color: p.textDim, fontSize: 11.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shown instead of a meal card when every recipe option for a meal type
/// conflicts with a stated allergy. Deliberately does not fabricate a
/// meal -- this is a safety-relevant gap in the demo's recipe set, not
/// something to paper over.
class _NoSafeOptionCard extends StatelessWidget {
  final String mealType;
  const _NoSafeOptionCard({required this.mealType});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.errorBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.errorBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: p.error, borderRadius: BorderRadius.circular(999)),
            child: Text(mealTypeLabels[mealType] ?? mealType,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          const SizedBox(height: 10),
          Icon(Icons.no_meals_outlined, color: p.error, size: 28),
          const SizedBox(height: 8),
          Text('No safe option', style: TextStyle(fontWeight: FontWeight.w700, color: p.errorFg)),
          const SizedBox(height: 6),
          Text(
            "None of this demo's ${(mealTypeLabels[mealType] ?? mealType).toLowerCase()} recipes avoid all "
            'of your stated allergies.',
            style: TextStyle(color: p.errorFg, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onEdit;
  final VoidCallback? onSwap;
  const _MealCard({required this.meal, required this.onEdit, this.onSwap});

  Widget _nutVal(AppPalette p, double? v, String unit) {
    if (v == null) {
      return Text('Not available', style: TextStyle(color: p.textDim, fontStyle: FontStyle.italic, fontSize: 12));
    }
    return Text('${fmtNum1(v)}$unit', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final pct = (meal.dailyPercentage * 100).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(mealTypeImages[meal.type] ?? '', width: 32, height: 32),
              const SizedBox(width: 8),
              Expanded(
                child: Text(meal.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: p.primary, borderRadius: BorderRadius.circular(999)),
                child: Text(mealTypeLabels[meal.type] ?? meal.type,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$pct% of day', style: TextStyle(color: p.textDim, fontSize: 11.5)),
                  if (onSwap != null)
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: IconButton(
                        key: Key('swap-meal-${meal.type}'),
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        tooltip: 'Swap ${mealTypeLabels[meal.type] ?? meal.type} recipe',
                        icon: Icon(Icons.swap_horiz, color: p.textMuted),
                        onPressed: onSwap,
                      ),
                    ),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: IconButton(
                      key: Key('edit-meal-${meal.type}'),
                      padding: EdgeInsets.zero,
                      iconSize: 16,
                      tooltip: 'Edit ${mealTypeLabels[meal.type] ?? meal.type} calories',
                      icon: Icon(Icons.edit_outlined, color: p.textMuted),
                      onPressed: onEdit,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            meal.totals.calories != null ? '${fmtInt(meal.totals.calories)} kcal' : 'Not available',
            style:
                TextStyle(color: p.accent, fontWeight: FontWeight.w800, fontSize: 18, fontFamily: 'Outfit'),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: p.bgSurfaceMuted, borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                for (final ing in meal.ingredients)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(ing.name,
                              style: TextStyle(color: p.textMuted, fontSize: 12.5),
                              overflow: TextOverflow.ellipsis),
                        ),
                        Text(ing.grams != null ? '${ing.grams} g' : 'Not available',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.6,
              children: [
                _statTile(p, 'Protein', _nutVal(p, meal.totals.protein, ' g')),
                _statTile(p, 'Carbs', _nutVal(p, meal.totals.carbs, ' g')),
                _statTile(p, 'Fat', _nutVal(p, meal.totals.fat, ' g')),
                _statTile(p, 'Total sugar', _nutVal(p, meal.totals.sugar, ' g')),
                _statTile(p, 'Sat. fat', _nutVal(p, meal.totals.satFat, ' g')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile(AppPalette p, String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.only(right: 6, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 9.5, color: p.textDim, letterSpacing: 0.3)),
          value,
        ],
      ),
    );
  }
}

class _DayAtGlance extends StatelessWidget {
  final List<Meal> meals;
  final NutritionTarget target;
  const _DayAtGlance({required this.meals, required this.target});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    double? sum(double? Function(Meal) pick) {
      double total = 0;
      for (final m in meals) {
        final v = pick(m);
        if (v == null) return null;
        total += v;
      }
      return (total * 10).round() / 10;
    }

    final rows = <(String, double?, num?, String)>[
      ('Calories', sum((m) => m.totals.calories), target.calories, 'kcal'),
      ('Protein', sum((m) => m.totals.protein), target.proteinGrams, 'g'),
      ('Carbohydrates', sum((m) => m.totals.carbs), target.carbohydrateGrams, 'g'),
      ('Fat', sum((m) => m.totals.fat), target.fatGrams, 'g'),
      ('Total sugar (from meals)', sum((m) => m.totals.sugar), null, 'g'),
      ('Saturated fat', sum((m) => m.totals.satFat), target.saturatedFatLimitGrams, 'g (limit)'),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 2, child: Text('Nutrient', style: TextStyle(color: p.textDim, fontSize: 11))),
            Expanded(
                child: Text('Meal total',
                    textAlign: TextAlign.right, style: TextStyle(color: p.textDim, fontSize: 11))),
            Expanded(
                child: Text('Daily target',
                    textAlign: TextAlign.right, style: TextStyle(color: p.textDim, fontSize: 11))),
          ],
        ),
        Divider(color: p.border),
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(row.$1, style: TextStyle(color: p.textMuted, fontSize: 13))),
                Expanded(
                  child: Text(
                    row.$2 == null ? 'Not available' : '${fmtNum1(row.$2)} ${row.$4.replaceAll(' (limit)', '')}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Text(
                    row.$3 == null ? '—' : '${fmtInt(row.$3)} ${row.$4}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Lets the user set a new calorie target for one meal. The rest of the
/// day's meals are rescaled proportionally by [AppState.setMealPercentage]
/// so the whole day still adds up to the daily calorie target.
Future<void> showEditMealCaloriesDialog(
  BuildContext context,
  Meal meal,
  int dailyCalories,
  AppState appState,
) {
  final label = mealTypeLabels[meal.type] ?? meal.type;
  final currentCalories = (dailyCalories * meal.dailyPercentage).round();
  final ctrl = TextEditingController(text: currentCalories.toString());
  final minCal = (dailyCalories * 0.05).round();
  final maxCal = (dailyCalories * 0.80).round();

  return showDialog<void>(
    context: context,
    builder: (context) {
      String? error;
      return StatefulBuilder(builder: (context, setState) {
        final p = context.palette;
        return AlertDialog(
          backgroundColor: p.bgCard,
          title: Text('Edit $label calories'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "The rest of today's meals will automatically adjust to keep your "
                '${fmtInt(dailyCalories)} kcal daily total.',
                style: TextStyle(color: p.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: '$label calories (kcal)',
                  helperText: 'Between ${fmtInt(minCal)} and ${fmtInt(maxCal)} kcal',
                  errorText: error,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final val = int.tryParse(ctrl.text.trim());
                if (val == null || val < minCal || val > maxCal) {
                  setState(() => error = 'Enter a value between ${fmtInt(minCal)} and ${fmtInt(maxCal)} kcal.');
                  return;
                }
                appState.setMealPercentage(meal.type, val / dailyCalories);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      });
    },
  );
}

/// Reopens the dislikes/allergies form so the user can revise it after the
/// initial required setup.
Future<void> _openPreferencesDialog(BuildContext context, AppState appState) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: MealPreferencesForm(
          initialDislikes: appState.dislikedFoods,
          initialAllergies: appState.allergies,
          onSave: (dislikes, allergies) {
            appState.savePreferences(dislikes: dislikes, allergies: allergies);
            Navigator.of(context).pop();
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      ),
    ),
  );
}

/// Lets the user pick which recipe is used for one meal type. Options that
/// conflict with a stated allergy are shown but disabled, since
/// [AppState.effectiveRecipes] would refuse to use them anyway.
Future<void> _openSwapDialog(BuildContext context, AppState appState, String mealType) {
  final options = mealRecipeOptions[mealType]!;
  final currentKey = appState.selectedRecipeKey[mealType] ?? defaultRecipeFor(mealType).key;

  return showDialog<void>(
    context: context,
    builder: (context) {
      final p = context.palette;
      return AlertDialog(
        backgroundColor: p.bgCard,
        title: Text('Choose ${mealTypeLabels[mealType] ?? mealType} recipe'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final r in options)
                Builder(builder: (context) {
                  final blocked = r.allergens.any(appState.allergies.contains);
                  final isSelected = r.key == currentKey;
                  return ListTile(
                    enabled: !blocked,
                    leading: Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: blocked ? p.textDim : (isSelected ? p.accent : p.textMuted),
                    ),
                    onTap: blocked
                        ? null
                        : () {
                            appState.setSelectedRecipe(mealType, r.key);
                            Navigator.of(context).pop();
                          },
                    title: Text(r.name),
                    subtitle: r.allergens.isEmpty
                        ? const Text('No major allergens tagged')
                        : Text(
                            'Contains: ${r.allergens.map((a) => a.label).join(', ')}',
                            style: TextStyle(color: blocked ? p.error : null),
                          ),
                  );
                }),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      );
    },
  );
}
