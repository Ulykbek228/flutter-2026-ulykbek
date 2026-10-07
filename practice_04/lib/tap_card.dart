import 'package:flutter/material.dart';

class TapCard extends StatefulWidget {
  const TapCard({super.key});

  @override
  State<TapCard> createState() => _TapCardState();
}

class _TapCardState extends State<TapCard> {
  // The only state in this file. It lives in the State object,
  // so it survives rebuilds and rotating the phone.
  int _taps = 0;

  Future<void> _confirmReset() async {
    // The dialog only answers yes/no; it never touches _taps itself.
    final reset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset the count?'),
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
    // Dismissing the dialog by tapping outside returns null — treat as Cancel.
    if (reset == true) {
      setState(() => _taps = 0);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    // A Card is not a button; InkWell makes it one, ripple included.
    child: InkWell(
      onTap: () => setState(() => _taps++),
      onLongPress: _confirmReset,
      child: ListTile(
        title: const Text('Tap this card'),
        subtitle: const Text('Long-press to reset'),
        trailing: Text(
          '$_taps',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    ),
  );
}
