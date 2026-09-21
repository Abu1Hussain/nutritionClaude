# Sufra | سفرة

A native Flutter Arabic recipe-box storefront, built on the existing NutriVision nutrition app. Customers explore traditional dishes, review estimated calories/macros and ingredients, save favourites, and assemble boxes for home cooking.

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
- Six Arabic recipe boxes: machboos, maqluba, mansaf, shawarma, mujaddara and falafel with hummus.
- Bundled food photography, English/Arabic dish names, ingredients, recipe guidance, allergen information, cooking time, and estimated nutrition per serving and per two-serving box.
- Search, category filters, favourites, quantity editing, sample BHD pricing, delivery totals, validated demo checkout and local order history.
- Cart, favourites and demo orders persist with SharedPreferences.
- Existing calculator, meal planning, targets, food search, activity and rewards remain accessible from the Nutrition tools icon in the app bar.
- GitHub Pages workflow now tests and builds Flutter and uploads only `build/web`, rather than publishing the repository's root HTML prototype.

## Validation

```sh
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build web --release --base-href /Nutrition/
flutter build apk --debug
```

The workflow runs analysis, tests and a web build on pull requests and main pushes; Pages deployment runs only for main pushes/manual runs. Select GitHub Actions as the Pages source in repository settings. Adjust base-href for a custom domain or a repository with another name.

The editing environment's Flutter SDK bootstrap was blocked by automatic security review because it attempted cloud metadata access. Flutter analysis, tests, device runs and compilation could therefore not be verified locally. Run the commands above in your development environment or the included CI workflow before release. Test sources include basket totals/persistence, order snapshots, invalid storage, and the existing nutrition calculations.

## Prototype boundaries

This is an ingredient-kit concept, not ready-cooked delivery. Each box serves two. Prices, delivery windows, quantities, allergens, cooking guidance and nutrition are sample product data, not supplier-verified specifications. Calorie estimates use 4 kcal/g protein and carbohydrate and 9 kcal/g fat. The app labels these estimates.

Checkout explicitly saves a **local demo order**. It does not charge, transmit an order, reserve stock or book delivery. No backend, merchant account or fulfillment service was supplied. Before launch, connect a backend for accounts, validated catalog/stock/pricing, address coverage, payments, order fulfillment and live status. Replace sample recipes and generated photos with verified product data and photography. Do not store sensitive customer/payment information in SharedPreferences.

Android release currently inherits the repository's development signing and example application ID. Configure production identifiers and signing before store distribution.

## Food artwork

`assets/images/arabic_meals.png` is a generated 3×2 photographic atlas, drawn by `MealPhoto` without remote image requests. Built-in image generation was used. Prompt: six equal overhead photographs on cream linen, olive/terracotta ceramics: Bahraini chicken machboos; Palestinian chicken maqluba; Jordanian lamb mansaf; chicken shawarma; mujaddara; falafel with hummus. Warm natural light, no text or watermarks. Illustrative serving suggestions, not photographs of supplied products.
