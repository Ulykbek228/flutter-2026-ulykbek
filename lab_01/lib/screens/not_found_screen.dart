import 'package:flutter/material.dart';

import '../widgets/empty_state.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Not found')),
    body: const EmptyState(
      icon: Icons.help_outline,
      message: 'This page does not exist',
    ),
  );
}
