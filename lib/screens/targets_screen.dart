import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_data.dart';
import '../services/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class TargetsScreen extends StatelessWidget {
  const TargetsScreen({super.key});

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
            const Text('Your targets', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('A quick summary of your daily and weekly goals, combining nutrition and activity.',
                style: TextStyle(color: p.textMuted)),
            const SizedBox(height: 20),
            if (t == null)
              SectionCard(
                child: Text(
                  'Calculate your target in the Calculator section first to see your weekly weight goal and '
                  'daily calorie target here.',
                  style: TextStyle(color: p.textMuted),
                ),
              )
            else
              Builder(builder: (context) {
                String weeklyText;
                if (t.goal == 'maintain') {
                  weeklyText = 'Maintain your current weight this week';
                } else if (t.goal == 'lose') {
                  weeklyText = 'Lose fat: ${t.weeklyRateKg} kg this week (estimate)';
                } else {
                  weeklyText = 'Gain muscle: ${t.weeklyRateKg} kg this week (estimate)';
                }
                return LayoutBuilder(builder: (context, constraints) {
                  final cols = responsiveColumns(constraints.maxWidth, desktop: 3, tablet: 2, mobile: 1);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700, color: p.textDim, letterSpacing: 0.4)),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: [
                          _TargetStatCard(
                            label: 'Daily step target',
                            value: '${fmtInt(dailyStepTarget)} steps/day',
                            note: 'A general activity goal used throughout NutriVision.',
                          ),
                          _TargetStatCard(
                            label: 'Daily calorie target',
                            value: '${fmtInt(t.calories)} kcal/day',
                            note: 'From your most recent calculation.',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text('Weekly',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700, color: p.textDim, letterSpacing: 0.4)),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: [
                          _TargetStatCard(
                            label: 'Weekly step target',
                            value: '${fmtInt(dailyStepTarget * 7)} steps/week',
                            note: '7 × your daily step target.',
                          ),
                          _TargetStatCard(
                            label: 'Weekly calorie target',
                            value: '${fmtInt(t.calories * 7)} kcal/week',
                            note: '7 × your daily calorie target.',
                          ),
                          _TargetStatCard(
                            label: 'Weekly weight goal',
                            value: weeklyText,
                            note: 'An estimate, not a guarantee. See the Calculator section for details.',
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'This information is calculated from your last successful calculation and stored on '
                        'this device only.',
                        style: TextStyle(color: p.textDim, fontSize: 11.5),
                      ),
                    ],
                  );
                });
              }),
          ],
        ),
      );
    });
  }
}

class _TargetStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String note;
  const _TargetStatCard({required this.label, required this.value, required this.note});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: p.textMuted, letterSpacing: 0.4)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: p.accent, fontFamily: 'Outfit')),
          const SizedBox(height: 6),
          Text(note, style: TextStyle(fontSize: 11.5, color: p.textDim)),
        ],
      ),
    );
  }
}
