import { router } from 'expo-router';
import { useMemo, useState } from 'react';
import { ScrollView, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';

import { DishCard } from '@/components/DishCard';
import { FloatingActionButton } from '@/components/FloatingActionButton';
import { APP_COLORS, APP_RADIUS } from '@/theme';
import { useAppStore } from '@/store/useAppStore';

const filters = ['All', 'Favorites', 'Mains', 'Bowls', 'Pasta', 'Soups', 'Desserts'] as const;

export default function MenuScreen() {
  const dishes = useAppStore((state) => state.dishes);
  const toggleFavorite = useAppStore((state) => state.toggleFavorite);
  const insets = useSafeAreaInsets();
  const [search, setSearch] = useState('');
  const [selectedFilter, setSelectedFilter] = useState<(typeof filters)[number]>('All');

  const filteredDishes = useMemo(() => {
    return dishes.filter((dish) => {
      const matchesSearch =
        search.trim().length === 0 ||
        dish.title.toLowerCase().includes(search.toLowerCase()) ||
        dish.description?.toLowerCase().includes(search.toLowerCase());

      const matchesFilter =
        selectedFilter === 'All' ||
        (selectedFilter === 'Favorites' ? dish.favorite : dish.category === selectedFilter);

      return matchesSearch && matchesFilter;
    });
  }, [dishes, search, selectedFilter]);

  const favorites = dishes.filter((dish) => dish.favorite);
  const recent = [...dishes].sort((a, b) => b.createdAt.localeCompare(a.createdAt)).slice(0, 4);

  return (
    <SafeAreaView edges={['top', 'left', 'right']} style={styles.safeArea}>
      <ScrollView contentContainerStyle={[styles.content, { paddingBottom: 160 + insets.bottom }]}>
        <View style={styles.header}>
          <View>
            <Text style={styles.title}>My Menu</Text>
            <Text style={styles.subtitle}>{dishes.length} dishes in your personal menu</Text>
          </View>
          <Pressable style={styles.searchIcon}>
            <Text style={styles.searchIconText}>⌕</Text>
          </Pressable>
        </View>

        <TextInput
          value={search}
          onChangeText={setSearch}
          placeholder="Search dishes, notes, and ideas"
          placeholderTextColor={APP_COLORS.textMuted}
          style={styles.searchInput}
        />

        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.chipsRow}>
          {filters.map((filter) => (
            <Pressable
              key={filter}
              onPress={() => setSelectedFilter(filter)}
              style={[styles.chip, selectedFilter === filter && styles.chipActive]}>
              <Text style={[styles.chipText, selectedFilter === filter && styles.chipTextActive]}>{filter}</Text>
            </Pressable>
          ))}
        </ScrollView>

        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Favorites</Text>
        </View>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.horizontalList}>
          {favorites.map((dish) => (
            <DishCard
              key={dish.id}
              dish={dish}
              compact
              onPress={() => router.push({ pathname: '/dish/[id]', params: { id: dish.id } })}
              onToggleFavorite={() => void toggleFavorite(dish.id)}
            />
          ))}
        </ScrollView>

        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Recently Added</Text>
        </View>
        <View style={styles.recentList}>
          {recent.map((dish) => (
            <Pressable
              key={dish.id}
              onPress={() => router.push({ pathname: '/dish/[id]', params: { id: dish.id } })}
              style={styles.recentRow}>
              <Text style={styles.recentName}>{dish.title}</Text>
              <Text style={styles.recentMeta}>{dish.category ?? 'Other'}</Text>
            </Pressable>
          ))}
        </View>

        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>All Dishes</Text>
        </View>
        <View style={styles.grid}>
          {filteredDishes.map((dish) => (
            <DishCard
              key={dish.id}
              dish={dish}
              onPress={() => router.push({ pathname: '/dish/[id]', params: { id: dish.id } })}
              onToggleFavorite={() => void toggleFavorite(dish.id)}
            />
          ))}
        </View>
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
    flexGrow: 1,
    gap: 16,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  title: {
    fontSize: 32,
    fontFamily: 'Georgia',
    fontWeight: '700',
    color: APP_COLORS.text,
  },
  subtitle: {
    marginTop: 4,
    color: APP_COLORS.textMuted,
    fontSize: 14,
  },
  searchIcon: {
    width: 42,
    height: 42,
    borderRadius: APP_RADIUS.pill,
    backgroundColor: APP_COLORS.card,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: APP_COLORS.border,
  },
  searchIconText: {
    color: APP_COLORS.green,
    fontSize: 18,
  },
  searchInput: {
    backgroundColor: APP_COLORS.card,
    borderRadius: APP_RADIUS.md,
    paddingHorizontal: 16,
    paddingVertical: 14,
    borderWidth: 1,
    borderColor: APP_COLORS.border,
    color: APP_COLORS.text,
    fontSize: 15,
  },
  chipsRow: {
    gap: 8,
    paddingRight: 20,
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
    fontWeight: '600',
    fontSize: 13,
  },
  chipTextActive: {
    color: APP_COLORS.white,
  },
  sectionHeader: {
    marginTop: 8,
  },
  sectionTitle: {
    fontSize: 20,
    color: APP_COLORS.text,
    fontWeight: '700',
  },
  horizontalList: {
    gap: 12,
    paddingRight: 20,
  },
  recentList: {
    backgroundColor: APP_COLORS.card,
    borderRadius: APP_RADIUS.lg,
    borderWidth: 1,
    borderColor: APP_COLORS.border,
    overflow: 'hidden',
  },
  recentRow: {
    paddingHorizontal: 16,
    paddingVertical: 14,
    borderBottomWidth: 1,
    borderBottomColor: APP_COLORS.border,
  },
  recentName: {
    color: APP_COLORS.text,
    fontSize: 16,
    fontWeight: '700',
  },
  recentMeta: {
    color: APP_COLORS.textMuted,
    fontSize: 13,
    marginTop: 4,
  },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
  },
});
