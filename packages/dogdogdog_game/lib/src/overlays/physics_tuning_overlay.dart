import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/physics_tuning.dart';
import '../game/dogdogdog_game.dart';

/// Debug/profile panel for live physics values.
///
/// Release builds do not register this overlay.
class PhysicsTuningOverlay extends StatefulWidget {
  const PhysicsTuningOverlay({required this.game, super.key});

  final DogDogDogGame game;

  @override
  State<PhysicsTuningOverlay> createState() => _PhysicsTuningOverlayState();
}

class _PhysicsTuningOverlayState extends State<PhysicsTuningOverlay> {
  String? _copiedLabel;

  PhysicsTuning get tuning => widget.game.tuning;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: const Color(0xF02A2A40),
        child: SafeArea(
          child: SizedBox(
            width: 320,
            child: AnimatedBuilder(
              animation: tuning,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 4, 4),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Physics',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close',
                            onPressed: widget.game.togglePhysicsTuning,
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        'Long-press the score, or Shift+P.',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        children: [
                          for (final spec in _sliders)
                            _TuneSlider(tuning: tuning, spec: spec),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_copiedLabel != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                _copiedLabel!,
                                style: const TextStyle(
                                  color: Color(0xFFFFCC80),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          FilledButton(
                            onPressed: widget.game.resetPhysicsTuning,
                            child: const Text('Reset to defaults'),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _copy,
                            child: const Text('Copy values'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: tuning.toDartSnippet()));
    if (!mounted) {
      return;
    }
    setState(() => _copiedLabel = 'Copied a PhysicsConfig snippet.');
  }
}

class _TuneSpec {
  const _TuneSpec({
    required this.label,
    required this.min,
    required this.max,
    required this.read,
    required this.write,
    this.decimals = 2,
    this.divisions,
  });

  final String label;
  final double min;
  final double max;
  final double Function(PhysicsTuning tuning) read;
  final void Function(PhysicsTuning tuning, double value) write;
  final int decimals;
  final int? divisions;
}

const List<_TuneSpec> _sliders = [
  _TuneSpec(
    label: 'Bounciness',
    min: 0,
    max: 1,
    read: _readRestitution,
    write: _writeRestitution,
  ),
  _TuneSpec(
    label: 'Friction',
    min: 0,
    max: 1.5,
    read: _readFriction,
    write: _writeFriction,
  ),
  _TuneSpec(
    label: 'Wall bounciness',
    min: 0,
    max: 1,
    read: _readWallRestitution,
    write: _writeWallRestitution,
  ),
  _TuneSpec(
    label: 'Wall friction',
    min: 0,
    max: 1.5,
    read: _readWallFriction,
    write: _writeWallFriction,
  ),
  _TuneSpec(
    label: 'Base density',
    min: 0.05,
    max: 8,
    read: _readDensity,
    write: _writeDensity,
  ),
  _TuneSpec(
    label: 'Density falloff',
    min: 0,
    max: 3,
    read: _readFalloff,
    write: _writeFalloff,
  ),
  _TuneSpec(
    label: 'Linear damping',
    min: 0,
    max: 2,
    read: _readLinear,
    write: _writeLinear,
  ),
  _TuneSpec(
    label: 'Angular damping',
    min: 0,
    max: 4,
    read: _readAngular,
    write: _writeAngular,
  ),
  _TuneSpec(
    label: 'Gravity',
    min: 5,
    max: 80,
    read: _readGravity,
    write: _writeGravity,
    decimals: 0,
  ),
  _TuneSpec(
    label: 'Solver sub-steps',
    min: 1,
    max: 12,
    divisions: 11,
    read: _readSubSteps,
    write: _writeSubSteps,
    decimals: 0,
  ),
  _TuneSpec(
    label: 'Overlap correction',
    min: 1,
    max: 24,
    divisions: 23,
    read: _readOverlap,
    write: _writeOverlap,
    decimals: 0,
  ),
];

double _readRestitution(PhysicsTuning tuning) => tuning.restitution;
void _writeRestitution(PhysicsTuning tuning, double value) =>
    tuning.setRestitution(value);
double _readFriction(PhysicsTuning tuning) => tuning.friction;
void _writeFriction(PhysicsTuning tuning, double value) =>
    tuning.setFriction(value);
double _readWallRestitution(PhysicsTuning tuning) => tuning.wallRestitution;
void _writeWallRestitution(PhysicsTuning tuning, double value) =>
    tuning.setWallRestitution(value);
double _readWallFriction(PhysicsTuning tuning) => tuning.wallFriction;
void _writeWallFriction(PhysicsTuning tuning, double value) =>
    tuning.setWallFriction(value);
double _readDensity(PhysicsTuning tuning) => tuning.baseDensity;
void _writeDensity(PhysicsTuning tuning, double value) =>
    tuning.setBaseDensity(value);
double _readFalloff(PhysicsTuning tuning) => tuning.densityFalloff;
void _writeFalloff(PhysicsTuning tuning, double value) =>
    tuning.setDensityFalloff(value);
double _readLinear(PhysicsTuning tuning) => tuning.linearDamping;
void _writeLinear(PhysicsTuning tuning, double value) =>
    tuning.setLinearDamping(value);
double _readAngular(PhysicsTuning tuning) => tuning.angularDamping;
void _writeAngular(PhysicsTuning tuning, double value) =>
    tuning.setAngularDamping(value);
double _readGravity(PhysicsTuning tuning) => tuning.gravityY;
void _writeGravity(PhysicsTuning tuning, double value) =>
    tuning.setGravityY(value);
double _readSubSteps(PhysicsTuning tuning) => tuning.subStepCount.toDouble();
void _writeSubSteps(PhysicsTuning tuning, double value) =>
    tuning.setSubStepCount(value.round());
double _readOverlap(PhysicsTuning tuning) =>
    tuning.overlapIterations.toDouble();
void _writeOverlap(PhysicsTuning tuning, double value) =>
    tuning.setOverlapIterations(value.round());

class _TuneSlider extends StatelessWidget {
  const _TuneSlider({required this.tuning, required this.spec});

  final PhysicsTuning tuning;
  final _TuneSpec spec;

  @override
  Widget build(BuildContext context) {
    final value = spec.read(tuning).clamp(spec.min, spec.max);
    final shown = spec.decimals == 0
        ? value.round().toString()
        : value.toStringAsFixed(spec.decimals);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  spec.label,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              Text(
                shown,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: spec.min,
            max: spec.max,
            divisions: spec.divisions,
            onChanged: (next) => spec.write(tuning, next),
          ),
        ],
      ),
    );
  }
}
