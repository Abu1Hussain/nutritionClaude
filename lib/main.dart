import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/box_store.dart';
import 'screens/box_shop_screen.dart';

import 'screens/calculator_screen.dart';
import 'screens/foods_screen.dart';
import 'screens/home_screen.dart';
import 'screens/meal_plan_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/targets_screen.dart';
import 'services/app_state.dart';
import 'services/food_repository.dart';
import 'theme.dart';
import 'widgets/responsive_scaffold.dart';

void main() {
  runApp(const NutriVisionRoot());
}

/// Loads persisted app state and the food database once, then hands off to
/// the main adaptive shell. Both are local (device storage + bundled
/// asset), so this normally resolves in well under a second.
///
/// AppState is provided *above* MaterialApp so the app can react live to
/// the user's light/dark mode choice (see the toggle button in
/// ResponsiveScaffold's app bar).
class NutriVisionRoot extends StatefulWidget {
  const NutriVisionRoot({super.key});

  @override
  State<NutriVisionRoot> createState() => _NutriVisionRootState();
}

class _NutriVisionRootState extends State<NutriVisionRoot> {
  late Future<(AppState, FoodRepository, BoxStore)> _future = _init();

  Future<(AppState, FoodRepository, BoxStore)> _init() async {
    final appState = AppState();
    final results = await Future.wait([appState.load(), FoodRepository.load()]);
    return (appState, results[1] as FoodRepository, BoxStore(await SharedPreferences.getInstance()));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(AppState, FoodRepository, BoxStore)>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(theme: buildLightTheme(), home: Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Could not load the app. Please try again.'),
            FilledButton(onPressed: () => setState(() => _future = _init()), child: const Text('Retry')),
          ]))));
        }
        if (!snapshot.hasData) {
          return MaterialApp(
            title: 'Sufra | سفرة',
            debugShowCheckedModeBanner: false,
            theme: buildDarkTheme(),
            home: const _LoadingScreen(),
          );
        }
        final (appState, foodRepo, boxStore) = snapshot.data!;
        return MultiProvider(
          providers: [ChangeNotifierProvider<AppState>.value(value: appState), ChangeNotifierProvider<BoxStore>.value(value: boxStore)],
          child: Consumer<AppState>(
            builder: (context, appState, _) => MaterialApp(
              title: 'Sufra | سفرة',
              debugShowCheckedModeBanner: false,
              theme: buildLightTheme(),
              darkTheme: buildDarkTheme(),
              themeMode: appState.themeMode,
              home: _ShopShell(foodRepo: foodRepo),
            ),
          ),
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: context.palette.accent),
            const SizedBox(height: 16),
            Text('Preparing your table…', style: TextStyle(color: context.palette.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _MainShell extends StatefulWidget {
  final FoodRepository foodRepo;
  const _MainShell({required this.foodRepo});

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  final _scaffoldKey = GlobalKey<ResponsiveScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      key: _scaffoldKey,
      initialIndex: 1,
      destinations: [
        NavDestinationSpec(
          label: 'Home',
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          builder: (context) => HomeScreen(onGoToRewards: () => _scaffoldKey.currentState?.navigateTo(5)),
        ),
        NavDestinationSpec(
          label: 'Calculator',
          icon: Icons.calculate_outlined,
          selectedIcon: Icons.calculate,
          builder: (context) => const CalculatorScreen(),
        ),
        NavDestinationSpec(
          label: 'Meal Plan',
          icon: Icons.restaurant_menu_outlined,
          selectedIcon: Icons.restaurant_menu,
          builder: (context) => MealPlanScreen(foodById: widget.foodRepo.byId),
        ),
        NavDestinationSpec(
          label: 'Targets',
          icon: Icons.flag_outlined,
          selectedIcon: Icons.flag,
          builder: (context) => const TargetsScreen(),
        ),
        NavDestinationSpec(
          label: 'Foods',
          icon: Icons.search_outlined,
          selectedIcon: Icons.search,
          builder: (context) => FoodsScreen(repository: widget.foodRepo),
        ),
        NavDestinationSpec(
          label: 'Rewards',
          icon: Icons.card_giftcard_outlined,
          selectedIcon: Icons.card_giftcard,
          builder: (context) => const RewardsScreen(),
        ),
      ],
    );
  }
}

class _ShopShell extends StatefulWidget {
  final FoodRepository foodRepo;
  const _ShopShell({required this.foodRepo});
  @override
  State<_ShopShell> createState() => _ShopShellState();
}
class _ShopShellState extends State<_ShopShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final count = context.watch<BoxStore>().count;
    final screens = <Widget>[
      const BoxShopScreen(),
      const BoxShopScreen(favoritesOnly: true),
      BasketScreen(onBrowse: () => setState(() => index = 0)),
      const BoxOrdersScreen(),
    ];
    final destinations = [
      const NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Explore'),
      const NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Saved'),
      NavigationDestination(icon: Badge(isLabelVisible: count > 0, label: Text('$count'), child: const Icon(Icons.shopping_bag_outlined)), label: 'Basket'),
      const NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('sufra / سفرة', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, fontSize: 25)), actions: [
        IconButton(tooltip: 'Nutrition tools', icon: const Icon(Icons.monitor_heart_outlined), onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _MainShell(foodRepo: widget.foodRepo)))),
        IconButton(tooltip: state.themeMode == ThemeMode.dark ? 'Switch to light mode' : 'Switch to dark mode', icon: Icon(state.themeMode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined), onPressed: state.toggleThemeMode),
        const SizedBox(width: 8),
      ]),
      body: SafeArea(child: LayoutBuilder(builder: (context, c) {
        final body = IndexedStack(index: index, children: screens);
        if (c.maxWidth < 900) return body;
        return Row(children: [NavigationRail(selectedIndex: index, labelType: NavigationRailLabelType.all, onDestinationSelected: (v) => setState(() => index = v), destinations: [
          for (final d in destinations) NavigationRailDestination(icon: d.icon, label: Text(d.label)),
        ]), const VerticalDivider(width: 1), Expanded(child: body)]);
      })),
      bottomNavigationBar: MediaQuery.sizeOf(context).width >= 900 ? null : NavigationBar(selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v), destinations: destinations),
    );
  }
}
