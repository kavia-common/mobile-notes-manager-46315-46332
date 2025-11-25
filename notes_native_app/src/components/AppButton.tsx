import React from 'react';
import { TouchableOpacity, Text, StyleSheet, ViewStyle, AccessibilityProps } from 'react-native';
import { theme } from '../theme/theme';

type Props = {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary' | 'danger' | 'ghost';
  style?: ViewStyle;
} & AccessibilityProps;

export default function AppButton({ title, onPress, variant = 'primary', style, accessibilityLabel }: Props) {
  const styles = getStyles(variant);
  return (
    <TouchableOpacity
      accessibilityRole="button"
      accessibilityLabel={accessibilityLabel || title}
      activeOpacity={0.8}
      onPress={onPress}
      style={[styles.btn, style]}>
      <Text style={styles.text}>{title}</Text>
    </TouchableOpacity>
  );
}

function getStyles(variant: Props['variant']) {
  const base = StyleSheet.create({
    btn: {
      paddingVertical: 12,
      paddingHorizontal: 16,
      borderRadius: theme.radius.md,
      alignItems: 'center',
      justifyContent: 'center',
      ...theme.shadow.card
    },
    text: {
      fontWeight: '600',
      fontSize: 16
    }
  });

  const variants: Record<string, any> = {
    primary: StyleSheet.create({
      btn: { backgroundColor: theme.colors.primary },
      text: { color: '#fff' }
    }),
    secondary: StyleSheet.create({
      btn: { backgroundColor: theme.colors.secondary },
      text: { color: '#111827' }
    }),
    danger: StyleSheet.create({
      btn: { backgroundColor: theme.colors.error },
      text: { color: '#fff' }
    }),
    ghost: StyleSheet.create({
      btn: { backgroundColor: 'transparent', borderWidth: 1, borderColor: theme.colors.border },
      text: { color: theme.colors.text }
    })
  };

  return {
    btn: [base.btn, variants[variant!].btn],
    text: [base.text, variants[variant!].text]
  };
}
