import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/tournament.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Tournament _t = widget.args.tournament;
  Timer? _timer;

  String get _me => widget.args.profile.name;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _apply(Tournament t) {
    setState(() => _t = t);
    widget.args.onChanged(t);
  }

  void _openProfile() {
    Navigator.of(context).pop();
    widget.args.onOpenProfile();
  }

  Future<void> _join() async {
    if (widget.args.profile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Set your nickname in Profile first'),
          action: SnackBarAction(label: 'Profile', onPressed: _openProfile),
        ),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Join ${_t.title}?'),
        content: Text('You will play as $_me.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Join'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    _apply(_t.copyWith(players: [..._t.players, _me]));
  }

  void _leave() =>
      _apply(_t.copyWith(players: _t.players.where((p) => p != _me).toList()));

  Future<void> _edit() async {
    final edited = await Navigator.of(
      context,
    ).pushNamed<Tournament>(Routes.form, arguments: FormArgs(tournament: _t));
    if (edited == null || !mounted) return;
    _apply(edited);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${_t.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    widget.args.onDelete(_t.id);
    Navigator.of(context).pop();
  }

  String _countdownText() => switch (Countdown.of(_t.startsAt)) {
    Upcoming(:final left) => 'In ${formatDuration(left)}',
    Started(:final since) => 'Live · ${formatDuration(since)}',
    Ended() => 'Ended',
  };

  @override
  Widget build(BuildContext context) {
    final joined = _me.isNotEmpty && _t.contains(_me);
    return Scaffold(
      appBar: AppBar(
        title: Text(_t.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => v == 'edit' ? _edit() : _delete(),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            _Header(tournament: _t, countdown: _countdownText()),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Players (${_t.count})'),
              ],
            ),
            Expanded(child: TabBarView(children: [_about(), _players()])),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: joined
              ? OutlinedButton(onPressed: _leave, child: const Text('Leave'))
              : FilledButton(
                  onPressed: _t.isFull || _t.isPast ? null : _join,
                  child: Text(_t.isFull ? 'Full' : 'Join'),
                ),
        ),
      ),
    );
  }

  Widget _about() {
    final (:taken, :free) = _t.places;
    final description = _t.description;
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.event),
          title: Text(formatDate(_t.startsAt)),
          subtitle: Text(_t.isPast ? 'Finished' : 'Starts'),
        ),
        ListTile(
          leading: Icon(_t.online ? Icons.link : Icons.place),
          title: Text(_t.place),
          subtitle: Text(_t.online ? 'Online' : 'Venue'),
        ),
        ListTile(
          leading: const Icon(Icons.groups),
          title: Text('$taken / ${_t.slots} players'),
          subtitle: Text(_t.isFull ? 'No free slots' : '$free free'),
        ),
        if (description != null)
          ListTile(leading: const Icon(Icons.notes), title: Text(description)),
      ],
    );
  }

  Widget _players() {
    if (_t.players.isEmpty) {
      return const EmptyState(
        icon: Icons.person_off_outlined,
        message: 'Nobody has joined yet',
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      children: [
        for (final name in _t.players)
          name == _me
              ? ListTile(
                  tileColor: scheme.primaryContainer,
                  leading: Icon(Icons.person, color: scheme.onPrimaryContainer),
                  title: Text(
                    '$name (You)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                )
              : ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(name),
                ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.tournament, required this.countdown});

  final Tournament tournament;
  final String countdown;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final category = tournament.category;
    return SizedBox(
      height: 170,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/header.png', fit: BoxFit.cover),
          Center(
            child: CircleAvatar(
              radius: 34,
              backgroundColor: scheme.surface,
              child: Icon(
                category.icon,
                size: 36,
                color: category.color(scheme),
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: Chip(
              avatar: Icon(category.icon),
              label: Text(category.label),
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                countdown,
                style: text.labelLarge?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
