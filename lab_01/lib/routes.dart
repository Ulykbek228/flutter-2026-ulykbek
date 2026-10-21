import 'package:flutter/foundation.dart';

import 'models/profile.dart';
import 'models/tournament.dart';

abstract final class Routes {
  static const shell = '/';
  static const detail = '/tournament';
  static const form = '/tournament/form';
}

class DetailArgs {
  const DetailArgs({
    required this.tournament,
    required this.profile,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final Tournament tournament;
  final Profile profile;
  final ValueChanged<Tournament> onChanged;
  final ValueChanged<String> onDelete;
  final VoidCallback onOpenProfile;
}

class FormArgs {
  const FormArgs({this.tournament});
  final Tournament? tournament;
}
