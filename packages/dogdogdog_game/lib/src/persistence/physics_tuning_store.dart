import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../config/physics_tuning.dart';

/// Saves debug physics slider values between runs.
class PhysicsTuningStore {
  PhysicsTuningStore({
    this.preferences,
    this.storageKey = 'dogdogdog_physics_tuning',
  });

  final SharedPreferences? preferences;
  final String storageKey;

  Future<SharedPreferences> _prefs() async {
    return preferences ?? SharedPreferences.getInstance();
  }

  /// Restores a saved tuning into [tuning]. Returns false when nothing is stored.
  Future<bool> restore(PhysicsTuning tuning) async {
    final prefs = await _prefs();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return false;
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return false;
    }
    tuning.applyJson(decoded.cast<String, dynamic>());
    return true;
  }

  Future<void> save(PhysicsTuning tuning) async {
    final prefs = await _prefs();
    await prefs.setString(storageKey, jsonEncode(tuning.toJson()));
  }

  Future<void> clear() async {
    final prefs = await _prefs();
    await prefs.remove(storageKey);
  }
}
