import { Image } from 'expo-image';
import { router } from 'expo-router';
import { SymbolView } from 'expo-symbols';
import { format } from 'date-fns';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';

import { FloatingActionButton } from '@/components/FloatingActionButton';
import { APP_COLORS, APP_RADIUS } from '@/theme';
import { useAppStore } from '@/store/useAppStore';
import type { PlannedMeal, PlanningLabel } from '@/types/models';
import { formatRelativeDate, getRemainingWeekRange, toDateKey } from '@/utils/date';

const planningLabelBackgrounds: Record<PlanningLabel, string> = {
  Breakfast: '#F7E8CA',
  Lunch: '#FAE9C9',
  Dinner: '#E3ECDD',
};

const planningLabelTextColors: Record<PlanningLabel, string> = {
  Breakfast: '#956009',
  Lunch: '#B67305',
  Dinner: '#2E5B39',
};

const planningLabelRank: Record<PlanningLabel, number> = {
  Breakfast: 0,
  Lunch: 1,
  Dinner: 2,
};

function getSortedMeals(meals: PlannedMeal[]) {
  return [...meals].sort((left, right) => {
    const leftLabel = left.label;
    const rightLabel = right.label;

    if (leftLabel && rightLabel && leftLabel !== rightLabel) {
      return planningLabelRank[leftLabel] - planningLabelRank[rightLabel];
    }

    if (leftLabel && !rightLabel) {
      return -1;
    }

    if (!leftLabel && rightLabel) {
      return 1;
    }

    return left.createdAt.localeCompare(right.createdAt);
  });
}

export default function PlanScreen() {
  const dishes = useAppStore((state) => state.dishes);
  const plannedMeals = useAppStore((state) => state.plannedMeals);
  const reviewItems = useAppStore((state) => state.reviewItems);
  const insets = useSafeAreaInsets();
  const today = new Date();
  const { days, label } = getRemainingWeekRange(today);
  const todayKey = toDateKey(today);

  const plannedByDate = plannedMeals.reduce(
    (map, meal) => {
      const current = map.get(meal.date) ?? [];
      current.push(meal);
      map.set(meal.date, current);
      return map;
    },
    new Map<string, PlannedMeal[]>(),
  );

  const plannedDishIds = new Set(plannedMeals.map((meal) => meal.dishId));
  const recommendedDish =
    [...dishes]
      .sort((a, b) => (a.lastMadeAt ?? '').localeCompare(b.lastMadeAt ?? ''))
      .find((dish) => !plannedDishIds.has(dish.id)) ?? dishes[0];
  const menuHighlights = dishes.slice(0, 4);

  return (
    <SafeAreaView edges={['top', 'left', 'right']} style={styles.safeArea}>
      <ScrollView contentContainerStyle={[styles.content, { paddingBottom: 180 + insets.bottom }]}>
        <View style={styles.header}>
          <View>
            <Text style={styles.title}>Plan</Text>
            <Text style={styles.subtitle}>{label}</Text>
          </View>
          <View style={styles.headerActions}>
            <Pressable
              style={styles.iconButton}
              onPress={() => router.push({ pathname: '/modals/plan-dish', params: { date: todayKey } })}>
              <SymbolView
                name={{ ios: 'calendar', android: 'calendar_month', web: 'calendar_month' }}
                size={22}
                weight="medium"
                tintColor={APP_COLORS.green}
              />
            </Pressable>
            <Pressable style={styles.iconButton} onPress={() => router.push('/modals/review')}>
              <SymbolView
                name={{ ios: 'slider.horizontal.3', android: 'tune', web: 'tune' }}
                size={22}
                weight="medium"
                tintColor={APP_COLORS.green}
              />
            </Pressable>
          </View>
        </View>

        {days.map((day) => {
          const dateKey = toDateKey(day);
          const meals = getSortedMeals(plannedByDate.get(dateKey) ?? []);
          const isToday = dateKey === todayKey;

          return (
            <View key={dateKey} style={styles.daySection}>
              <View style={styles.dayRail}>
                <Text style={[styles.dayName, isToday && styles.dayNameToday]}>{isToday ? 'TODAY' : format(day, 'EEE').toUpperCase()}</Text>
                <Text style={styles.dayNumber}>{format(day, 'd')}</Text>
                <Text style={styles.dayShort}>{format(day, 'EEE').toUpperCase()}</Text>
              </View>

              <View style={styles.dayCard}>
                {meals.map((meal, index) => {
                  const dish = dishes.find((item) => item.id === meal.dishId);
                  if (!dish) {
                    return null;
                  }

                  return (
                    <Pressable
                      key={meal.id}
                      onPress={() => router.push({ pathname: '/dish/[id]', params: { id: dish.id } })}
                      style={[styles.mealRow, index < meals.length - 1 && styles.mealRowBorder]}>
                      <Image source={dish.heroImageUri} style={styles.mealImage} contentFit="cover" />
                      <View style={styles.mealBody}>
                        <View style={styles.mealTopLine}>
                          <Text numberOfLines={1} style={styles.mealTitle}>
                            {dish.title}
                          </Text>
                          <Text style={styles.mealMore}>•••</Text>
                        </View>
                        <View style={styles.mealMetaRow}>
                          <Text style={styles.mealMeta}>{dish.prepMinutes ?? 0} min</Text>
                          <Text style={styles.mealMetaBullet}>•</Text>
                          <Text style={styles.mealMeta}>Serves {dish.servings ?? 1}</Text>
                        </View>
                      </View>
                      {meal.label ? (
                        <View style={[styles.labelBadge, { backgroundColor: planningLabelBackgrounds[meal.label] }]}>
                          <Text style={[styles.labelBadgeText, { color: planningLabelTextColors[meal.label] }]}>
                            {meal.label}
                          </Text>
                        </View>
                      ) : null}
                    </Pressable>
                  );
                })}

                <Pressable
                  onPress={() => router.push({ pathname: '/modals/plan-dish', params: { date: dateKey } })}
                  style={[styles.addDishRow, meals.length === 0 && styles.addDishRowEmpty]}>
                  <Text style={styles.addDishIcon}>＋</Text>
                  <Text style={styles.addDishText}>Add dish</Text>
                </Pressable>
              </View>
            </View>
          );
        })}

        {recommendedDish ? (
          <Pressable
            style={styles.recommendationCard}
            onPress={() => router.push({ pathname: '/dish/[id]', params: { id: recommendedDish.id } })}>
            <View style={styles.recommendationHeader}>
              <View style={styles.recommendationCopy}>
                <Text style={styles.recommendationSpark}>✦</Text>
                <Text style={styles.recommendationTitle}>Cook Tonight?</Text>
                <Text style={styles.recommendationHint}>
                  Based on your menu and what you have not cooked recently.
                </Text>
              </View>
              <Image source={recommendedDish.heroImageUri} style={styles.recommendationHero} contentFit="cover" />
            </View>

            <View style={styles.recommendationRow}>
              <Image source={recommendedDish.heroImageUri} style={styles.recommendationThumb} contentFit="cover" />
              <View style={styles.recommendationBody}>
                <Text style={styles.recommendationDish}>{recommendedDish.title}</Text>
                <Text style={styles.recommendationMeta}>
                  {recommendedDish.prepMinutes ?? 0} min • Last made {formatRelativeDate(recommendedDish.lastMadeAt)}
                </Text>
              </View>
              <Text style={styles.recommendationSave}>⌑</Text>
            </View>
          </Pressable>
        ) : null}

        {reviewItems.length > 0 ? (
          <Pressable style={styles.reviewCard} onPress={() => router.push('/modals/review')}>
            <Text style={styles.reviewCount}>{reviewItems.length} items need review</Text>
            <Text style={styles.reviewHint}>AI needs help confirming a few captures.</Text>
          </Pressable>
        ) : null}

        <View style={styles.menuSectionHeader}>
          <Text style={styles.menuSectionTitle}>From your menu</Text>
          <Pressable onPress={() => router.push('/menu')}>
            <Text style={styles.menuSectionAction}>See all</Text>
          </Pressable>
        </View>

        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          style={styles.menuHighlightsScroll}
          contentContainerStyle={styles.menuHighlights}>
          {menuHighlights.map((dish) => (
            <Pressable
              key={dish.id}
              onPress={() => router.push({ pathname: '/modals/plan-dish', params: { dishId: dish.id } })}
              style={styles.menuCard}>
              <Image source={dish.heroImageUri} style={styles.menuCardImage} contentFit="cover" />
              <Text numberOfLines={2} style={styles.menuCardTitle}>
                {dish.title}
              </Text>
            </Pressable>
          ))}
        </ScrollView>
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
    paddingHorizontal: 16,
    paddingTop: 8,
    flexGrow: 1,
    gap: 10,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    gap: 12,
    marginBottom: 2,
  },
  title: {
    color: APP_COLORS.green,
    fontSize: 34,
    fontWeight: '700',
    fontFamily: 'Georgia',
  },
  subtitle: {
    color: APP_COLORS.text,
    fontSize: 14,
    marginTop: 2,
  },
  headerActions: {
    flexDirection: 'row',
    gap: 8,
    paddingTop: 6,
  },
  iconButton: {
    width: 52,
    height: 52,
    borderRadius: 18,
    backgroundColor: APP_COLORS.card,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: APP_COLORS.border,
    shadowColor: '#000000',
    shadowOpacity: 0.05,
    shadowRadius: 14,
    shadowOffset: { width: 0, height: 6 },
    elevation: 2,
  },
  daySection: {
    flexDirection: 'row',
    gap: 10,
    alignItems: 'stretch',
  },
  dayRail: {
    width: 54,
    alignItems: 'center',
    paddingTop: 12,
    gap: 1,
  },
  dayName: {
    color: APP_COLORS.text,
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 0.6,
  },
  dayNameToday: {
    color: APP_COLORS.green,
  },
  dayNumber: {
    color: APP_COLORS.text,
    fontSize: 22,
    lineHeight: 25,
    fontWeight: '700',
    fontFamily: 'Georgia',
    marginTop: 2,
  },
  dayShort: {
    color: APP_COLORS.textMuted,
    fontSize: 11,
  },
  dayCard: {
    flex: 1,
    backgroundColor: APP_COLORS.card,
    borderRadius: APP_RADIUS.lg,
    borderWidth: 1,
    borderColor: APP_COLORS.border,
    padding: 10,
    gap: 2,
    shadowColor: '#000000',
    shadowOpacity: 0.04,
    shadowRadius: 14,
    shadowOffset: { width: 0, height: 6 },
    elevation: 2,
    minHeight: 102,
  },
  mealRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    paddingVertical: 7,
  },
  mealRowBorder: {
    borderBottomWidth: 1,
    borderBottomColor: '#F2E7D8',
  },
  mealImage: {
    width: 68,
    height: 68,
    borderRadius: 12,
    backgroundColor: APP_COLORS.creamDeep,
  },
  mealBody: {
    flex: 1,
    gap: 4,
  },
  mealTopLine: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: 6,
  },
  mealTitle: {
    flex: 1,
    color: APP_COLORS.text,
    fontSize: 14,
    fontFamily: 'Georgia',
    fontWeight: '700',
  },
  mealMore: {
    color: APP_COLORS.text,
    fontSize: 14,
    lineHeight: 16,
  },
  mealMetaRow: {
    flexDirection: 'row',
    alignItems: 'center',
    flexWrap: 'wrap',
    gap: 6,
  },
  mealMeta: {
    color: APP_COLORS.textMuted,
    fontSize: 12,
  },
  mealMetaBullet: {
    color: APP_COLORS.textMuted,
    fontSize: 12,
  },
  labelBadge: {
    borderRadius: APP_RADIUS.pill,
    paddingHorizontal: 8,
    paddingVertical: 5,
    alignSelf: 'flex-start',
    marginLeft: 6,
  },
  labelBadgeText: {
    fontSize: 12,
    fontWeight: '700',
  },
  addDishRow: {
    minHeight: 46,
    marginTop: 6,
    borderRadius: APP_RADIUS.md,
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
    gap: 5,
    backgroundColor: '#FFFEFB',
  },
  addDishRowEmpty: {
    flex: 1,
    marginTop: 0,
  },
  addDishIcon: {
    color: APP_COLORS.gold,
    fontSize: 16,
    lineHeight: 18,
  },
  addDishText: {
    color: '#C98511',
    fontSize: 13,
    fontWeight: '700',
  },
  recommendationCard: {
    backgroundColor: APP_COLORS.card,
    borderRadius: APP_RADIUS.lg,
    borderWidth: 1,
    borderColor: APP_COLORS.border,
    overflow: 'hidden',
    marginTop: 2,
  },
  recommendationHeader: {
    minHeight: 138,
    padding: 16,
    flexDirection: 'row',
    alignItems: 'stretch',
    gap: 12,
    backgroundColor: '#FCF7EE',
  },
  recommendationSpark: {
    color: APP_COLORS.gold,
    fontSize: 24,
    marginBottom: 4,
  },
  recommendationCopy: {
    flex: 1,
    gap: 4,
    justifyContent: 'center',
  },
  recommendationTitle: {
    color: APP_COLORS.text,
    fontSize: 20,
    fontFamily: 'Georgia',
    fontWeight: '700',
  },
  recommendationHint: {
    color: APP_COLORS.textMuted,
    fontSize: 14,
    lineHeight: 20,
  },
  recommendationHero: {
    width: '40%',
    minWidth: 118,
    maxWidth: 150,
    minHeight: 106,
    borderRadius: 0,
    alignSelf: 'stretch',
  },
  recommendationRow: {
    margin: 12,
    marginTop: -22,
    backgroundColor: APP_COLORS.white,
    borderRadius: APP_RADIUS.md,
    borderWidth: 1,
    borderColor: APP_COLORS.border,
    padding: 9,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  recommendationThumb: {
    width: 70,
    height: 62,
    borderRadius: 14,
    backgroundColor: APP_COLORS.creamDeep,
  },
  recommendationBody: {
    flex: 1,
    gap: 4,
  },
  recommendationDish: {
    color: APP_COLORS.text,
    fontSize: 16,
    fontFamily: 'Georgia',
    fontWeight: '700',
  },
  recommendationMeta: {
    color: APP_COLORS.textMuted,
    fontSize: 12,
    lineHeight: 17,
    flexShrink: 1,
  },
  recommendationSave: {
    color: APP_COLORS.textMuted,
    fontSize: 20,
  },
  reviewCard: {
    backgroundColor: APP_COLORS.goldSoft,
    borderRadius: APP_RADIUS.md,
    padding: 14,
    gap: 4,
  },
  reviewCount: {
    color: APP_COLORS.text,
    fontSize: 15,
    fontWeight: '700',
  },
  reviewHint: {
    color: APP_COLORS.textMuted,
    fontSize: 12,
  },
  menuSectionHeader: {
    marginTop: 2,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  menuSectionTitle: {
    color: APP_COLORS.text,
    fontSize: 18,
    fontFamily: 'Georgia',
    fontWeight: '700',
  },
  menuSectionAction: {
    color: APP_COLORS.green,
    fontSize: 14,
    fontWeight: '600',
  },
  menuHighlights: {
    gap: 10,
    paddingHorizontal: 16,
  },
  menuHighlightsScroll: {
    marginHorizontal: -16,
  },
  menuCard: {
    width: 132,
    backgroundColor: APP_COLORS.card,
    borderRadius: APP_RADIUS.md,
    borderWidth: 1,
    borderColor: APP_COLORS.border,
    overflow: 'hidden',
  },
  menuCardImage: {
    width: '100%',
    height: 102,
    backgroundColor: APP_COLORS.creamDeep,
  },
  menuCardTitle: {
    color: APP_COLORS.text,
    fontSize: 14,
    fontWeight: '700',
    lineHeight: 18,
    padding: 9,
    minHeight: 50,
  },
});
