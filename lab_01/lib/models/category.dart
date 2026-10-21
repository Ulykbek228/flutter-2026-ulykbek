import 'package:flutter/material.dart';

enum Category {
  premier('Premier 5v5', Icons.emoji_events),
  wingman('Wingman 2v2', Icons.people),
  aimDuel('Aim duel 1v1', Icons.gps_fixed),
  retake('Retakes', Icons.replay),
  deathmatch('Deathmatch', Icons.whatshot),
  surf('Surf & KZ', Icons.waves);

  const Category(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    Category.premier => scheme.primary,
    Category.wingman => scheme.secondary,
    Category.aimDuel => scheme.tertiary,
    Category.retake => scheme.error,
    Category.deathmatch => scheme.inversePrimary,
    Category.surf => scheme.outline,
  };
}
