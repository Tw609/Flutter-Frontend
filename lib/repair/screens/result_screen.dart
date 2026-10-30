import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../artwork_store.dart';
import '../image_export.dart';
import '../models/artwork.dart';
import '../ui_helpers.dart';
import '../widgets/artwork_image.dart';
import '../app_icons.dart';

/// What the result screen can ask the rest of the app to do.
class ArtworkActions {
  const ArtworkActions({
    required this.onEdit,
    required this.onRegenerate,
    required this.onDelete,
  });

  final ValueChanged<Artwork> onEdit;
  final ValueChanged<Artwork> onRegenerate;
  final ValueChanged<Artwork> onDelete;
}

enum _ResultMenu { edit, details, delete }

/// One screen for a finished image, both right after generating and when you
/// open an image from the Library.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.artwork, required this.actions});

  final Artwork artwork;
  final ArtworkActions actions;

  void _onMenu(BuildContext context, _ResultMenu item) {
    switch (item) {
      case _ResultMenu.edit:
        actions.onEdit(artwork);
      case _ResultMenu.details:
        _showDetails(context);
      case _ResultMenu.delete:
        _confirmDelete(context);
    }
  }

  /// The three-dot menu: a bottom sheet with one row per action.
  void _showMenu(BuildContext context) {
    void choose(BuildContext sheetContext, _ResultMenu item) {
      Navigator.pop(sheetContext);
      _onMenu(context, item);
    }

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MenuRow(
                icon: AppIcons.pencilSimple,
                label: 'Edit prompt and style',
                onTap: () => choose(sheetContext, _ResultMenu.edit),
              ),
              _MenuRow(
                icon: AppIcons.info,
                label: 'Image details',
                onTap: () => choose(sheetContext, _ResultMenu.details),
              ),
              _MenuRow(
                icon: AppIcons.trash,
                label: 'Delete image',
                isDanger: true,
                onTap: () => choose(sheetContext, _ResultMenu.delete),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Image details',
                style: Theme.of(sheetContext).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              _detailRow(sheetContext, 'Style', artwork.style),
              _detailRow(
                sheetContext,
                'Created',
                formatDateTime(artwork.createdAt),
              ),
              _detailRow(sheetContext, 'Prompt', artwork.prompt),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: artwork.prompt));
                  if (!sheetContext.mounted) return;
                  Navigator.pop(sheetContext);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Prompt copied.')),
                  );
                },
                icon: const Icon(AppIcons.copy),
                label: const Text('Copy prompt'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(value),
          ],
        ),
      );

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete image?'),
        content: const Text('This also removes it from Saved images.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              actions.onDelete(artwork);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Your image'),
      actions: [
        IconButton(
          tooltip: 'More options',
          onPressed: () => _showMenu(context),
          icon: const Icon(AppIcons.dotsThreeVertical),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ArtworkImage(artwork: artwork),
        const SizedBox(height: 12),
        Row(
          children: [
            Chip(label: Text(artwork.style)),
            const Spacer(),
            Text(
              formatDate(artwork.createdAt),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Text(
          'Your idea',
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(artwork.prompt),
        const SizedBox(height: 18),
        ArtworkActionRow(artwork: artwork),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => actions.onRegenerate(artwork),
          icon: const Icon(AppIcons.arrowClockwise),
          label: const Text('Regenerate'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        ),
      ],
    ),
  );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isDanger ? scheme.error : scheme.onSurface;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

class ArtworkActionRow extends StatelessWidget {
  const ArtworkActionRow({super.key, required this.artwork});

  final Artwork artwork;

  Future<void> _download(BuildContext context) async {
    final message = await saveToGallery(artwork);
    if (context.mounted) showNotice(context, message);
  }

  Future<void> _share(BuildContext context) async {
    final message = await shareImage(artwork);
    if (message != null && context.mounted) showNotice(context, message);
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: ValueListenableBuilder<List<Artwork>>(
          valueListenable: ArtworkStore.saved,
          builder: (context, saved, _) {
            final isSaved = saved.contains(artwork);
            return _ActionButton(
              icon: isSaved
                  ? AppIcons.bookmarkSimpleFill
                  : AppIcons.bookmarkSimple,
              label: isSaved ? 'Saved' : 'Save',
              onTap: () => ArtworkStore.toggleSaved(artwork),
            );
          },
        ),
      ),
      Expanded(
        child: _ActionButton(
          icon: AppIcons.downloadSimple,
          label: 'Download',
          onTap: () => _download(context),
        ),
      ),
      Expanded(
        child: _ActionButton(
          icon: AppIcons.shareNetwork,
          label: 'Share',
          onTap: () => _share(context),
        ),
      ),
    ],
  );
}

/// Icon with its label underneath. Three of these fit in a row on any phone
/// width, so no label wraps onto a second line.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    ),
  );
}
