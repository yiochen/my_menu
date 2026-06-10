export type ID = string;

export type DishCategory =
  | 'Mains'
  | 'Bowls'
  | 'Pasta'
  | 'Soups'
  | 'Desserts'
  | 'Other';

export type Dish = {
  id: ID;
  title: string;
  description?: string;
  heroImageUri?: string;
  category?: DishCategory;
  favorite?: boolean;
  prepMinutes?: number;
  difficulty?: 'Easy' | 'Medium' | 'Hard';
  servings?: number;
  madeCount: number;
  lastMadeAt?: string;
  ingredientIds: ID[];
  recipeStepIds: ID[];
  noteIds: ID[];
  sourceIds: ID[];
  createdAt: string;
  updatedAt: string;
};

export type Ingredient = {
  id: ID;
  dishId: ID;
  name: string;
  quantity?: string;
  unit?: string;
  optional?: boolean;
};

export type RecipeStep = {
  id: ID;
  dishId: ID;
  order: number;
  text: string;
};

export type DishNote = {
  id: ID;
  dishId: ID;
  text: string;
  createdAt: string;
  updatedAt: string;
};

export type SourcePhoto = {
  id: ID;
  dishId: ID;
  uri: string;
  capturedAt: string;
  note?: string;
  aiMatched?: boolean;
  confidence?: number;
};

export type CaptureItem = {
  id: ID;
  type: 'photo' | 'idea';
  uri?: string;
  text?: string;
  status: 'processing' | 'attached' | 'created_dish' | 'needs_review' | 'deleted';
  suggestedDishIds?: ID[];
  confidence?: number;
  linkedDishId?: ID;
  createdAt: string;
};

export type PlanningLabel = 'Breakfast' | 'Lunch' | 'Dinner';

export type PlannedMeal = {
  id: ID;
  dishId: ID;
  date: string;
  label?: PlanningLabel;
  createdAt: string;
};

export type ReviewItem = {
  id: ID;
  captureItemId: ID;
  uri?: string;
  text?: string;
  suggestedDishIds: ID[];
  confidence?: number;
  createdAt: string;
};
