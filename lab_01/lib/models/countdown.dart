/// Where a tournament is in time. sealed: a switch must cover all three.
sealed class Countdown {
  const Countdown();

  /// A match night lasts about three hours.
  static const length = Duration(hours: 3);

  factory Countdown.of(DateTime startsAt, {DateTime? now}) {
    final current = now ?? DateTime.now();
    if (current.isBefore(startsAt)) {
      return Upcoming(startsAt.difference(current));
    }
    final since = current.difference(startsAt);
    return since < length ? Started(since) : const Ended();
  }
}

class Upcoming extends Countdown {
  const Upcoming(this.left);
  final Duration left;
}

class Started extends Countdown {
  const Started(this.since);
  final Duration since;
}

class Ended extends Countdown {
  const Ended();
}
