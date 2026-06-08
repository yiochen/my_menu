# MyMenu

MyMenu is a mobile-first cooking app built with Expo and React Native.

The product idea is simple: capture what you cook, let the app organize it into dishes, and build a personal menu over time. The current MVP is fully client-side and uses local persistence plus mock AI behind service interfaces so we can swap in a real backend later.

## MVP Features

- Weekly planning with a simple `Plan` tab
- Personal dish library in the `Menu` tab
- Dish detail view with recipe, ingredients, notes, and source photo history
- Floating capture flow for:
  - taking a photo
  - importing photos
  - adding a dish idea as text
- Mock AI classification that:
  - attaches captures to an existing dish
  - creates a new dish
  - sends uncertain matches to a review queue
- Cover improvement flow using the AI service boundary
- AsyncStorage-backed local database with seeded sample data on first launch

## Tech Stack

- Expo SDK 56
- React Native
- TypeScript
- Expo Router
- Zustand
- AsyncStorage
- `expo-image-picker`
- `date-fns`

## Architecture

The app is intentionally structured so UI code does not talk directly to storage or AI implementations.

```txt
UI
↓
Zustand Store
↓
DatabaseService / AiService
```

Key files:

- [src/types/models.ts](src/types/models.ts)
- [src/store/useAppStore.ts](src/store/useAppStore.ts)
- [src/services/db/types.ts](src/services/db/types.ts)
- [src/services/db/localDb.ts](src/services/db/localDb.ts)
- [src/services/ai/types.ts](src/services/ai/types.ts)
- [src/services/ai/index.ts](src/services/ai/index.ts)
- [src/services/ai/mockAi.ts](src/services/ai/mockAi.ts)

## Project Structure

```txt
src/
  app/
    (tabs)/
      plan.tsx
      menu.tsx
    dish/
      [id].tsx
    modals/
      capture.tsx
      review.tsx
      improve-cover.tsx
      plan-dish.tsx
  components/
  data/
  services/
  store/
  theme/
  types/
  utils/
```

## Local Development

Install dependencies:

```bash
npm install
```

Start the Expo dev server:

```bash
npm run start
```

Useful shortcuts:

```bash
npm run ios
npm run android
npm run web
```

## Verification

Type-check the project:

```bash
npx tsc --noEmit
```

Export the web build:

```bash
npx expo export --platform web
```

## EAS Setup

This repo is already linked to an EAS project and includes a basic [eas.json](eas.json).

Available build profiles:

- `development`: internal dev client build
- `preview`: internal distribution build
- `production`: release build with auto-incremented versioning

Examples:

```bash
eas build --profile preview --platform ios
eas build --profile preview --platform android
```

## Notes

- The MVP is intentionally client-only.
- Auth, backend APIs, Supabase, and production AI are not implemented yet.
- `openAiClient.ts` is currently a stub and `mockAi.ts` is the active implementation unless an OpenAI API key-backed implementation is added later.
