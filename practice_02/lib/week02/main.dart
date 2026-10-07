import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';

void main() {
  final library = Library()..open();
  for (final json in rawBooks) {
    library.add(Book.fromJson(json));
  }
  library
    ..add(const Magazine(title: 'Flutter Weekly', year: 2025, issue: 42))
    ..add(const Ghost(title: 'Invisible Book', year: 1990));

  print('Opened at: ${library.openedAt}\n');

  print('--- Items ---');
  for (final item in library.items) {
    print('${item.describe()}${item.isOld ? '  [old]' : ''}');
  }

  final cleanCode = library.findByTitle('Clean Code');
  print('\n--- Level 1-3 ---');
  print('findByTitle(Clean Code): $cleanCode');
  print('isLong: ${cleanCode?.isLong}');
  print('borrowLabel: ${cleanCode?.borrowLabel()}');
  print('copyWith(year: 2025): ${cleanCode?.copyWith(year: 2025)}');
  print('findByTitle(Missing): ${library.findByTitle('Missing')}');
  print('countryOf(Refactoring): ${library.countryOf('Refactoring')}');
  print('countryOf(Design Patterns): ${library.countryOf('Design Patterns')}');
  print('countryOf(Missing): ${library.countryOf('Missing')}');

  print('\n--- Level 4 ---');
  print('Titles: ${library.titles}');
  print('After 2010: ${library.booksAfter2010.map((b) => b.title).toList()}');
  print('Average pages: ${library.averagePages.toStringAsFixed(1)}');
  print('Books per author: ${library.booksPerAuthor}');
  print('Authors: ${library.authorNames}');
  print('Genres: ${library.genres.map((g) => g.label).toSet()}');

  print('\n--- Report ---');
  print(library.report());

  print('\n--- Level 5 ---');
  final books = library.books.toList();
  final (:count, :avgPages) = statsOf(books);
  print('statsOf: count=$count, avgPages=${avgPages.toStringAsFixed(1)}');

  final states = <ShelfState>[
    const Empty(),
    Ready(books),
    const Broken('a shelf fell off the wall'),
  ];
  for (final state in states) {
    print(describe(state));
  }
}
