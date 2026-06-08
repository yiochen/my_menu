import { Tabs } from 'expo-router';

import { APP_COLORS } from '@/theme';

export default function TabsLayout() {
  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: APP_COLORS.green,
        tabBarInactiveTintColor: APP_COLORS.textMuted,
        tabBarStyle: {
          backgroundColor: APP_COLORS.card,
          borderTopColor: APP_COLORS.border,
          height: 74,
          paddingBottom: 10,
          paddingTop: 10,
        },
        tabBarLabelStyle: {
          fontSize: 12,
          fontWeight: '700',
        },
      }}>
      <Tabs.Screen
        name="plan"
        options={{
          title: 'Plan',
          tabBarIcon: () => null,
        }}
      />
      <Tabs.Screen
        name="menu"
        options={{
          title: 'Menu',
          tabBarIcon: () => null,
        }}
      />
    </Tabs>
  );
}
