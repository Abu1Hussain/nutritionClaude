import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../models/reward.dart';

const String appName = 'NutriVision';

const double gaugeMin = 12;
const double gaugeMax = 45;
const int dailyStepTarget = 5000;
const int stepsPerCoin = 1000;

class ActivityLevel {
  final double factor;
  final String label;
  final String description;
  const ActivityLevel(this.factor, this.label, this.description);
}

const List<ActivityLevel> activityLevels = [
  ActivityLevel(1.2, 'Sedentary', 'Little or no exercise'),
  ActivityLevel(1.375, 'Lightly active', 'Exercise 1-3 days per week'),
  ActivityLevel(1.55, 'Moderately active', 'Exercise 3-5 days per week'),
  ActivityLevel(1.725, 'Very active', 'Exercise 6-7 days per week'),
  ActivityLevel(1.9, 'Extra active', 'Intense training or physical job'),
];

const Map<String, String> goalLabels = {
  'lose': 'Lose fat',
  'maintain': 'Maintain weight',
  'gain': 'Gain muscle',
};

const List<double> weeklyRateOptions = [0.25, 0.5, 0.75];

/// BMI gauge bands: 4 yellow (low), 1 green (reference), 4 red (high).
/// These are visual subdivisions used by this app, not clinical categories.
class GaugeBand {
  final double min;
  final double max;
  final Color color;
  const GaugeBand(this.min, this.max, this.color);
}

const List<GaugeBand> gaugeBands = [
  GaugeBand(12, 15, Color(0xFF92400E)),
  GaugeBand(15, 16, Color(0xFFB45309)),
  GaugeBand(16, 17, Color(0xFFD97706)),
  GaugeBand(17, 18.5, Color(0xFFF59E0B)),
  GaugeBand(18.5, 25, Color(0xFF10B981)),
  GaugeBand(25, 30, Color(0xFFF87171)),
  GaugeBand(30, 35, Color(0xFFEF4444)),
  GaugeBand(35, 40, Color(0xFFDC2626)),
  GaugeBand(40, 45, Color(0xFF991B1B)),
];

String bmiStatus(double bmi) {
  if (bmi < 18.5) return 'Below reference';
  if (bmi < 25) return 'Healthy range';
  if (bmi < 30) return 'Above reference';
  if (bmi < 35) return 'Obesity — class 1';
  if (bmi < 40) return 'Obesity — class 2';
  return 'Obesity — class 3';
}

/// Selectable recipes per meal type. Each ingredient's `share` is its
/// fraction of that meal's calorie allocation. Real USDA SR Legacy food ids
/// (see assets/data). Every recipe is tagged with the major allergens its
/// ingredients contain, used to filter the plan against
/// [AppState.allergies] and to power the "swap this meal" picker.
const Map<String, List<MealRecipeSpec>> mealRecipeOptions = {
  'breakfast': [
    MealRecipeSpec(
      key: 'breakfast_oat_bowl',
      name: 'Berry and almond oat bowl',
      allergens: {Allergen.dairy, Allergen.treeNuts},
      ingredients: [
        MealIngredientSpec(foodId: 170887, label: 'Plain skim yogurt', share: 0.25),
        MealIngredientSpec(foodId: 173904, label: 'Oats', share: 0.40),
        MealIngredientSpec(foodId: 171711, label: 'Blueberries', share: 0.15),
        MealIngredientSpec(foodId: 170567, label: 'Almonds', share: 0.20),
      ],
    ),
    MealRecipeSpec(
      key: 'breakfast_veggie_eggs',
      name: 'Veggie scrambled eggs',
      allergens: {Allergen.eggs, Allergen.wheat},
      ingredients: [
        MealIngredientSpec(foodId: 172187, label: 'Scrambled eggs', share: 0.45),
        MealIngredientSpec(foodId: 168463, label: 'Spinach', share: 0.15),
        MealIngredientSpec(foodId: 172688, label: 'Whole-wheat toast', share: 0.25),
        MealIngredientSpec(foodId: 171705, label: 'Avocado', share: 0.15),
      ],
    ),
  ],
  'lunch': [
    MealRecipeSpec(
      key: 'lunch_chicken_rice',
      name: 'Chicken and brown-rice bowl',
      allergens: {Allergen.treeNuts},
      ingredients: [
        MealIngredientSpec(foodId: 171477, label: 'Oven-roasted chicken', share: 0.40),
        MealIngredientSpec(foodId: 169704, label: 'Cooked brown rice', share: 0.35),
        MealIngredientSpec(foodId: 169967, label: 'Broccoli', share: 0.10),
        MealIngredientSpec(foodId: 170567, label: 'Almonds', share: 0.15),
      ],
    ),
    MealRecipeSpec(
      key: 'lunch_turkey_quinoa',
      name: 'Turkey and quinoa bowl',
      allergens: {},
      ingredients: [
        MealIngredientSpec(foodId: 171506, label: 'Ground turkey', share: 0.40),
        MealIngredientSpec(foodId: 168917, label: 'Cooked quinoa', share: 0.35),
        MealIngredientSpec(foodId: 169967, label: 'Broccoli', share: 0.15),
        MealIngredientSpec(foodId: 171413, label: 'Olive oil', share: 0.10),
      ],
    ),
  ],
  'dinner': [
    MealRecipeSpec(
      key: 'dinner_salmon_bulgur',
      name: 'Salmon and bulgur plate',
      allergens: {Allergen.fish, Allergen.treeNuts},
      ingredients: [
        MealIngredientSpec(foodId: 175168, label: 'Cooked salmon', share: 0.45),
        MealIngredientSpec(foodId: 170287, label: 'Cooked bulgur', share: 0.30),
        MealIngredientSpec(foodId: 169967, label: 'Broccoli', share: 0.10),
        MealIngredientSpec(foodId: 170567, label: 'Almonds', share: 0.15),
      ],
    ),
    MealRecipeSpec(
      key: 'dinner_beef_sweetpotato',
      name: 'Beef and sweet potato plate',
      allergens: {},
      ingredients: [
        MealIngredientSpec(foodId: 168635, label: 'Lean beef', share: 0.45),
        MealIngredientSpec(foodId: 168483, label: 'Sweet potato', share: 0.30),
        MealIngredientSpec(foodId: 169967, label: 'Broccoli', share: 0.15),
        MealIngredientSpec(foodId: 171413, label: 'Olive oil', share: 0.10),
      ],
    ),
  ],
  'dessert': [
    MealRecipeSpec(
      key: 'dessert_yogurt',
      name: 'Strawberry chocolate yogurt',
      allergens: {Allergen.dairy},
      ingredients: [
        MealIngredientSpec(foodId: 170887, label: 'Plain skim yogurt', share: 0.45),
        MealIngredientSpec(foodId: 167762, label: 'Strawberries', share: 0.25),
        MealIngredientSpec(foodId: 170273, label: 'Dark chocolate', share: 0.30),
      ],
    ),
    MealRecipeSpec(
      key: 'dessert_berry_cup',
      name: 'Mixed berry cup',
      allergens: {},
      ingredients: [
        MealIngredientSpec(foodId: 167762, label: 'Strawberries', share: 0.5),
        MealIngredientSpec(foodId: 173946, label: 'Blackberries', share: 0.5),
      ],
    ),
  ],
};

const Map<String, double> mealPctNoDessert = {'breakfast': 0.30, 'lunch': 0.38, 'dinner': 0.32};
const Map<String, double> mealPctWithDessert = {
  'breakfast': 0.25,
  'lunch': 0.35,
  'dinner': 0.30,
  'dessert': 0.10,
};

const Map<String, String> mealTypeLabels = {
  'breakfast': 'Breakfast',
  'lunch': 'Lunch',
  'dinner': 'Dinner',
  'dessert': 'Dessert',
};

/// The first (default) recipe option for a meal type.
MealRecipeSpec defaultRecipeFor(String mealType) => mealRecipeOptions[mealType]!.first;

/// Looks up a specific recipe by its key within a meal type, falling back
/// to the default if the key is unknown (e.g. a stale persisted value from
/// a recipe that no longer exists).
MealRecipeSpec recipeByKey(String mealType, String? key) {
  final options = mealRecipeOptions[mealType]!;
  if (key == null) return options.first;
  return options.firstWhere((r) => r.key == key, orElse: () => options.first);
}

/// A fixed taxonomy of common allergens/intolerances, used for the meal
/// preferences setup step. Free-text "dislikes" are separate and are a
/// softer, non-safety-critical preference.
const List<Allergen> allergenTaxonomy = Allergen.values;

/// Demo rewards catalog. Redemptions are recorded locally only; no real
/// purchases, gift cards, or devices are sent.
const List<Reward> rewardsCatalog = [
  Reward(id: 'amzn-10', name: 'Amazon Gift Card \$10', category: 'Gift Cards', cost: 100, icon: '\u{1F6D2}'),
  Reward(id: 'amzn-25', name: 'Amazon Gift Card \$25', category: 'Gift Cards', cost: 240, icon: '\u{1F6D2}'),
  Reward(id: 'amzn-50', name: 'Amazon Gift Card \$50', category: 'Gift Cards', cost: 460, icon: '\u{1F6D2}'),
  Reward(id: 'amzn-100', name: 'Amazon Gift Card \$100', category: 'Gift Cards', cost: 900, icon: '\u{1F6D2}'),
  Reward(id: 'psn-10', name: 'PlayStation Store Card \$10', category: 'Gaming', cost: 100, icon: '\u{1F3AE}'),
  Reward(id: 'psn-25', name: 'PlayStation Store Card \$25', category: 'Gaming', cost: 240, icon: '\u{1F3AE}'),
  Reward(id: 'psn-50', name: 'PlayStation Store Card \$50', category: 'Gaming', cost: 460, icon: '\u{1F3AE}'),
  Reward(id: 'xbox-10', name: 'Xbox Gift Card \$10', category: 'Gaming', cost: 100, icon: '\u{1F3AE}'),
  Reward(id: 'xbox-25', name: 'Xbox Gift Card \$25', category: 'Gaming', cost: 240, icon: '\u{1F3AE}'),
  Reward(id: 'xbox-50', name: 'Xbox Gift Card \$50', category: 'Gaming', cost: 460, icon: '\u{1F3AE}'),
  Reward(id: 'steam-10', name: 'Steam Wallet Card \$10', category: 'Gaming', cost: 100, icon: '\u{1F3AE}'),
  Reward(id: 'steam-25', name: 'Steam Wallet Card \$25', category: 'Gaming', cost: 240, icon: '\u{1F3AE}'),
  Reward(id: 'steam-50', name: 'Steam Wallet Card \$50', category: 'Gaming', cost: 460, icon: '\u{1F3AE}'),
  Reward(id: 'steam-100', name: 'Steam Wallet Card \$100', category: 'Gaming', cost: 900, icon: '\u{1F3AE}'),
  Reward(id: 'spotify-1', name: 'Spotify Premium - 1 month', category: 'Subscriptions', cost: 90, icon: '\u{1F3B5}'),
  Reward(id: 'spotify-3', name: 'Spotify Premium - 3 months', category: 'Subscriptions', cost: 250, icon: '\u{1F3B5}'),
  Reward(id: 'spotify-12', name: 'Spotify Premium - 12 months', category: 'Subscriptions', cost: 900, icon: '\u{1F3B5}'),
  Reward(id: 'netflix-25', name: 'Netflix Gift Card \$25', category: 'Subscriptions', cost: 240, icon: '\u{1F3AC}'),
  Reward(id: 'apple-music-3', name: 'Apple Music - 3 months', category: 'Subscriptions', cost: 250, icon: '\u{1F3B6}'),
  Reward(id: 'yt-premium-1', name: 'YouTube Premium - 1 month', category: 'Subscriptions', cost: 90, icon: '\u{25B6}'),
  Reward(id: 'disney-3', name: 'Disney+ - 3 months', category: 'Subscriptions', cost: 260, icon: '\u{2728}'),
  Reward(id: 'kindle-3', name: 'Kindle Unlimited - 3 months', category: 'Subscriptions', cost: 300, icon: '\u{1F4DA}'),
  Reward(id: 'gym-1', name: 'Gym Membership - 1 month', category: 'Fitness', cost: 500, icon: '\u{1F3CB}'),
  Reward(id: 'gym-3', name: 'Gym Membership - 3 months', category: 'Fitness', cost: 1400, icon: '\u{1F3CB}'),
  Reward(id: 'gym-12', name: 'Gym Membership - 12 months', category: 'Fitness', cost: 5000, icon: '\u{1F3CB}'),
  Reward(id: 'yoga-10', name: 'Yoga Studio Pack - 10 classes', category: 'Fitness', cost: 600, icon: '\u{1F9D8}'),
  Reward(id: 'apple-watch-se', name: 'Apple Watch SE', category: 'Fitness', cost: 6000, icon: '\u{231A}'),
  Reward(id: 'apple-watch-series', name: 'Apple Watch Series 10', category: 'Fitness', cost: 9000, icon: '\u{231A}'),
  Reward(id: 'fitbit-charge', name: 'Fitbit Charge', category: 'Fitness', cost: 3500, icon: '\u{231A}'),
  Reward(id: 'airpods-pro', name: 'AirPods Pro', category: 'Tech', cost: 5500, icon: '\u{1F3A7}'),
  Reward(id: 'gplay-10', name: 'Google Play Gift Card \$10', category: 'Gift Cards', cost: 100, icon: '\u{1F4F1}'),
  Reward(id: 'gplay-25', name: 'Google Play Gift Card \$25', category: 'Gift Cards', cost: 240, icon: '\u{1F4F1}'),
  Reward(id: 'nike-25', name: 'Nike Gift Card \$25', category: 'Shopping', cost: 240, icon: '\u{1F45F}'),
  Reward(id: 'adidas-25', name: 'Adidas Gift Card \$25', category: 'Shopping', cost: 240, icon: '\u{1F45F}'),
  Reward(id: 'starbucks-10', name: 'Starbucks Gift Card \$10', category: 'Shopping', cost: 100, icon: '\u{2615}'),
  Reward(id: 'ubereats-15', name: 'Uber Eats Gift Card \$15', category: 'Shopping', cost: 150, icon: '\u{1F35F}'),
];

/// Sponsored rewards funded by a [SponsorDeal]. These appear in the
/// Rewards screen alongside [rewardsCatalog] with a "Sponsored by" badge
/// and a finite per-period coupon count.
///
/// These are placeholder/fictional companies for this prototype -- no real
/// brand has sponsored NutriVision. A real deployment would source these
/// (and the fee/coupon figures) from the admin view's saved deals rather
/// than a compile-time list.
const List<Reward> sponsoredRewards = [
  Reward(
    id: 'sponsor-aurora-pass',
    name: 'Aurora Fitness — 1 month studio pass',
    category: 'Sponsored',
    cost: 200,
    icon: '\u{1F3CB}',
    sponsorId: 'sponsor-aurora',
  ),
  Reward(
    id: 'sponsor-peakgear-discount',
    name: 'Peak Gear — 20% off gear',
    category: 'Sponsored',
    cost: 150,
    icon: '\u{1F6CD}',
    sponsorId: 'sponsor-peakgear',
  ),
  Reward(
    id: 'sponsor-greenleaf-coupon',
    name: 'GreenLeaf Grocers — \$10 coupon',
    category: 'Sponsored',
    cost: 120,
    icon: '\u{1F345}',
    sponsorId: 'sponsor-greenleaf',
  ),
];

/// This period's sponsor deals (admin-configured, in a real deployment).
/// Recomputed relative to "now" so the demo always shows a current month.
final List<SponsorDeal> sponsorDeals = _buildSponsorDeals();

List<SponsorDeal> _buildSponsorDeals() {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  return [
    SponsorDeal(
      id: 'sponsor-aurora',
      companyName: 'Aurora Fitness Co.',
      feeAmount: 100,
      feeCurrency: 'BHD',
      couponsPerPeriod: 30,
      startDate: start,
      endDate: end,
      rewardId: 'sponsor-aurora-pass',
    ),
    SponsorDeal(
      id: 'sponsor-peakgear',
      companyName: 'Peak Gear Supply',
      feeAmount: 150,
      feeCurrency: 'BHD',
      couponsPerPeriod: 20,
      startDate: start,
      endDate: end,
      rewardId: 'sponsor-peakgear-discount',
    ),
    SponsorDeal(
      id: 'sponsor-greenleaf',
      companyName: 'GreenLeaf Grocers',
      feeAmount: 80,
      feeCurrency: 'BHD',
      couponsPerPeriod: 40,
      startDate: start,
      endDate: end,
      rewardId: 'sponsor-greenleaf-coupon',
    ),
  ];
}

const String caloMenuUrl = 'https://calo.app/en/menu';
const String caloAppUrl = 'https://calo.go.link/?adj_t=1fubx4rk';

/// Original flat-icon artwork (bundled locally, not third-party brand
/// logos) used on reward and meal cards. Real gift-card/store logos are
/// intentionally not used here -- this is a demo catalog, not an
/// authorized use of those trademarks.
const Map<String, String> _rewardCategoryImages = {
  'Gift Cards': 'assets/images/cat_gift.png',
  'Gaming': 'assets/images/cat_gaming.png',
  'Subscriptions': 'assets/images/cat_subscriptions.png',
  'Fitness': 'assets/images/cat_fitness.png',
  'Tech': 'assets/images/cat_tech.png',
  'Shopping': 'assets/images/cat_shopping.png',
  'Sponsored': 'assets/images/cat_sponsored.png',
};

String rewardCategoryImage(String category) =>
    _rewardCategoryImages[category] ?? 'assets/images/cat_gift.png';

const Map<String, String> mealTypeImages = {
  'breakfast': 'assets/images/cat_breakfast.png',
  'lunch': 'assets/images/cat_lunch.png',
  'dinner': 'assets/images/cat_dinner.png',
  'dessert': 'assets/images/cat_dessert.png',
};
