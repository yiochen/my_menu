import 'package:mymenu/domain/dishes/dish.dart';

final List<Dish> seededDishes = <Dish>[
  Dish(
    id: 'dish_linguine',
    title: 'Lemon Garlic Linguine',
    description:
        'Creamy, garlicky, and bright with lemon. The weeknight pasta that always lands.',
    heroImageUrl:
        'https://images.unsplash.com/photo-1645112411341-6c4fd023714a?auto=format&fit=crop&w=1200&q=80',
    category: 'Pasta',
    prepMinutes: 25,
    difficulty: 'Easy',
    servings: 2,
    madeCount: 8,
    lastMadeLabel: '2 weeks ago',
    isFavorite: true,
    ingredients: <String>[
      '8 oz linguine',
      '4 garlic cloves',
      '3 tbsp butter',
      '1 lemon',
      '1/2 cup parmesan',
      '2 tbsp parsley (optional)',
    ],
    recipeSteps: <String>[
      'Cook linguine in salted water until just al dente and reserve a little pasta water.',
      'Saute sliced garlic gently in butter until fragrant but not browned.',
      'Add lemon zest, juice, parmesan, and a splash of pasta water to make a glossy sauce.',
      'Toss in linguine, adjust with more pasta water, and finish with parsley.',
    ],
    notes: <String>[
      'Use more lemon next time.',
      'Kids liked the version with extra parmesan.',
      'Do not overcook the garlic.',
    ],
    sourcePhotos: const <SourcePhoto>[
      SourcePhoto(
        url:
            'https://images.unsplash.com/photo-1645112411341-6c4fd023714a?auto=format&fit=crop&w=1200&q=80',
        capturedLabel: '3 days ago',
        note: 'Added more garlic and parsley.',
        confidenceLabel: '92%',
      ),
      SourcePhoto(
        url:
            'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=1200&q=80',
        capturedLabel: '7 weeks ago',
        note: 'Used shrimp instead of chicken.',
      ),
    ],
  ),
  Dish(
    id: 'dish_pho',
    title: 'Pho',
    description:
        'Comforting broth, slippery noodles, and a big plate of herbs on the side.',
    heroImageUrl:
        'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?auto=format&fit=crop&w=1200&q=80',
    category: 'Soups',
    prepMinutes: 30,
    difficulty: 'Medium',
    servings: 4,
    madeCount: 6,
    lastMadeLabel: '4 days ago',
    ingredients: <String>[
      '14 oz rice noodles',
      '6 cups beef broth',
      '2 tbsp fish sauce',
      '2 star anise',
      '2 cups bean sprouts',
      '1 bundle Thai basil',
    ],
    recipeSteps: <String>[
      'Warm the broth with aromatics and fish sauce until deeply fragrant.',
      'Soak or cook rice noodles according to package directions.',
      'Layer noodles, thinly sliced beef, and hot broth into bowls.',
      'Serve with sprouts, basil, lime, and chile on the side.',
    ],
    notes: <String>[
      'Broth improves overnight.',
      'Add charred onion when there is time.',
    ],
    sourcePhotos: const <SourcePhoto>[
      SourcePhoto(
        url:
            'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?auto=format&fit=crop&w=1200&q=80',
        capturedLabel: '4 days ago',
        note: 'Extra herbs today.',
        confidenceLabel: '88%',
      ),
      SourcePhoto(
        url:
            'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=1200&q=80',
        capturedLabel: '5 weeks ago',
        note: 'Used brisket slices.',
      ),
    ],
  ),
  Dish(
    id: 'dish_katsu',
    title: 'Chicken Katsu Curry',
    description: 'Crispy chicken over rice with silky Japanese curry sauce.',
    heroImageUrl:
        'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=1200&q=80',
    category: 'Mains',
    prepMinutes: 40,
    difficulty: 'Medium',
    servings: 3,
    madeCount: 5,
    lastMadeLabel: '11 days ago',
    ingredients: <String>[
      '3 chicken cutlets',
      '1.5 cups panko',
      '2 eggs',
      '1 box Japanese curry roux',
      '1 onion',
      '1 carrot',
    ],
    recipeSteps: <String>[
      'Bread chicken cutlets with flour, egg, and panko.',
      'Pan fry until deeply golden and cooked through.',
      'Simmer onion and carrot, then melt in curry roux with water.',
      'Slice the chicken and serve over rice with plenty of curry sauce.',
    ],
    notes: <String>[
      'Double the curry sauce.',
      'Best with shredded cabbage.',
    ],
    sourcePhotos: const <SourcePhoto>[
      SourcePhoto(
        url:
            'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=1200&q=80',
        capturedLabel: '11 days ago',
        note: 'Used thinner cutlets.',
        confidenceLabel: '83%',
      ),
    ],
  ),
  Dish(
    id: 'dish_salmon',
    title: 'Miso Salmon Bowl',
    description:
        'Sweet-salty glazed salmon with rice, cucumbers, and a fast pickled crunch.',
    heroImageUrl:
        'https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=1200&q=80',
    category: 'Bowls',
    prepMinutes: 20,
    difficulty: 'Easy',
    servings: 2,
    madeCount: 4,
    lastMadeLabel: '18 days ago',
    isFavorite: true,
    ingredients: <String>[
      '2 salmon fillets',
      '2 tbsp white miso',
      '1 tbsp soy sauce',
      '2 cups cooked rice',
      '1 cucumber',
      '1 tbsp sesame seeds (optional)',
    ],
    recipeSteps: <String>[
      'Whisk miso, soy, and a little honey together for the glaze.',
      'Roast or air fry salmon until just cooked and lacquered.',
      'Assemble bowls with rice, cucumber, and salmon.',
      'Finish with sesame seeds and any quick pickles in the fridge.',
    ],
    notes: <String>[
      'Great fast dinner.',
      'Try with brown rice when meal prepping.',
    ],
    sourcePhotos: const <SourcePhoto>[
      SourcePhoto(
        url:
            'https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=1200&q=80',
        capturedLabel: '18 days ago',
        note: 'Added avocado.',
        confidenceLabel: '91%',
      ),
      SourcePhoto(
        url:
            'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=1200&q=80',
        capturedLabel: '8 weeks ago',
        note: 'More vibrant glaze here.',
      ),
    ],
  ),
];
