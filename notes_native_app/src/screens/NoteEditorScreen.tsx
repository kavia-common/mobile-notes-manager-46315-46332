import React, { useEffect, useRef, useState } from 'react';
import { View, TextInput, StyleSheet, Alert, KeyboardAvoidingView, Platform, ScrollView } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../App';
import { theme } from '../theme/theme';
import AppButton from '../components/AppButton';
import Snackbar from '../components/Snackbar';
import { Note } from '../models/Note';
import { createNoteRepository, INoteRepository } from '../storage/NoteRepository';

type Props = NativeStackScreenProps<RootStackParamList, 'NoteEditor'>;

export default function NoteEditorScreen({ navigation, route }: Props) {
  const repoRef = useRef<INoteRepository>(createNoteRepository());
  const noteId = route.params?.id;
  const isEditing = !!noteId;

  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [snack, setSnack] = useState<string | null>(null);

  useEffect(() => {
    navigation.setOptions({ title: isEditing ? 'Edit Note' : 'New Note' });
    (async () => {
      if (isEditing && noteId) {
        const existing = await repoRef.current.get(noteId);
        if (existing) {
          setTitle(existing.title);
          setContent(existing.content);
        }
      }
    })();
  }, [isEditing, noteId, navigation]);

  const validate = () => {
    const t = title.trim();
    const c = content.trim();
    return t.length > 0 || c.length > 0;
  };

  const save = async () => {
    if (!validate()) {
      setSnack('Please add a title or content before saving.');
      return;
    }
    if (isEditing && noteId) {
      const existing = await repoRef.current.get(noteId);
      if (!existing) return;
      await repoRef.current.update({ ...existing, title, content });
    } else {
      await repoRef.current.create({ title, content });
    }
    setSnack('Saved');
    navigation.goBack();
  };

  const autoSave = async () => {
    if (!validate()) return;
    if (isEditing && noteId) {
      const existing = await repoRef.current.get(noteId);
      if (!existing) return;
      await repoRef.current.update({ ...existing, title, content });
    }
  };

  const confirmDelete = () => {
    if (!isEditing || !noteId) return;
    Alert.alert('Delete note', 'Are you sure you want to delete this note?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Delete',
        style: 'destructive',
        onPress: async () => {
          await repoRef.current.delete(noteId);
          setSnack('Deleted');
          navigation.popToTop();
        }
      }
    ]);
  };

  return (
    <KeyboardAvoidingView style={{ flex: 1, backgroundColor: theme.colors.background }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <ScrollView contentContainerStyle={styles.container} keyboardShouldPersistTaps="handled">
        <TextInput
          accessibilityLabel="Note title"
          placeholder="Title"
          placeholderTextColor={theme.colors.muted}
          value={title}
          onChangeText={setTitle}
          onBlur={autoSave}
          style={styles.title}
        />
        <TextInput
          accessibilityLabel="Note content"
          placeholder="Start typing..."
          placeholderTextColor={theme.colors.muted}
          value={content}
          onChangeText={setContent}
          onBlur={autoSave}
          style={styles.content}
          multiline
          textAlignVertical="top"
        />
        <View style={styles.actions}>
          {isEditing && (
            <AppButton accessibilityLabel="Delete note" title="Delete" variant="danger" onPress={confirmDelete} />
          )}
          <AppButton accessibilityLabel="Save note" title="Save" onPress={save} />
        </View>
      </ScrollView>
      <Snackbar visible={!!snack} message={snack} />
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: 16,
    gap: 12
  },
  title: {
    backgroundColor: theme.colors.surface,
    borderRadius: theme.radius.md,
    borderWidth: 1,
    borderColor: theme.colors.border,
    paddingHorizontal: 12,
    paddingVertical: 12,
    fontSize: 18,
    color: theme.colors.text,
    ...theme.shadow.card
  },
  content: {
    minHeight: 240,
    backgroundColor: theme.colors.surface,
    borderRadius: theme.radius.md,
    borderWidth: 1,
    borderColor: theme.colors.border,
    paddingHorizontal: 12,
    paddingVertical: 12,
    fontSize: 16,
    color: theme.colors.text,
    ...theme.shadow.card
  },
  actions: {
    marginTop: 8,
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: 12
  }
});
