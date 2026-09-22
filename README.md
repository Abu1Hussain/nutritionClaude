# Sufra | سفرة

A native Flutter Arabic recipe-box storefront, built on the existing NutriVision nutrition app. Customers explore traditional dishes, review estimated calories/macros and ingredients, save favourites, and assemble boxes for home cooking.

## Meal-kit experience update

- Arabic RTL storefront and five destinations: meals, plans, favourites, basket and orders.
- Audience discovery for first-time cooks, athletes, families and balanced-meal browsing.
- Four purchase options: one box, three-box full day, five-box week, and twenty-box/four-week month. Each box serves two. Weekly/monthly cover **one meal per day, five days per week**, not every daily meal.
- Editable recipe choices with a shared integer-fils pricing policy. Monthly selections repeat for four weeks; sample weekly/monthly discounts are 5%/10%.
- Optional included starter kit: measuring spoons, scoop, food thermometer and food scale. Included with the first delivery of a selected cycle; defaults off after the first local demo order.
- Ingredient checklist and step-by-step cooking mode; breakfast recipe added for the full-day plan.
- Plan details, kit, discount and delivery count persist with each demo order. Incomplete bundles cannot check out. Storage mutations are serialized and rolled back on failure.

Read [the Arabic launch and product plan](docs/LAUNCH_AR.md). Suggested campaign: **أول طبخة عليك… والمقادير علينا**.

## Run the Flutter app

Install Flutter stable (Dart 3.8 or later), then from this directory:

```sh
flutter pub get
flutter run
```

Choose an Android emulator or connected phone. For iOS, use macOS with Xcode and an iOS simulator or configured device. For Flutter in a browser:

```sh
flutter run -d chrome
```

`lib/main.dart` is the application entry point. Do not open the root `index.html` to run Flutter: that file is the original, independent HTML prototype. `web/index.html` is only the Flutter bootstrap host. The original HTML/CSS/JS files remain as a reference, not the deployed app.

## What changed

- Sufra storefront in cream, olive and terracotta; mobile bottom navigation and desktop navigation rail; light/dark modes.
- Seven recipe boxes, including overnight oats for breakfast and six Arabic dishes: machboos, maqluba, mansaf, shawarma, mujaddara and falafel with hummus.
- Bundled food photography, English/Arabic dish names, ingredients, recipe guidance, allergen information, cooking time, and estimated nutrition per serving and per two-serving box.
- Search, category filters, favourites, quantity editing, sample BHD pricing, delivery totals, validated demo checkout and local order history.
- Cart, favourites and demo orders persist with SharedPreferences.
- Existing calculator, meal planning, targets, food search, activity and rewards remain accessible from the Nutrition tools icon in the app bar.
- GitHub Pages workflow now tests and builds Flutter and uploads only `build/web`, rather than publishing the repository's root HTML prototype.

## Validation

```sh
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build web --release --base-href /nutritionClaude/
flutter build apk --debug
```

The workflow runs analysis, tests and a web build on pull requests and main pushes; Pages deployment runs only for main pushes/manual runs. Select GitHub Actions as the Pages source in repository settings. Adjust base-href for a custom domain or a repository with another name.

The current editing session passed 19 dependency-free Dart pricing/catalog checks (`dart tool/check_plan_pricing.dart`) and Dart syntax/format checks on changed sources. Full Flutter analysis, widget tests, browser preview and compilation were **not run successfully**: automatic approval review blocked Flutter bootstrap after it attempted access to the cloud metadata endpoint. No APK or compiled web release is included. Run the commands above or the existing CI before merging/releasing.

New test sources cover monthly totals and four deliveries, daily bundles, persisted kit selection, incomplete-plan checkout, invalid replacements, duplicate queued checkout, narrow RTL layout and guided cooking. These Flutter tests are added but remain unexecuted in this environment.

## Prototype boundaries

This is an ingredient-kit concept, not ready-cooked delivery. Each box serves two. Prices, delivery windows, quantities, allergens, cooking guidance and nutrition are sample product data, not supplier-verified specifications. Calorie estimates use 4 kcal/g protein and carbohydrate and 9 kcal/g fat. The app labels these estimates.

Checkout explicitly saves a **local demo order**. It does not charge, transmit an order, reserve stock or book delivery. No backend, merchant account or fulfillment service was supplied. Before launch, connect a backend for accounts, validated catalog/stock/pricing, address coverage, payments, order fulfillment and live status. Replace sample recipes and generated photos with verified product data and photography. Do not store sensitive customer/payment information in SharedPreferences.

Android release currently inherits the repository's development signing and example application ID. Configure production identifiers and signing before store distribution.

## Food artwork

`assets/images/arabic_meals.png` is a generated 3×2 photographic atlas, drawn by `MealPhoto` without remote image requests. Built-in image generation was used. Prompt: six equal overhead photographs on cream linen, olive/terracotta ceramics: Bahraini chicken machboos; Palestinian chicken maqluba; Jordanian lamb mansaf; chicken shawarma; mujaddara; falafel with hummus. Warm natural light, no text or watermarks. Illustrative serving suggestions, not photographs of supplied products.
