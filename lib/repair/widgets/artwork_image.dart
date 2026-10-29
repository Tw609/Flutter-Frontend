import 'package:flutter/material.dart';

import '../models/artwork.dart';
import 'sample_artwork.dart';

/// Shows the real image when the artwork has an address, otherwise the local
/// sample picture.
class ArtworkImage extends StatelessWidget {
  const ArtworkImage({super.key, required this.artwork, this.radius = 22});

  final Artwork artwork;
  final double radius;

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
            errorBuilder: (context, error, stackTrace) =>
                Center(child: Icon(Icons.broken_image_outlined, size: 48)),
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
              const Center(child: Icon(Icons.broken_image_outlined, size: 48)),
        ),
      ),
    );
  }
}
