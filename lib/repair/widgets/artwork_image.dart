import 'package:flutter/material.dart';

import '../models/artwork.dart';
import 'sample_artwork.dart';
import '../app_icons.dart';

/// Shows the real image when the artwork has an address, otherwise the local
/// sample picture.
class ArtworkImage extends StatelessWidget {
  const ArtworkImage({
    super.key,
    required this.artwork,
    this.radius = 22,
    this.cacheWidth,
  });

  final Artwork artwork;
  final double radius;

  /// Decode the image at this width. Use it for small thumbnails.
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    //* Backend return as a imagebase64
    final bytes = artwork.imageBytes;
    if (bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            cacheWidth: cacheWidth,
            errorBuilder: (context, error, stackTrace) =>
                Center(child: Icon(AppIcons.imageBroken, size: 48)),
          ),
        ),
      );
    }

    final url = artwork.imageUrl;
    if (url == null) return SampleArtwork(seed: artwork.seed, radius: radius);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const Center(child: CircularProgressIndicator()),
          errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(AppIcons.imageBroken, size: 48)),
        ),
      ),
    );
  }
}
