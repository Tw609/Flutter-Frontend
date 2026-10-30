import 'package:flutter/material.dart';

import '../explore_ideas.dart';
import '../widgets/explore_image.dart';
import '../widgets/page_title.dart';

/// The second tab: example ideas. Tapping one fills the Create page.
class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key, required this.onPick});

  final ValueChanged<ExploreIdea> onPick;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      const SliverPadding(
        padding: EdgeInsets.fromLTRB(22, 22, 22, 16),
        sliver: SliverToBoxAdapter(
          child: PageTitle('Explore', 'Tap an idea to try it yourself.'),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 14,
            childAspectRatio: .78,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final idea = exploreIdeas[index];
            return InkWell(
              onTap: () => onPick(idea),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: ExploreImage(idea: idea)),
                  const SizedBox(height: 6),
                  Text(
                    idea.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    idea.style,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }, childCount: exploreIdeas.length),
        ),
      ),
    ],
  );
}
