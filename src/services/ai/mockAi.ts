import { MOCK_GENERATED_DISHES } from '@/data/sampleData';
import type { Dish } from '@/types/models';

import type {
  AiService,
  ClassifyCaptureInput,
  ClassifyCaptureResult,
  GenerateDishFromIdeaInput,
  GenerateDishFromPhotoInput,
  GeneratedDish,
  ImproveDishCoverInput,
  ImproveDishCoverResult,
} from './types';

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function hashString(input: string) {
  let hash = 0;
  for (let index = 0; index < input.length; index += 1) {
    hash = (hash * 31 + input.charCodeAt(index)) >>> 0;
  }
  return hash;
}

function normalize(input?: string) {
  return (input ?? '').toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim();
}

function slugTitle(title: string) {
  return normalize(title);
}

function toGeneratedDish(seed: (typeof MOCK_GENERATED_DISHES)[number]): GeneratedDish {
  return {
    title: seed.title,
    description: seed.description,
    category: seed.category,
    prepMinutes: seed.prepMinutes,
    difficulty: seed.difficulty,
    servings: seed.servings,
    ingredients: seed.ingredients,
    recipeSteps: seed.recipeSteps,
    notes: seed.notes,
    heroImageUri: seed.heroImageUri,
  };
}

function findMatchingDish(existingDishes: Dish[], haystack: string) {
  const normalizedHaystack = normalize(haystack);
  return existingDishes.find((dish) => {
    const title = slugTitle(dish.title);
    return title && normalizedHaystack.includes(title.split(' ')[0]) && normalizedHaystack.includes(title.split(' ').slice(-1)[0]);
  });
}

function getDeterministicDelay(input: string) {
  return 800 + (hashString(input) % 700);
}

function buildDishFromIdeaText(text: string) {
  const normalized = normalize(text);
  if (normalized.includes('pasta') || normalized.includes('linguine')) {
    return toGeneratedDish(MOCK_GENERATED_DISHES.find((dish) => dish.title === 'Lemon Garlic Linguine')!);
  }
  if (normalized.includes('pho') || normalized.includes('noodle soup')) {
    return toGeneratedDish(MOCK_GENERATED_DISHES.find((dish) => dish.title === 'Pho')!);
  }
  if (normalized.includes('salmon') || normalized.includes('bowl')) {
    return toGeneratedDish(MOCK_GENERATED_DISHES.find((dish) => dish.title === 'Miso Salmon Bowl')!);
  }
  if (normalized.includes('shrimp')) {
    return toGeneratedDish(MOCK_GENERATED_DISHES.find((dish) => dish.title === 'Garlic Butter Shrimp')!);
  }

  const seed = MOCK_GENERATED_DISHES[hashString(text) % MOCK_GENERATED_DISHES.length];
  return {
    ...toGeneratedDish(seed),
    title: text
      .split(' ')
      .filter(Boolean)
      .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
      .join(' '),
    description: `A saved dish idea for ${text.toLowerCase()}, ready to refine the next time you cook it.`,
  };
}

export const mockAiService: AiService = {
  async classifyCapture({ capture, existingDishes }: ClassifyCaptureInput): Promise<ClassifyCaptureResult> {
    const signature = capture.text ?? capture.uri ?? capture.id;
    await sleep(getDeterministicDelay(signature));

    const haystack = `${capture.text ?? ''} ${capture.uri ?? ''}`;
    const directMatch = findMatchingDish(existingDishes, haystack);
    if (directMatch) {
      return {
        action: 'attach_to_existing',
        dishId: directMatch.id,
        confidence: 0.91,
      };
    }

    const bucket = hashString(signature) % 10;
    if (bucket <= 4 && existingDishes.length > 0) {
      return {
        action: 'attach_to_existing',
        dishId: existingDishes[hashString(`${signature}dish`) % existingDishes.length].id,
        confidence: 0.78,
      };
    }

    if (bucket <= 6) {
      const suggestions = existingDishes.slice(0, 3).map((dish) => dish.id);
      return {
        action: 'needs_review',
        suggestedDishIds: suggestions,
        confidence: 0.54,
      };
    }

    return {
      action: 'create_new_dish',
      generatedDish: await this.generateDishFromPhoto({ capture }),
      confidence: 0.73,
    };
  },

  async generateDishFromPhoto({ capture }: GenerateDishFromPhotoInput) {
    const signature = capture.uri ?? capture.text ?? capture.id;
    await sleep(getDeterministicDelay(`${signature}-generate`));
    const seed = MOCK_GENERATED_DISHES[hashString(signature) % MOCK_GENERATED_DISHES.length];
    return toGeneratedDish(seed);
  },

  async generateDishFromIdea({ text }: GenerateDishFromIdeaInput) {
    await sleep(getDeterministicDelay(`${text}-idea`));
    return buildDishFromIdeaText(text);
  },

  async improveDishCover({ dish, sourcePhotos, prompt }: ImproveDishCoverInput): Promise<ImproveDishCoverResult> {
    await sleep(getDeterministicDelay(`${dish.id}-${prompt}`));
    const pool = sourcePhotos.map((photo) => photo.uri).filter(Boolean);
    if (pool.length > 0) {
      const next = pool[hashString(`${dish.id}-${prompt}`) % pool.length];
      return { heroImageUri: next };
    }

    return {
      heroImageUri:
        dish.heroImageUri ??
        'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=1200&q=80',
    };
  },
};
