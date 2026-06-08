import { Image } from 'expo-image';
import { router } from 'expo-router';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { APP_COLORS, APP_RADIUS } from '@/theme';
import { useAppStore } from '@/store/useAppStore';

export default function ReviewModal() {
  const reviewItems = useAppStore((state) => state.reviewItems);
  const dishes = useAppStore((state) => state.dishes);
  const resolveReview = useAppStore((state) => state.resolveReview);
  const deleteCapture = useAppStore((state) => state.deleteCapture);
  const captureItems = useAppStore((state) => state.captureItems);

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.header}>
        <View>
          <Text style={styles.title}>Review Queue</Text>
          <Text style={styles.subtitle}>Validate AI labeling only when needed.</Text>
        </View>
        <Pressable onPress={() => router.back()} style={styles.closeButton}>
          <Text style={styles.closeText}>✕</Text>
        </Pressable>
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        {reviewItems.length === 0 ? (
          <View style={styles.emptyState}>
            <Text style={styles.emptyTitle}>Nothing needs review.</Text>
            <Text style={styles.emptyText}>New captures will only appear here when the match is uncertain.</Text>
          </View>
        ) : null}

        {reviewItems.map((item) => {
          const capture = captureItems.find((captureItem) => captureItem.id === item.captureItemId);
          const suggested = dishes.filter((dish) => item.suggestedDishIds.includes(dish.id));
          const others = dishes.filter((dish) => !item.suggestedDishIds.includes(dish.id));

          return (
            <View key={item.id} style={styles.reviewCard}>
              {item.uri ? <Image source={item.uri} style={styles.reviewImage} contentFit="cover" /> : null}
              <Text style={styles.reviewQuestion}>Which dish is this?</Text>
              <Text style={styles.reviewConfidence}>
                Confidence {Math.round((item.confidence ?? 0) * 100)}%
              </Text>
              {item.text ? <Text style={styles.reviewText}>{item.text}</Text> : null}

              {suggested.map((dish) => (
                <Pressable
                  key={dish.id}
                  onPress={() => void resolveReview(item.id, dish.id)}
                  style={styles.optionButton}>
                  <Text style={styles.optionTitle}>{dish.title}</Text>
                  <Text style={styles.optionMeta}>Attach to this dish</Text>
                </Pressable>
              ))}

              {others.slice(0, 4).map((dish) => (
                <Pressable
                  key={dish.id}
                  onPress={() => void resolveReview(item.id, dish.id)}
                  style={styles.optionButtonSecondary}>
                  <Text style={styles.optionTitle}>{dish.title}</Text>
                </Pressable>
              ))}

              <Pressable onPress={() => void resolveReview(item.id, 'create_new')} style={styles.createButton}>
                <Text style={styles.createButtonText}>Create New Dish</Text>
              </Pressable>
              <Pressable
                onPress={() => capture && deleteCapture(capture.id, item.id)}
                style={styles.deleteButton}>
                <Text style={styles.deleteButtonText}>Delete Capture</Text>
              </Pressable>
            </View>
          );
        })}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: APP_COLORS.cream,
  },
  header: {
    paddingHorizontal: 20,
    paddingTop: 10,
    paddingBottom: 12,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },
  title: {
    fontSize: 28,
    color: APP_COLORS.text,
    fontFamily: 'Georgia',
    fontWeight: '700',
  },
  subtitle: {
    color: APP_COLORS.textMuted,
    marginTop: 6,
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
  content: {
    padding: 20,
    gap: 16,
  },
  emptyState: {
    backgroundColor: APP_COLORS.card,
    borderRadius: APP_RADIUS.lg,
    padding: 20,
    gap: 8,
  },
  emptyTitle: {
    color: APP_COLORS.text,
    fontSize: 18,
    fontWeight: '700',
  },
  emptyText: {
    color: APP_COLORS.textMuted,
  },
  reviewCard: {
    backgroundColor: APP_COLORS.card,
    borderRadius: APP_RADIUS.lg,
    padding: 16,
    gap: 10,
    borderWidth: 1,
    borderColor: APP_COLORS.border,
  },
  reviewImage: {
    width: '100%',
    height: 180,
    borderRadius: APP_RADIUS.md,
    backgroundColor: APP_COLORS.greenSoft,
  },
  reviewQuestion: {
    color: APP_COLORS.text,
    fontSize: 20,
    fontWeight: '700',
  },
  reviewConfidence: {
    color: APP_COLORS.textMuted,
    fontSize: 13,
  },
  reviewText: {
    color: APP_COLORS.text,
  },
  optionButton: {
    backgroundColor: APP_COLORS.white,
    borderRadius: APP_RADIUS.md,
    padding: 14,
  },
  optionButtonSecondary: {
    backgroundColor: '#F8F4EB',
    borderRadius: APP_RADIUS.md,
    padding: 14,
    borderWidth: 1,
    borderColor: APP_COLORS.border,
  },
  optionTitle: {
    color: APP_COLORS.text,
    fontWeight: '700',
  },
  optionMeta: {
    color: APP_COLORS.textMuted,
    fontSize: 12,
    marginTop: 4,
  },
  createButton: {
    backgroundColor: APP_COLORS.green,
    borderRadius: APP_RADIUS.md,
    paddingVertical: 14,
    alignItems: 'center',
  },
  createButtonText: {
    color: APP_COLORS.white,
    fontWeight: '700',
  },
  deleteButton: {
    alignItems: 'center',
    paddingVertical: 10,
  },
  deleteButtonText: {
    color: APP_COLORS.danger,
    fontWeight: '700',
  },
});
