import React, { useCallback, useEffect, useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, RefreshControl } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../App';
import { theme } from '../theme/theme';
import SearchBar from '../components/SearchBar';
import FAB from '../components/FAB';
import Snackbar from '../components/Snackbar';
import { Note } from '../models/Note';
import { createNoteRepository, INoteRepository } from '../storage/NoteRepository';

type Props = NativeStackScreenProps<RootStackParamList, 'NotesList'>;

export default function NotesListScreen({ navigation }: Props) {
  const repoRef = React.useRef<INoteRepository>(createNoteRepository());

  const [notes, setNotes] = useState<Note[]>([]);
  const [query, setQuery] = useState('');
  const [refreshing, setRefreshing] = useState(false);
  const [snack, setSnack] = useState<string | null>(null);

  const load = useCallback(async () => {
    const data = query.trim() ? await repoRef.current.search(query) : await repoRef.current.list();
    setNotes(data);
  }, [query]);

  useEffect(() => {
    const unsubscribe = navigation.addListener('focus', () => {
      load();
    });
    load();
    return unsubscribe;
  }, [navigation, load]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await repoRef.current.reload();
    await load();
    setRefreshing(false);
  }, [load]);

  const renderItem = ({ item }: { item: Note }) => (
    <TouchableOpacity
      accessibilityRole="button"
      accessibilityLabel={`Open note ${item.title || 'Untitled'}`}
      onPress={() => navigation.navigate('ViewNote', { id: item.id })}
      style={styles.card}>
      <Text numberOfLines={1} style={styles.cardTitle}>
        {item.title || 'Untitled'}
      </Text>
      <Text numberOfLines={2} style={styles.cardPreview}>
        {item.content || 'No content'}
      </Text>
      <Text style={styles.cardMeta}>
        {new Date(item.updatedAt).toLocaleString()}
      </Text>
    </TouchableOpacity>
  );

  const Empty = () => (
    <View style={styles.empty}>
      <Text style={styles.emptyTitle}>No notes yet</Text>
      <Text style={styles.emptySubtitle}>Tap the + button to create your first note.</Text>
    </View>
  );

  return (
    <View style={styles.container}>
      <SearchBar value={query} onChangeText={(t) => { setQuery(t); }} />
      <FlatList
        data={notes}
        keyExtractor={n => n.id}
        contentContainerStyle={{ padding: 16, paddingBottom: 100 }}
        renderItem={renderItem}
        ListEmptyComponent={<Empty />}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
      />
      <FAB onPress={() => navigation.navigate('NoteEditor')} />
      <Snackbar visible={!!snack} message={snack} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background
  },
  card: {
    backgroundColor: theme.colors.surface,
    padding: 12,
    borderRadius: theme.radius.md,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: theme.colors.border,
    ...theme.shadow.card
  },
  cardTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: theme.colors.text
  },
  cardPreview: {
    marginTop: 6,
    fontSize: 14,
    color: theme.colors.muted
  },
  cardMeta: {
    marginTop: 8,
    fontSize: 12,
    color: theme.colors.muted
  },
  empty: {
    marginTop: 48,
    alignItems: 'center'
  },
  emptyTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: theme.colors.text
  },
  emptySubtitle: {
    marginTop: 6,
    color: theme.colors.muted
  }
});
