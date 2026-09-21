import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_data.dart';
import '../services/app_state.dart';
import '../services/health_sync_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onGoToRewards;
  const HomeScreen({super.key, required this.onGoToRewards});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _stepsCtrl = TextEditingController();
  final _healthSync = HealthSyncService();
  bool _initialized = false;
  bool _syncing = false;
  bool _liveTrackingOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _maybeAutoSync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-sync whenever the user comes back to the app, so steps taken while
    // it was backgrounded show up promptly -- the closest this prototype
    // gets to "live" without true background health sync.
    if (state == AppLifecycleState.resumed) _maybeAutoSync();
  }

  /// Silently checks for already-granted Health permission and, if
  /// present, pulls today's steps without prompting the user. Never shows
  /// a permission dialog on its own -- that only happens from the explicit
  /// "Sync steps from Health app" button.
  Future<void> _maybeAutoSync() async {
    if (!HealthSyncService.isSupported) return;
    final already = await _healthSync.hasPermissionAlready();
    if (!mounted) return;
    setState(() => _liveTrackingOn = already);
    if (!already) return;
    final steps = await _healthSync.fetchTodaySteps();
    if (!mounted || steps == null) return;
    context.read<AppState>().logSteps(steps);
    setState(() => _stepsCtrl.text = steps.toString());
  }

  Future<void> _syncFromHealth(AppState appState) async {
    setState(() => _syncing = true);
    try {
      final granted = await _healthSync.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Permission was not granted, so steps could not be synced.'),
          ));
        }
        return;
      }
      setState(() => _liveTrackingOn = true);
      final steps = await _healthSync.fetchTodaySteps();
      if (steps == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Couldn't read today's steps right now. Try again, or enter them manually."),
          ));
        }
        return;
      }
      appState.logSteps(steps);
      setState(() {
        _stepsCtrl.text = steps.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Synced ${fmtInt(steps)} steps for today.'),
        ));
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stepsCtrl.dispose();
    super.dispose();
  }

  void _showReminderIfNeeded(AppState appState, {bool force = false}) {
    final steps = appState.todaySteps;
    final remaining = dailyStepTarget - steps;
    if (!force && remaining <= 0) return;
    final message = remaining > 0
        ? 'You have ${fmtInt(remaining)} steps left to reach today’s ${fmtInt(dailyStepTarget)}-step target.'
        : 'Great job — you have already reached today’s step target!';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Consumer<AppState>(builder: (context, appState, _) {
      if (!_initialized) {
        _stepsCtrl.text = appState.todaySteps == 0 ? '' : appState.todaySteps.toString();
        _initialized = true;
      }
      final steps = appState.todaySteps;
      final pct = (steps / dailyStepTarget * 100).clamp(0, 100).toDouble();
      final remaining = dailyStepTarget - steps;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Today's activity", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              "Track today's steps, see the Fit Coins you've earned, and manage step-goal reminders. "
              'Information here is stored on this device only.',
              style: TextStyle(color: p.textMuted),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final left = _stepsCard(p, appState, steps, pct, remaining);
              final right = _coinsCard(p, appState);
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Expanded(child: left), const SizedBox(width: 20), Expanded(child: right)],
                );
              }
              return Column(children: [left, const SizedBox(height: 20), right]);
            }),
          ],
        ),
      );
    });
  }

  Widget _stepsCard(AppPalette p, AppState appState, int steps, double pct, int remaining) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Daily total steps', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              if (_liveTrackingOn) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: p.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text('LIVE', style: TextStyle(color: p.accent, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _stepsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Steps logged today', hintText: 'e.g. 6200'),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  final val = int.tryParse(_stepsCtrl.text.trim());
                  if (val == null || val < 0 || val > 200000) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid number of steps between 0 and 200,000.')),
                    );
                    return;
                  }
                  appState.logSteps(val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Steps saved. Fit Coins earned today: ${appState.coinsForSteps(val)}.')),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 12,
              backgroundColor: p.bgInput,
              valueColor: AlwaysStoppedAnimation(p.accent),
            ),
          ),
          const SizedBox(height: 8),
          Text('${fmtInt(steps)} / ${fmtInt(dailyStepTarget)} steps',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(
            remaining <= 0
                ? 'Daily step target reached — nice work!'
                : '${fmtInt(remaining)} steps remaining today',
            style: TextStyle(color: p.textDim, fontSize: 12.5),
          ),
          if (HealthSyncService.isSupported) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _syncing ? null : () => _syncFromHealth(appState),
                icon: _syncing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: p.textMuted),
                      )
                    : const Icon(Icons.sync, size: 18),
                label: Text(_syncing
                    ? 'Syncing…'
                    : (_liveTrackingOn ? 'Refresh steps now' : 'Connect Health app for live steps')),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _liveTrackingOn
                  ? 'Connected. Your real step count from Apple Health (iPhone) or Health Connect (Android) '
                      'refreshes automatically whenever you open or return to this app, plus on tap here.'
                  : 'Once connected, your real step count from Apple Health (iPhone) or Health Connect '
                      '(Android) will refresh automatically whenever you open or return to this app. Asks '
                      'for your permission the first time. External service — no automatic account '
                      'connection.',
              style: TextStyle(color: p.textDim, fontSize: 11.5),
            ),
          ] else ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: p.bgSurfaceMuted, borderRadius: BorderRadius.circular(8)),
              child: Text(
                'On a phone, steps can sync from the Health app (iPhone) or Health Connect (Android). That '
                "isn't available on this device/platform — log steps manually above instead. External "
                'service — no automatic account connection or data synchronization.',
                style: TextStyle(color: p.textDim, fontSize: 11.5),
              ),
            ),
          ],
          Divider(height: 32, color: p.border),
          const Text('Step-goal reminders', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: appState.remindersEnabled,
            onChanged: (v) {
              appState.setRemindersEnabled(v);
              if (v) _showReminderIfNeeded(appState);
            },
            title: const Text("Remind me about today's step target"),
          ),
          Text(
            'Shows an in-app reminder while NutriVision is open. This build does not use background '
            'operating-system push notifications.',
            style: TextStyle(color: p.textDim, fontSize: 11.5),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => _showReminderIfNeeded(appState, force: true),
            child: const Text('Send a test reminder'),
          ),
        ],
      ),
    );
  }

  Widget _coinsCard(AppPalette p, AppState appState) {
    final history = appState.stepsLog.keys.where((k) => k != todayKey()).toList()
      ..sort((a, b) => b.compareTo(a));
    final recent = history.take(7).toList();

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fit Coins', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('You earn 1 Fit Coin for every 1,000 steps logged.',
              style: TextStyle(color: p.textDim, fontSize: 12.5)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _coinStat(p, 'Earned today', '${appState.coinsForSteps(appState.todaySteps)}', false)),
              const SizedBox(width: 12),
              Expanded(child: _coinStat(p, 'Lifetime balance', '${appState.coinBalance}', true)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(onPressed: widget.onGoToRewards, child: const Text('Spend coins in Rewards')),
          ),
          Divider(height: 32, color: p.border),
          const Text('Recent days', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (recent.isEmpty)
            Text('No previous days logged yet.', style: TextStyle(color: p.textDim, fontSize: 12.5))
          else
            for (final key in recent)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(key, style: TextStyle(color: p.textMuted, fontSize: 12.5)),
                    Text('${fmtInt(appState.stepsLog[key])} steps',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                    Text('${appState.coinsForSteps(appState.stepsLog[key]!)} coins',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                  ],
                ),
              ),
          Divider(height: 32, color: p.border),
          TextButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: p.bgCard,
                  title: const Text('Reset saved data?'),
                  content: const Text(
                    'This clears your saved target, logged steps, Fit Coin history, and redeemed rewards on '
                    'this device. This cannot be undone.',
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Reset')),
                  ],
                ),
              );
              if (confirmed == true) {
                await appState.resetAll();
                setState(() {
                  _stepsCtrl.clear();
                  _initialized = false;
                });
              }
            },
            child: const Text('Reset saved data on this device'),
          ),
        ],
      ),
    );
  }

  Widget _coinStat(AppPalette p, String label, String value, bool emphasize) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: emphasize ? p.accent.withValues(alpha: 0.14) : p.bgCard,
        border: Border.all(color: emphasize ? p.accent.withValues(alpha: 0.4) : p.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 10.5, color: p.textMuted, letterSpacing: 0.3)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Outfit')),
        ],
      ),
    );
  }
}
