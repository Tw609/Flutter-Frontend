import 'package:flutter/material.dart';

import '../artwork_store.dart';
import '../models/artwork.dart';
import '../ui_helpers.dart';
import '../widgets/artwork_image.dart';
import '../widgets/page_title.dart';

/// The third tab: every image the user made, or only the saved ones.
class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key, required this.onOpen});

  final ValueChanged<Artwork> onOpen;

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  bool _showSaved = false;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<List<Artwork>>(
    valueListenable: _showSaved ? ArtworkStore.saved : ArtworkStore.history,
    builder: (context, artworks, _) => CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const PageTitle('Library', 'Your images, all in one place.'),
              const SizedBox(height: 14),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('All')),
                  ButtonSegment(value: true, label: Text('Saved')),
                ],
                selected: {_showSaved},
                onSelectionChanged: (value) =>
                    setState(() => _showSaved = value.first),
              ),
            ]),
          ),
        ),
        if (artworks.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              _showSaved ? 'No saved images yet' : 'Your gallery is waiting',
              _showSaved
                  ? 'Save an image from its result page.'
                  : 'Create an image and it will appear here.',
            ),
          )
        else
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
                final artwork = artworks[index];
                return InkWell(
                  onTap: () => widget.onOpen(artwork),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        // cacheWidth decodes a small copy, not the full image.
                        child: ArtworkImage(
                          artwork: artwork,
                          radius: 18,
                          cacheWidth: 400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        artwork.prompt,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${artwork.style} • ${formatDate(artwork.createdAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }, childCount: artworks.length),
            ),
          ),
      ],
    ),
  );
}
