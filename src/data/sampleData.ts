import { formatISO, subDays } from 'date-fns';

import { type DishCategory } from '@/types/models';

export type SeedDish = {
  title: string;
  description: string;
  heroImageUri: string;
  category: DishCategory;
  prepMinutes: number;
  difficulty: 'Easy' | 'Medium' | 'Hard';
  servings: number;
  madeCount: number;
  lastMadeAt: string;
  ingredients: {
    name: string;
    quantity?: string;
    unit?: string;
    optional?: boolean;
  }[];
  recipeSteps: string[];
  notes: string[];
  sourcePhotos: {
    uri: string;
    capturedAt: string;
    note?: string;
    aiMatched?: boolean;
    confidence?: number;
  }[];
};

const sources = {
  linguine: [
    'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1645112411341-6c4fd023714a?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=1200&q=80',
  ],
  pho: [
    'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=1200&q=80',
  ],
  katsu: [
    'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1574484284002-952d92456975?auto=format&fit=crop&w=1200&q=80',
  ],
  salmon: [
    'https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=1200&q=80',
  ],
  beefSoup: [
    'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?auto=format&fit=crop&w=1200&q=80',
  ],
  shrimp: [
    'https://images.unsplash.com/photo-1563379091339-03246963d29b?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1625944525533-473f1b3d54b1?auto=format&fit=crop&w=1200&q=80',
  ],
} as const;

function daysAgo(days: number) {
  return formatISO(subDays(new Date(), days));
}

export const SAMPLE_DISHES: SeedDish[] = [
  {
    title: 'Lemon Garlic Linguine',
    description: 'Creamy, garlicky, and bright with lemon. The weeknight pasta that always lands.',
    heroImageUri: sources.linguine[0],
    category: 'Pasta',
    prepMinutes: 25,
    difficulty: 'Easy',
    servings: 2,
    madeCount: 8,
    lastMadeAt: daysAgo(14),
    ingredients: [
      { name: 'Linguine', quantity: '8', unit: 'oz' },
      { name: 'Garlic cloves', quantity: '4' },
      { name: 'Butter', quantity: '3', unit: 'tbsp' },
      { name: 'Lemon', quantity: '1' },
      { name: 'Parmesan', quantity: '0.5', unit: 'cup' },
      { name: 'Parsley', quantity: '2', unit: 'tbsp', optional: true },
    ],
    recipeSteps: [
      'Cook linguine in salted water until just al dente and reserve a little pasta water.',
      'Saute sliced garlic gently in butter until fragrant but not browned.',
      'Add lemon zest, juice, parmesan, and a splash of pasta water to make a glossy sauce.',
      'Toss in linguine, adjust with more pasta water, and finish with parsley.',
    ],
    notes: [
      'Use more lemon next time.',
      'Kids liked the version with extra parmesan.',
      'Do not overcook the garlic.',
    ],
    sourcePhotos: [
      { uri: sources.linguine[0], capturedAt: daysAgo(3), note: 'Added more garlic and parsley.', aiMatched: true, confidence: 0.92 },
      { uri: sources.linguine[1], capturedAt: daysAgo(48), note: 'Used shrimp instead of chicken.' },
      { uri: sources.linguine[2], capturedAt: daysAgo(84), note: 'First time making it.' },
    ],
  },
  {
    title: 'Pho',
    description: 'Comforting broth, slippery noodles, and a big plate of herbs on the side.',
    heroImageUri: sources.pho[0],
    category: 'Soups',
    prepMinutes: 30,
    difficulty: 'Medium',
    servings: 4,
    madeCount: 6,
    lastMadeAt: daysAgo(4),
    ingredients: [
      { name: 'Rice noodles', quantity: '14', unit: 'oz' },
      { name: 'Beef broth', quantity: '6', unit: 'cups' },
      { name: 'Fish sauce', quantity: '2', unit: 'tbsp' },
      { name: 'Star anise', quantity: '2' },
      { name: 'Bean sprouts', quantity: '2', unit: 'cups' },
      { name: 'Thai basil', quantity: '1', unit: 'bundle' },
    ],
    recipeSteps: [
      'Warm the broth with aromatics and fish sauce until deeply fragrant.',
      'Soak or cook rice noodles according to package directions.',
      'Layer noodles, thinly sliced beef, and hot broth into bowls.',
      'Serve with sprouts, basil, lime, and chile on the side.',
    ],
    notes: ['Broth improves overnight.', 'Add charred onion when there is time.'],
    sourcePhotos: [
      { uri: sources.pho[0], capturedAt: daysAgo(4), note: 'Extra herbs today.', aiMatched: true, confidence: 0.88 },
      { uri: sources.pho[1], capturedAt: daysAgo(39), note: 'Used brisket slices.' },
    ],
  },
  {
    title: 'Chicken Katsu Curry',
    description: 'Crispy chicken over rice with silky Japanese curry sauce.',
    heroImageUri: sources.katsu[0],
    category: 'Mains',
    prepMinutes: 40,
    difficulty: 'Medium',
    servings: 3,
    madeCount: 5,
    lastMadeAt: daysAgo(11),
    ingredients: [
      { name: 'Chicken cutlets', quantity: '3' },
      { name: 'Panko', quantity: '1.5', unit: 'cups' },
      { name: 'Eggs', quantity: '2' },
      { name: 'Japanese curry roux', quantity: '1', unit: 'box' },
      { name: 'Onion', quantity: '1' },
      { name: 'Carrot', quantity: '1' },
    ],
    recipeSteps: [
      'Bread chicken cutlets with flour, egg, and panko.',
      'Pan fry until deeply golden and cooked through.',
      'Simmer onion and carrot, then melt in curry roux with water.',
      'Slice the chicken and serve over rice with plenty of curry sauce.',
    ],
    notes: ['Double the curry sauce.', 'Best with shredded cabbage.'],
    sourcePhotos: [
      { uri: sources.katsu[0], capturedAt: daysAgo(11), note: 'Used thinner cutlets.', aiMatched: true, confidence: 0.83 },
      { uri: sources.katsu[1], capturedAt: daysAgo(63), note: 'Excellent lunch leftovers.' },
    ],
  },
  {
    title: 'Miso Salmon Bowl',
    description: 'Sweet-salty glazed salmon with rice, cucumbers, and a fast pickled crunch.',
    heroImageUri: sources.salmon[0],
    category: 'Bowls',
    prepMinutes: 20,
    difficulty: 'Easy',
    servings: 2,
    madeCount: 4,
    lastMadeAt: daysAgo(18),
    ingredients: [
      { name: 'Salmon fillets', quantity: '2' },
      { name: 'White miso', quantity: '2', unit: 'tbsp' },
      { name: 'Soy sauce', quantity: '1', unit: 'tbsp' },
      { name: 'Cooked rice', quantity: '2', unit: 'cups' },
      { name: 'Cucumber', quantity: '1' },
      { name: 'Sesame seeds', quantity: '1', unit: 'tbsp', optional: true },
    ],
    recipeSteps: [
      'Whisk miso, soy, and a little honey together for the glaze.',
      'Roast or air fry salmon until just cooked and lacquered.',
      'Assemble bowls with rice, cucumber, and salmon.',
      'Finish with sesame seeds and any quick pickles in the fridge.',
    ],
    notes: ['Great fast dinner.', 'Try with brown rice when meal prepping.'],
    sourcePhotos: [
      { uri: sources.salmon[0], capturedAt: daysAgo(18), note: 'Added avocado.', aiMatched: true, confidence: 0.91 },
      { uri: sources.salmon[1], capturedAt: daysAgo(56), note: 'More vibrant glaze here.' },
    ],
  },
  {
    title: 'Beef Noodle Soup',
    description: 'Rich broth, braised beef, and noodles that make the whole kitchen smell serious.',
    heroImageUri: sources.beefSoup[0],
    category: 'Soups',
    prepMinutes: 45,
    difficulty: 'Hard',
    servings: 4,
    madeCount: 3,
    lastMadeAt: daysAgo(24),
    ingredients: [
      { name: 'Beef shank', quantity: '1.5', unit: 'lb' },
      { name: 'Egg noodles', quantity: '12', unit: 'oz' },
      { name: 'Ginger', quantity: '2', unit: 'inch' },
      { name: 'Garlic', quantity: '5', unit: 'cloves' },
      { name: 'Soy sauce', quantity: '3', unit: 'tbsp' },
      { name: 'Bok choy', quantity: '3', unit: 'heads', optional: true },
    ],
    recipeSteps: [
      'Brown the beef shank well before simmering with ginger, garlic, and broth.',
      'Cook until the beef is tender enough to shred or slice.',
      'Boil noodles separately and warm greens in the broth.',
      'Assemble bowls with noodles, beef, broth, and greens.',
    ],
    notes: ['Excellent rainy day dish.', 'Freeze extra broth in portions.'],
    sourcePhotos: [
      { uri: sources.beefSoup[0], capturedAt: daysAgo(24), note: 'Broth came out richer this time.', aiMatched: true, confidence: 0.8 },
      { uri: sources.beefSoup[1], capturedAt: daysAgo(90), note: 'Needed more chile oil.' },
    ],
  },
];

export const MOCK_GENERATED_DISHES: SeedDish[] = [
  ...SAMPLE_DISHES,
  {
    title: 'Garlic Butter Shrimp',
    description: 'Fast skillet shrimp with butter, garlic, and lemon over rice or toast.',
    heroImageUri: sources.shrimp[0],
    category: 'Mains',
    prepMinutes: 18,
    difficulty: 'Easy',
    servings: 2,
    madeCount: 1,
    lastMadeAt: daysAgo(2),
    ingredients: [
      { name: 'Shrimp', quantity: '1', unit: 'lb' },
      { name: 'Butter', quantity: '3', unit: 'tbsp' },
      { name: 'Garlic', quantity: '4', unit: 'cloves' },
      { name: 'Lemon', quantity: '1' },
      { name: 'Parsley', quantity: '2', unit: 'tbsp', optional: true },
    ],
    recipeSteps: [
      'Pat shrimp dry and season lightly with salt.',
      'Cook shrimp quickly in butter until just pink.',
      'Add garlic and lemon at the end so the sauce stays fresh.',
      'Finish with parsley and spoon over rice or crusty bread.',
    ],
    notes: ['Do not crowd the pan.'],
    sourcePhotos: [
      { uri: sources.shrimp[0], capturedAt: daysAgo(2), note: 'Great over rice.' },
      { uri: sources.shrimp[1], capturedAt: daysAgo(31), note: 'Added chile flakes.' },
    ],
  },
];
