import React from 'react';
import { View, Text, StyleSheet, Animated } from 'react-native';
import { theme } from '../theme/theme';

type Props = {
  message: string | null;
  visible: boolean;
};

export default function Snackbar({ message, visible }: Props) {
  if (!visible || !message) return null;
  return (
    <View accessible accessibilityLiveRegion="polite" style={styles.wrapper}>
      <View style={styles.snack}>
        <Text style={styles.text}>{message}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 16,
    alignItems: 'center',
    paddingHorizontal: 16
  },
  snack: {
    backgroundColor: '#111827',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: theme.radius.md,
    ...theme.shadow.card
  },
  text: {
    color: '#fff',
    fontSize: 14
  }
});
