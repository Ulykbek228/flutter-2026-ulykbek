// Level 3 — null safety. Level 4 — collections.

import 'models.dart';

class Library {
  final List<LibraryItem> items = [];

  /// Assigned once in [open], not in the constructor.
  late final DateTime openedAt;

  /// Filled with ??= the first time the report is built.
  String? _cachedReport;

  void add(LibraryItem item) => items.add(item);

  void open() => openedAt = DateTime.now();

  Iterable<Book> get books => items.whereType<Book>();

  /// Returns null when there is no such book — never throws.
  Book? findByTitle(String title) =>
      books.where((book) => book.title == title).firstOrNull;

  /// One expression: ?. stops at a missing book, ?? covers both
  /// a missing book and a book whose author has no country.
  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';

  // ---- Level 4: one expression each, no for loops ----

  List<String> get titles => items.map((item) => item.title).toList();

  List<Book> get booksAfter2010 =>
      books.where((book) => book.year > 2010).toList();

  // fold, not reduce: reduce must return the element type (Book) and
  // throws on an empty list; fold starts from 0 and sums into an int.
  double get averagePages => books.isEmpty
      ? 0
      : books.fold<int>(0, (sum, book) => sum + book.pages) / books.length;

  Map<String, int> get booksPerAuthor => books.fold(
    <String, int>{},
    (counts, book) =>
        counts..update(book.author.name, (n) => n + 1, ifAbsent: () => 1),
  );

  Set<String> get authorNames => books.map((book) => book.author.name).toSet();

  Set<Genre> get genres => books.map((book) => book.genre).toSet();

  /// One display list, built as a single literal.
  List<String> get displayLines => [
    'CATALOGUE',
    for (final book in books) '${book.title} (${book.year})',
    ...authorNames,
    if (books.any((book) => book.pages == 0)) '(incomplete data)',
  ];

  /// Built once, then served from the cache.
  String report() => _cachedReport ??= displayLines.join('\n');
}
