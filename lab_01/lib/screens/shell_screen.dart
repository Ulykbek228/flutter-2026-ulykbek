import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/category.dart';
import '../models/profile.dart';
import '../models/tournament.dart';
import '../routes.dart';
import 'favourites_tab.dart';
import 'list_tab.dart';
import 'profile_tab.dart';

/// Owns the data: the tournaments and the profile live here.
/// Tabs get them through constructors and send changes up as callbacks.
class ShellScreen extends StatefulWidget {
  const ShellScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  List<Tournament> _tournaments = seedTournaments();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  // The route caches this screen, so it mirrors the mode it shows in Profile.
  late ThemeMode _themeMode = widget.themeMode;

  static const _titles = ['Tournaments', 'Favourites', 'Profile'];

  void _update(Tournament t) => setState(
    () => _tournaments = [for (final x in _tournaments) x.id == t.id ? t : x],
  );

  void _toggleFavourite(String id) => setState(
    () => _tournaments = [
      for (final x in _tournaments)
        x.id == id ? x.copyWith(favourite: !x.favourite) : x,
    ],
  );

  void _delete(String id) => setState(
    () => _tournaments = _tournaments.where((x) => x.id != id).toList(),
  );

  void _goToTab(int i) => setState(() => _tab = i);

  void _setProfile(Profile p) => setState(() => _profile = p);

  void _setThemeMode(ThemeMode m) {
    setState(() => _themeMode = m);
    widget.onThemeModeChanged(m);
  }

  void _open(Tournament t) => Navigator.of(context).pushNamed(
    Routes.detail,
    arguments: DetailArgs(
      tournament: t,
      profile: _profile,
      onChanged: _update,
      onDelete: _delete,
      onOpenProfile: () => _goToTab(2),
    ),
  );

  Future<void> _create() async {
    final created = await Navigator.of(context)
        .pushNamed<Tournament>(Routes.form, arguments: const FormArgs());
    if (created == null || !mounted) return;
    setState(() => _tournaments = [..._tournaments, created]);
  }

  void _about() {
    Navigator.of(context).pop(); // close the drawer
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CS2 Cups'),
        content: Text(
          'Student CS2 tournaments: ${Category.values.length} formats, '
          'join with your nickname.\nLab 1 · Mobile Development with Flutter.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _reset() async {
    Navigator.of(context).pop(); // close the drawer
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'All tournaments go back and the profile is cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      _tournaments = seedTournaments();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_titles[_tab])),
    drawer: Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'CS2 Cups',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: _about,
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text('Reset data'),
            onTap: _reset,
          ),
        ],
      ),
    ),
    // IndexedStack keeps every tab alive: search text and scroll survive.
    body: IndexedStack(
      index: _tab,
      children: [
        ListTab(
          tournaments: _tournaments,
          onOpen: _open,
          onToggleFavourite: _toggleFavourite,
        ),
        FavouritesTab(
          tournaments: _tournaments,
          onOpen: _open,
          onToggleFavourite: _toggleFavourite,
          onBrowse: () => _goToTab(0),
        ),
        ProfileTab(
          profile: _profile,
          tournaments: _tournaments,
          themeMode: _themeMode,
          onChanged: _setProfile,
          onThemeModeChanged: _setThemeMode,
        ),
      ],
    ),
    floatingActionButton: _tab == 0
        ? FloatingActionButton.extended(
            onPressed: _create,
            icon: const Icon(Icons.add),
            label: const Text('New'),
          )
        : null,
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: _goToTab,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.sports_esports_outlined),
          selectedIcon: Icon(Icons.sports_esports),
          label: 'Tournaments',
        ),
        NavigationDestination(
          icon: Icon(Icons.star_border),
          selectedIcon: Icon(Icons.star),
          label: 'Favourites',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    ),
  );
}
