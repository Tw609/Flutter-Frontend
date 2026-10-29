import 'package:flutter_application_1/repair/services/api_image_service.dart';

import '../styles.dart';

import 'dart:typed_data';

/// The steps the Generating screen shows, in order.
enum GenerationStage { checking, creating, saving }

/// The ways the backend can fail. Each one has its own message on screen.
enum ImageServiceErrorKind {
  busy,
  rateLimited,
  blocked,
  timeout,
  offline,
  unknown,
}

extension ImageServiceErrorText on ImageServiceErrorKind {
  String get title => switch (this) {
    ImageServiceErrorKind.busy => 'The image service is busy',
    ImageServiceErrorKind.rateLimited => 'Too many requests for now',
    ImageServiceErrorKind.blocked => 'We cannot create that idea',
    ImageServiceErrorKind.timeout => 'This is taking too long',
    ImageServiceErrorKind.offline => 'No internet connection',
    ImageServiceErrorKind.unknown => 'Something went wrong',
  };

  String get message => switch (this) {
    ImageServiceErrorKind.busy => 'Many people are creating images right now. Please try again in a moment.',
    ImageServiceErrorKind.rateLimited => 'You reached the limit for now. Please wait a little before creating another image.',
    ImageServiceErrorKind.blocked => 'Your idea may go against our content rules. Try describing something different.',
    ImageServiceErrorKind.timeout => 'The image service did not answer in time. Check your connection and try again.',
    ImageServiceErrorKind.offline => 'Connect to the internet, then try again.',
    ImageServiceErrorKind.unknown =>
      'We could not create your image. Please try again.',
  };

  /// A blocked idea will be blocked again, so there is no Try again button.
  bool get canRetry => this != ImageServiceErrorKind.blocked;
}

class ImageServiceException implements Exception {
  const ImageServiceException(this.kind, {this.retryAfterSeconds});

  final ImageServiceErrorKind kind;

  /// How long to wait before trying again (for example from a 429 reply).
  final int? retryAfterSeconds;
}

class GeneratedImage {
  const GeneratedImage({required this.seed, this.imageUrl, this.imageBytes});

  /// Picks the local sample picture while there is no real image.
  final int seed;

  /// The real image address once the backend returns one.
  final String? imageUrl;

  final Uint8List? imageBytes;
}

/// Everything the screens need from the AI backend. The screens only talk to
/// this class, so they never change when the backend does.
abstract class ImageService {
  /// Backend: POST /api/ai/enhance-prompt
  Future<String> improvePrompt({required String idea, required String style});

  /// Backend: POST /api/ai/generate-image
  /// Call [onStage] when each step starts so the Generating screen can follow.
  Future<GeneratedImage> generateImage({
    required String prompt,
    required String style,
    void Function(GenerationStage stage)? onStage,
  });
}

/// The service the whole app uses.
///
/// To connect the real backend:
/// 1. Write `class ApiImageService implements ImageService` (in a new file).
/// 2. Map replies to errors: 429 -> rateLimited (use Retry-After for
///    retryAfterSeconds), 503 -> busy, a safety-filter rejection -> blocked,
///    request timeout -> timeout, no connection -> offline, anything else ->
///    unknown. Throw [ImageServiceException] for each.
/// 3. Change the line below to `ImageService imageService = ApiImageService();`
//* ImageService DemoimageService = DemoImageService();
ImageService imageService = ApiImageService();

/// Works without a backend. It can also fake each failure so you can see every
/// error screen. Put one of these tags anywhere in the idea:
///
/// - `[busy]`     busy screen, works on the second try
/// - `[limit]`    rate limit screen with a 10 second wait, works on retry
/// - `[timeout]`  timeout screen, works on the second try
/// - `[offline]`  offline screen, works on the second try
/// - `[blocked]`  blocked screen, never works
class DemoImageService implements ImageService {
  final _failedOnce = <String>{};

  static const _tags = {
    '[busy]': ImageServiceErrorKind.busy,
    '[limit]': ImageServiceErrorKind.rateLimited,
    '[timeout]': ImageServiceErrorKind.timeout,
    '[offline]': ImageServiceErrorKind.offline,
  };

  void _maybeFail(String step, String text) {
    final lower = text.toLowerCase();
    if (step == 'generate' && lower.contains('[blocked]')) {
      throw const ImageServiceException(ImageServiceErrorKind.blocked);
    }
    for (final tag in _tags.entries) {
      if (lower.contains(tag.key) && _failedOnce.add('$step:$lower')) {
        throw ImageServiceException(
          tag.value,
          retryAfterSeconds: tag.value == ImageServiceErrorKind.rateLimited
              ? 10
              : null,
        );
      }
    }
  }

  @override
  Future<String> improvePrompt({
    required String idea,
    required String style,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _maybeFail('improve', idea);
    return '$idea, ${styleDetail(style)}, thoughtfully composed, warm mood';
  }

  @override
  Future<GeneratedImage> generateImage({
    required String prompt,
    required String style,
    void Function(GenerationStage stage)? onStage,
  }) async {
    onStage?.call(GenerationStage.checking);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    _maybeFail('generate', prompt);
    onStage?.call(GenerationStage.creating);
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    onStage?.call(GenerationStage.saving);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return GeneratedImage(seed: DateTime.now().microsecondsSinceEpoch);
  }
}
