import 'package:flutter/material.dart';

import '../models/tournament.dart';

class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({super.key, required this.tournament});

  final Tournament tournament;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final color = tournament.category.color(scheme);
    final (:taken, :free) = tournament.places;
    final badge = tournament.isFull
        ? 'FULL'
        : free <= 5
        ? '$free left'
        : null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withValues(alpha: 0.18),
          child: Icon(tournament.category.icon, color: color),
        ),
        if (badge != null)
          Positioned(
            right: -10,
            bottom: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: tournament.isFull ? scheme.error : scheme.tertiary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: scheme.surface, width: 2),
              ),
              child: Text(
                badge,
                style: text.labelSmall?.copyWith(
                  color: tournament.isFull ? scheme.onError : scheme.onTertiary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
