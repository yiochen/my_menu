import { Image } from 'expo-image';
import { router, useLocalSearchParams } from 'expo-router';
import { useMemo, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { APP_COLORS, APP_RADIUS } from '@/theme';
import { useAppStore } from '@/store/useAppStore';
import { formatDateShort, formatRelativeDate, toDateKey } from '@/utils/date';

const tabs = ['Recipe', 'Ingredients', 'Notes', 'Sources'] as const;

export default function DishDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const [selectedTab, setSelectedTab] = useState<(typeof tabs)[number]>('Recipe');
  const [noteDraft, setNoteDraft] = useState('');

  const dishes = useAppStore((state) => state.dishes);
  const ingredients = useAppStore((state) => state.ingredients);
  const recipeSteps = useAppStore((state) => state.recipeSteps);
  const notes = useAppStore((state) => state.notes);
  const sourcePhotos = useAppStore((state) => state.sourcePhotos);
  const addNote = useAppStore((state) => state.addNote);

  const dish = dishes.find((item) => item.id === id);
  const dishIngredients = useMemo(
    () => ingredients.filter((item) => item.dishId === id),
    [id, ingredients],
  );
  const dishSteps = useMemo(
    () => recipeSteps.filter((item) => item.dishId === id).sort((a, b) => a.order - b.order),
    [id, recipeSteps],
  );
  const dishNotes = useMemo(
    () => notes.filter((item) => item.dishId === id).sort((a, b) => b.updatedAt.localeCompare(a.updatedAt)),
    [id, notes],
  );
  const dishSources = useMemo(
    () => sourcePhotos.filter((item) => item.dishId === id).sort((a, b) => b.capturedAt.localeCompare(a.capturedAt)),
    [id, sourcePhotos],
  );

  if (!dish) {
    return (
      <SafeAreaView style={styles.safeArea}>
        <View style={styles.missingWrap}>
          <Text style={styles.missingText}>Dish not found.</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.heroWrap}>
          <Image source={dish.heroImageUri} style={styles.hero} contentFit="cover" />
          <View style={styles.heroOverlay}>
            <Pressable onPress={() => router.back()} style={styles.heroButton}>
              <Text style={styles.heroButtonText}>‹</Text>
            </Pressable>
            <Pressable
              onPress={() => router.push({ pathname: '/modals/improve-cover', params: { dishId: dish.id } })}
              style={styles.improveButton}>
              <Text style={styles.improveText}>✨ Improve Cover</Text>
            </Pressable>
          </View>
        </View>

        <View style={styles.card}>
          <Text style={styles.title}>{dish.title}</Text>
          <Text style={styles.description}>{dish.description}</Text>

          <View style={styles.statsGrid}>
            <View style={styles.statItem}>
              <Text style={styles.statValue}>{dish.madeCount}</Text>
              <Text style={styles.statLabel}>Made</Text>
            </View>
            <View style={styles.statItem}>
              <Text style={styles.statValue}>{formatRelativeDate(dish.lastMadeAt)}</Text>
              <Text style={styles.statLabel}>Last made</Text>
            </View>
            <View style={styles.statItem}>
              <Text style={styles.statValue}>{dish.prepMinutes ?? 0} min</Text>
              <Text style={styles.statLabel}>Time</Text>
            </View>
            <View style={styles.statItem}>
              <Text style={styles.statValue}>{dish.difficulty ?? 'Easy'}</Text>
              <Text style={styles.statLabel}>Difficulty</Text>
            </View>
            <View style={styles.statItem}>
              <Text style={styles.statValue}>{dish.servings ?? 2}</Text>
              <Text style={styles.statLabel}>Servings</Text>
            </View>
          </View>

          <View style={styles.tabsRow}>
            {tabs.map((tab) => (
              <Pressable
                key={tab}
                onPress={() => setSelectedTab(tab)}
                style={[styles.tab, selectedTab === tab && styles.tabActive]}>
                <Text style={[styles.tabText, selectedTab === tab && styles.tabTextActive]}>{tab}</Text>
              </Pressable>
            ))}
          </View>

          {selectedTab === 'Recipe' ? (
            <View style={styles.sectionList}>
              {dishSteps.map((step) => (
                <View key={step.id} style={styles.listRow}>
                  <Text style={styles.stepNumber}>{step.order}</Text>
                  <Text style={styles.listText}>{step.text}</Text>
                </View>
              ))}
            </View>
          ) : null}

          {selectedTab === 'Ingredients' ? (
            <View style={styles.sectionList}>
              {dishIngredients.map((ingredient) => (
                <View key={ingredient.id} style={styles.listRow}>
                  <Text style={styles.bullet}>•</Text>
                  <Text style={styles.listText}>
                    {[ingredient.quantity, ingredient.unit, ingredient.name].filter(Boolean).join(' ')}
                    {ingredient.optional ? ' (optional)' : ''}
                  </Text>
                </View>
              ))}
            </View>
          ) : null}

          {selectedTab === 'Notes' ? (
            <View style={styles.sectionList}>
              <View style={styles.noteComposer}>
                <TextInput
                  value={noteDraft}
                  onChangeText={setNoteDraft}
                  placeholder="Add a note for next time"
                  placeholderTextColor={APP_COLORS.textMuted}
                  style={styles.noteInput}
                />
                <Pressable
                  onPress={async () => {
                    if (!noteDraft.trim()) {
                      return;
                    }
                    await addNote(dish.id, noteDraft.trim());
                    setNoteDraft('');
                  }}
                  style={styles.noteButton}>
                  <Text style={styles.noteButtonText}>Add</Text>
                </Pressable>
              </View>
              {dishNotes.map((note) => (
                <View key={note.id} style={styles.noteCard}>
                  <Text style={styles.listText}>{note.text}</Text>
                  <Text style={styles.noteDate}>{formatDateShort(note.updatedAt)}</Text>
                </View>
              ))}
            </View>
          ) : null}

          {selectedTab === 'Sources' ? (
            <View style={styles.sectionList}>
              {dishSources.map((source) => (
                <View key={source.id} style={styles.sourceCard}>
                  <Image source={source.uri} style={styles.sourceImage} contentFit="cover" />
                  <View style={styles.sourceBody}>
                    <Text style={styles.sourceDate}>{formatDateShort(source.capturedAt)}</Text>
                    <Text style={styles.listText}>{source.note ?? 'Saved to your dish history.'}</Text>
                    <Text style={styles.sourceMeta}>
                      {source.aiMatched ? 'Matched automatically' : 'Added manually'}
                      {typeof source.confidence === 'number' ? ` · ${Math.round(source.confidence * 100)}% confidence` : ''}
                    </Text>
                  </View>
                </View>
              ))}
            </View>
          ) : null}
        </View>
      </ScrollView>

      <View style={styles.footer}>
        <Pressable
          onPress={() =>
            router.push({ pathname: '/modals/plan-dish', params: { dishId: dish.id, date: toDateKey(new Date()) } })
          }
          style={styles.primaryButton}>
          <Text style={styles.primaryButtonText}>Cook Again</Text>
        </Pressable>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: APP_COLORS.cream,
  },
  content: {
    paddingBottom: 120,
  },
  heroWrap: {
    position: 'relative',
  },
  hero: {
    width: '100%',
    height: 300,
    backgroundColor: APP_COLORS.greenSoft,
  },
  heroOverlay: {
    position: 'absolute',
    top: 16,
    left: 16,
    right: 16,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },
  heroButton: {
    width: 38,
    height: 38,
    borderRadius: APP_RADIUS.pill,
    backgroundColor: 'rgba(255,255,255,0.88)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  heroButtonText: {
    color: APP_COLORS.text,
    fontSize: 26,
    lineHeight: 28,
  },
  improveButton: {
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: APP_RADIUS.pill,
    backgroundColor: 'rgba(255,249,240,0.95)',
  },
  improveText: {
    color: APP_COLORS.green,
    fontWeight: '700',
    fontSize: 13,
  },
  card: {
    marginTop: -24,
    marginHorizontal: 16,
    backgroundColor: APP_COLORS.card,
    borderRadius: APP_RADIUS.lg,
    padding: 18,
    borderWidth: 1,
    borderColor: APP_COLORS.border,
    gap: 16,
  },
  title: {
    fontSize: 31,
    color: APP_COLORS.text,
    fontFamily: 'Georgia',
    fontWeight: '700',
  },
  description: {
    color: APP_COLORS.textMuted,
    fontSize: 15,
    lineHeight: 21,
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
  },
  statItem: {
    minWidth: 90,
    backgroundColor: APP_COLORS.white,
    borderRadius: APP_RADIUS.md,
    padding: 12,
  },
  statValue: {
    color: APP_COLORS.green,
    fontSize: 15,
    fontWeight: '700',
  },
  statLabel: {
    color: APP_COLORS.textMuted,
    fontSize: 12,
    marginTop: 4,
  },
  tabsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  tab: {
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: APP_RADIUS.pill,
    backgroundColor: APP_COLORS.white,
  },
  tabActive: {
    backgroundColor: APP_COLORS.green,
  },
  tabText: {
    color: APP_COLORS.text,
    fontWeight: '600',
  },
  tabTextActive: {
    color: APP_COLORS.white,
  },
  sectionList: {
    gap: 12,
  },
  listRow: {
    flexDirection: 'row',
    gap: 12,
    alignItems: 'flex-start',
  },
  stepNumber: {
    width: 24,
    height: 24,
    borderRadius: APP_RADIUS.pill,
    backgroundColor: APP_COLORS.greenSoft,
    color: APP_COLORS.green,
    textAlign: 'center',
    lineHeight: 24,
    fontWeight: '700',
  },
  bullet: {
    color: APP_COLORS.gold,
    fontSize: 18,
    lineHeight: 20,
  },
  listText: {
    flex: 1,
    color: APP_COLORS.text,
    fontSize: 15,
    lineHeight: 21,
  },
  noteComposer: {
    flexDirection: 'row',
    gap: 10,
  },
  noteInput: {
    flex: 1,
    backgroundColor: APP_COLORS.white,
    borderRadius: APP_RADIUS.md,
    borderWidth: 1,
    borderColor: APP_COLORS.border,
    paddingHorizontal: 14,
    paddingVertical: 12,
    color: APP_COLORS.text,
  },
  noteButton: {
    paddingHorizontal: 16,
    borderRadius: APP_RADIUS.md,
    backgroundColor: APP_COLORS.green,
    justifyContent: 'center',
  },
  noteButtonText: {
    color: APP_COLORS.white,
    fontWeight: '700',
  },
  noteCard: {
    backgroundColor: APP_COLORS.white,
    borderRadius: APP_RADIUS.md,
    padding: 14,
    gap: 8,
  },
  noteDate: {
    color: APP_COLORS.textMuted,
    fontSize: 12,
  },
  sourceCard: {
    flexDirection: 'row',
    gap: 12,
    backgroundColor: APP_COLORS.white,
    borderRadius: APP_RADIUS.md,
    padding: 10,
  },
  sourceImage: {
    width: 84,
    height: 84,
    borderRadius: APP_RADIUS.md,
    backgroundColor: APP_COLORS.greenSoft,
  },
  sourceBody: {
    flex: 1,
    gap: 6,
  },
  sourceDate: {
    color: APP_COLORS.green,
    fontWeight: '700',
  },
  sourceMeta: {
    color: APP_COLORS.textMuted,
    fontSize: 12,
  },
  footer: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    padding: 16,
    backgroundColor: 'rgba(246,240,228,0.98)',
  },
  primaryButton: {
    backgroundColor: APP_COLORS.green,
    borderRadius: APP_RADIUS.md,
    paddingVertical: 16,
    alignItems: 'center',
  },
  primaryButtonText: {
    color: APP_COLORS.white,
    fontSize: 16,
    fontWeight: '700',
  },
  missingWrap: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  missingText: {
    color: APP_COLORS.textMuted,
    fontSize: 16,
  },
});
