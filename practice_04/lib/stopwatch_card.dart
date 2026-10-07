import 'dart:async';

import 'package:flutter/material.dart';

class StopwatchCard extends StatefulWidget {
  const StopwatchCard({super.key});

  @override
  State<StopwatchCard> createState() => _StopwatchCardState();
}

class _StopwatchCardState extends State<StopwatchCard> {
  int _seconds = 0;
  Timer? _timer;

  /// Computed from _seconds — a value you can compute is not state.
  String get _formatted {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  bool get _running => _timer != null;

  void _start() {
    // Already running: do not create a second timer.
    if (_running) return;
    setState(() {
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => setState(() => _seconds++),
      );
    });
  }

  void _stop() {
    _timer?.cancel();
    setState(() => _timer = null);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _timer = null;
      _seconds = 0;
    });
  }

  @override
  void dispose() {
    // Without this, the timer keeps firing after the widget is gone:
    // "setState() called after dispose()".
    _timer?.cancel();
    super.dispose(); // last — mirror image of super.initState() first
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(_formatted, style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: _running ? null : _start,
                child: const Text('Start'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _running ? _stop : null,
                child: const Text('Stop'),
              ),
              const SizedBox(width: 8),
              TextButton(onPressed: _reset, child: const Text('Reset')),
            ],
          ),
        ],
      ),
    ),
  );
}
