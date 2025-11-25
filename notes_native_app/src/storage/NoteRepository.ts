import AsyncStorage from '@react-native-async-storage/async-storage';
import { v4 as uuidv4 } from 'uuid';
import { Note } from '../models/Note';

const STORAGE_KEY = 'ocean_notes__v1';

// PUBLIC_INTERFACE
export interface INoteRepository {
  /** Create a new note and persist it. */
  create(note: Omit<Note, 'id' | 'createdAt' | 'updatedAt'>): Promise<Note>;
  /** Update an existing note. Throws if not found. */
  update(note: Note): Promise<Note>;
  /** Delete a note by id. Returns true if removed. */
  delete(id: string): Promise<boolean>;
  /** Get a note by id. Returns undefined if not found. */
  get(id: string): Promise<Note | undefined>;
  /** List all notes sorted by updatedAt desc. */
  list(): Promise<Note[]>;
  /** Search notes by substring in title or content. */
  search(query: string): Promise<Note[]>;
  /** Force reload from storage. Useful for pull-to-refresh. */
  reload(): Promise<Note[]>;
}

async function readAll(): Promise<Note[]> {
  const raw = await AsyncStorage.getItem(STORAGE_KEY);
  if (!raw) return [];
  try {
    const parsed = JSON.parse(raw) as Note[];
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

async function writeAll(notes: Note[]): Promise<void> {
  await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(notes));
}

// PUBLIC_INTERFACE
export class AsyncStorageNoteRepository implements INoteRepository {
  private cache: Note[] | null = null;

  async ensureCache() {
    if (this.cache == null) {
      this.cache = await readAll();
    }
  }

  async create(note: Omit<Note, 'id' | 'createdAt' | 'updatedAt'>): Promise<Note> {
    await this.ensureCache();
    const now = Date.now();
    const created: Note = {
      id: uuidv4(),
      title: note.title.trim(),
      content: note.content.trim(),
      createdAt: now,
      updatedAt: now
    };
    const arr = [created, ...(this.cache ?? [])];
    this.cache = arr;
    await writeAll(arr);
    return created;
  }

  async update(note: Note): Promise<Note> {
    await this.ensureCache();
    const idx = (this.cache ?? []).findIndex(n => n.id === note.id);
    if (idx < 0) throw new Error('Note not found');
    const updated: Note = {
      ...note,
      title: note.title.trim(),
      content: note.content.trim(),
      updatedAt: Date.now()
    };
    const arr = [...(this.cache ?? [])];
    arr[idx] = updated;
    // keep updatedAt desc
    arr.sort((a, b) => b.updatedAt - a.updatedAt);
    this.cache = arr;
    await writeAll(arr);
    return updated;
  }

  async delete(id: string): Promise<boolean> {
    await this.ensureCache();
    const before = (this.cache ?? []).length;
    const arr = (this.cache ?? []).filter(n => n.id !== id);
    const removed = arr.length !== before;
    this.cache = arr;
    await writeAll(arr);
    return removed;
  }

  async get(id: string): Promise<Note | undefined> {
    await this.ensureCache();
    return (this.cache ?? []).find(n => n.id === id);
  }

  async list(): Promise<Note[]> {
    await this.ensureCache();
    const arr = [...(this.cache ?? [])];
    arr.sort((a, b) => b.updatedAt - a.updatedAt);
    return arr;
  }

  async search(query: string): Promise<Note[]> {
    await this.ensureCache();
    const q = query.trim().toLowerCase();
    if (!q) return this.list();
    return (this.cache ?? [])
      .filter(n => (n.title + ' ' + n.content).toLowerCase().includes(q))
      .sort((a, b) => b.updatedAt - a.updatedAt);
  }

  async reload(): Promise<Note[]> {
    this.cache = await readAll();
    return this.list();
  }
}

// PUBLIC_INTERFACE
export function createNoteRepository(): INoteRepository {
  /** Factory for the note repository; can be swapped to SQLite in future. */
  return new AsyncStorageNoteRepository();
}
