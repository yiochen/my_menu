# MyMenu Product Vision

## Overview

MyMenu is a personal cooking memory system.

It helps home cooks capture dishes, organize them into a personal menu, improve dish presentation with AI, remember how they made each dish, and plan what to cook again.

The product is inspired by the idea of Google Photos for cooking:

- Capture first.
- Organize automatically.
- Revisit later.
- Improve over time.

MyMenu is not primarily a social media app, a generic recipe manager, or a meal-planning app. It is a living record of what someone can cook.

## Product Vision

Most people already take photos of food they cook, but those photos usually disappear into the camera roll.

MyMenu turns those scattered cooking moments into a structured, beautiful, useful personal menu.

A dish in MyMenu is not just a recipe. It is a living object that can contain:

- A beautiful AI-augmented cover image
- Real source photos from times the user made the dish
- Ingredients
- Cooking instructions
- Personal notes
- A cooking history
- Future planning information

The long-term goal is to help users build their own personal restaurant: a visual cookbook of dishes they have made, want to improve, and want to cook again.

## Core Product Loop

```txt
Capture dish or idea
↓
AI organizes it
↓
Dish is added or updated
↓
User improves cover image
↓
User adds notes and recipe details
↓
User plans to cook it again
↓
Next time they make it, they capture another source photo
↓
Dish becomes richer over time
```

## Core Concepts

### Dish

A Dish is the primary object in the app.

Examples:

- Lemon Garlic Linguine
- Pho
- Chicken Katsu Curry
- Miso Salmon Bowl

A dish contains the durable knowledge about something the user can cook.

A dish may include:

- Title
- Description
- Hero image / cover image
- Ingredients
- Recipe steps
- Notes
- Source photos
- Made count
- Last made date
- Planned meals

### Cover Image

The cover image is the best current visual representation of a dish.

It is usually AI-augmented.

The app should not expose permanent modes like:

- Original
- Restaurant Style
- Next Time

Instead, the user-facing model is:

- Cover Image
- Sources
- Improve Cover

The cover is aspirational and menu-worthy. It does not have to be an exact documentary image of one cooking session.

### Sources

Sources are the real captured or imported photos of the dish.

They represent the actual times the user made the dish.

Sources are important because they:

- Preserve the user's real cooking history
- Help the user see their progression
- Provide context for AI classification
- Provide context for future cover image generation
- Distinguish MyMenu from a generic AI image generator

A dish can have many source photos.

Example:

```txt
Pho
Made 12 times

Jun 2026 - source photo
Apr 2026 - source photo
Jan 2026 - source photo
```

### Notes

Notes are first-class.

Users often remember important cooking details that do not belong in a formal recipe.

Examples:

- Use more lemon next time.
- Kids liked this version.
- Do not overcook the shrimp.
- Use Costco parmesan.
- Try serving in a shallow bowl next time.

These notes become part of the dish's living history.

### Plan

The Plan screen answers: What am I cooking this week?

It is intentionally lightweight.

The MVP should support a simple weekly plan, not a full meal-planning system.

Avoid building too early:

- Grocery lists
- Pantry tracking
- Nutrition
- Family scheduling
- Complex calendar views

The goal is simply to help users choose dishes from their own menu and schedule them for later.

## App Structure

The app should stay simple.

Primary navigation:

- Plan
- Menu

A floating `+` button should be available globally for capture.

There should not be a permanent Capture tab.

There should not be a permanent Inbox tab.

## Main Screens

### Plan

Purpose: What am I cooking this week?

Includes:

- Current week
- Planned dishes by day
- Empty day actions
- Cook Tonight recommendation
- Contextual review card if AI needs user confirmation

### Menu

Purpose: What dishes do I have?

Includes:

- Dish library
- Search
- Filters
- Favorites
- Recently added dishes
- All dishes

### Dish Detail

Purpose: Everything about this dish.

Includes:

- Large cover image
- `✨ Improve Cover` action
- Dish title and description
- Made count
- Last made date
- Recipe
- Ingredients
- Notes
- Sources
- Cook Again action

### Capture Modal

Opened from the floating `+`.

Purpose: Capture anything quickly.

Options:

- Take Photo
- Import Photos
- Add Idea

Important: the user should not need to choose whether the capture belongs to a new dish or an existing dish before capturing.

The app should capture first, then organize.

### Review Queue

The review queue is not a main tab.

It appears only when needed.

For example:

```txt
2 items need review
```

The review queue exists for cases where AI is unsure whether a capture belongs to an existing dish or should become a new dish.

## Capture Philosophy

Capture should be extremely fast.

Users are often:

- Cooking
- Hungry
- Cleaning
- Hosting guests
- About to eat

The app should not slow them down.

Bad flow:

```txt
Find dish
Open dish
Tap add photo
Take photo
Confirm
```

Preferred flow:

```txt
Tap +
Take photo
Done
AI organizes it
```

The app should behave more like Google Photos than a manual filing system.

## AI Role

AI should help with:

- Classifying captures
- Deciding whether a capture belongs to an existing dish
- Creating new dish records
- Generating dish names and descriptions
- Drafting ingredients and recipe steps
- Improving cover images
- Suggesting next-time improvements

AI should not be framed as perfect or documentary-accurate.

Recipes should be treated as AI-assisted drafts that the user can review and edit.

Suggested disclaimer:

> AI-assisted recipe. Review ingredients and cooking safety before use.

## Offline-First Principle

The app should be offline-first.

Users should always be able to view and edit their local cooking knowledge.

The app should work offline for:

- Plan screen
- Menu screen
- Dish detail
- Recipes
- Ingredients
- Notes
- Source photos
- Weekly planned meals
- Review queue

Network is required only for cloud features such as:

- AI dish classification
- AI recipe generation
- AI cover generation
- Backup/sync
- Public sharing
- Multi-device support

Local SQLite should be the source of truth. Remote storage should sync with it.

## Backend Direction

The intended V1 backend direction is:

```txt
Local SQLite
↓
Sync queue
↓
Supabase
↓
AI Edge Functions
```

Supabase should eventually handle:

- Auth
- Postgres storage
- Row Level Security
- Source photo storage
- Dish cover storage
- Remote sync
- Public menu sharing
- AI service calls through Edge Functions

API keys should never live in the mobile app.

## Data Model Summary

Core entities:

- Dish
- Ingredient
- RecipeStep
- DishNote
- SourcePhoto
- CaptureItem
- PlannedMeal
- ReviewItem
- SyncOperation
- Profile

Important design choice:

Use locally generated UUIDs so the same IDs can be used locally and remotely.

This avoids complicated local ID to remote ID mapping later.

## Monetization Direction

MyMenu should not use ads.

Potential revenue sources:

### Pro Subscription

Possible Pro features:

- More AI cover improvements
- More AI recipe generation
- More dish storage
- Custom menu themes
- Public menu customization
- Advanced export options

### AI Credits

Alternative or additional model:

- Cover improvement costs credits
- Recipe enrichment costs credits
- Bulk import / bulk AI processing costs credits

### Cookbook Export

Long-term premium feature:

Turn your personal menu into a cookbook.

This could become a one-time purchase or printed product.

## What MyMenu Is Not

MyMenu is not:

- Instagram for food
- A public social feed
- A generic recipe search app
- A grocery list app
- A nutrition tracker
- A restaurant discovery app
- A full meal-planning suite

Those features may be tempting, but they are not the core.

The core is:

- Capture what you cook.
- Remember how you made it.
- Make it look inspiring.
- Cook it again.

## Product Priorities

### MVP

- Local-only app
- Dish library
- Plan screen
- Capture modal
- Notes
- Sources
- Mock AI
- Local persistence

### V1

- Offline-first SQLite
- Supabase backend
- Auth
- Remote sync
- Source photo upload
- Real AI classification
- Real AI cover improvement
- Public menu sharing
- Basic usage metering
- Privacy/export/delete flows

### Later

- Recipe web search enrichment
- Cookbook export
- Subscriptions or AI credits
- Custom themes
- Advanced planning
- Family cookbook mode
- Printed cookbook product

## Core UX Principles

1. Capture should take less than 10 seconds.
2. Users should not organize manually unless AI is uncertain.
3. The dish is the core object.
4. The cover image is aspirational.
5. Source photos are the real history.
6. Notes are first-class.
7. The app should work offline.
8. The menu should become more valuable over time.
9. AI should amplify the user's cooking, not replace it.
10. Avoid adding generic recipe-app features too early.

## Positioning

One-sentence pitch:

MyMenu turns your home cooking into a beautiful personal menu that remembers what you made, how you made it, and what you should cook again.

Short taglines:

- Google Photos for cooking.
- Your personal restaurant.
- Capture what you cook. Cook it again.
- A living cookbook of your own food.
- Turn everyday cooking into a personal menu.
