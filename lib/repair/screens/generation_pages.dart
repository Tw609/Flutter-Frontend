import 'dart:async';

import 'package:flutter/material.dart';

import '../artwork_store.dart';
import '../models/artwork.dart';
import '../services/image_service.dart';
import 'result_screen.dart';

/// Runs the generation and shows each real step as it happens. If it fails,
/// it swaps itself for the matching error screen.
class GeneratingPage extends StatefulWidget {
  const GeneratingPage({
    super.key,
    required this.prompt,
    required this.style,
    required this.actions,
    required this.onEditIdea,
  });

  final String prompt;
  final String style;
  final ArtworkActions actions;
  final VoidCallback onEditIdea;

  @override
  State<GeneratingPage> createState() => _GeneratingPageState();
}

class _GeneratingPageState extends State<GeneratingPage> {
  static const _steps = [
    'Checking your idea',
    'Creating your image',
    'Saving to your library',
  ];

  int _stage = 0;
  bool _slow = false;
  Timer? _slowTimer;

  @override
  void initState() {
    super.initState();
    _slowTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) setState(() => _slow = true);
    });
    _generate();
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    super.dispose();
  }

  Future<void> _generate() async {
    try {
      final result = await imageService.generateImage(
        prompt: widget.prompt,
        style: widget.style,
        onStage: (stage) {
          if (mounted) setState(() => _stage = stage.index);
        },
      );
      // Closing the screen disposes it, so a cancelled image is never added.
      if (!mounted) return;
      final artwork = Artwork(
        prompt: widget.prompt,
        style: widget.style,
        createdAt: DateTime.now(),
        seed: result.seed,
        imageUrl: result.imageUrl,
        imageBytes: result.imageBytes,
      );
      ArtworkStore.addHistory(artwork);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ResultScreen(artwork: artwork, actions: widget.actions),
        ),
      );
    } on ImageServiceException catch (error) {
      if (!mounted) return;
      _showError(error);
    } catch (_) {
      if (!mounted) return;
      _showError(const ImageServiceException(ImageServiceErrorKind.unknown));
    }
  }

  void _showError(ImageServiceException error) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GenerationErrorPage(
          error: error,
          onEditIdea: widget.onEditIdea,
          onRetry: (errorContext) => Navigator.pushReplacement(
            errorContext,
            MaterialPageRoute(
              builder: (_) => GeneratingPage(
                prompt: widget.prompt,
                style: widget.style,
                actions: widget.actions,
                onEditIdea: widget.onEditIdea,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepIcon(int index, ColorScheme scheme) {
    if (index < _stage) return Icon(Icons.check_circle, color: scheme.primary);
    if (index == _stage) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      );
    }
    return Icon(Icons.radio_button_unchecked, color: scheme.outline);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Cancel',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(Icons.auto_awesome, size: 58),
              ),
              const SizedBox(height: 22),
              Text(
                'Creating your image',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Please keep the app open.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 18),
              for (var index = 0; index < _steps.length; index++)
                ListTile(
                  dense: true,
                  leading: _stepIcon(index, scheme),
                  title: Text(_steps[index]),
                ),
              if (_slow)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'This is taking longer than usual. You can keep waiting, or close this screen and try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One screen for every failure. The icon, text and buttons follow the kind of
/// error. A rate limit shows a countdown before Try again works.
class GenerationErrorPage extends StatefulWidget {
  const GenerationErrorPage({
    super.key,
    required this.error,
    required this.onRetry,
    required this.onEditIdea,
  });

  final ImageServiceException error;
  final void Function(BuildContext context) onRetry;
  final VoidCallback onEditIdea;

  @override
  State<GenerationErrorPage> createState() => _GenerationErrorPageState();
}

class _GenerationErrorPageState extends State<GenerationErrorPage> {
  Timer? _timer;
  int _wait = 0;

  @override
  void initState() {
    super.initState();
    _wait = widget.error.retryAfterSeconds ?? 0;
    if (_wait > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() => _wait--);
        if (_wait <= 0) timer.cancel();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  IconData get _icon => switch (widget.error.kind) {
    ImageServiceErrorKind.busy => Icons.warning_amber_rounded,
    ImageServiceErrorKind.rateLimited => Icons.hourglass_top,
    ImageServiceErrorKind.blocked => Icons.block,
    ImageServiceErrorKind.timeout => Icons.timer_off_outlined,
    ImageServiceErrorKind.offline => Icons.wifi_off,
    ImageServiceErrorKind.unknown => Icons.error_outline,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final kind = widget.error.kind;
    final message = _wait > 0
        ? 'Please wait $_wait ${_wait == 1 ? 'second' : 'seconds'} before creating another image.'
        : kind.message;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: scheme.errorContainer,
                  child: Icon(_icon, color: scheme.error, size: 32),
                ),
                const SizedBox(height: 18),
                Text(
                  kind.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                if (kind.canRetry) ...[
                  FilledButton(
                    onPressed: _wait > 0 ? null : () => widget.onRetry(context),
                    child: Text(
                      _wait > 0 ? 'Try again in ${_wait}s' : 'Try again',
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: widget.onEditIdea,
                    child: const Text('Edit my idea'),
                  ),
                ] else
                  FilledButton(
                    onPressed: widget.onEditIdea,
                    child: const Text('Edit my idea'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
