import type { CaptureItem, Dish, DishCategory, ID, SourcePhoto } from '@/types/models';

export type ClassifyCaptureInput = {
  capture: CaptureItem;
  existingDishes: Dish[];
  sourcePhotosByDishId: Record<ID, SourcePhoto[]>;
};

export type GeneratedDish = {
  title: string;
  description: string;
  category?: DishCategory;
  prepMinutes?: number;
  difficulty?: 'Easy' | 'Medium' | 'Hard';
  servings?: number;
  ingredients: {
    name: string;
    quantity?: string;
    unit?: string;
    optional?: boolean;
  }[];
  recipeSteps: string[];
  notes?: string[];
  heroImageUri?: string;
};

export type ClassifyCaptureResult =
  | {
      action: 'attach_to_existing';
      dishId: ID;
      confidence: number;
    }
  | {
      action: 'create_new_dish';
      generatedDish: GeneratedDish;
      confidence: number;
    }
  | {
      action: 'needs_review';
      suggestedDishIds: ID[];
      confidence: number;
    };

export type GenerateDishFromPhotoInput = {
  capture: CaptureItem;
};

export type GenerateDishFromIdeaInput = {
  text: string;
};

export type ImproveDishCoverInput = {
  dish: Dish;
  sourcePhotos: SourcePhoto[];
  prompt: string;
};

export type ImproveDishCoverResult = {
  heroImageUri: string;
};

export interface AiService {
  classifyCapture(input: ClassifyCaptureInput): Promise<ClassifyCaptureResult>;
  generateDishFromPhoto(input: GenerateDishFromPhotoInput): Promise<GeneratedDish>;
  generateDishFromIdea(input: GenerateDishFromIdeaInput): Promise<GeneratedDish>;
  improveDishCover(input: ImproveDishCoverInput): Promise<ImproveDishCoverResult>;
}
