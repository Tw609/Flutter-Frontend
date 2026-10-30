import 'package:flutter/material.dart';

import '../artwork_store.dart';
import '../models/artwork.dart';
import '../services/image_service.dart';
import '../styles.dart';
import '../ui_helpers.dart';
import '../widgets/chitra_logo.dart';
import '../widgets/user_avatar.dart';
import '../app_icons.dart';

/// The first tab: write an idea, pick a style, generate.
class CreateTab extends StatefulWidget {
  const CreateTab({
    super.key,
    required this.controller,
    required this.style,
    required this.isGenerating,
    required this.onGenerate,
    required this.onOpenResult,
  });

  final TextEditingController controller;
  final ValueNotifier<String> style;
  final bool isGenerating;
  final VoidCallback onGenerate;
  final ValueChanged<Artwork> onOpenResult;

  @override
  State<CreateTab> createState() => _CreateTabState();
}

class _CreateTabState extends State<CreateTab> {
  bool _isImproving = false;

  // Remembers the idea the user typed before "Improve with AI", so pressing the
  // button again rebuilds from that idea instead of stacking more wording.
  String? _ideaBeforeImprove;
  String? _lastImproved;
  String? _improvedStyle;

  /// True when the box still holds improved wording written for another style.
  bool get _styleOutOfDate =>
      _lastImproved != null &&
      widget.controller.text.trim() == _lastImproved &&
      widget.style.value != _improvedStyle;

  void _setPrompt(String text) {
    widget.controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  Future<void> _improvePrompt() async {
    final typed = widget.controller.text.trim();
    if (typed.isEmpty) {
      showNotice(context, 'Write your idea before improving it.');
      return;
    }
    // If the box still holds the last improved text, start again from the
    // original idea. Otherwise the user edited it, so their text is the idea.
    final idea = typed == _lastImproved ? (_ideaBeforeImprove ?? typed) : typed;
    FocusScope.of(context).unfocus();
    final style = widget.style.value;
    setState(() => _isImproving = true);
    try {
      final improved = await imageService.improvePrompt(
        idea: idea,
        style: style,
      );
      if (!mounted) return;
      _ideaBeforeImprove = idea;
      _improvedStyle = style;
      _lastImproved = improved.trim();
      _setPrompt(_lastImproved!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Improved prompt added. Review and edit it below.',
          ),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              if (widget.controller.text.trim() == _lastImproved) {
                _setPrompt(idea);
              }
            },
          ),
        ),
      );
    } on ImageServiceException catch (error) {
      if (!mounted) return;
      showNotice(context, error.kind.title);
    } finally {
      if (mounted) setState(() => _isImproving = false);
    }
  }

  Widget _sectionLabel(String number, String label) => Row(
    children: [
      CircleAvatar(
        radius: 11,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: Text(number, style: Theme.of(context).textTheme.labelSmall),
      ),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    ],
  );

  Widget _promptField(ColorScheme scheme) => TextField(
    controller: widget.controller,
    maxLines: 4,
    maxLength: maxPromptLength,
    decoration: InputDecoration(
      hintText: 'A fox reading a book in a cozy library',
      helperText: 'Add the subject, setting, light and mood.',
      filled: true,
      fillColor: scheme.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.all(16),
    ),
  );

  Widget _styleRow() => SizedBox(
    height: 48,
    child: ValueListenableBuilder<String>(
      valueListenable: widget.style,
      builder: (context, selected, _) => ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: artStyles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final style = artStyles[index];
          return ChoiceChip(
            avatar: Icon(style.icon, size: 18),
            label: Text(style.name),
            selected: selected == style.name,
            showCheckmark: false,
            onSelected: (_) => widget.style.value = style.name,
          );
        },
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Row(
          children: [
            const ChitraLogo(size: 34, animate: false),
            const SizedBox(width: 10),
            Text(
              'Chitra AI',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            const UserAvatar(),
          ],
        ),
        const SizedBox(height: 25),
        Text(
          'What do you want\nto see?',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 22),
        _sectionLabel('1', 'Describe your idea'),
        const SizedBox(height: 10),
        _promptField(scheme),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _isImproving ? null : _improvePrompt,
            icon: _isImproving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(AppIcons.sparkle, size: 18, color: brandGold),
            label: Text(_isImproving ? 'Improving...' : 'Improve with AI'),
          ),
        ),
        // Shown only when the style changed after the prompt was improved.
        ListenableBuilder(
          listenable: Listenable.merge([widget.controller, widget.style]),
          builder: (context, _) => _styleOutOfDate
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'You changed the style. Tap Improve with AI to update the wording for ${widget.style.value}.',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: scheme.primary),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 14),
        _sectionLabel('2', 'Pick a style'),
        const SizedBox(height: 10),
        _styleRow(),
        const SizedBox(height: 26),
        FilledButton.icon(
          onPressed: widget.isGenerating ? null : widget.onGenerate,
          icon: const Icon(AppIcons.sparkle),
          label: const Text('Generate image'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        ),
        ValueListenableBuilder<List<Artwork>>(
          valueListenable: ArtworkStore.history,
          builder: (context, history, _) {
            if (history.isEmpty) return const SizedBox.shrink();
            final latest = history.first;
            return Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Card(
                child: ListTile(
                  onTap: () => widget.onOpenResult(latest),
                  leading: const Icon(AppIcons.clockCounterClockwise),
                  title: Text(
                    latest.prompt,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('Latest image • ${latest.style}'),
                  trailing: const Icon(AppIcons.caretRight),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
