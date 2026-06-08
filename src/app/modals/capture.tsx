import * as ImagePicker from 'expo-image-picker';
import { router } from 'expo-router';
import { useState } from 'react';
import { Alert, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { APP_COLORS, APP_RADIUS } from '@/theme';
import { useAppStore } from '@/store/useAppStore';

export default function CaptureModal() {
  const capturePhoto = useAppStore((state) => state.capturePhoto);
  const importPhotos = useAppStore((state) => state.importPhotos);
  const addIdea = useAppStore((state) => state.addIdea);

  const [busy, setBusy] = useState(false);
  const [ideaText, setIdeaText] = useState('');
  const [summary, setSummary] = useState<string | null>(null);
  const [createdDishId, setCreatedDishId] = useState<string | null>(null);
  const [hasReviewItems, setHasReviewItems] = useState(false);

  async function onTakePhoto() {
    setBusy(true);
    try {
      const permission = await ImagePicker.requestCameraPermissionsAsync();
      if (!permission.granted) {
        Alert.alert('Camera access needed', 'Enable camera access to capture dishes.');
        return;
      }

      const result = await ImagePicker.launchCameraAsync({
        mediaTypes: ['images'],
        quality: 0.8,
      });

      if (result.canceled || !result.assets[0]?.uri) {
        return;
      }

      const next = await capturePhoto(result.assets[0].uri);
      setSummary(buildSummary(next));
      setCreatedDishId(next.createdDishIds[0] ?? next.attachedDishIds[0] ?? null);
      setHasReviewItems(next.reviewCount > 0);
    } finally {
      setBusy(false);
    }
  }

  async function onImportPhotos() {
    setBusy(true);
    try {
      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ['images'],
        quality: 0.8,
        allowsMultipleSelection: true,
        orderedSelection: true,
      });

      if (result.canceled) {
        return;
      }

      const next = await importPhotos(result.assets.map((asset) => asset.uri));
      setSummary(buildSummary(next));
      setCreatedDishId(next.createdDishIds[0] ?? next.attachedDishIds[0] ?? null);
      setHasReviewItems(next.reviewCount > 0);
    } finally {
      setBusy(false);
    }
  }

  async function onAddIdea() {
    if (!ideaText.trim()) {
      return;
    }

    setBusy(true);
    try {
      const dish = await addIdea(ideaText.trim());
      router.replace({ pathname: '/dish/[id]', params: { id: dish.id } });
    } finally {
      setBusy(false);
    }
  }

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>
        <View style={styles.header}>
          <View>
            <Text style={styles.title}>Capture Anything</Text>
            <Text style={styles.subtitle}>
              Quickly capture or import without choosing a dish. We&apos;ll organize it automatically.
            </Text>
          </View>
          <Pressable onPress={() => router.back()} style={styles.closeButton}>
            <Text style={styles.closeText}>✕</Text>
          </Pressable>
        </View>

        <View style={styles.actions}>
          <Pressable onPress={() => void onTakePhoto()} style={styles.actionCard} disabled={busy}>
            <Text style={styles.actionTitle}>Take Photo</Text>
            <Text style={styles.actionBody}>Capture a dish in the moment.</Text>
          </Pressable>
          <Pressable onPress={() => void onImportPhotos()} style={styles.actionCard} disabled={busy}>
            <Text style={styles.actionTitle}>Import Photos</Text>
            <Text style={styles.actionBody}>Choose from your gallery and let AI sort them.</Text>
          </Pressable>
        </View>

        <View style={styles.ideaCard}>
          <Text style={styles.actionTitle}>Add Idea</Text>
          <TextInput
            value={ideaText}
            onChangeText={setIdeaText}
            placeholder="Creamy mushroom pasta"
            placeholderTextColor={APP_COLORS.textMuted}
            style={styles.input}
          />
          <Pressable onPress={() => void onAddIdea()} style={styles.primaryButton} disabled={busy}>
            <Text style={styles.primaryButtonText}>{busy ? 'Working...' : 'Save Idea'}</Text>
          </Pressable>
        </View>

        {summary ? (
          <View style={styles.summaryCard}>
            <Text style={styles.summaryTitle}>Latest Result</Text>
            <Text style={styles.summaryText}>{summary}</Text>
            {createdDishId ? (
              <Pressable
                onPress={() => router.replace({ pathname: '/dish/[id]', params: { id: createdDishId } })}
                style={styles.secondaryButton}>
                <Text style={styles.secondaryButtonText}>Open Dish</Text>
              </Pressable>
            ) : null}
            {hasReviewItems ? (
              <Pressable onPress={() => router.push('/modals/review')} style={styles.secondaryButton}>
                <Text style={styles.secondaryButtonText}>Open Review Queue</Text>
              </Pressable>
            ) : null}
          </View>
        ) : null}
      </View>
    </SafeAreaView>
  );
}

function buildSummary(summary: { createdDishIds: string[]; attachedDishIds: string[]; reviewCount: number; processed: number }) {
  return `Processed ${summary.processed} item${summary.processed === 1 ? '' : 's'} · created ${summary.createdDishIds.length} dish${summary.createdDishIds.length === 1 ? '' : 'es'} · attached ${summary.attachedDishIds.length} photo${summary.attachedDishIds.length === 1 ? '' : 's'} · ${summary.reviewCount} need review`;
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: APP_COLORS.cream,
  },
  container: {
    flex: 1,
    padding: 20,
    gap: 18,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: 16,
  },
  title: {
    fontSize: 28,
    fontFamily: 'Georgia',
    fontWeight: '700',
    color: APP_COLORS.text,
  },
  subtitle: {
    marginTop: 8,
    color: APP_COLORS.textMuted,
    fontSize: 14,
    lineHeight: 20,
    maxWidth: 280,
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
  actions: {
    gap: 12,
  },
  actionCard: {
    backgroundColor: APP_COLORS.card,
    borderRadius: APP_RADIUS.lg,
    padding: 18,
    borderWidth: 1,
    borderColor: APP_COLORS.border,
    gap: 4,
  },
  actionTitle: {
    color: APP_COLORS.text,
    fontSize: 18,
    fontWeight: '700',
  },
  actionBody: {
    color: APP_COLORS.textMuted,
    fontSize: 14,
  },
  ideaCard: {
    backgroundColor: APP_COLORS.card,
    borderRadius: APP_RADIUS.lg,
    padding: 18,
    borderWidth: 1,
    borderColor: APP_COLORS.border,
    gap: 12,
  },
  input: {
    backgroundColor: APP_COLORS.white,
    borderRadius: APP_RADIUS.md,
    borderWidth: 1,
    borderColor: APP_COLORS.border,
    paddingHorizontal: 14,
    paddingVertical: 12,
    color: APP_COLORS.text,
  },
  primaryButton: {
    backgroundColor: APP_COLORS.green,
    borderRadius: APP_RADIUS.md,
    paddingVertical: 14,
    alignItems: 'center',
  },
  primaryButtonText: {
    color: APP_COLORS.white,
    fontWeight: '700',
    fontSize: 15,
  },
  summaryCard: {
    backgroundColor: APP_COLORS.goldSoft,
    borderRadius: APP_RADIUS.lg,
    padding: 18,
    gap: 10,
  },
  summaryTitle: {
    color: APP_COLORS.text,
    fontSize: 18,
    fontWeight: '700',
  },
  summaryText: {
    color: APP_COLORS.text,
    fontSize: 14,
    lineHeight: 20,
  },
  secondaryButton: {
    paddingVertical: 12,
  },
  secondaryButtonText: {
    color: APP_COLORS.green,
    fontWeight: '700',
  },
});
