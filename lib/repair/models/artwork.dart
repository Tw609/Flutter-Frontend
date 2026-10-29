import 'dart:typed_data';

class Artwork {
  const Artwork({
    required this.prompt,
    required this.style,
    required this.createdAt,
    required this.seed,
    this.imageUrl,
    this.imageBytes,
  });
  final String prompt;
  final String style;
  final DateTime createdAt;
  final int seed;

  /// Null while the app uses the local sample picture. Set it when the
  /// backend returns a real image address.
  final String? imageUrl;

  final Uint8List? imageBytes;
}
