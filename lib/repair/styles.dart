/// One style the user can pick on the Create page.
///
/// The names Photorealistic, Anime and Cyberpunk match the backend style
/// packs. Watercolor and 3D are new, so the backend needs a pack for each
/// before it can honour them.
class ArtStyle {
  const ArtStyle(this.name, this.detail);

  final String name;

  /// Wording the demo adds when you tap "Improve with AI".
  final String detail;
}

const artStyles = [
  ArtStyle(
    'Photorealistic',
    'photorealistic details, natural lighting, sharp focus',
  ),
  ArtStyle('Anime', 'expressive anime illustration, clean line art'),
  ArtStyle('Cyberpunk', 'neon lights, futuristic city, high contrast'),
  ArtStyle('Watercolor', 'soft watercolor washes, delicate paper texture'),
  ArtStyle('3D', 'polished 3D render, dimensional lighting'),
];

const defaultStyleName = 'Photorealistic';

/// Longest idea the prompt box accepts. Change it to match the backend limit.
const maxPromptLength = 500;

String styleDetail(String styleName) {
  for (final style in artStyles) {
    if (style.name == styleName) return style.detail;
  }
  return artStyles.first.detail;
}
