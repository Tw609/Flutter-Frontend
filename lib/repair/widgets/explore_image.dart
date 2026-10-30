import 'package:flutter/material.dart';

import '../explore_ideas.dart';
import '../app_icons.dart';

/// The picture for an Explore idea. If the file is not in assets/explore/ yet,
/// a plain placeholder shows instead of an error.
class ExploreImage extends StatelessWidget {
  const ExploreImage({super.key, required this.idea, this.radius = 18});

  final ExploreIdea idea;
  final double radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.asset(
      idea.image,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: 500,
      errorBuilder: (context, error, stackTrace) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: Icon(
          AppIcons.image,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}
