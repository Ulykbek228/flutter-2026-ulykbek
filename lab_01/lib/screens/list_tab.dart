import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/tournament.dart';
import '../widgets/empty_state.dart';
import '../widgets/tournament_card.dart';

class ListTab extends StatefulWidget {
  const ListTab({
    super.key,
    required this.tournaments,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<Tournament> tournaments;
  final ValueChanged<Tournament> onOpen;
  final ValueChanged<String> onToggleFavourite;

  @override
  State<ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> {
  final _search = TextEditingController();
  Category? _category;
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Tournament> get _visible {
    final query = _search.text.trim().toLowerCase();
    final list = widget.tournaments
        .where((t) => query.isEmpty || t.title.toLowerCase().contains(query))
        .where((t) => _category == null || t.category == _category)
        .where((t) => _showPast || !t.isPast)
        .toList();
    return list..sort(_byDate);
  }

  static int _byDate(Tournament a, Tournament b) {
    if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
    return a.startsAt.compareTo(b.startsAt);
  }

  void _clearSearch() {
    _search.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              hintText: 'Search tournaments',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              for (final c in Category.values)
                ChoiceChip(
                  avatar: Icon(c.icon),
                  label: Text(c.label),
                  selected: _category == c,
                  onSelected: (_) => setState(() => _category = c),
                ),
              FilterChip(
                label: const Text('Show past'),
                selected: _showPast,
                onSelected: (v) => setState(() => _showPast = v),
              ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No tournaments match',
                  actionLabel: _search.text.isEmpty ? null : 'Clear search',
                  onAction: _clearSearch,
                )
              : LayoutBuilder(
                  builder: (context, constraints) => constraints.maxWidth >= 600
                      ? _grid(visible)
                      : _list(visible),
                ),
        ),
      ],
    );
  }

  Widget _card(Tournament t) => TournamentCard(
    tournament: t,
    onTap: () => widget.onOpen(t),
    onToggleFavourite: () => widget.onToggleFavourite(t.id),
  );

  Widget _list(List<Tournament> items) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
    itemCount: items.length,
    itemBuilder: (context, i) => _card(items[i]),
    separatorBuilder: (context, i) => const SizedBox(height: 4),
  );

  Widget _grid(List<Tournament> items) => GridView.builder(
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 360,
      mainAxisExtent: 136,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
    ),
    itemCount: items.length,
    itemBuilder: (context, i) => _card(items[i]),
  );
}
