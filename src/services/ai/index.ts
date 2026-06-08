import { mockAiService } from './mockAi';
import { openAiClient } from './openAiClient';
import type { AiService } from './types';

const apiKey = process.env.EXPO_PUBLIC_OPENAI_API_KEY;

export const aiService: AiService = apiKey ? openAiClient : mockAiService;

export type * from './types';
