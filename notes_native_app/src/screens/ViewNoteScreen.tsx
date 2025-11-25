import React, { useEffect, useRef, useState } from 'react';
import { View, Text, StyleSheet, ScrollView, Alert } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../App';
import { theme } from '../theme/theme';
import { Note } from '../models/Note';
import { createNoteRepository, INoteRepository } from '../storage/NoteRepository';
import AppButton from '../components/AppButton';

type Props = NativeStackScreenProps<RootStackParamList, 'ViewNote'>;

export default function ViewNoteScreen({ route, navigation }: Props) {
  const { id } = route.params;
  const repoRef = useRef<INoteRepository>(createNoteRepository());
  const [note, setNote] = useState<Note | undefined>();

  useEffect(() => {
    (async () => {
      const n = await repoRef.current.get(id);
      setNote(n);
      navigation.setOptions({ title: n?.title || 'View Note' });
    })();
  }, [id, navigation]);

  const copy = async () => {
    try {
      const { setStringAsync } = await import('expo-clipboard');
      await setStringAsync(`${note?.title}\n\n${note?.content}`);
      Alert.alert('Copied', 'Note copied to clipboard.');
    } catch {
      Alert.alert('Error', 'Copy not available.');
    }
  };

  const share = async () => {
    try {
      const Share = await import('react-native').then(m => m.Share);
      await Share.share({ message: `${note?.title}\n\n${note?.content}` });
    } catch {
      Alert.alert('Error', 'Share not available.');
    }
  };

  if (!note) {
    return (
      <View style={[styles.container, { alignItems: 'center', justifyContent: 'center' }]}>
        <Text style={{ color: theme.colors.muted }}>Loading...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.title}>{note.title || 'Untitled'}</Text>
        <Text style={styles.meta}>{new Date(note.updatedAt).toLocaleString()}</Text>
        <Text style={styles.body}>{note.content || 'No content'}</Text>
      </ScrollView>
      <View style={styles.actions}>
        <AppButton accessibilityLabel="Edit note" title="Edit" variant="secondary" onPress={() => navigation.navigate('NoteEditor', { id })} />
        <AppButton accessibilityLabel="Copy note" title="Copy" variant="ghost" onPress={copy} />
        <AppButton accessibilityLabel="Share note" title="Share" variant="ghost" onPress={share} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background
  },
  content: {
    padding: 16
  },
  title: {
    fontSize: 22,
    fontWeight: '800',
    color: theme.colors.text
  },
  meta: {
    marginTop: 6,
    color: theme.colors.muted
  },
  body: {
    marginTop: 16,
    fontSize: 16,
    color: theme.colors.text,
    lineHeight: 22
  },
  actions: {
    borderTopWidth: 1,
    borderTopColor: theme.colors.border,
    backgroundColor: theme.colors.surface,
    padding: 12,
    flexDirection: 'row',
    gap: 12,
    justifyContent: 'space-between'
  }
});
