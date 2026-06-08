import { router } from 'expo-router';
import { ScrollView, Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { FloatingActionButton } from '@/components/FloatingActionButton';
import { APP_COLORS, APP_RADIUS } from '@/theme';
import { useAppStore } from '@/store/useAppStore';
import { formatRelativeDate, getWeekRange, toDateKey } from '@/utils/date';

export default function PlanScreen() {
  const dishes = useAppStore((state) => state.dishes);
  const plannedMeals = useAppStore((state) => state.plannedMeals);
  const reviewItems = useAppStore((state) => state.reviewItems);
  const { days, label } = getWeekRange();

  const plannedByDate = new Map(plannedMeals.map((meal) => [meal.date, meal]));
  const recommendedDish = [...dishes]
    .sort((a, b) => (a.lastMadeAt ?? '').localeCompare(b.lastMadeAt ?? ''))
    .find((dish) => !plannedMeals.some((meal) => meal.dishId === dish.id)) ?? dishes[0];

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.header}>
          <View>
            <Text style={styles.eyebrow}>Plan</Text>
            <Text style={styles.title}>This Week</Text>
            <Text style={styles.subtitle}>{label}</Text>
          </View>
          <Pressable style={styles.iconButton} onPress={() => router.push('/modals/review')}>
            <Text style={styles.iconText}>◎</Text>
          </Pressable>
        </View>

        <View style={styles.sectionCard}>
          {days.map((day) => {
            const dateKey = toDateKey(day);
            const meal = plannedByDate.get(dateKey);
            const dish = meal ? dishes.find((item) => item.id === meal.dishId) : undefined;

            return (
              <Pressable
                key={dateKey}
                onPress={() =>
                  dish
                    ? router.push({ pathname: '/dish/[id]', params: { id: dish.id } })
                    : router.push({ pathname: '/modals/plan-dish', params: { date: dateKey } })
                }
                style={styles.dayRow}>
                <View style={styles.dayBadge}>
                  <Text style={styles.dayLabel}>{day.toLocaleDateString('en-US', { weekday: 'short' }).toUpperCase()}</Text>
                  <Text style={styles.dayNumber}>{day.getDate()}</Text>
                </View>
                <View style={styles.dayContent}>
                  <Text style={styles.dayTitle}>{dish?.title ?? '+ Add dinner'}</Text>
                  <Text style={styles.dayMeta}>
                    {dish ? `${dish.prepMinutes ?? 0} min` : 'Build your week one dinner at a time'}
                  </Text>
                </View>
              </Pressable>
            );
          })}
        </View>

        {recommendedDish ? (
          <Pressable
            style={styles.recommendationCard}
            onPress={() => router.push({ pathname: '/dish/[id]', params: { id: recommendedDish.id } })}>
            <Text style={styles.cardLabel}>Cook Tonight?</Text>
            <Text style={styles.recommendationTitle}>{recommendedDish.title}</Text>
            <Text style={styles.recommendationMeta}>
              {recommendedDish.prepMinutes ?? 0} min · Last made {formatRelativeDate(recommendedDish.lastMadeAt)}
            </Text>
          </Pressable>
        ) : null}

        {reviewItems.length > 0 ? (
          <Pressable style={styles.reviewCard} onPress={() => router.push('/modals/review')}>
            <Text style={styles.reviewCount}>{reviewItems.length} items need your review</Text>
            <Text style={styles.reviewHint}>Tap to confirm uncertain AI matches</Text>
          </Pressable>
        ) : null}
      </ScrollView>
      <FloatingActionButton />
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
    paddingBottom: 140,
    gap: 18,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },
  eyebrow: {
    color: APP_COLORS.gold,
    fontSize: 12,
    fontWeight: '700',
    letterSpacing: 1.1,
    textTransform: 'uppercase',
  },
  title: {
    color: APP_COLORS.text,
    fontSize: 32,
    fontWeight: '700',
    fontFamily: 'Georgia',
  },
  subtitle: {
    color: APP_COLORS.textMuted,
    fontSize: 14,
    marginTop: 6,
  },
  iconButton: {
    width: 40,
    height: 40,
    borderRadius: APP_RADIUS.pill,
    backgroundColor: APP_COLORS.card,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: APP_COLORS.border,
  },
  iconText: {
    color: APP_COLORS.green,
    fontSize: 18,
  },
  sectionCard: {
    backgroundColor: APP_COLORS.card,
    borderRadius: APP_RADIUS.lg,
    padding: 12,
    borderWidth: 1,
    borderColor: APP_COLORS.border,
    gap: 10,
  },
  dayRow: {
    flexDirection: 'row',
    gap: 12,
    padding: 10,
    borderRadius: APP_RADIUS.md,
    backgroundColor: APP_COLORS.white,
  },
  dayBadge: {
    width: 46,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 2,
  },
  dayLabel: {
    fontSize: 10,
    color: APP_COLORS.textMuted,
    fontWeight: '700',
  },
  dayNumber: {
    fontSize: 17,
    color: APP_COLORS.green,
    fontWeight: '700',
  },
  dayContent: {
    flex: 1,
    justifyContent: 'center',
    gap: 4,
  },
  dayTitle: {
    fontSize: 16,
    color: APP_COLORS.text,
    fontWeight: '700',
  },
  dayMeta: {
    color: APP_COLORS.textMuted,
    fontSize: 13,
  },
  recommendationCard: {
    backgroundColor: APP_COLORS.green,
    borderRadius: APP_RADIUS.lg,
    padding: 18,
    gap: 6,
  },
  cardLabel: {
    color: APP_COLORS.goldSoft,
    fontSize: 12,
    fontWeight: '700',
    textTransform: 'uppercase',
    letterSpacing: 1,
  },
  recommendationTitle: {
    color: APP_COLORS.white,
    fontSize: 22,
    fontWeight: '700',
    fontFamily: 'Georgia',
  },
  recommendationMeta: {
    color: '#E7E4D8',
    fontSize: 13,
  },
  reviewCard: {
    backgroundColor: APP_COLORS.goldSoft,
    borderRadius: APP_RADIUS.md,
    padding: 18,
    gap: 5,
  },
  reviewCount: {
    color: APP_COLORS.text,
    fontSize: 17,
    fontWeight: '700',
  },
  reviewHint: {
    color: APP_COLORS.textMuted,
    fontSize: 13,
  },
});
