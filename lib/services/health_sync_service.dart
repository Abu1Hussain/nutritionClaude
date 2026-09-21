import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:health/health.dart';

/// Wraps the `health` plugin (Apple HealthKit on iOS, Google Health Connect
/// on Android) to read today's step count.
///
/// Only iOS and Android are supported by the underlying plugin -- callers
/// must check [isSupported] before showing any related UI, since there is
/// no HealthKit or Health Connect equivalent on web or desktop.
///
/// This performs an on-demand pull ("sync now"), not a continuous
/// background sync: true background health sync needs platform-specific
/// background task scheduling beyond what this prototype sets up.
class HealthSyncService {
  static bool get isSupported {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  final Health _health = Health();
  bool _configured = false;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  /// True if step-read permission is already granted, without prompting.
  /// Safe to call silently (e.g. when a screen opens) since it never shows
  /// a permission dialog.
  Future<bool> hasPermissionAlready() async {
    if (!isSupported) return false;
    try {
      await _ensureConfigured();
      return await _health.hasPermissions(const [HealthDataType.STEPS]) == true;
    } catch (_) {
      return false;
    }
  }

  /// Requests permission to read step data. Returns true if granted (or
  /// already granted), false if denied or unsupported on this platform.
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    try {
      await _ensureConfigured();
      const types = [HealthDataType.STEPS];
      final alreadyGranted = await _health.hasPermissions(types);
      if (alreadyGranted == true) return true;
      return await _health.requestAuthorization(types);
    } catch (_) {
      return false;
    }
  }

  /// Fetches today's total step count (midnight to now) from Health
  /// Connect / Apple Health, or null if unsupported, unauthorized, or the
  /// read failed for any reason.
  Future<int?> fetchTodaySteps() async {
    if (!isSupported) return null;
    try {
      await _ensureConfigured();
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      return await _health.getTotalStepsInInterval(midnight, now);
    } catch (_) {
      return null;
    }
  }
}
