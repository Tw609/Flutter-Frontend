import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../artwork_store.dart';
import '../models/artwork.dart';
import '../ui_helpers.dart';
import '../widgets/artwork_image.dart';

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
                icon: const Icon(Icons.copy),
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
        PopupMenuButton<_ResultMenu>(
          tooltip: 'More options',
          onSelected: (item) => _onMenu(context, item),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: _ResultMenu.edit,
              child: _MenuRow(Icons.edit_outlined, 'Edit prompt and style'),
            ),
            const PopupMenuItem(
              value: _ResultMenu.details,
              child: _MenuRow(Icons.info_outline, 'Image details'),
            ),
            const PopupMenuItem(
              value: _ResultMenu.delete,
              child: _MenuRow(Icons.delete_outline, 'Delete image'),
            ),
          ],
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
          icon: const Icon(Icons.refresh),
          label: const Text('Regenerate'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        ),
      ],
    ),
  );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) =>
      Row(children: [Icon(icon), const SizedBox(width: 12), Text(label)]);
}

class ArtworkActionRow extends StatelessWidget {
  const ArtworkActionRow({super.key, required this.artwork});

  final Artwork artwork;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: ValueListenableBuilder<List<Artwork>>(
          valueListenable: ArtworkStore.saved,
          builder: (context, saved, _) {
            final isSaved = saved.contains(artwork);
            return OutlinedButton.icon(
              onPressed: () => ArtworkStore.toggleSaved(artwork),
              icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_outline),
              label: Text(isSaved ? 'Saved' : 'Save'),
            );
          },
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () {
            // TODO: Save the image file to the device once image bytes exist.
            showNotice(context, 'Download is coming soon.');
          },
          icon: const Icon(Icons.download_outlined),
          label: const Text('Download'),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () {
            // TODO: Open the device share sheet once image bytes exist.
            showNotice(context, 'Sharing is coming soon.');
          },
          icon: const Icon(Icons.share_outlined),
          label: const Text('Share'),
        ),
      ),
    ],
  );
}
