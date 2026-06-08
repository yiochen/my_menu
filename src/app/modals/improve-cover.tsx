import { Image } from 'expo-image';
import { router, useLocalSearchParams } from 'expo-router';
import { useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { APP_COLORS, APP_RADIUS } from '@/theme';
import { useAppStore } from '@/store/useAppStore';

const chips = [
  'Stay close to original',
  'More restaurant style',
  'Brighter and more vibrant',
  'Use a ceramic bowl',
  'Cleaner table setting',
  'Smaller portion',
  'Add more garnish',
];

export default function ImproveCoverModal() {
  const { dishId } = useLocalSearchParams<{ dishId: string }>();
  const dishes = useAppStore((state) => state.dishes);
  const improveCover = useAppStore((state) => state.improveCover);
  const [prompt, setPrompt] = useState('Stay close to original');
  const [busy, setBusy] = useState(false);

  const dish = dishes.find((item) => item.id === dishId);
  if (!dish) {
    return null;
  }

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.header}>
          <View>
            <Text style={styles.title}>Improve Cover</Text>
            <Text style={styles.subtitle}>Use your source photos to create the best version of this dish.</Text>
          </View>
          <Pressable onPress={() => router.back()} style={styles.closeButton}>
            <Text style={styles.closeText}>✕</Text>
          </Pressable>
        </View>

        <Image source={dish.heroImageUri} style={styles.image} contentFit="cover" />

        <View style={styles.chips}>
          {chips.map((chip) => (
            <Pressable
              key={chip}
              onPress={() => setPrompt(chip)}
              style={[styles.chip, prompt === chip && styles.chipActive]}>
              <Text style={[styles.chipText, prompt === chip && styles.chipTextActive]}>{chip}</Text>
            </Pressable>
          ))}
        </View>

        <TextInput
          value={prompt}
          onChangeText={setPrompt}
          placeholder="Describe how you want it to look..."
          placeholderTextColor={APP_COLORS.textMuted}
          multiline
          style={styles.input}
        />

        <Pressable
          onPress={async () => {
            setBusy(true);
            try {
              await improveCover(dish.id, prompt);
              router.back();
            } finally {
              setBusy(false);
            }
          }}
          style={styles.primaryButton}>
          <Text style={styles.primaryButtonText}>{busy ? 'Regenerating...' : 'Regenerate Cover'}</Text>
        </Pressable>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: APP_COLORS.cream,
  },
  content: {
    padding: 20,
    gap: 16,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: 16,
  },
  title: {
    fontSize: 28,
    color: APP_COLORS.text,
    fontFamily: 'Georgia',
    fontWeight: '700',
  },
  subtitle: {
    color: APP_COLORS.textMuted,
    marginTop: 8,
    maxWidth: 280,
    lineHeight: 20,
  },
  closeButton: {
    width: 36,
    height: 36,
    borderRadius: APP_RADIUS.pill,
    backgroundColor: APP_COLORS.card,
    alignItems: 'center',
    justifyContent: 'center',
  },
  closeText: {
    color: APP_COLORS.text,
    fontWeight: '700',
  },
  image: {
    width: '100%',
    height: 240,
    borderRadius: APP_RADIUS.lg,
    backgroundColor: APP_COLORS.greenSoft,
  },
  chips: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  chip: {
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: APP_RADIUS.pill,
    backgroundColor: APP_COLORS.card,
    borderWidth: 1,
    borderColor: APP_COLORS.border,
  },
  chipActive: {
    backgroundColor: APP_COLORS.green,
    borderColor: APP_COLORS.green,
  },
  chipText: {
    color: APP_COLORS.text,
    fontSize: 13,
    fontWeight: '600',
  },
  chipTextActive: {
    color: APP_COLORS.white,
  },
  input: {
    minHeight: 120,
    backgroundColor: APP_COLORS.white,
    borderRadius: APP_RADIUS.md,
    borderWidth: 1,
    borderColor: APP_COLORS.border,
    paddingHorizontal: 14,
    paddingVertical: 14,
    color: APP_COLORS.text,
    textAlignVertical: 'top',
  },
  primaryButton: {
    backgroundColor: APP_COLORS.green,
    borderRadius: APP_RADIUS.md,
    paddingVertical: 16,
    alignItems: 'center',
  },
  primaryButtonText: {
    color: APP_COLORS.white,
    fontWeight: '700',
    fontSize: 15,
  },
});
