import 'package:flutter/material.dart';

import '../artwork_store.dart';

/// Circle with the user's initials.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.radius = 19});

  final double radius;

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'AI';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: radius,
    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    child: ValueListenableBuilder<String>(
      valueListenable: ArtworkStore.userName,
      builder: (context, name, _) => Text(
        _initials(name),
        style: TextStyle(fontSize: radius * 0.6, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
