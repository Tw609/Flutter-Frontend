import 'package:flutter/material.dart';

import '../artwork_store.dart';
import '../explore_ideas.dart';
import '../models/artwork.dart';
import '../styles.dart';
import '../ui_helpers.dart';
import '../widgets/floating_nav_bar.dart';
import 'create_tab.dart';
import 'explore_tab.dart';
import 'generation_pages.dart';
import 'library_tab.dart';
import 'profile_tab.dart';
import 'result_screen.dart';

/// The main screen: four tabs and the bottom bar.
/// It holds the idea and style, because Explore and Edit both change them.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onLogout});

  final void Function(BuildContext context)? onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _promptController = TextEditingController();
  final _style = ValueNotifier<String>(defaultStyleName);
  int _tab = 0;
  bool _isGenerating = false;

  @override
  void dispose() {
    _promptController.dispose();
    _style.dispose();
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
    _openGenerating(idea, _style.value);
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

  /// Puts an idea back in the Create tab so the user can change it.
  void _editIdea(String prompt, String style) {
    Navigator.popUntil(context, (route) => route.isFirst);
    if (!mounted) return;
    setState(() {
      _setPrompt(prompt);
      _style.value = style;
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

  void _useExploreIdea(ExploreIdea idea) {
    setState(() {
      _setPrompt(idea.prompt);
      _style.value = idea.style;
      _tab = 0;
    });
  }

  void _logOut() {
    ArtworkStore.reset();
    widget.onLogout?.call(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: IndexedStack(
        index: _tab,
        children: [
          CreateTab(
            controller: _promptController,
            style: _style,
            isGenerating: _isGenerating,
            onGenerate: _generate,
            onOpenResult: _openResult,
          ),
          ExploreTab(onPick: _useExploreIdea),
          LibraryTab(onOpen: _openResult),
          ProfileTab(onLogout: _logOut),
        ],
      ),
    ),
    bottomNavigationBar: FloatingNavBar(
      selectedIndex: _tab,
      onSelected: (index) => setState(() => _tab = index),
    ),
  );
}
