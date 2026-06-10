import { create } from 'zustand';
import { formatISO } from 'date-fns';

import { aiService, type GeneratedDish } from '@/services/ai';
import { localDb } from '@/services/db/localDb';
import type { CreateDishInput, DatabaseService } from '@/services/db/types';
import type {
  CaptureItem,
  Dish,
  DishNote,
  ID,
  Ingredient,
  PlanningLabel,
  PlannedMeal,
  RecipeStep,
  ReviewItem,
  SourcePhoto,
} from '@/types/models';
import { getWeekRange, toDateKey } from '@/utils/date';

type CaptureProcessSummary = {
  createdDishIds: ID[];
  attachedDishIds: ID[];
  reviewCount: number;
  processed: number;
};

type AppStore = {
  dishes: Dish[];
  plannedMeals: PlannedMeal[];
  reviewItems: ReviewItem[];
  ingredients: Ingredient[];
  recipeSteps: RecipeStep[];
  notes: DishNote[];
  sourcePhotos: SourcePhoto[];
  captureItems: CaptureItem[];
  isLoading: boolean;
  loadInitialData: () => Promise<void>;
  capturePhoto: (uri: string) => Promise<CaptureProcessSummary>;
  importPhotos: (uris: string[]) => Promise<CaptureProcessSummary>;
  addIdea: (text: string) => Promise<Dish>;
  createDishFromGenerated: (generatedDish: GeneratedDish) => Promise<Dish>;
  attachCaptureToDish: (captureId: ID, dishId: ID) => Promise<void>;
  resolveReview: (reviewItemId: ID, resolution: ID | 'create_new') => Promise<void>;
  deleteCapture: (captureId: ID, reviewItemId?: ID) => Promise<void>;
  planDish: (dishId: ID, date: string, label?: PlanningLabel) => Promise<void>;
  improveCover: (dishId: ID, prompt: string) => Promise<void>;
  addNote: (dishId: ID, text: string) => Promise<void>;
  toggleFavorite: (dishId: ID) => Promise<void>;
};

const dbService: DatabaseService = localDb;

async function refreshStore(set: (partial: Partial<AppStore>) => void, showLoading = false) {
  if (showLoading) {
    set({ isLoading: true });
  }
  const nextState = await hydrateState();
  set({ ...nextState, isLoading: false });
}

async function hydrateState() {
  const dishes = await dbService.getDishes();
  const { start, end } = getWeekRange();
  const plannedMeals = await dbService.getPlannedMeals(toDateKey(start), toDateKey(end));
  const reviewItems = await dbService.getReviewItems();

  const ingredients = (await Promise.all(dishes.map((dish) => dbService.getIngredients(dish.id)))).flat();
  const recipeSteps = (await Promise.all(dishes.map((dish) => dbService.getRecipeSteps(dish.id)))).flat();
  const notes = (await Promise.all(dishes.map((dish) => dbService.getNotes(dish.id)))).flat();
  const sourcePhotos = (await Promise.all(dishes.map((dish) => dbService.getSourcePhotos(dish.id)))).flat();
  const captureItems = await dbService.getCaptureItems();

  return {
    dishes,
    plannedMeals,
    reviewItems,
    ingredients,
    recipeSteps,
    notes,
    sourcePhotos,
    captureItems,
  };
}

async function createDishFromGenerated(generatedDish: GeneratedDish) {
  const input: CreateDishInput = {
    title: generatedDish.title,
    description: generatedDish.description,
    heroImageUri: generatedDish.heroImageUri,
    category: generatedDish.category,
    prepMinutes: generatedDish.prepMinutes,
    difficulty: generatedDish.difficulty,
    servings: generatedDish.servings,
    notes: generatedDish.notes,
    ingredients: generatedDish.ingredients,
    recipeSteps: generatedDish.recipeSteps,
  };

  return dbService.createDish(input);
}

async function attachCapture(capture: CaptureItem, dishId: ID) {
  const dish = await dbService.getDish(dishId);
  if (!dish) {
    throw new Error(`Dish not found: ${dishId}`);
  }

  if (capture.uri) {
    await dbService.addSourcePhoto(dishId, {
      uri: capture.uri,
      capturedAt: formatISO(new Date()),
      aiMatched: true,
      confidence: capture.confidence,
      note: capture.text,
    });
  }

  await dbService.updateDish(dishId, {
    madeCount: dish.madeCount + 1,
    lastMadeAt: formatISO(new Date()),
  });

  await dbService.updateCaptureItem(capture.id, {
    status: 'attached',
    linkedDishId: dishId,
  });
}

async function processCapture(capture: CaptureItem, dishes: Dish[]) {
  const sourcePhotosByDishId: Record<ID, SourcePhoto[]> = {};
  for (const dish of dishes) {
    sourcePhotosByDishId[dish.id] = await dbService.getSourcePhotos(dish.id);
  }

  const result = await aiService.classifyCapture({
    capture,
    existingDishes: dishes,
    sourcePhotosByDishId,
  });

  if (result.action === 'attach_to_existing') {
    await dbService.updateCaptureItem(capture.id, {
      confidence: result.confidence,
      linkedDishId: result.dishId,
    });
    await attachCapture({ ...capture, confidence: result.confidence }, result.dishId);
    return { type: 'attached' as const, dishId: result.dishId };
  }

  if (result.action === 'create_new_dish') {
    const dish = await createDishFromGenerated(result.generatedDish);
    if (capture.uri) {
      await dbService.addSourcePhoto(dish.id, {
        uri: capture.uri,
        capturedAt: formatISO(new Date()),
        aiMatched: false,
        confidence: result.confidence,
      });
      await dbService.updateDish(dish.id, {
        madeCount: 1,
        lastMadeAt: formatISO(new Date()),
      });
    }
    await dbService.updateCaptureItem(capture.id, {
      status: 'created_dish',
      confidence: result.confidence,
      linkedDishId: dish.id,
    });
    return { type: 'created' as const, dishId: dish.id };
  }

  await dbService.updateCaptureItem(capture.id, {
    status: 'needs_review',
    suggestedDishIds: result.suggestedDishIds,
    confidence: result.confidence,
  });
  await dbService.createReviewItem({
    captureItemId: capture.id,
    uri: capture.uri,
    text: capture.text,
    suggestedDishIds: result.suggestedDishIds,
    confidence: result.confidence,
    createdAt: capture.createdAt,
  });
  return { type: 'review' as const };
}

export const useAppStore = create<AppStore>((set, get) => ({
  dishes: [],
  plannedMeals: [],
  reviewItems: [],
  ingredients: [],
  recipeSteps: [],
  notes: [],
  sourcePhotos: [],
  captureItems: [],
  isLoading: true,

  async loadInitialData() {
    await localDb.initialize();
    await refreshStore(set, get().dishes.length === 0);
  },

  async capturePhoto(uri) {
    const capture = await dbService.createCaptureItem({ type: 'photo', uri, status: 'processing' });
    const outcome = await processCapture(capture, get().dishes);
    await refreshStore(set);
    return {
      createdDishIds: outcome.type === 'created' ? [outcome.dishId] : [],
      attachedDishIds: outcome.type === 'attached' ? [outcome.dishId] : [],
      reviewCount: outcome.type === 'review' ? 1 : 0,
      processed: 1,
    };
  },

  async importPhotos(uris) {
    const summary: CaptureProcessSummary = {
      createdDishIds: [],
      attachedDishIds: [],
      reviewCount: 0,
      processed: uris.length,
    };

    for (const uri of uris) {
      const capture = await dbService.createCaptureItem({ type: 'photo', uri, status: 'processing' });
      const outcome = await processCapture(capture, get().dishes);
      if (outcome.type === 'created') {
        summary.createdDishIds.push(outcome.dishId);
      } else if (outcome.type === 'attached') {
        summary.attachedDishIds.push(outcome.dishId);
      } else {
        summary.reviewCount += 1;
      }
    }

    await refreshStore(set);
    return summary;
  },

  async addIdea(text) {
    const capture = await dbService.createCaptureItem({
      type: 'idea',
      text,
      status: 'processing',
    });
    const generated = await aiService.generateDishFromIdea({ text });
    const dish = await createDishFromGenerated(generated);
    await dbService.updateCaptureItem(capture.id, {
      status: 'created_dish',
      linkedDishId: dish.id,
    });
    await refreshStore(set);
    return dish;
  },

  async createDishFromGenerated(generatedDish) {
    const dish = await createDishFromGenerated(generatedDish);
    await refreshStore(set);
    return dish;
  },

  async attachCaptureToDish(captureId, dishId) {
    const capture = get().captureItems.find((item) => item.id === captureId);
    if (!capture) {
      return;
    }

    await attachCapture(capture, dishId);
    await refreshStore(set);
  },

  async resolveReview(reviewItemId, resolution) {
    const reviewItem = get().reviewItems.find((item) => item.id === reviewItemId);
    if (!reviewItem) {
      return;
    }

    const capture = get().captureItems.find((item) => item.id === reviewItem.captureItemId);
    if (!capture) {
      await dbService.resolveReviewItem(reviewItemId);
      await refreshStore(set);
      return;
    }

    if (resolution === 'create_new') {
      const generated =
        capture.type === 'idea'
          ? await aiService.generateDishFromIdea({ text: capture.text ?? 'New Dish' })
          : await aiService.generateDishFromPhoto({ capture });
      const dish = await createDishFromGenerated(generated);
      if (capture.uri) {
        await dbService.addSourcePhoto(dish.id, { uri: capture.uri, aiMatched: false, confidence: reviewItem.confidence });
        await dbService.updateDish(dish.id, {
          madeCount: 1,
          lastMadeAt: formatISO(new Date()),
        });
      }
      await dbService.updateCaptureItem(capture.id, {
        status: 'created_dish',
        linkedDishId: dish.id,
      });
    } else {
      await attachCapture(capture, resolution);
    }

    await dbService.resolveReviewItem(reviewItemId);
    await refreshStore(set);
  },

  async deleteCapture(captureId, reviewItemId) {
    await dbService.updateCaptureItem(captureId, { status: 'deleted' });
    if (reviewItemId) {
      await dbService.resolveReviewItem(reviewItemId);
    }
    await refreshStore(set);
  },

  async planDish(dishId, date, label) {
    await dbService.planMeal(dishId, date, label);
    await refreshStore(set);
  },

  async improveCover(dishId, prompt) {
    const dish = get().dishes.find((item) => item.id === dishId);
    if (!dish) {
      return;
    }

    const sourcePhotos = get().sourcePhotos.filter((item) => item.dishId === dishId);
    const result = await aiService.improveDishCover({ dish, sourcePhotos, prompt });
    await dbService.updateDish(dishId, { heroImageUri: result.heroImageUri });
    await refreshStore(set);
  },

  async addNote(dishId, text) {
    await dbService.addNote(dishId, text);
    await refreshStore(set);
  },

  async toggleFavorite(dishId) {
    const dish = get().dishes.find((item) => item.id === dishId);
    if (!dish) {
      return;
    }

    await dbService.updateDish(dishId, { favorite: !dish.favorite });
    await refreshStore(set);
  },
}));
