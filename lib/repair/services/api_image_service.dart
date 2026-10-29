import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'image_service.dart';

class ApiImageService implements ImageService {
  ApiImageService({this.baseUrl = 'http://192.168.1.36:8010'});

  final String baseUrl;

  @override
  Future<String> improvePrompt({
    required String idea,
    required String style,
  }) async {
    final response = await _post('/api/ai/enhance-prompt', {
      'raw_prompt': idea,
      'style': style,
    }, const Duration(seconds: 40));
    final data = _readJson(response);
    return data['enhanced_prompt'] as String;
  }

  @override
  Future<GeneratedImage> generateImage({
    required String prompt,
    required String style,
    void Function(GenerationStage stage)? onStage,
  }) async {
    onStage?.call(GenerationStage.checking);
    onStage?.call(GenerationStage.creating);
    final response = await _post('/api/ai/generate-image', {
      'prompt': prompt,
    }, Duration(seconds: 90));
    final data = _readJson(response);
    onStage?.call(GenerationStage.saving);
    final bytes = base64Decode(data['image_base64'] as String);
    return GeneratedImage(
      seed: DateTime.now().microsecondsSinceEpoch,
      imageBytes: bytes,
    );
  }

  Future<http.Response> _post(String path, Map body, Duration timeout) async {
    final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw ImageServiceException(ImageServiceErrorKind.timeout);
    } on SocketException {
      throw ImageServiceException(ImageServiceErrorKind.offline);
    } on http.ClientException {
      throw ImageServiceException(ImageServiceErrorKind.offline);
    }
    //* FOR DEBUGGIN
    // print(
    //   '${response.statusCode}'
    //   '${response.body}',
    // );
    if (response.statusCode == 200) return response;
    if (response.statusCode == 400) {
      throw ImageServiceException(ImageServiceErrorKind.blocked);
    }
    if (response.statusCode == 429) {
      throw ImageServiceException(
        ImageServiceErrorKind.rateLimited,
        retryAfterSeconds:
            int.tryParse(response.headers['retry-after'] ?? '') ?? 60,
      );
    }
    if (response.statusCode == 502) {
      throw ImageServiceException(ImageServiceErrorKind.busy);
    }
    throw ImageServiceException(ImageServiceErrorKind.unknown);
  }

  Map<String, dynamic> _readJson(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    } catch (_) {
      throw ImageServiceException(ImageServiceErrorKind.unknown);
    }
  }
}
