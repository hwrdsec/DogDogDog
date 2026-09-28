/// Tracks continuous time each body spends in the danger zone.
///
/// Call [update] each frame with the set of body ids currently above the
/// danger line (already filtered — e.g. excluding a still-falling drop).
/// Returns a triggering id once any body has stayed above for
/// [gracePeriodSeconds].
class DangerMonitor {
  DangerMonitor({required this.gracePeriodSeconds})
    : assert(gracePeriodSeconds >= 0);

  final double gracePeriodSeconds;

  final Map<int, double> _elapsed = {};

  /// Seconds each tracked id has been continuously above the line.
  Map<int, double> get elapsedById => Map.unmodifiable(_elapsed);

  void reset() => _elapsed.clear();

  /// Advances timers for [currentlyAbove]. Returns a triggering id, or null.
  int? update(Set<int> currentlyAbove, double dt) {
    if (dt < 0) {
      return null;
    }

    _elapsed.removeWhere((id, _) => !currentlyAbove.contains(id));

    for (final id in currentlyAbove) {
      final next = (_elapsed[id] ?? 0) + dt;
      _elapsed[id] = next;
      if (next >= gracePeriodSeconds) {
        return id;
      }
    }
    return null;
  }
}
