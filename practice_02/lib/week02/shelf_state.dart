// Level 5 — Dart 3: sealed classes, patterns, records.

import 'models.dart';

/// sealed: the compiler knows every subtype, so a switch over
/// ShelfState must handle all of them — no default needed.
sealed class ShelfState {
  const ShelfState();
}

class Empty extends ShelfState {
  const Empty();
}

class Ready extends ShelfState {
  const Ready(this.books);

  final List<Book> books;
}

class Broken extends ShelfState {
  const Broken(this.message);

  final String message;
}

/// Switch expression with object patterns, and no default.
String describe(ShelfState state) => switch (state) {
  Empty() => 'Shelf is empty',
  Ready(:final books) => 'Shelf is ready with ${books.length} books',
  Broken(:final message) => 'Shelf is broken: $message',
};

/// Two numbers returned together as a record — not a class, not a List.
({int count, double avgPages}) statsOf(List<Book> books) => (
  count: books.length,
  avgPages: books.isEmpty
      ? 0
      : books.fold<int>(0, (sum, book) => sum + book.pages) / books.length,
);
