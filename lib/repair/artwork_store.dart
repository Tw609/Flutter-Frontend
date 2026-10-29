import 'package:flutter/foundation.dart';

import 'models/artwork.dart';

/// In-memory UI demo state. Nothing is persisted between app launches.
class ArtworkStore {
  ArtworkStore._();

  static const defaultName = 'Guest';
  static const defaultUsername = '@guest';

  static final ValueNotifier<List<Artwork>> history = ValueNotifier([]);
  static final ValueNotifier<List<Artwork>> saved = ValueNotifier([]);
  static final ValueNotifier<String> userName = ValueNotifier(defaultName);
  static final ValueNotifier<String> username = ValueNotifier(defaultUsername);

  /// Empty when the user signed in with Google.
  static final ValueNotifier<String> email = ValueNotifier('');

  static void addHistory(Artwork artwork) {
    history.value = [artwork, ...history.value];
  }

  static bool isSaved(Artwork artwork) => saved.value.contains(artwork);

  static void toggleSaved(Artwork artwork) {
    saved.value = isSaved(artwork)
        ? saved.value.where((item) => item != artwork).toList()
        : [artwork, ...saved.value];
  }

  static void remove(Artwork artwork) {
    history.value = history.value.where((item) => item != artwork).toList();
    saved.value = saved.value.where((item) => item != artwork).toList();
  }

  static void updateProfile({required String name, required String username}) {
    userName.value = name;
    ArtworkStore.username.value = username.startsWith('@')
        ? username
        : '@$username';
  }

  static void reset() {
    history.value = [];
    saved.value = [];
    userName.value = defaultName;
    username.value = defaultUsername;
    email.value = '';
  }
}
