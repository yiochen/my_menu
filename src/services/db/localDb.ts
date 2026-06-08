import AsyncStorage from '@react-native-async-storage/async-storage';
import { formatISO } from 'date-fns';

import { SAMPLE_DISHES } from '@/data/sampleData';
import type {
  CaptureItem,
  Dish,
  DishNote,
  ID,
  Ingredient,
  PlannedMeal,
  RecipeStep,
  ReviewItem,
  SourcePhoto,
} from '@/types/models';
import { createId } from '@/utils/id';

import type { AddSourcePhotoInput, CreateDishInput, DatabaseService } from './types';

export const STORAGE_KEY = 'mymenu.localdb.v1';

export type LocalDbState = {
  dishes: Dish[];
  ingredients: Ingredient[];
  recipeSteps: RecipeStep[];
  notes: DishNote[];
  sourcePhotos: SourcePhoto[];
  captureItems: CaptureItem[];
  plannedMeals: PlannedMeal[];
  reviewItems: ReviewItem[];
  hasSeeded: boolean;
};

const emptyState: LocalDbState = {
  dishes: [],
  ingredients: [],
  recipeSteps: [],
  notes: [],
  sourcePhotos: [],
  captureItems: [],
  plannedMeals: [],
  reviewItems: [],
  hasSeeded: false,
};

async function readState() {
  const raw = await AsyncStorage.getItem(STORAGE_KEY);
  if (!raw) {
    return { ...emptyState };
  }

  return { ...emptyState, ...(JSON.parse(raw) as LocalDbState) };
}

async function writeState(state: LocalDbState) {
  await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function touchDish(dish: Dish): Dish {
  return { ...dish, updatedAt: formatISO(new Date()) };
}

async function withState<T>(updater: (state: LocalDbState) => T | Promise<T>) {
  const state = await readState();
  const result = await updater(state);
  await writeState(state);
  return result;
}

async function seedIfNeeded() {
  await withState(async (state) => {
    if (state.hasSeeded) {
      return;
    }

    for (const seed of SAMPLE_DISHES) {
      const now = formatISO(new Date());
      const dishId = createId('dish');
      const ingredientIds: ID[] = [];
      const recipeStepIds: ID[] = [];
      const noteIds: ID[] = [];
      const sourceIds: ID[] = [];

      for (const ingredient of seed.ingredients) {
        const id = createId('ingredient');
        ingredientIds.push(id);
        state.ingredients.push({ id, dishId, ...ingredient });
      }

      seed.recipeSteps.forEach((text, index) => {
        const id = createId('step');
        recipeStepIds.push(id);
        state.recipeSteps.push({ id, dishId, order: index + 1, text });
      });

      seed.notes.forEach((text) => {
        const id = createId('note');
        noteIds.push(id);
        state.notes.push({
          id,
          dishId,
          text,
          createdAt: now,
          updatedAt: now,
        });
      });

      seed.sourcePhotos.forEach((source) => {
        const id = createId('source');
        sourceIds.push(id);
        state.sourcePhotos.push({
          id,
          dishId,
          uri: source.uri,
          capturedAt: source.capturedAt ?? now,
          note: source.note,
          aiMatched: source.aiMatched,
          confidence: source.confidence,
        });
      });

      state.dishes.push({
        id: dishId,
        title: seed.title,
        description: seed.description,
        heroImageUri: seed.heroImageUri,
        category: seed.category,
        favorite: seed.title === 'Lemon Garlic Linguine' || seed.title === 'Miso Salmon Bowl',
        prepMinutes: seed.prepMinutes,
        difficulty: seed.difficulty,
        servings: seed.servings,
        madeCount: seed.madeCount,
        lastMadeAt: seed.lastMadeAt,
        ingredientIds,
        recipeStepIds,
        noteIds,
        sourceIds,
        createdAt: now,
        updatedAt: now,
      });
    }

    state.hasSeeded = true;
  });
}

async function createDish(input: CreateDishInput) {
  return withState(async (state) => {
    const now = formatISO(new Date());
    const dishId = createId('dish');
    const ingredientIds: ID[] = [];
    const recipeStepIds: ID[] = [];
    const noteIds: ID[] = [];
    const sourceIds: ID[] = [];

    for (const ingredient of input.ingredients ?? []) {
      const id = createId('ingredient');
      ingredientIds.push(id);
      state.ingredients.push({ id, dishId, ...ingredient });
    }

    (input.recipeSteps ?? []).forEach((text, index) => {
      const id = createId('step');
      recipeStepIds.push(id);
      state.recipeSteps.push({ id, dishId, order: index + 1, text });
    });

    (input.notes ?? []).forEach((text) => {
      const id = createId('note');
      noteIds.push(id);
      state.notes.push({
        id,
        dishId,
        text,
        createdAt: now,
        updatedAt: now,
      });
    });

    (input.sourcePhotos ?? []).forEach((source) => {
      const id = createId('source');
      sourceIds.push(id);
      state.sourcePhotos.push({
        id,
        dishId,
        uri: source.uri,
        capturedAt: source.capturedAt ?? now,
        note: source.note,
        aiMatched: source.aiMatched,
        confidence: source.confidence,
      });
    });

    const dish: Dish = {
      id: dishId,
      title: input.title,
      description: input.description,
      heroImageUri: input.heroImageUri,
      category: input.category,
      favorite: input.favorite ?? false,
      prepMinutes: input.prepMinutes,
      difficulty: input.difficulty,
      servings: input.servings,
      madeCount: input.madeCount ?? 0,
      lastMadeAt: input.lastMadeAt,
      ingredientIds,
      recipeStepIds,
      noteIds,
      sourceIds,
      createdAt: now,
      updatedAt: now,
    };

    state.dishes.unshift(dish);
    return dish;
  });
}

function updateDishRefs<T extends { id: ID; dishId: ID }>(
  collection: T[],
  nextItems: T[],
  existingIds: ID[],
) {
  for (const existingId of existingIds) {
    const index = collection.findIndex((item) => item.id === existingId);
    if (index >= 0) {
      collection.splice(index, 1);
    }
  }

  nextItems.forEach((item) => {
    collection.push(item);
  });

  return nextItems.map((item) => item.id);
}

export const localDb: DatabaseService & { initialize(): Promise<void> } = {
  async initialize() {
    await seedIfNeeded();
  },

  async getDishes() {
    const state = await readState();
    return [...state.dishes].sort((a, b) => b.updatedAt.localeCompare(a.updatedAt));
  },

  async getDish(id) {
    const state = await readState();
    return state.dishes.find((dish) => dish.id === id) ?? null;
  },

  async getNotes(dishId) {
    const state = await readState();
    return state.notes
      .filter((item) => item.dishId === dishId)
      .sort((a, b) => b.updatedAt.localeCompare(a.updatedAt));
  },

  async getCaptureItems() {
    const state = await readState();
    return [...state.captureItems].sort((a, b) => b.createdAt.localeCompare(a.createdAt));
  },

  async createDish(input) {
    return createDish(input);
  },

  async updateDish(id, patch) {
    return withState(async (state) => {
      const index = state.dishes.findIndex((dish) => dish.id === id);
      if (index < 0) {
        throw new Error(`Dish not found: ${id}`);
      }

      const updated = touchDish({ ...state.dishes[index], ...patch, id });
      state.dishes[index] = updated;
      return updated;
    });
  },

  async deleteDish(id) {
    await withState(async (state) => {
      state.dishes = state.dishes.filter((dish) => dish.id !== id);
      state.ingredients = state.ingredients.filter((item) => item.dishId !== id);
      state.recipeSteps = state.recipeSteps.filter((item) => item.dishId !== id);
      state.notes = state.notes.filter((item) => item.dishId !== id);
      state.sourcePhotos = state.sourcePhotos.filter((item) => item.dishId !== id);
      state.plannedMeals = state.plannedMeals.filter((item) => item.dishId !== id);
    });
  },

  async addSourcePhoto(dishId, input) {
    return withState(async (state) => {
      const dish = state.dishes.find((item) => item.id === dishId);
      if (!dish) {
        throw new Error(`Dish not found: ${dishId}`);
      }

      const source: SourcePhoto = {
        id: createId('source'),
        dishId,
        uri: input.uri,
        capturedAt: input.capturedAt ?? formatISO(new Date()),
        note: input.note,
        aiMatched: input.aiMatched,
        confidence: input.confidence,
      };
      state.sourcePhotos.unshift(source);
      dish.sourceIds = [source.id, ...dish.sourceIds];
      dish.updatedAt = formatISO(new Date());
      return source;
    });
  },

  async getSourcePhotos(dishId) {
    const state = await readState();
    return state.sourcePhotos
      .filter((item) => item.dishId === dishId)
      .sort((a, b) => b.capturedAt.localeCompare(a.capturedAt));
  },

  async addNote(dishId, text) {
    return withState(async (state) => {
      const dish = state.dishes.find((item) => item.id === dishId);
      if (!dish) {
        throw new Error(`Dish not found: ${dishId}`);
      }

      const now = formatISO(new Date());
      const note: DishNote = {
        id: createId('note'),
        dishId,
        text,
        createdAt: now,
        updatedAt: now,
      };

      state.notes.unshift(note);
      dish.noteIds = [note.id, ...dish.noteIds];
      dish.updatedAt = now;
      return note;
    });
  },

  async updateNote(noteId, text) {
    return withState(async (state) => {
      const note = state.notes.find((item) => item.id === noteId);
      if (!note) {
        throw new Error(`Note not found: ${noteId}`);
      }

      note.text = text;
      note.updatedAt = formatISO(new Date());
      return note;
    });
  },

  async deleteNote(noteId) {
    await withState(async (state) => {
      const note = state.notes.find((item) => item.id === noteId);
      if (!note) {
        return;
      }

      state.notes = state.notes.filter((item) => item.id !== noteId);
      const dish = state.dishes.find((item) => item.id === note.dishId);
      if (dish) {
        dish.noteIds = dish.noteIds.filter((id) => id !== noteId);
        dish.updatedAt = formatISO(new Date());
      }
    });
  },

  async getIngredients(dishId) {
    const state = await readState();
    return state.ingredients.filter((item) => item.dishId === dishId);
  },

  async setIngredients(dishId, ingredients) {
    await withState(async (state) => {
      const dish = state.dishes.find((item) => item.id === dishId);
      if (!dish) {
        throw new Error(`Dish not found: ${dishId}`);
      }

      const nextItems = ingredients.map((ingredient) => ({
        ...ingredient,
        id: ingredient.id || createId('ingredient'),
        dishId,
      }));
      dish.ingredientIds = updateDishRefs(state.ingredients, nextItems, dish.ingredientIds);
      dish.updatedAt = formatISO(new Date());
    });
  },

  async getRecipeSteps(dishId) {
    const state = await readState();
    return state.recipeSteps
      .filter((item) => item.dishId === dishId)
      .sort((a, b) => a.order - b.order);
  },

  async setRecipeSteps(dishId, steps) {
    await withState(async (state) => {
      const dish = state.dishes.find((item) => item.id === dishId);
      if (!dish) {
        throw new Error(`Dish not found: ${dishId}`);
      }

      const nextItems = steps.map((step, index) => ({
        ...step,
        id: step.id || createId('step'),
        dishId,
        order: index + 1,
      }));
      dish.recipeStepIds = updateDishRefs(state.recipeSteps, nextItems, dish.recipeStepIds);
      dish.updatedAt = formatISO(new Date());
    });
  },

  async getPlannedMeals(startDate, endDate) {
    const state = await readState();
    return state.plannedMeals.filter((item) => item.date >= startDate && item.date <= endDate);
  },

  async planMeal(dishId, date) {
    return withState(async (state) => {
      const existing = state.plannedMeals.find((item) => item.date === date && item.mealType === 'dinner');
      if (existing) {
        existing.dishId = dishId;
        return existing;
      }

      const meal: PlannedMeal = {
        id: createId('plan'),
        dishId,
        date,
        mealType: 'dinner',
        createdAt: formatISO(new Date()),
      };
      state.plannedMeals.push(meal);
      return meal;
    });
  },

  async removePlannedMeal(id) {
    await withState(async (state) => {
      state.plannedMeals = state.plannedMeals.filter((item) => item.id !== id);
    });
  },

  async createCaptureItem(input) {
    return withState(async (state) => {
      const capture: CaptureItem = {
        id: createId('capture'),
        type: input.type ?? 'photo',
        uri: input.uri,
        text: input.text,
        status: input.status ?? 'processing',
        suggestedDishIds: input.suggestedDishIds ?? [],
        confidence: input.confidence,
        linkedDishId: input.linkedDishId,
        createdAt: input.createdAt ?? formatISO(new Date()),
      };

      state.captureItems.unshift(capture);
      return capture;
    });
  },

  async updateCaptureItem(id, patch) {
    return withState(async (state) => {
      const index = state.captureItems.findIndex((item) => item.id === id);
      if (index < 0) {
        throw new Error(`Capture item not found: ${id}`);
      }

      state.captureItems[index] = {
        ...state.captureItems[index],
        ...patch,
        id,
      };

      return state.captureItems[index];
    });
  },

  async getReviewItems() {
    const state = await readState();
    return [...state.reviewItems].sort((a, b) => b.createdAt.localeCompare(a.createdAt));
  },

  async createReviewItem(input) {
    return withState(async (state) => {
      const review: ReviewItem = {
        id: createId('review'),
        captureItemId: input.captureItemId ?? '',
        uri: input.uri,
        text: input.text,
        suggestedDishIds: input.suggestedDishIds ?? [],
        confidence: input.confidence,
        createdAt: input.createdAt ?? formatISO(new Date()),
      };

      state.reviewItems.unshift(review);
      return review;
    });
  },

  async resolveReviewItem(id) {
    await withState(async (state) => {
      state.reviewItems = state.reviewItems.filter((item) => item.id !== id);
    });
  },
};
