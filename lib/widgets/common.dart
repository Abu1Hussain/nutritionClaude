import 'package:flutter/material.dart';

import '../theme.dart';

/// A bordered, rounded card used throughout the app (mirrors the web
/// app's `.field-card` / `.glass-bg` panels).
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const SectionCard({super.key, required this.child, this.padding = const EdgeInsets.all(20)});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: p.bgCard.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border),
        boxShadow: [BoxShadow(color: p.cardShadow, blurRadius: 24, offset: const Offset(0, 8))],
      ),
      // Material(transparency) gives any descendant ListTile/SwitchListTile/
      // CheckboxListTile a proper Material ancestor so their ink splashes
      // and background painting behave correctly inside this decorated box.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

enum NoticeKind { info, warning, error }

class NoticeBanner extends StatelessWidget {
  final String text;
  final NoticeKind kind;

  const NoticeBanner({super.key, required this.text, this.kind = NoticeKind.info});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Color bg;
    Color fg;
    switch (kind) {
      case NoticeKind.warning:
        bg = p.warningBg;
        fg = p.warningFg;
        break;
      case NoticeKind.error:
        bg = p.errorBg;
        fg = p.errorFg;
        break;
      case NoticeKind.info:
        bg = p.infoBg;
        fg = p.infoFg;
        break;
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 13.5)),
    );
  }
}

class StatRow extends StatelessWidget {
  final String label;
  final String value;

  const StatRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: p.textMuted, fontSize: 13.5)),
          Text(value, style: TextStyle(color: p.textMain, fontWeight: FontWeight.w700, fontSize: 13.5)),
        ],
      ),
    );
  }
}

class NutrientCard extends StatelessWidget {
  final String name;
  final String value;
  final String unit;
  final bool isLimit;

  const NutrientCard({super.key, required this.name, required this.value, required this.unit, required this.isLimit});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border),
        boxShadow: [BoxShadow(color: p.cardShadow, blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name.toUpperCase(),
              style: TextStyle(color: p.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(value,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: p.textMain),
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 4),
              Text(unit, style: TextStyle(fontSize: 12, color: p.textDim, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isLimit ? p.warningBg : p.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              isLimit ? 'Upper limit' : 'Target',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: isLimit ? p.warningFg : p.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chooses a grid column count from available width, mirroring the web
/// app's desktop/tablet/mobile breakpoints.
int responsiveColumns(double width, {int desktop = 3, int tablet = 2, int mobile = 1}) {
  if (width >= 900) return desktop;
  if (width >= 600) return tablet;
  return mobile;
}

String fmtInt(num? v) {
  if (v == null) return '—';
  final n = v.round();
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return (n < 0 ? '-' : '') + buf.toString();
}

String fmtNum1(double? v) => v == null ? '—' : v.toStringAsFixed(1);
