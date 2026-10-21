import 'category.dart';

/// One CS2 tournament. Immutable: a change is a new Tournament via copyWith.
class Tournament {
  const Tournament({
    required this.id,
    required this.title,
    required this.category,
    required this.startsAt,
    required this.slots,
    required this.online,
    required this.place,
    this.description,
    this.favourite = false,
    List<String> players = const [],
    // A named parameter cannot be private, so the field is set here.
    // ignore: prefer_initializing_formals
  }) : _players = players;

  /// Defaults for the "new tournament" form.
  Tournament.empty()
    : id = '',
      title = '',
      category = Category.premier,
      startsAt = DateTime.now().add(const Duration(days: 1)),
      slots = 10,
      online = false,
      place = '',
      description = null,
      favourite = false,
      _players = const [];

  final String id;
  final String title;
  final Category category;
  final DateTime startsAt;

  /// The limit the players list counts against.
  final int slots;

  /// Mode: online means [place] is a link (Discord / FACEIT lobby).
  final bool online;
  final String place;
  final String? description;
  final bool favourite;
  final List<String> _players;

  /// Read-only view: nobody outside can add to the list in place.
  List<String> get players => List.unmodifiable(_players);

  // Derived values are getters, never fields.
  int get count => _players.length;
  int get free => slots - count < 0 ? 0 : slots - count;
  bool get isFull => count >= slots;
  bool get isPast => startsAt.isBefore(DateTime.now());
  bool contains(String name) => _players.contains(name);

  /// Both numbers at once, as a record.
  ({int taken, int free}) get places => (taken: count, free: free);

  Tournament copyWith({
    String? id,
    String? title,
    Category? category,
    DateTime? startsAt,
    int? slots,
    bool? online,
    String? place,
    String? description,
    bool clearDescription = false,
    bool? favourite,
    List<String>? players,
  }) => Tournament(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    startsAt: startsAt ?? this.startsAt,
    slots: slots ?? this.slots,
    online: online ?? this.online,
    place: place ?? this.place,
    description: clearDescription ? null : description ?? this.description,
    favourite: favourite ?? this.favourite,
    players: players ?? _players,
  );
}
