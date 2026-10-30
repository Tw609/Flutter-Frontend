/// One card on the Explore tab. Tapping it fills the Create page with
/// [prompt] and [style].
///
/// The picture for each card is a file in assets/explore/. Generate it with
/// the same prompt and style, then save it under the [image] name.
class ExploreIdea {
  const ExploreIdea({
    required this.title,
    required this.style,
    required this.prompt,
    required this.image,
  });

  final String title;
  final String style;
  final String prompt;
  final String image;
}

// The prompts describe the scene only. The style is added by the style chip.
const exploreIdeas = [
  ExploreIdea(
    title: 'Misty mountain lake',
    style: 'Photorealistic',
    prompt:
        'A still mountain lake at sunrise with thin mist drifting over the '
        'water, pine forest along the shore, soft golden light on the far '
        'peaks and a small wooden rowboat in the foreground, calm and quiet',
    image: 'assets/explore/misty_lake.jpg',
  ),
  ExploreIdea(
    title: 'Fox in the library',
    style: 'Anime',
    prompt:
        'A young fox in a knitted scarf reading a thick book in a cozy old '
        'library, warm lamp light, floating dust sparkles, tall bookshelves '
        'behind and a cup of tea on the desk, peaceful mood',
    image: 'assets/explore/fox_library.jpg',
  ),
  ExploreIdea(
    title: 'Neon rain city',
    style: 'Cyberpunk',
    prompt:
        'A narrow alley in a rainy futuristic city at night, glowing pink and '
        'teal signs, wet pavement full of reflections, a lone person with a '
        'clear umbrella walking away, steam rising from the vents',
    image: 'assets/explore/neon_city.jpg',
  ),
  ExploreIdea(
    title: 'Cottage by the sea',
    style: 'Watercolor',
    prompt:
        'A small white cottage on a cliff above the sea, wildflowers in '
        'bloom around it, a few sailboats on the water and a soft morning '
        'sky, calm and nostalgic',
    image: 'assets/explore/sea_cottage.jpg',
  ),
  ExploreIdea(
    title: 'Robot gardener',
    style: '3D',
    prompt:
        'A cute round robot with big eyes watering potted plants on a sunny '
        'balcony, tiny leaves and flowers, soft shadows, bright and '
        'friendly, centered composition',
    image: 'assets/explore/robot_gardener.jpg',
  ),
  ExploreIdea(
    title: 'Lighthouse storm',
    style: 'Cinematic',
    prompt:
        'A lone lighthouse on a rocky coast at dusk, huge waves crashing '
        'against the rocks, a beam of light cutting through dark storm '
        'clouds, strong backlight, wide shot',
    image: 'assets/explore/lighthouse.jpg',
  ),
  ExploreIdea(
    title: 'Floating castle',
    style: 'Fantasy',
    prompt:
        'A glowing castle floating above the clouds, waterfalls pouring from '
        'its edges into the mist below, a dragon flying in the distance, '
        'golden sunset sky',
    image: 'assets/explore/floating_castle.jpg',
  ),
  ExploreIdea(
    title: 'Sunflower field',
    style: 'Oil Painting',
    prompt:
        'A wide field of sunflowers at golden hour with a winding dirt path '
        'leading to a distant farmhouse, dramatic clouds, warm light',
    image: 'assets/explore/sunflowers.jpg',
  ),
  ExploreIdea(
    title: 'Night market',
    style: 'Pixel Art',
    prompt:
        'A busy night market street in a small town, glowing paper lanterns, '
        'food stalls, tiny villagers walking around and a cat sitting on a '
        'rooftop',
    image: 'assets/explore/night_market.jpg',
  ),
  ExploreIdea(
    title: 'Street cafe',
    style: 'Sketch',
    prompt:
        'A cozy corner cafe with a striped awning, a few small round tables '
        'outside, a bicycle leaning on the wall and potted plants by the '
        'door',
    image: 'assets/explore/street_cafe.jpg',
  ),
];
