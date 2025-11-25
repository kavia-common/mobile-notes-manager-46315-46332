import React from 'react';
import { View, TextInput, StyleSheet } from 'react-native';
import { theme } from '../theme/theme';

type Props = {
  value: string;
  onChangeText: (t: string) => void;
  placeholder?: string;
};

export default function SearchBar({ value, onChangeText, placeholder = 'Search notes...' }: Props) {
  return (
    <View style={styles.container}>
      <TextInput
        accessibilityLabel="Search notes"
        placeholder={placeholder}
        placeholderTextColor={theme.colors.muted}
        value={value}
        onChangeText={onChangeText}
        style={styles.input}
        returnKeyType="search"
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: theme.colors.surface,
    padding: 12,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.border
  },
  input: {
    backgroundColor: '#fff',
    borderRadius: theme.radius.md,
    borderWidth: 1,
    borderColor: theme.colors.border,
    paddingHorizontal: 12,
    paddingVertical: 10,
    fontSize: 16,
    color: theme.colors.text
  }
});
