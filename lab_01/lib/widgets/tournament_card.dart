import 'package:flutter/material.dart';

import '../models/tournament.dart';
import '../utils/format.dart';
import 'category_avatar.dart';

class TournamentCard extends StatelessWidget {
  const TournamentCard({
    super.key,
    required this.tournament,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final Tournament tournament;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final t = tournament;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
          child: Row(
            children: [
              CategoryAvatar(tournament: t),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.isPast
                          ? '${formatDate(t.startsAt)} · finished'
                          : formatDate(t.startsAt),
                      style: text.bodySmall?.copyWith(
                        color: t.isPast ? scheme.outline : scheme.primary,
                      ),
                    ),
                    Text(
                      t.online ? 'Online' : t.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleFavourite,
                tooltip: t.favourite ? 'Remove from favourites' : 'Favourite',
                icon: Icon(
                  t.favourite ? Icons.star : Icons.star_border,
                  color: t.favourite ? scheme.tertiary : scheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
