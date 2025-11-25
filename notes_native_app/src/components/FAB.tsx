import React from 'react';
import { TouchableOpacity, Text, StyleSheet, ViewStyle } from 'react-native';
import { theme } from '../theme/theme';

type Props = {
  label?: string;
  onPress: () => void;
  style?: ViewStyle;
};

export default function FAB({ label = '+', onPress, style }: Props) {
  return (
    <TouchableOpacity
      accessibilityRole="button"
      accessibilityLabel="Create new note"
      activeOpacity={0.85}
      onPress={onPress}
      style={[styles.fab, style]}>
      <Text style={styles.label}>{label}</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  fab: {
    position: 'absolute',
    right: 20,
    bottom: 24,
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: theme.colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
    ...theme.shadow.card
  },
  label: {
    color: '#fff',
    fontSize: 28,
    fontWeight: '700',
    marginTop: -2
  }
});
