import 'package:flutter/material.dart';

import 'app_icons.dart';

/// One style the user can pick on the Create page.
///
/// Photorealistic, Anime and Cyberpunk already exist as backend style packs.
/// Every other name below needs a matching pack on the backend before it
/// changes the picture.
class ArtStyle {
  const ArtStyle(this.name, this.icon, this.detail);

  final String name;
  final IconData icon;

  /// Wording the demo adds when you tap "Improve with AI".
  final String detail;
}

const artStyles = [
  ArtStyle(
    'Photorealistic',
    AppIcons.camera,
    'photorealistic details, natural lighting, sharp focus',
  ),
  ArtStyle(
    'Anime',
    AppIcons.smiley,
    'expressive anime illustration, clean line art',
  ),
  ArtStyle(
    'Cyberpunk',
    AppIcons.lightning,
    'neon lights, futuristic city, high contrast',
  ),
  ArtStyle(
    'Watercolor',
    AppIcons.drop,
    'soft watercolor washes, delicate paper texture',
  ),
  ArtStyle('3D', AppIcons.cube, 'polished 3D render, dimensional lighting'),
  ArtStyle(
    'Cinematic',
    AppIcons.filmSlate,
    'cinematic film still, dramatic lighting, shallow depth of field',
  ),
  ArtStyle(
    'Fantasy',
    AppIcons.castleTurret,
    'epic fantasy art, magical atmosphere, rich detail',
  ),
  ArtStyle(
    'Oil Painting',
    AppIcons.paintBrush,
    'classic oil painting, thick brush strokes, rich colors',
  ),
  ArtStyle(
    'Pixel Art',
    AppIcons.gameController,
    'retro pixel art, limited color palette, crisp pixels',
  ),
  ArtStyle(
    'Sketch',
    AppIcons.pencilSimple,
    'hand-drawn pencil sketch, fine lines, light shading',
  ),
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
