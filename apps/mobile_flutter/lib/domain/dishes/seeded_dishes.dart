import 'package:mymenu/domain/dishes/dish.dart';

const String _salmonImage =
    'https://images.unsplash.com/photo-1467003909585-2f8a72700288'
    '?auto=format&fit=crop&w=1200&q=80';
const String _linguineImage =
    'https://images.unsplash.com/photo-1645112411341-6c4fd023714a'
    '?auto=format&fit=crop&w=1200&q=80';
const String _katsuImage =
    'https://images.unsplash.com/photo-1512058564366-18510be2db19'
    '?auto=format&fit=crop&w=1200&q=80';
const String _phoImage =
    'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43'
    '?auto=format&fit=crop&w=1200&q=80';
const String _salmonArtwork = 'asset://assets/dish_art/miso-salmon.png';
const String _linguineArtwork = 'asset://assets/dish_art/linguine.png';
const String _katsuArtwork = 'asset://assets/dish_art/katsu.png';
const String _phoArtwork = 'asset://assets/dish_art/pho.png';

final List<Dish> seededDishes = <Dish>[
  Dish(
    id: 'dish_salmon',
    title: 'Miso Salmon Bowl',
    description: 'Sweet-savory salmon, rice, and whatever greens are around.',
    heroImageUrl: _salmonArtwork,
    category: 'Bowls',
    prepMinutes: 25,
    difficulty: 'Easy',
    madeCount: 8,
    lastMadeLabel: 'Jul 18',
    isFavorite: true,
    ingredients: const <String>[
      'Salmon fillets|2 pieces · about 6 oz each',
      'White miso + maple|2 tbsp + 1 tbsp',
      'Cooked rice|2 bowls',
      'Seasonal greens|Whatever is around',
    ],
    recipeSteps: const <String>[
      'Whisk white miso, maple syrup, and a splash of soy.',
      'Brush the salmon generously and roast until nearly cooked.',
      'Broil for the last 2 minutes so the edges turn crisp.',
      'Serve over rice with greens and any quick pickles.',
    ],
    notes: _notes('dish_salmon', <String>[
      'Broil for the last 2 minutes—the crispy edges made it way better.',
      'Kids liked this glaze. Keep the chili crisp on the table next time.',
      'Try serving in a shallow bowl next time.',
    ]),
    sourcePhotos: _sources(_salmonImage, 12),
  ),
  Dish(
    id: 'dish_linguine',
    title: 'Lemon Garlic Linguine',
    description: 'Bright lemon, silky garlic butter, and a shower of parmesan.',
    heroImageUrl: _linguineArtwork,
    category: 'Pasta',
    prepMinutes: 30,
    difficulty: 'Easy',
    madeCount: 5,
    lastMadeLabel: 'Jun 28',
    isFavorite: true,
    ingredients: const <String>[
      'Linguine|8 oz',
      'Garlic + butter|4 cloves + 3 tbsp',
      'Lemon|Zest and juice',
      'Parmesan|½ cup, finely grated',
    ],
    recipeSteps: const <String>[
      'Cook linguine in well-salted water until just al dente.',
      'Warm the garlic gently in butter without browning it.',
      'Add lemon, parmesan, and pasta water to make a glossy sauce.',
      'Toss, taste, and finish with more lemon.',
    ],
    notes: _notes('dish_linguine', <String>[
      'Use more lemon next time.',
      'Kids liked the extra parmesan.',
      'Do not overcook the garlic.',
    ]),
    sourcePhotos: _sources(_linguineImage, 7),
  ),
  Dish(
    id: 'dish_katsu',
    title: 'Chicken Katsu Curry',
    description: 'Crispy chicken over rice with silky Japanese curry.',
    heroImageUrl: _katsuArtwork,
    category: 'Mains',
    prepMinutes: 45,
    difficulty: 'Medium',
    madeCount: 3,
    lastMadeLabel: 'Jun 14',
    ingredients: const <String>[
      'Chicken cutlets|3 thin cutlets',
      'Panko|1½ cups',
      'Japanese curry|1 box',
      'Rice + cabbage|For serving',
    ],
    recipeSteps: const <String>[
      'Bread the cutlets with flour, egg, and panko.',
      'Pan-fry until deeply golden and cooked through.',
      'Simmer onion and carrot, then add the curry roux.',
      'Slice the chicken and serve with rice and plenty of sauce.',
    ],
    notes: _notes('dish_katsu', <String>[
      'Crispier crumbs next time.',
      'Double the curry sauce.',
    ]),
    sourcePhotos: _sources(_katsuImage, 5),
  ),
  Dish(
    id: 'dish_pho',
    title: 'Sunday Pho',
    description: 'A slow, fragrant broth with noodles and a table of herbs.',
    heroImageUrl: _phoArtwork,
    category: 'Soups',
    prepMinutes: 120,
    difficulty: 'Weekend',
    madeCount: 12,
    lastMadeLabel: 'May 31',
    ingredients: const <String>[
      'Rice noodles|14 oz',
      'Beef broth|6 cups',
      'Star anise + onion|For the broth',
      'Herbs, sprouts, lime|For the table',
    ],
    recipeSteps: const <String>[
      'Char onion and ginger, then toast the spices.',
      'Simmer the aromatics in broth until deeply fragrant.',
      'Cook the noodles and divide among warm bowls.',
      'Ladle over broth and serve with herbs and lime.',
    ],
    notes: _notes('dish_pho', <String>[
      'Broth improves overnight.',
      'Evolving since 2024.',
    ]),
    sourcePhotos: _sources(_phoImage, 18),
  ),
  Dish(
    id: 'dish_garlic_noodles',
    title: 'Garlic Butter Noodles',
    description: 'Glossy noodles with toasted garlic and black pepper.',
    heroImageUrl: _linguineArtwork,
    category: 'Pasta',
    prepMinutes: 20,
    difficulty: 'Easy',
    madeCount: 1,
    lastMadeLabel: 'Jul 2',
    ingredients: const <String>['Noodles|8 oz', 'Garlic butter|4 tbsp'],
    recipeSteps: const <String>[
      'Boil noodles.',
      'Toss with garlic butter and pasta water.',
    ],
    notes: _notes('dish_garlic_noodles', <String>[
      'More black pepper next time.',
    ]),
    sourcePhotos: _sources(_linguineImage, 2),
  ),
  Dish(
    id: 'dish_tofu',
    title: 'Sesame Tofu Bowl',
    description: 'Crisp tofu, rice, sesame glaze, and green vegetables.',
    heroImageUrl: _salmonImage,
    category: 'Bowls',
    prepMinutes: 30,
    difficulty: 'Easy',
    madeCount: 2,
    lastMadeLabel: 'Jun 20',
    ingredients: const <String>['Firm tofu|1 block', 'Sesame glaze|½ cup'],
    recipeSteps: const <String>[
      'Crisp the tofu.',
      'Glaze and serve over rice.',
    ],
    notes: _notes('dish_tofu', <String>[
      'Press the tofu longer.',
    ]),
    sourcePhotos: _sources(_salmonImage, 3),
  ),
];

List<DishNote> _notes(String dishId, List<String> bodies) {
  return bodies.asMap().entries.map((MapEntry<int, String> entry) {
    return DishNote(
      id: '${dishId}_note_${entry.key}',
      dishId: dishId,
      body: entry.value,
      position: entry.key,
    );
  }).toList(growable: false);
}

List<SourcePhoto> _sources(String url, int count) {
  const List<String> labels = <String>[
    'Jul 18, 2026',
    'May 9, 2026',
    'Jan 24, 2026',
    'Nov 2, 2025',
  ];
  return List<SourcePhoto>.generate(
    count,
    (int index) => SourcePhoto(
      url: url,
      capturedLabel: labels[index % labels.length],
      note: index == 0 ? 'Latest cooking moment.' : null,
      confidenceLabel: index == 0 ? '94%' : null,
    ),
    growable: false,
  );
}
