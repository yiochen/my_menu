import { router, useLocalSearchParams } from 'expo-router';
import { useMemo, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { APP_COLORS, APP_RADIUS } from '@/theme';
import { useAppStore } from '@/store/useAppStore';
import { getWeekRange, toDateKey } from '@/utils/date';

export default function PlanDishModal() {
  const { dishId, date } = useLocalSearchParams<{ dishId?: string; date?: string }>();
  const dishes = useAppStore((state) => state.dishes);
  const planDish = useAppStore((state) => state.planDish);
  const { days } = getWeekRange();
  const [selectedDishId, setSelectedDishId] = useState(dishId ?? dishes[0]?.id);

  const selectedDish = useMemo(
    () => dishes.find((dish) => dish.id === selectedDishId),
    [dishes, selectedDishId],
  );

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.header}>
        <View>
          <Text style={styles.title}>Plan Dinner</Text>
          <Text style={styles.subtitle}>Pick a dish and drop it onto this week.</Text>
        </View>
        <Pressable onPress={() => router.back()} style={styles.closeButton}>
          <Text style={styles.closeText}>✕</Text>
        </Pressable>
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.sectionTitle}>Choose Dish</Text>
        <View style={styles.sectionCard}>
          {dishes.map((dish) => (
            <Pressable
              key={dish.id}
              onPress={() => setSelectedDishId(dish.id)}
              style={[styles.dishRow, selectedDishId === dish.id && styles.dishRowActive]}>
              <Text style={[styles.dishRowText, selectedDishId === dish.id && styles.dishRowTextActive]}>{dish.title}</Text>
            </Pressable>
          ))}
        </View>

        <Text style={styles.sectionTitle}>This Week</Text>
        <View style={styles.sectionCard}>
          {days.map((day) => {
            const dateKey = toDateKey(day);
            const active = dateKey === date;
            return (
              <Pressable
                key={dateKey}
                onPress={async () => {
                  if (!selectedDish) {
                    return;
                  }
                  await planDish(selectedDish.id, dateKey);
                  router.back();
                }}
                style={[styles.dayRow, active && styles.dayRowActive]}>
                <View>
                  <Text style={styles.dayLabel}>{day.toLocaleDateString('en-US', { weekday: 'long' })}</Text>
                  <Text style={styles.dayMeta}>{dateKey}</Text>
                </View>
                <Text style={styles.dayAction}>Plan</Text>
              </Pressable>
            );
          })}
        </View>
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
    fontFamily: 'Georgia',
    fontWeight: '700',
    color: APP_COLORS.text,
  },
  subtitle: {
    color: APP_COLORS.textMuted,
    marginTop: 8,
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
    gap: 14,
  },
  sectionTitle: {
    color: APP_COLORS.text,
    fontSize: 18,
    fontWeight: '700',
  },
  sectionCard: {
    backgroundColor: APP_COLORS.card,
    borderRadius: APP_RADIUS.lg,
    borderWidth: 1,
    borderColor: APP_COLORS.border,
    padding: 10,
    gap: 10,
  },
  dishRow: {
    paddingHorizontal: 14,
    paddingVertical: 12,
    borderRadius: APP_RADIUS.md,
    backgroundColor: APP_COLORS.white,
  },
  dishRowActive: {
    backgroundColor: APP_COLORS.green,
  },
  dishRowText: {
    color: APP_COLORS.text,
    fontWeight: '600',
  },
  dishRowTextActive: {
    color: APP_COLORS.white,
  },
  dayRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 14,
    paddingVertical: 14,
    borderRadius: APP_RADIUS.md,
    backgroundColor: APP_COLORS.white,
  },
  dayRowActive: {
    borderWidth: 1,
    borderColor: APP_COLORS.gold,
  },
  dayLabel: {
    color: APP_COLORS.text,
    fontWeight: '700',
  },
  dayMeta: {
    color: APP_COLORS.textMuted,
    marginTop: 4,
  },
  dayAction: {
    color: APP_COLORS.green,
    fontWeight: '700',
  },
});
