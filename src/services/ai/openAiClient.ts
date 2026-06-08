import type { AiService } from './types';

export const openAiClient: AiService = {
  async classifyCapture() {
    throw new Error('OpenAI client is not configured for this MVP.');
  },
  async generateDishFromPhoto() {
    throw new Error('OpenAI client is not configured for this MVP.');
  },
  async generateDishFromIdea() {
    throw new Error('OpenAI client is not configured for this MVP.');
  },
  async improveDishCover() {
    throw new Error('OpenAI client is not configured for this MVP.');
  },
};
