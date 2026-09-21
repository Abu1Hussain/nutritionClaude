import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';

class NavDestinationSpec {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget Function(BuildContext) builder;

  const NavDestinationSpec({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.builder,
  });
}

/// The app shell: a bottom NavigationBar on every device (phone, tablet,
/// desktop/PC, web) so the primary navigation is always in the same place,
/// per the user's explicit request. Only the *content* area adapts to the
/// available width (each screen handles its own responsive layout via
/// LayoutBuilder). Keeps at most one nav shell mounted, so switching tabs
/// never triggers a full page reload/rebuild of the app shell itself.
class ResponsiveScaffold extends StatefulWidget {
  final List<NavDestinationSpec> destinations;
  final int initialIndex;

  const ResponsiveScaffold({super.key, required this.destinations, this.initialIndex = 0});

  @override
  State<ResponsiveScaffold> createState() => ResponsiveScaffoldState();
}

class ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  late int _index = widget.initialIndex;

  void navigateTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.themeMode == ThemeMode.dark;

    final body = IndexedStack(
      index: _index,
      children: [for (final d in widget.destinations) Builder(builder: d.builder)],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('\u{1F957}', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Nutrition tools', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => context.read<AppState>().toggleThemeMode(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      // The content itself is centered and width-capped on large screens
      // (desktop/PC/tablet) so text and cards stay readable, while each
      // screen's own LayoutBuilder still reflows its grid/columns to fit.
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: body,
        ),
      ),
      bottomNavigationBar: SafeArea(
        // heightFactor: 1 makes Center shrink-wrap to the NavigationBar's own
        // height. Without it, Center fills all the loose height Scaffold
        // offers the bottomNavigationBar slot, which tricks Scaffold into
        // starving the body down to zero height and centering the nav bar
        // in the middle of the screen instead of pinning it to the bottom.
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                for (final d in widget.destinations)
                  NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: d.label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
