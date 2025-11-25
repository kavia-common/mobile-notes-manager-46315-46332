import AsyncStorage from '@react-native-async-storage/async-storage';
import { AsyncStorageNoteRepository } from '../src/storage/NoteRepository';

jest.mock('@react-native-async-storage/async-storage', () => {
  let store: Record<string, string> = {};
  return {
    __esModule: true,
    default: {
      getItem: jest.fn(async (k: string) => store[k] ?? null),
      setItem: jest.fn(async (k: string, v: string) => { store[k] = v; }),
      removeItem: jest.fn(async (k: string) => { delete store[k]; }),
      clear: jest.fn(async () => { store = {}; })
    }
  };
});

describe('AsyncStorageNoteRepository', () => {
  beforeEach(async () => {
    // @ts-ignore
    await AsyncStorage.clear();
  });

  it('creates and lists notes', async () => {
    const repo = new AsyncStorageNoteRepository();
    const n = await repo.create({ title: 'A', content: 'B' });
    const list = await repo.list();
    expect(list.length).toBe(1);
    expect(list[0].id).toBe(n.id);
  });

  it('updates a note and sorts by updatedAt desc', async () => {
    const repo = new AsyncStorageNoteRepository();
    const n1 = await repo.create({ title: 'A', content: 'B' });
    const n2 = await repo.create({ title: 'C', content: 'D' });

    const updated = await repo.update({ ...n1, title: 'A2', content: 'B2' });
    const list = await repo.list();
    expect(list[0].id).toBe(updated.id);
  });

  it('deletes a note', async () => {
    const repo = new AsyncStorageNoteRepository();
    const n = await repo.create({ title: 'X', content: 'Y' });
    const ok = await repo.delete(n.id);
    expect(ok).toBe(true);
    const list = await repo.list();
    expect(list.length).toBe(0);
  });

  it('search finds substring in title or content', async () => {
    const repo = new AsyncStorageNoteRepository();
    await repo.create({ title: 'Shopping', content: 'Eggs' });
    await repo.create({ title: 'Work', content: 'Meeting notes' });
    const found = await repo.search('shop');
    expect(found.length).toBe(1);
    expect(found[0].title).toBe('Shopping');
  });
});
