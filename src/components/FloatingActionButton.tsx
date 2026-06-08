import { router } from 'expo-router';
import { Pressable, StyleSheet, Text } from 'react-native';

import { APP_COLORS, APP_RADIUS } from '@/theme';

export function FloatingActionButton() {
  return (
    <Pressable onPress={() => router.push('/modals/capture')} style={styles.button}>
      <Text style={styles.label}>+</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  button: {
    position: 'absolute',
    right: 20,
    bottom: 94,
    width: 60,
    height: 60,
    borderRadius: APP_RADIUS.pill,
    backgroundColor: APP_COLORS.gold,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000000',
    shadowOpacity: 0.18,
    shadowRadius: 16,
    shadowOffset: { width: 0, height: 8 },
    elevation: 8,
  },
  label: {
    fontSize: 34,
    lineHeight: 38,
    color: APP_COLORS.white,
    fontWeight: '300',
  },
});
