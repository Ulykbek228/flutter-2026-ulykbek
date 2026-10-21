import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/tournament.dart';

/// Tab 3: nickname, group and the theme.
class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.tournaments,
    required this.themeMode,
    required this.onChanged,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<Tournament> tournaments;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.name);
  late final _group = TextEditingController(text: widget.profile.group);

  static final _groupPattern = RegExp(r'^[A-Z]{2,5}-\d{4}$');

  @override
  void didUpdateWidget(ProfileTab old) {
    super.didUpdateWidget(old);
    // "Reset data" in the drawer clears the profile from above.
    if (old.profile.name != widget.profile.name) {
      _name.text = widget.profile.name;
    }
    if (old.profile.group != widget.profile.group) {
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    super.dispose();
  }

  void _saveName(String value) =>
      widget.onChanged(widget.profile.copyWith(name: value.trim()));

  void _saveGroup(String value) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onChanged(widget.profile.copyWith(group: value.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.profile.name;
    final lists = name.isEmpty
        ? 0
        : widget.tournaments.where((t) => t.contains(name)).length;
    final text = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _name,
            textInputAction: TextInputAction.next,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: const InputDecoration(
              labelText: 'Nickname',
              helperText: 'Press Enter to save',
              border: OutlineInputBorder(),
            ),
            onFieldSubmitted: _saveName,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _group,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.characters,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: const InputDecoration(
              labelText: 'Group',
              hintText: 'IT-2302',
              helperText: 'Press Enter to save',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                v == null || v.isEmpty || _groupPattern.hasMatch(v.trim())
                ? null
                : 'Format: IT-2302',
            onFieldSubmitted: _saveGroup,
          ),
          const SizedBox(height: 24),
          Text(
            name.isEmpty
                ? 'Set a nickname to join tournaments'
                : 'You are on $lists ${lists == 1 ? 'list' : 'lists'}',
            style: text.titleMedium,
          ),
          const SizedBox(height: 24),
          Text('Theme', style: text.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final (mode, label) in const [
                (ThemeMode.system, 'System'),
                (ThemeMode.light, 'Light'),
                (ThemeMode.dark, 'Dark'),
              ])
                ChoiceChip(
                  label: Text(label),
                  selected: widget.themeMode == mode,
                  onSelected: (_) => widget.onThemeModeChanged(mode),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
