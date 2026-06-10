import { router, useLocalSearchParams } from 'expo-router';
import { useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { APP_COLORS, APP_RADIUS } from '@/theme';
import { useAppStore } from '@/store/useAppStore';
import type { PlanningLabel } from '@/types/models';
import { getRemainingWeekRange, toDateKey } from '@/utils/date';

const planningLabels: (PlanningLabel | 'None')[] = ['None', 'Breakfast', 'Lunch', 'Dinner'];

export default function PlanDishModal() {
  const { dishId, date } = useLocalSearchParams<{ dishId?: string; date?: string }>();
  const dishes = useAppStore((state) => state.dishes);
  const planDish = useAppStore((state) => state.planDish);
  const { days } = getRemainingWeekRange();
  const [selectedDishId, setSelectedDishId] = useState(dishId ?? dishes[0]?.id);
  const [selectedLabel, setSelectedLabel] = useState<PlanningLabel | 'None'>('None');

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.header}>
        <View>
          <Text style={styles.title}>Add to Plan</Text>
          <Text style={styles.subtitle}>Pick a dish, then optionally tag it for the day.</Text>
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
              <View style={styles.dishTextBlock}>
                <Text style={[styles.dishRowText, selectedDishId === dish.id && styles.dishRowTextActive]}>
                  {dish.title}
                </Text>
                <Text style={[styles.dishRowMeta, selectedDishId === dish.id && styles.dishRowMetaActive]}>
                  {dish.prepMinutes ?? 0} min
                  {dish.servings ? ` • Serves ${dish.servings}` : ''}
                </Text>
              </View>
            </Pressable>
          ))}
        </View>

        <Text style={styles.sectionTitle}>Planning Label</Text>
        <View style={styles.labelRow}>
          {planningLabels.map((label) => {
            const active = selectedLabel === label;
            return (
              <Pressable
                key={label}
                onPress={() => setSelectedLabel(label)}
                style={[styles.labelChip, active && styles.labelChipActive]}>
                <Text style={[styles.labelChipText, active && styles.labelChipTextActive]}>{label}</Text>
              </Pressable>
            );
          })}
        </View>

        <Text style={styles.sectionTitle}>Choose Day</Text>
        <View style={styles.sectionCard}>
          {days.map((day) => {
            const dateKey = toDateKey(day);
            const active = dateKey === date;
            return (
              <Pressable
                key={dateKey}
                onPress={async () => {
                  if (!selectedDishId) {
                    return;
                  }
                  await planDish(selectedDishId, dateKey, selectedLabel === 'None' ? undefined : selectedLabel);
                  router.back();
                }}
                style={[styles.dayRow, active && styles.dayRowActive]}>
                <View>
                  <Text style={styles.dayLabel}>{day.toLocaleDateString('en-US', { weekday: 'long' })}</Text>
                  <Text style={styles.dayMeta}>{day.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}</Text>
                </View>
                <Text style={styles.dayAction}>Add dish</Text>
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
    gap: 16,
  },
  title: {
    fontSize: 30,
    fontFamily: 'Georgia',
    fontWeight: '700',
    color: APP_COLORS.text,
  },
  subtitle: {
    color: APP_COLORS.textMuted,
    marginTop: 8,
    fontSize: 15,
  },
  closeButton: {
    width: 38,
    height: 38,
    borderRadius: APP_RADIUS.pill,
    backgroundColor: APP_COLORS.card,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: APP_COLORS.border,
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
    paddingVertical: 14,
    borderRadius: APP_RADIUS.md,
    backgroundColor: APP_COLORS.white,
    borderWidth: 1,
    borderColor: 'transparent',
  },
  dishRowActive: {
    borderColor: APP_COLORS.green,
    backgroundColor: '#F3F8F2',
  },
  dishTextBlock: {
    gap: 4,
  },
  dishRowText: {
    color: APP_COLORS.text,
    fontWeight: '700',
    fontSize: 16,
  },
  dishRowTextActive: {
    color: APP_COLORS.green,
  },
  dishRowMeta: {
    color: APP_COLORS.textMuted,
    fontSize: 13,
  },
  dishRowMetaActive: {
    color: APP_COLORS.green,
  },
  labelRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
  },
  labelChip: {
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: APP_RADIUS.pill,
    backgroundColor: APP_COLORS.card,
    borderWidth: 1,
    borderColor: APP_COLORS.border,
  },
  labelChipActive: {
    backgroundColor: APP_COLORS.green,
    borderColor: APP_COLORS.green,
  },
  labelChipText: {
    color: APP_COLORS.text,
    fontSize: 13,
    fontWeight: '600',
  },
  labelChipTextActive: {
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
    borderWidth: 1,
    borderColor: 'transparent',
  },
  dayRowActive: {
    borderColor: APP_COLORS.gold,
  },
  dayLabel: {
    color: APP_COLORS.text,
    fontWeight: '700',
    fontSize: 15,
  },
  dayMeta: {
    color: APP_COLORS.textMuted,
    marginTop: 4,
  },
  dayAction: {
    color: APP_COLORS.gold,
    fontWeight: '700',
    fontSize: 15,
  },
});
