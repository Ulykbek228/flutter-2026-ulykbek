// Level 1 — classes and constructors.
// Level 2 — hierarchy: abstract, extends, implements, mixin.

class Author {
  const Author(this.name, {this.country});

  final String name;
  final String? country;

  @override
  String toString() => 'Author($name, ${country ?? 'unknown country'})';
}

enum Genre {
  craft('Craft'),
  theory('Theory'),
  unknown('Unknown');

  const Genre(this.label);

  final String label;

  /// Anything unexpected — including null — becomes [Genre.unknown].
  static Genre fromString(String? raw) => switch (raw) {
    'craft' => Genre.craft,
    'theory' => Genre.theory,
    _ => Genre.unknown,
  };
}

/// Everything the catalogue can hold.
abstract class LibraryItem {
  const LibraryItem({required this.title, required this.year});

  final String title;
  final int year;

  /// Abstract: every subclass must say how it describes itself.
  String describe();

  /// Has a body, so subclasses inherit it for free.
  bool get isOld => year < 2000;
}

/// `with` — "this can also do". Only usable on a LibraryItem,
/// because it reads [title] from it.
mixin Borrowable on LibraryItem {
  String borrowLabel() => 'Borrow "$title"';
}

/// `extends` — "this is a kind of" LibraryItem.
class Book extends LibraryItem with Borrowable {
  const Book({
    required super.title,
    required super.year,
    required this.pages,
    required this.author,
    required this.genre,
    this.description,
  });

  /// All defaults for missing keys live here, not in every caller.
  /// Survives both incomplete entries from the starter data.
  factory Book.fromJson(Map<String, dynamic> json) => Book(
    title: json['title'] as String? ?? 'Untitled',
    year: json['year'] as int? ?? 0,
    pages: json['pages'] as int? ?? 0,
    author: Author(
      json['author'] as String? ?? 'Unknown',
      country: json['country'] as String?,
    ),
    genre: Genre.fromString(json['genre'] as String?),
    description: json['description'] as String?,
  );

  final int pages;
  final Author author;
  final Genre genre;
  final String? description;

  bool get isLong => pages > 400;

  Book copyWith({
    String? title,
    int? year,
    int? pages,
    Author? author,
    Genre? genre,
    String? description,
  }) => Book(
    title: title ?? this.title,
    year: year ?? this.year,
    pages: pages ?? this.pages,
    author: author ?? this.author,
    genre: genre ?? this.genre,
    description: description ?? this.description,
  );

  @override
  String describe() {
    // A public field is not promoted by a null check — copy it into a local.
    final text = description;
    final base =
        '$title by ${author.name} ($year), $pages pages, ${genre.label}';
    return text == null ? base : '$base — $text';
  }

  @override
  String toString() =>
      'Book($title, $year, $pages p., ${author.name}, '
      '${genre.name})';
}

class Magazine extends LibraryItem {
  const Magazine({
    required super.title,
    required super.year,
    required this.issue,
  });

  final int issue;

  @override
  String describe() => '$title #$issue ($year)';

  @override
  String toString() => 'Magazine($title, #$issue, $year)';
}

/// `implements` — "this behaves like" a LibraryItem.
/// Only the contract is taken; every member is written here by hand.
class Ghost implements LibraryItem {
  const Ghost({required this.title, required this.year});

  @override
  final String title;

  @override
  final int year;

  @override
  String describe() => 'Ghost "$title" — nothing inherited';

  @override
  bool get isOld => year < 2000;

  @override
  String toString() => 'Ghost($title, $year)';
}
