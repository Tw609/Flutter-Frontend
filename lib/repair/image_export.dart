import 'dart:io';
import 'dart:typed_data';

import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

import 'models/artwork.dart';

/// Shown for the offline demo pictures, which have no image file.
const noImageFileMessage = 'This demo picture has no image file yet.';

String _fileName(Artwork artwork) =>
    'chitra_${artwork.createdAt.millisecondsSinceEpoch}';

// PNG files start with the byte 0x89. Anything else is treated as JPEG.
String _extension(Uint8List bytes) =>
    bytes.isNotEmpty && bytes[0] == 0x89 ? 'png' : 'jpg';

/// Saves the image to the phone's photo gallery.
/// Returns the message to show the user.
Future<String> saveToGallery(Artwork artwork) async {
  final bytes = artwork.imageBytes;
  if (bytes == null) return noImageFileMessage;
  try {
    final allowed = await Gal.hasAccess() || await Gal.requestAccess();
    if (!allowed) return 'Allow photo access to save images.';
    await Gal.putImageBytes(bytes, name: _fileName(artwork));
    return 'Saved to your gallery.';
  } on GalException catch (error) {
    return error.type.message;
  }
}

/// Opens the phone's share sheet with the image.
/// Returns a message only when something went wrong.
Future<String?> shareImage(Artwork artwork) async {
  final bytes = artwork.imageBytes;
  if (bytes == null) return noImageFileMessage;
  try {
    // The share sheet needs a real file, so write the bytes to a temp file.
    final file = File(
      '${Directory.systemTemp.path}/${_fileName(artwork)}.${_extension(bytes)}',
    );
    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(
      ShareParams(text: 'Made with Chitra AI', files: [XFile(file.path)]),
    );
    return null;
  } on Exception {
    return 'Could not share this image.';
  }
}
