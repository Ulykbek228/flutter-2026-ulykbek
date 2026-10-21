import 'package:flutter/material.dart';

import '../models/tournament.dart';
import '../widgets/empty_state.dart';
import '../widgets/tournament_card.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.tournaments,
    required this.onOpen,
    required this.onToggleFavourite,
    required this.onBrowse,
  });

  final List<Tournament> tournaments;
  final ValueChanged<Tournament> onOpen;
  final ValueChanged<String> onToggleFavourite;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final favourites = tournaments.where((t) => t.favourite).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.star_border,
        message: 'No favourites yet',
        actionLabel: 'Browse tournaments',
        onAction: onBrowse,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: favourites.length,
      itemBuilder: (context, i) => TournamentCard(
        tournament: favourites[i],
        onTap: () => onOpen(favourites[i]),
        onToggleFavourite: () => onToggleFavourite(favourites[i].id),
      ),
      separatorBuilder: (context, i) => const SizedBox(height: 4),
    );
  }
}
