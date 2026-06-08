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

export type CreateDishInput = {
  title: string;
  description?: string;
  heroImageUri?: string;
  category?: Dish['category'];
  favorite?: boolean;
  prepMinutes?: number;
  difficulty?: Dish['difficulty'];
  servings?: number;
  madeCount?: number;
  lastMadeAt?: string;
  ingredients?: Array<{
    name: string;
    quantity?: string;
    unit?: string;
    optional?: boolean;
  }>;
  recipeSteps?: string[];
  notes?: string[];
  sourcePhotos?: Array<{
    uri: string;
    capturedAt?: string;
    note?: string;
    aiMatched?: boolean;
    confidence?: number;
  }>;
};

export type AddSourcePhotoInput = {
  uri: string;
  capturedAt?: string;
  note?: string;
  aiMatched?: boolean;
  confidence?: number;
};

export interface DatabaseService {
  getDishes(): Promise<Dish[]>;
  getDish(id: ID): Promise<Dish | null>;
  getNotes(dishId: ID): Promise<DishNote[]>;
  getCaptureItems(): Promise<CaptureItem[]>;
  createDish(input: CreateDishInput): Promise<Dish>;
  updateDish(id: ID, patch: Partial<Dish>): Promise<Dish>;
  deleteDish(id: ID): Promise<void>;
  addSourcePhoto(dishId: ID, input: AddSourcePhotoInput): Promise<SourcePhoto>;
  getSourcePhotos(dishId: ID): Promise<SourcePhoto[]>;
  addNote(dishId: ID, text: string): Promise<DishNote>;
  updateNote(noteId: ID, text: string): Promise<DishNote>;
  deleteNote(noteId: ID): Promise<void>;
  getIngredients(dishId: ID): Promise<Ingredient[]>;
  setIngredients(dishId: ID, ingredients: Ingredient[]): Promise<void>;
  getRecipeSteps(dishId: ID): Promise<RecipeStep[]>;
  setRecipeSteps(dishId: ID, steps: RecipeStep[]): Promise<void>;
  getPlannedMeals(startDate: string, endDate: string): Promise<PlannedMeal[]>;
  planMeal(dishId: ID, date: string): Promise<PlannedMeal>;
  removePlannedMeal(id: ID): Promise<void>;
  createCaptureItem(input: Partial<CaptureItem>): Promise<CaptureItem>;
  updateCaptureItem(id: ID, patch: Partial<CaptureItem>): Promise<CaptureItem>;
  getReviewItems(): Promise<ReviewItem[]>;
  createReviewItem(input: Partial<ReviewItem>): Promise<ReviewItem>;
  resolveReviewItem(id: ID): Promise<void>;
}
