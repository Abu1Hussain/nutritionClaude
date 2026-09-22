import 'dart:convert';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_data.dart';
import '../models/logged_meal.dart';
import '../models/meal.dart';
import '../models/measurement_entry.dart';
import '../models/nutrition_target.dart';
import '../models/reward.dart';
import 'nutrition_calculator.dart';

const String _storageKey = 'nutrivision_state_v1';

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String todayKey() => dateKey(DateTime.now());

/// Central, persisted app state. Everything is stored locally on-device via
/// SharedPreferences -- nothing here is sent to a server.
class AppState extends ChangeNotifier {
  NutritionTarget? target;
  bool dessertEnabled = false;
  Map<String, int> stepsLog = {};
  List<Redemption> redemptions = [];
  bool remindersEnabled = false;
  ThemeMode themeMode = ThemeMode.light;

  /// User-edited meal calorie split (type -> fraction of the day), or null
  /// to use the built-in defaults. Keyed by the meal types for the current
  /// dessert setting; cleared automatically if that set changes.
  Map<String, double>? mealPercentOverrides;

  /// The recipe currently selected per meal type (mealType -> recipe key).
  /// Missing entries fall back to [defaultRecipeFor].
  Map<String, String> selectedRecipeKey = {};

  /// Append-only log of which recipe was in effect for each meal type on
  /// each day (date -> mealType -> recipe key), used to notice a repeated
  /// choice and offer it as the new default. Trimmed to the last 60 days.
  Map<String, Map<String, String>> mealChoiceHistory = {};

  List<String> dislikedFoods = [];
  Set<Allergen> allergies = {};
  bool preferencesConfigured = false;

  List<MeasurementEntry> measurements = [];
  String measurementUnit = 'cm'; // 'cm' | 'in'

  List<LoggedMeal> loggedMeals = [];

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        if (data['target'] != null) {
          target = NutritionTarget.fromJson(data['target'] as Map<String, dynamic>);
        }
        dessertEnabled = data['dessertEnabled'] as bool? ?? false;
        remindersEnabled = data['remindersEnabled'] as bool? ?? false;
        themeMode = (data['themeMode'] as String?) == 'dark' ? ThemeMode.dark : ThemeMode.light;

        final overrides = data['mealPercentOverrides'] as Map<String, dynamic>?;
        if (overrides != null) {
          mealPercentOverrides = overrides.map((k, v) => MapEntry(k, (v as num).toDouble()));
        }

        final selRecipes = data['selectedRecipeKey'] as Map<String, dynamic>?;
        if (selRecipes != null) {
          selectedRecipeKey = selRecipes.map((k, v) => MapEntry(k, v as String));
        }

        final history = data['mealChoiceHistory'] as Map<String, dynamic>?;
        if (history != null) {
          mealChoiceHistory = history.map(
            (k, v) => MapEntry(k, (v as Map<String, dynamic>).map((k2, v2) => MapEntry(k2, v2 as String))),
          );
        }

        dislikedFoods = (data['dislikedFoods'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [];
        final allergyNames = (data['allergies'] as List<dynamic>?)?.map((e) => e as String).toSet() ?? {};
        allergies = Allergen.values.where((a) => allergyNames.contains(a.name)).toSet();
        preferencesConfigured = data['preferencesConfigured'] as bool? ?? false;

        measurementUnit = data['measurementUnit'] as String? ?? 'cm';
        final measurementsRaw = data['measurements'] as List<dynamic>?;
        if (measurementsRaw != null) {
          measurements =
              measurementsRaw.map((e) => MeasurementEntry.fromJson(e as Map<String, dynamic>)).toList();
        }

        final loggedMealsRaw = data['loggedMeals'] as List<dynamic>?;
        if (loggedMealsRaw != null) {
          loggedMeals = loggedMealsRaw.map((e) => LoggedMeal.fromJson(e as Map<String, dynamic>)).toList();
        }

        final steps = data['stepsLog'] as Map<String, dynamic>?;
        if (steps != null) {
          stepsLog = steps.map((k, v) => MapEntry(k, (v as num).toInt()));
        }
        final reds = data['redemptions'] as List<dynamic>?;
        if (reds != null) {
          redemptions = reds.map((e) => Redemption.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {
      // Corrupt or unavailable storage - start fresh.
    }
    applySmartDefaultsIfNewDay();
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = {
        'target': target?.toJson(),
        'dessertEnabled': dessertEnabled,
        'remindersEnabled': remindersEnabled,
        'themeMode': themeMode == ThemeMode.light ? 'light' : 'dark',
        'mealPercentOverrides': mealPercentOverrides,
        'selectedRecipeKey': selectedRecipeKey,
        'mealChoiceHistory': mealChoiceHistory,
        'dislikedFoods': dislikedFoods,
        'allergies': allergies.map((a) => a.name).toList(),
        'preferencesConfigured': preferencesConfigured,
        'measurementUnit': measurementUnit,
        'measurements': measurements.map((m) => m.toJson()).toList(),
        'loggedMeals': loggedMeals.map((m) => m.toJson()).toList(),
        'stepsLog': stepsLog,
        'redemptions': redemptions.map((r) => r.toJson()).toList(),
      };
      await prefs.setString(_storageKey, jsonEncode(payload));
    } catch (_) {
      // Storage unavailable (e.g. restricted context) - fail silently.
    }
  }

  /// Runs the calculator pipeline and, on success, stores the result as the
  /// current target used across Meal Plan, Targets, and Share.
  CalculationOutcome calculate({
    required int age,
    required String sex,
    required double heightCm,
    required double weightKg,
    required double activityFactor,
    required String goal,
    required double weeklyRateKg,
  }) {
    final outcome = runCalculation(
      age: age,
      sex: sex,
      heightCm: heightCm,
      weightKg: weightKg,
      activityFactor: activityFactor,
      goal: goal,
      weeklyRateKg: goal == 'maintain' ? 0 : weeklyRateKg,
    );

    if (outcome.ok) {
      target = NutritionTarget(
        age: age,
        sex: sex,
        heightCm: heightCm,
        weightKg: weightKg,
        activityFactor: activityFactor,
        goal: goal,
        weeklyRateKg: goal == 'maintain' ? 0 : weeklyRateKg,
        bmi: outcome.bmi,
        bmr: outcome.bmr.round(),
        tdee: outcome.tdee.round(),
        calories: outcome.calories,
        proteinGrams: outcome.proteinGrams,
        carbohydrateGrams: outcome.carbohydrateGrams,
        fatGrams: outcome.fatGrams,
        addedSugarLimitGrams: outcome.addedSugarLimitGrams,
        saturatedFatLimitGrams: outcome.saturatedFatLimitGrams,
        refWeightMin: outcome.refWeightRange.min,
        refWeightMax: outcome.refWeightRange.max,
      );
      _persist();
      notifyListeners();
    }
    return outcome;
  }

  void setDessertEnabled(bool value) {
    dessertEnabled = value;
    // The set of meals changes (3 <-> 4), so any custom split no longer
    // applies cleanly -- revert to the default split for the new meal set.
    mealPercentOverrides = null;
    _persist();
    notifyListeners();
  }

  /// The meal calorie split currently in effect: the user's custom split if
  /// one is set and still matches today's meal set, otherwise the default.
  Map<String, double> currentMealPercentages() {
    final defaults = dessertEnabled ? mealPctWithDessert : mealPctNoDessert;
    final overrides = mealPercentOverrides;
    if (overrides == null) return defaults;
    if (!setEquals(overrides.keys.toSet(), defaults.keys.toSet())) return defaults;
    return overrides;
  }

  bool get hasCustomMealSplit => mealPercentOverrides != null;

  /// Sets [type]'s share of the day to [newPercentage] (clamped to a
  /// sensible 5%-80% range) and proportionally rescales every other meal so
  /// the whole day still sums to 100%, preserving their relative sizes
  /// relative to each other.
  void setMealPercentage(String type, double newPercentage) {
    final current = Map<String, double>.from(currentMealPercentages());
    if (!current.containsKey(type)) return;

    final clampedNew = newPercentage.clamp(0.05, 0.80);
    final oldPct = current[type]!;
    final otherSum = 1 - oldPct;
    final remaining = 1 - clampedNew;
    final others = current.keys.where((k) => k != type).toList();

    if (otherSum <= 0.0001) {
      for (final k in others) {
        current[k] = remaining / others.length;
      }
    } else {
      for (final k in others) {
        current[k] = current[k]! / otherSum * remaining;
      }
    }
    current[type] = clampedNew;

    mealPercentOverrides = current;
    _persist();
    notifyListeners();
  }

  void resetMealPercentages() {
    mealPercentOverrides = null;
    _persist();
    notifyListeners();
  }

  // ==================================================================
  //  Meal recipe choice, allergen filtering, and the "smart default"
  // ==================================================================

  bool _conflictsWithAllergies(MealRecipeSpec r) => r.allergens.any(allergies.contains);

  /// True if the user's raw selection for [mealType] conflicts with a
  /// stated allergy (so [effectiveRecipes] had to substitute a safe
  /// alternative instead).
  bool recipeFallbackApplied(String mealType) {
    final chosen = recipeByKey(mealType, selectedRecipeKey[mealType]);
    return _conflictsWithAllergies(chosen);
  }

  /// The recipe actually used for [mealType] today: the user's selection,
  /// unless it conflicts with a stated allergy, in which case the first
  /// non-conflicting alternative is used instead. Returns null if every
  /// option for this meal type conflicts with a stated allergy -- callers
  /// must never fall back to a conflicting recipe in that case, only show
  /// that no safe option is available.
  MealRecipeSpec? effectiveRecipe(String mealType) {
    final chosen = recipeByKey(mealType, selectedRecipeKey[mealType]);
    if (!_conflictsWithAllergies(chosen)) return chosen;
    for (final r in mealRecipeOptions[mealType]!) {
      if (!_conflictsWithAllergies(r)) return r;
    }
    return null;
  }

  /// True if no recipe option for [mealType] avoids every stated allergy.
  bool hasNoSafeOption(String mealType) => effectiveRecipe(mealType) == null;

  Map<String, MealRecipeSpec?> effectiveRecipes(bool includeDessert) {
    final types = includeDessert
        ? mealRecipeOptions.keys
        : mealRecipeOptions.keys.where((t) => t != 'dessert');
    return {for (final t in types) t: effectiveRecipe(t)};
  }

  void setSelectedRecipe(String mealType, String recipeKey) {
    selectedRecipeKey[mealType] = recipeKey;
    _recordTodaysChoice(mealType, recipeKey);
    _trimOldMealHistory();
    _persist();
    notifyListeners();
  }

  void _recordTodaysChoice(String mealType, String recipeKey) {
    final today = todayKey();
    mealChoiceHistory.putIfAbsent(today, () => {});
    mealChoiceHistory[today]![mealType] = recipeKey;
  }

  List<String> _last7DatesBefore(String dateKeyStr) {
    final date = DateTime.parse(dateKeyStr);
    return [for (int i = 1; i <= 7; i++) dateKey(date.subtract(Duration(days: i)))];
  }

  /// Once per new day: for each meal type, if the same recipe was chosen on
  /// each of the 7 immediately preceding days, adopt it as today's default
  /// (still editable). Then records today's resulting choice into history.
  void applySmartDefaultsIfNewDay() {
    final today = todayKey();
    if (mealChoiceHistory.containsKey(today)) return;

    final priorDays = _last7DatesBefore(today);
    for (final type in mealRecipeOptions.keys) {
      final choices = priorDays.map((d) => mealChoiceHistory[d]?[type]).toList();
      final allSame = choices.every((c) => c != null && c == choices.first);
      if (allSame) {
        selectedRecipeKey[type] = choices.first!;
      }
      _recordTodaysChoice(type, selectedRecipeKey[type] ?? defaultRecipeFor(type).key);
    }
    _trimOldMealHistory();
  }

  void _trimOldMealHistory() {
    final cutoff = DateTime.now().subtract(const Duration(days: 60));
    mealChoiceHistory.removeWhere((k, v) {
      try {
        return DateTime.parse(k).isBefore(cutoff);
      } catch (_) {
        return true;
      }
    });
  }

  // ==================================================================
  //  Meal plan preferences (dislikes + allergies)
  // ==================================================================

  void savePreferences({required List<String> dislikes, required Set<Allergen> allergies}) {
    dislikedFoods = dislikes;
    this.allergies = allergies;
    preferencesConfigured = true;
    _persist();
    notifyListeners();
  }

  // ==================================================================
  //  Body measurements
  // ==================================================================

  void addMeasurement(MeasurementEntry entry) {
    measurements.add(entry);
    measurements.sort((a, b) => a.date.compareTo(b.date));
    _persist();
    notifyListeners();
  }

  void deleteMeasurement(String id) {
    measurements.removeWhere((m) => m.id == id);
    _persist();
    notifyListeners();
  }

  void setMeasurementUnit(String unit) {
    measurementUnit = unit;
    _persist();
    notifyListeners();
  }

  // ==================================================================
  //  Meal logging
  // ==================================================================

  void addLoggedMeal(LoggedMeal meal) {
    loggedMeals.insert(0, meal);
    _persist();
    notifyListeners();
  }

  void deleteLoggedMeal(String id) {
    loggedMeals.removeWhere((m) => m.id == id);
    _persist();
    notifyListeners();
  }

  // ==================================================================
  //  Theme / reminders
  // ==================================================================

  void setRemindersEnabled(bool value) {
    remindersEnabled = value;
    _persist();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    _persist();
    notifyListeners();
  }

  void toggleThemeMode() {
    setThemeMode(themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  // ==================================================================
  //  Steps / Fit Coins
  // ==================================================================

  int stepsForDate(String key) => stepsLog[key] ?? 0;
  int get todaySteps => stepsForDate(todayKey());

  int coinsForSteps(int steps) => steps ~/ stepsPerCoin;

  int get totalEarnedCoins => stepsLog.values.fold(0, (sum, steps) => sum + coinsForSteps(steps));

  int get totalSpentCoins => redemptions.fold(0, (sum, r) => sum + r.cost);

  int get coinBalance => totalEarnedCoins - totalSpentCoins;

  void logSteps(int steps) {
    stepsLog[todayKey()] = steps;
    _persist();
    notifyListeners();
  }

  // ==================================================================
  //  Rewards / sponsorships
  // ==================================================================

  int sponsorRedeemedCount(String rewardId) => redemptions.where((r) => r.rewardId == rewardId).length;

  int sponsorRemainingCoupons(SponsorDeal deal) =>
      (deal.couponsPerPeriod - sponsorRedeemedCount(deal.rewardId)).clamp(0, deal.couponsPerPeriod);

  SponsorDeal? sponsorDealFor(String? sponsorId) {
    if (sponsorId == null) return null;
    for (final d in sponsorDeals) {
      if (d.id == sponsorId) return d;
    }
    return null;
  }

  bool redeem(Reward reward) {
    if (coinBalance < reward.cost) return false;
    final deal = sponsorDealFor(reward.sponsorId);
    if (deal != null && (!deal.isActive || sponsorRemainingCoupons(deal) <= 0)) return false;

    redemptions.add(Redemption(
      id: '${reward.id}-${DateTime.now().millisecondsSinceEpoch}',
      rewardId: reward.id,
      name: reward.name,
      cost: reward.cost,
      timestamp: DateTime.now(),
    ));
    _persist();
    notifyListeners();
    return true;
  }

  Future<void> resetAll() async {
    target = null;
    dessertEnabled = false;
    remindersEnabled = false;
    mealPercentOverrides = null;
    selectedRecipeKey = {};
    mealChoiceHistory = {};
    dislikedFoods = [];
    allergies = {};
    preferencesConfigured = false;
    measurements = [];
    loggedMeals = [];
    stepsLog = {};
    redemptions = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (_) {
      // ignore
    }
    notifyListeners();
  }
}
