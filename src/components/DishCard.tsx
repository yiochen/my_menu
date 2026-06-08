import { Image } from 'expo-image';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import type { Dish } from '@/types/models';
import { formatRelativeDate } from '@/utils/date';
import { APP_COLORS, APP_RADIUS } from '@/theme';

type DishCardProps = {
  dish: Dish;
  onPress: () => void;
  onToggleFavorite?: () => void;
  compact?: boolean;
};

export function DishCard({ dish, onPress, onToggleFavorite, compact = false }: DishCardProps) {
  return (
    <Pressable onPress={onPress} style={[styles.card, compact && styles.cardCompact]}>
      <Image source={dish.heroImageUri} style={[styles.image, compact && styles.imageCompact]} contentFit="cover" />
      <Pressable onPress={onToggleFavorite} hitSlop={10} style={styles.favorite}>
        <Text style={styles.favoriteText}>{dish.favorite ? '♥' : '♡'}</Text>
      </Pressable>
      <View style={styles.content}>
        <Text numberOfLines={2} style={styles.title}>
          {dish.title}
        </Text>
        <Text style={styles.meta}>
          {dish.madeCount} made · {dish.lastMadeAt ? formatRelativeDate(dish.lastMadeAt) : 'New'}
        </Text>
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    width: 170,
    backgroundColor: APP_COLORS.card,
    borderRadius: APP_RADIUS.md,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: APP_COLORS.border,
  },
  cardCompact: {
    width: 146,
  },
  image: {
    width: '100%',
    height: 120,
  },
  imageCompact: {
    height: 98,
  },
  content: {
    padding: 12,
    gap: 4,
  },
  title: {
    color: APP_COLORS.text,
    fontSize: 15,
    fontWeight: '700',
  },
  meta: {
    color: APP_COLORS.textMuted,
    fontSize: 12,
  },
  favorite: {
    position: 'absolute',
    right: 10,
    top: 10,
    width: 28,
    height: 28,
    borderRadius: APP_RADIUS.pill,
    backgroundColor: 'rgba(255,255,255,0.88)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  favoriteText: {
    color: APP_COLORS.gold,
    fontSize: 15,
  },
});
