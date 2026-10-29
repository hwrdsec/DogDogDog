import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'physics_config.dart';

/// Live physics values shared by the game and the debug tuning panel.
///
/// Starts from [PhysicsConfig.defaults]. Slider changes notify listeners so
/// dogs already on the field can pick up the new numbers.
class PhysicsTuning extends ChangeNotifier {
  PhysicsTuning({PhysicsConfig initial = PhysicsConfig.defaults}) {
    applyConfig(initial, notify: false);
  }

  late double gravityY;
  late double restitution;
  late double friction;
  late double wallRestitution;
  late double wallFriction;
  late double baseDensity;
  late double densityFalloff;
  late double linearDamping;
  late double angularDamping;
  late int subStepCount;
  late int overlapIterations;

  void applyConfig(PhysicsConfig config, {bool notify = true}) {
    gravityY = config.gravityY;
    restitution = config.ballRestitution;
    friction = config.ballFriction;
    wallRestitution = config.wallRestitution;
    wallFriction = config.wallFriction;
    baseDensity = config.ballDensity;
    densityFalloff = config.densityFalloff;
    linearDamping = config.ballLinearDamping;
    angularDamping = config.ballAngularDamping;
    subStepCount = config.subStepCount;
    overlapIterations = config.overlapIterations;
    if (notify) {
      notifyListeners();
    }
  }

  void reset() => applyConfig(PhysicsConfig.defaults);

  double densityForLevel(int level) {
    return PhysicsConfig.densityFor(
      level: level,
      baseDensity: baseDensity,
      falloff: densityFalloff,
    );
  }

  void setGravityY(double value) => _set(() => gravityY = value);
  void setRestitution(double value) => _set(() => restitution = value);
  void setFriction(double value) => _set(() => friction = value);
  void setWallRestitution(double value) => _set(() => wallRestitution = value);
  void setWallFriction(double value) => _set(() => wallFriction = value);
  void setBaseDensity(double value) => _set(() => baseDensity = value);
  void setDensityFalloff(double value) => _set(() => densityFalloff = value);
  void setLinearDamping(double value) => _set(() => linearDamping = value);
  void setAngularDamping(double value) => _set(() => angularDamping = value);

  void setSubStepCount(int value) => _set(() => subStepCount = value);
  void setOverlapIterations(int value) => _set(() => overlapIterations = value);

  Map<String, num> toJson() {
    return {
      'gravityY': gravityY,
      'ballRestitution': restitution,
      'ballFriction': friction,
      'wallRestitution': wallRestitution,
      'wallFriction': wallFriction,
      'ballDensity': baseDensity,
      'densityFalloff': densityFalloff,
      'ballLinearDamping': linearDamping,
      'ballAngularDamping': angularDamping,
      'subStepCount': subStepCount,
      'overlapIterations': overlapIterations,
    };
  }

  /// Applies keys written by [toJson]. Unknown keys are ignored.
  void applyJson(Map<String, dynamic> json) {
    gravityY = _asDouble(json['gravityY'], gravityY);
    restitution = _asDouble(json['ballRestitution'], restitution);
    friction = _asDouble(json['ballFriction'], friction);
    wallRestitution = _asDouble(json['wallRestitution'], wallRestitution);
    wallFriction = _asDouble(json['wallFriction'], wallFriction);
    baseDensity = _asDouble(json['ballDensity'], baseDensity);
    densityFalloff = _asDouble(json['densityFalloff'], densityFalloff);
    linearDamping = _asDouble(json['ballLinearDamping'], linearDamping);
    angularDamping = _asDouble(json['ballAngularDamping'], angularDamping);
    subStepCount = _asInt(json['subStepCount'], subStepCount);
    overlapIterations = _asInt(json['overlapIterations'], overlapIterations);
    notifyListeners();
  }

  /// Dart constructor text a tester can paste back to lock in new defaults.
  String toDartSnippet() {
    final values = toJson();
    final lines = values.entries
        .map((entry) => '  ${entry.key}: ${_format(entry.value)},')
        .join('\n');
    return 'PhysicsConfig(\n$lines\n)';
  }

  String toJsonText() => const JsonEncoder.withIndent('  ').convert(toJson());

  void _set(void Function() change) {
    change();
    notifyListeners();
  }

  static double _asDouble(Object? value, double fallback) {
    if (value is num) {
      return value.toDouble();
    }
    return fallback;
  }

  static int _asInt(Object? value, int fallback) {
    if (value is num) {
      return value.round();
    }
    return fallback;
  }

  static String _format(num value) {
    if (value is int) {
      return value.toString();
    }
    final text = value.toStringAsFixed(4);
    return text
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}
