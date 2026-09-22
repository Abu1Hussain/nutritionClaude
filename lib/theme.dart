import 'package:flutter/material.dart';

/// Semantic color slots used throughout the app. Two instances exist
/// ([AppPalette.dark], [AppPalette.light]) so every widget can look up the
/// right color for the active theme via `context.palette` instead of
/// hardcoding one mode's colors.
class AppPalette extends ThemeExtension<AppPalette> {
  final Color bgPage;
  final Color bgCard;
  final Color bgInput;
  final Color bgSurfaceMuted;

  final Color primary;
  final Color primaryHover;
  final Color accent;
  final Color accentHover;
  final Color secondary;
  final Color warning;
  final Color error;

  final Color textMain;
  final Color textMuted;
  final Color textDim;

  final Color border;
  final Color borderFocus;
  final Color divider;

  final Color warningBg;
  final Color warningBorder;
  final Color warningFg;

  final Color errorBg;
  final Color errorBorder;
  final Color errorFg;

  final Color infoBg;
  final Color infoBorder;
  final Color infoFg;

  final Color gaugeMarkerFg;
  final Color gaugeMarkerRing;

  /// Soft ambient shadow used on cards for a premium, elevated feel.
  /// Kept transparent in dark mode, where shadows don't read against a
  /// dark background and the existing border carries the card edge instead.
  final Color cardShadow;

  const AppPalette({
    required this.bgPage,
    required this.bgCard,
    required this.bgInput,
    required this.bgSurfaceMuted,
    required this.primary,
    required this.primaryHover,
    required this.accent,
    required this.accentHover,
    required this.secondary,
    required this.warning,
    required this.error,
    required this.textMain,
    required this.textMuted,
    required this.textDim,
    required this.border,
    required this.borderFocus,
    required this.divider,
    required this.warningBg,
    required this.warningBorder,
    required this.warningFg,
    required this.errorBg,
    required this.errorBorder,
    required this.errorFg,
    required this.infoBg,
    required this.infoBorder,
    required this.infoFg,
    required this.gaugeMarkerFg,
    required this.gaugeMarkerRing,
    required this.cardShadow,
  });

  static const dark = AppPalette(
    bgPage: Color(0xFF18261F),
    bgCard: Color(0xFF24362B),
    bgInput: Color(0xFF18261F),
    bgSurfaceMuted: Color(0x33000000),
    primary: Color(0xFF64886B),
    primaryHover: Color(0xFF315440),
    accent: Color(0xFFE3AA7B),
    accentHover: Color(0xFFAC5539),
    secondary: Color(0xFFD89777),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    textMain: Color(0xFFF8FAFC),
    textMuted: Color(0xFF94A3B8),
    textDim: Color(0xFF64748B),
    border: Color(0xFF334155),
    borderFocus: Color(0xFF818CF8),
    divider: Color(0x11FFFFFF),
    warningBg: Color(0x1FF59E0B),
    warningBorder: Color(0x59F59E0B),
    warningFg: Color(0xFFFCD34D),
    errorBg: Color(0x1FEF4444),
    errorBorder: Color(0x66EF4444),
    errorFg: Color(0xFFFCA5A5),
    infoBg: Color(0x1F6366F1),
    infoBorder: Color(0x4D6366F1),
    infoFg: Color(0xFFC7D2FE),
    gaugeMarkerFg: Color(0xFFF8FAFC),
    gaugeMarkerRing: Color(0xFF24362B),
    cardShadow: Color(0x00000000),
  );

  static const light = AppPalette(
    bgPage: Color(0xFFF8F5EE),
    bgCard: Color(0xFFFFFFFF),
    bgInput: Color(0xFFF0EDE4),
    bgSurfaceMuted: Color(0x0A0F172A),
    primary: Color(0xFF315440),
    primaryHover: Color(0xFF233E30),
    accent: Color(0xFFAC5539),
    accentHover: Color(0xFF87432D),
    secondary: Color(0xFFAC5539),
    warning: Color(0xFFD97706),
    error: Color(0xFFDC2626),
    textMain: Color(0xFF263D32),
    textMuted: Color(0xFF4B5563),
    textDim: Color(0xFF6B7280),
    border: Color(0xFFE5E2D8),
    borderFocus: Color(0xFF64886B),
    divider: Color(0x0F0F172A),
    warningBg: Color(0x1FD97706),
    warningBorder: Color(0x59D97706),
    warningFg: Color(0xFF92400E),
    errorBg: Color(0x1ADC2626),
    errorBorder: Color(0x4DDC2626),
    errorFg: Color(0xFF991B1B),
    infoBg: Color(0x1A4F46E5),
    infoBorder: Color(0x4D4F46E5),
    infoFg: Color(0xFF3730A3),
    gaugeMarkerFg: Color(0xFF18261F),
    gaugeMarkerRing: Color(0xFFFFFFFF),
    cardShadow: Color(0x140F172A),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      bgPage: c(bgPage, other.bgPage),
      bgCard: c(bgCard, other.bgCard),
      bgInput: c(bgInput, other.bgInput),
      bgSurfaceMuted: c(bgSurfaceMuted, other.bgSurfaceMuted),
      primary: c(primary, other.primary),
      primaryHover: c(primaryHover, other.primaryHover),
      accent: c(accent, other.accent),
      accentHover: c(accentHover, other.accentHover),
      secondary: c(secondary, other.secondary),
      warning: c(warning, other.warning),
      error: c(error, other.error),
      textMain: c(textMain, other.textMain),
      textMuted: c(textMuted, other.textMuted),
      textDim: c(textDim, other.textDim),
      border: c(border, other.border),
      borderFocus: c(borderFocus, other.borderFocus),
      divider: c(divider, other.divider),
      warningBg: c(warningBg, other.warningBg),
      warningBorder: c(warningBorder, other.warningBorder),
      warningFg: c(warningFg, other.warningFg),
      errorBg: c(errorBg, other.errorBg),
      errorBorder: c(errorBorder, other.errorBorder),
      errorFg: c(errorFg, other.errorFg),
      infoBg: c(infoBg, other.infoBg),
      infoBorder: c(infoBorder, other.infoBorder),
      infoFg: c(infoFg, other.infoFg),
      gaugeMarkerFg: c(gaugeMarkerFg, other.gaugeMarkerFg),
      gaugeMarkerRing: c(gaugeMarkerRing, other.gaugeMarkerRing),
      cardShadow: c(cardShadow, other.cardShadow),
    );
  }
}

extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}

ThemeData buildDarkTheme() => _buildTheme(AppPalette.dark, Brightness.dark);
ThemeData buildLightTheme() => _buildTheme(AppPalette.light, Brightness.light);

ThemeData _buildTheme(AppPalette p, Brightness brightness) {
  final base = ThemeData(brightness: brightness, useMaterial3: true);
  // Fonts are bundled as local assets (see pubspec.yaml) rather than fetched
  // from a CDN at runtime, so the app renders correctly offline and on a
  // first launch with no network connection.
  final textTheme = base.textTheme.apply(
    fontFamily: 'Plus Jakarta Sans',
    bodyColor: p.textMain,
    displayColor: p.textMain,
  );

  return base.copyWith(
    scaffoldBackgroundColor: p.bgPage,
    textTheme: textTheme,
    extensions: [p],
    colorScheme: base.colorScheme.copyWith(
      brightness: brightness,
      primary: p.primary,
      secondary: p.accent,
      surface: p.bgCard,
      error: p.error,
    ),
    cardColor: p.bgCard,
    dividerColor: p.border,
    appBarTheme: AppBarTheme(
      backgroundColor: p.bgPage,
      foregroundColor: p.textMain,
      elevation: 0,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: p.bgCard,
      selectedIconTheme: IconThemeData(color: p.accent),
      unselectedIconTheme: IconThemeData(color: p.textMuted),
      selectedLabelTextStyle: TextStyle(color: p.accent, fontWeight: FontWeight.w700),
      unselectedLabelTextStyle: TextStyle(color: p.textMuted),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.bgCard,
      indicatorColor: p.primary.withValues(alpha: 0.25),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? p.accent : p.textMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? p.accent : p.textMuted);
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.bgInput,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: p.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: p.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: p.borderFocus, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: TextStyle(color: p.textDim),
      labelStyle: TextStyle(color: p.textMuted),
      helperStyle: TextStyle(color: p.textDim),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        // A bounded minimum size, not Size.fromHeight(48) -- that forces an
        // *infinite* minimum width, which crashes inside any Row/Wrap.
        // Wrap a button in SizedBox(width: double.infinity, ...) instead
        // wherever a full-width button is actually wanted.
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.textMain,
        side: BorderSide(color: p.border),
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: p.textMuted),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? Colors.white : p.textMuted),
      trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? p.accent : p.bgInput),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? p.primary : Colors.transparent),
      side: BorderSide(color: p.border, width: 1.5),
    ),
    dialogTheme: DialogThemeData(backgroundColor: p.bgCard),
    cardTheme: CardThemeData(
      color: p.bgCard,
      elevation: brightness == Brightness.light ? 1 : 0,
      shadowColor: p.cardShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: p.border),
      ),
    ),
    iconTheme: IconThemeData(color: p.textMuted),
  );
}
