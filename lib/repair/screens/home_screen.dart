import 'package:flutter/material.dart';

import '../artwork_store.dart';
import '../models/artwork.dart';
import '../services/image_service.dart';
import '../styles.dart';
import '../theme_state.dart';
import '../ui_helpers.dart';
import '../widgets/artwork_image.dart';
import '../widgets/sample_artwork.dart';
import 'account_pages.dart';
import 'generation_pages.dart';
import 'result_screen.dart';

/// Sample ideas on the Explore tab. Tapping one fills the Create page.
const _exploreIdeas = [
  ('Misty mountain lake', 'Photorealistic'),
  ('Neon city at night', 'Cyberpunk'),
  ('Cozy house by the sea', 'Watercolor'),
  ('Cute robot watering plants', '3D'),
  ('A fox reading in a cozy library', 'Anime'),
  ('Spring flower bouquet', 'Photorealistic'),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onLogout});

  final void Function(BuildContext context)? onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _promptController = TextEditingController();
  int _tab = 0;
  String _style = defaultStyleName;
  bool _isGenerating = false;
  bool _isImproving = false;
  bool _showSaved = false;

  // Remembers the idea the user typed before "Improve with AI", so pressing the
  // button again rebuilds from that idea instead of stacking more wording.
  String? _ideaBeforeImprove;
  String? _lastImproved;
  String? _improvedStyle;

  /// True when the box still holds improved wording written for another style.
  bool get _styleOutOfDate =>
      _lastImproved != null &&
      _promptController.text.trim() == _lastImproved &&
      _style != _improvedStyle;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  ArtworkActions get _actions => ArtworkActions(
    onEdit: _editArtwork,
    onRegenerate: _regenerateArtwork,
    onDelete: _deleteArtwork,
  );

  void _setPrompt(String text) {
    _promptController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _generate() {
    final idea = _promptController.text.trim();
    if (idea.isEmpty) {
      showNotice(context, 'Please describe your idea first.');
      return;
    }
    _openGenerating(idea, _style);
  }

  void _openGenerating(String prompt, String style) {
    FocusScope.of(context).unfocus();
    setState(() => _isGenerating = true);
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => GeneratingPage(
          prompt: prompt,
          style: style,
          actions: _actions,
          onEditIdea: () => _editIdea(prompt, style),
        ),
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _isGenerating = false);
    });
  }

  void _openResult(Artwork artwork) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(artwork: artwork, actions: _actions),
      ),
    );
  }

  void _editIdea(String prompt, String style) {
    Navigator.popUntil(context, (route) => route.isFirst);
    if (!mounted) return;
    setState(() {
      _setPrompt(prompt);
      _style = style;
      _tab = 0;
    });
  }

  void _editArtwork(Artwork artwork) =>
      _editIdea(artwork.prompt, artwork.style);

  void _regenerateArtwork(Artwork artwork) {
    _editIdea(artwork.prompt, artwork.style);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openGenerating(artwork.prompt, artwork.style);
    });
  }

  void _deleteArtwork(Artwork artwork) {
    ArtworkStore.remove(artwork);
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> _improvePrompt() async {
    final typed = _promptController.text.trim();
    if (typed.isEmpty) {
      showNotice(context, 'Write your idea before improving it.');
      return;
    }
    // If the box still holds the last improved text, start again from the
    // original idea. Otherwise the user edited it, so their text is the idea.
    final idea = typed == _lastImproved ? (_ideaBeforeImprove ?? typed) : typed;
    FocusScope.of(context).unfocus();
    final style = _style;
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
              if (_promptController.text.trim() == _lastImproved) {
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

  void _toggleTheme() {
    appThemeMode.value = appThemeMode.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: IndexedStack(
        index: _tab,
        children: [
          _createPage(),
          _explorePage(),
          _libraryPage(),
          _profilePage(),
        ],
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (index) => setState(() => _tab = index),
      backgroundColor: Theme.of(context).colorScheme.surface,
      indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle),
          label: 'Create',
        ),
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: 'Explore',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view),
          label: 'Library',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    ),
  );

  Widget _createPage() {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, color: scheme.primary),
            const SizedBox(width: 8),
            Text(
              'Imagine AI',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            CircleAvatar(
              radius: 19,
              backgroundColor: scheme.secondaryContainer,
              child: ValueListenableBuilder<String>(
                valueListenable: ArtworkStore.userName,
                builder: (context, name, _) => Text(_initials(name)),
              ),
            ),
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
        TextField(
          controller: _promptController,
          maxLines: 4,
          maxLength: maxPromptLength,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'A fox reading a book in a cozy library',
            filled: true,
            fillColor: scheme.surface,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(18)),
              borderSide: BorderSide(color: scheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(18)),
              borderSide: BorderSide(color: scheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _isImproving ? null : _improvePrompt,
            icon: _isImproving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome, size: 16),
            label: Text(_isImproving ? 'Improving...' : 'Improve with AI'),
          ),
        ),
        Text(
          _styleOutOfDate
              ? 'You changed the style. Tap Improve with AI to update the wording for $_style.'
              : 'The improved wording appears in the prompt box so you can edit it.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: _styleOutOfDate ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 22),
        _sectionLabel('2', 'Pick a style'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: artStyles
              .map(
                (style) => ChoiceChip(
                  label: Text(style.name),
                  selected: _style == style.name,
                  onSelected: (_) => setState(() => _style = style.name),
                  selectedColor: scheme.secondaryContainer,
                  side: BorderSide(color: scheme.outlineVariant),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Prompt tip • Add subject, setting, lighting and mood. Style words like “watercolor” change the image finish.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: scheme.onSecondaryContainer),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _isGenerating ? null : _generate,
          icon: const Icon(Icons.auto_awesome),
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
                  onTap: () => _openResult(latest),
                  leading: const Icon(Icons.history),
                  title: Text(
                    latest.prompt,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('Latest image • ${latest.style}'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _explorePage() => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      _pageTitle('Explore', 'Try a sample idea and style.'),
      const SizedBox(height: 18),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: .72,
        children: List.generate(_exploreIdeas.length, (index) {
          final (idea, style) = _exploreIdeas[index];
          return InkWell(
            onTap: () => setState(() {
              _promptController.text = idea;
              _style = style;
              _tab = 0;
            }),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: SampleArtwork(seed: index, radius: 18)),
                const SizedBox(height: 6),
                Text(
                  idea,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  style,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    ],
  );

  Widget _libraryPage() => ValueListenableBuilder<List<Artwork>>(
    valueListenable: _showSaved ? ArtworkStore.saved : ArtworkStore.history,
    builder: (context, artworks, _) => ListView(
      padding: const EdgeInsets.all(22),
      children: [
        _pageTitle('Library', 'Your images, all in one place.'),
        const SizedBox(height: 14),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('All')),
            ButtonSegment(value: true, label: Text('Saved')),
          ],
          selected: {_showSaved},
          onSelectionChanged: (value) =>
              setState(() => _showSaved = value.first),
        ),
        const SizedBox(height: 16),
        if (artworks.isEmpty)
          _emptyState(
            _showSaved ? 'No saved images yet' : 'Your gallery is waiting',
            _showSaved
                ? 'Save an image from its result page.'
                : 'Create an image and it will appear here.',
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: .78,
            ),
            itemCount: artworks.length,
            itemBuilder: (context, index) {
              final artwork = artworks[index];
              return InkWell(
                onTap: () => _openResult(artwork),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: ArtworkImage(artwork: artwork, radius: 18)),
                    const SizedBox(height: 6),
                    Text(
                      artwork.prompt,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${artwork.style} • ${formatDate(artwork.createdAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    ),
  );

  Widget _profilePage() => ListView(
    padding: const EdgeInsets.all(22),
    children: [
      Row(
        children: [
          Text(
            'Profile',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Toggle light and dark mode',
            onPressed: _toggleTheme,
            icon: Icon(
              appThemeMode.value == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode_outlined,
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Center(
        child: CircleAvatar(
          radius: 42,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: ValueListenableBuilder<String>(
            valueListenable: ArtworkStore.userName,
            builder: (context, name, _) => Text(
              _initials(name),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      ValueListenableBuilder<String>(
        valueListenable: ArtworkStore.userName,
        builder: (context, name, _) => Center(
          child: Text(
            name,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      ValueListenableBuilder<String>(
        valueListenable: ArtworkStore.username,
        builder: (context, username, _) => Center(
          child: Text(
            username,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
      Center(
        child: OutlinedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfilePage()),
          ),
          child: const Text('Edit profile'),
        ),
      ),
      const SizedBox(height: 12),
      _profileRow(
        Icons.palette_outlined,
        'Appearance',
        '›',
        () => _push(const AppearancePage()),
      ),
      _profileRow(
        Icons.alternate_email,
        'Change email',
        '›',
        () => _push(const ChangeEmailPage()),
      ),
      _profileRow(
        Icons.lock_outline,
        'Change password',
        '›',
        () => _push(const ChangePasswordPage()),
      ),
      _profileRow(
        Icons.help_outline,
        'Help and support',
        '›',
        () => _push(const HelpSupportPage()),
      ),
      _profileRow(Icons.logout, 'Log out', '›', _logOut),
    ],
  );

  void _push(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  void _logOut() {
    ArtworkStore.reset();
    widget.onLogout?.call(context);
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

  Widget _pageTitle(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall
            ?.copyWith(fontWeight: FontWeight.w800),
      ),
      Text(
        subtitle,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ],
  );

  Widget _emptyState(String title, String subtitle) => Padding(
    padding: const EdgeInsets.only(top: 70),
    child: Column(
      children: [
        Icon(
          Icons.image_outlined,
          color: Theme.of(context).colorScheme.primary,
          size: 52,
        ),
        const SizedBox(height: 10),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );

  Widget _profileRow(
    IconData icon,
    String title,
    String trailing,
    VoidCallback onTap,
  ) => Card(
    child: ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: Text(
        trailing,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ),
  );

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'AI';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }
}
