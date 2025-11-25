import React from 'react';
import { NavigationContainer, DefaultTheme, Theme } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { StatusBar } from 'expo-status-bar';
import NotesListScreen from './screens/NotesListScreen';
import NoteEditorScreen from './screens/NoteEditorScreen';
import ViewNoteScreen from './screens/ViewNoteScreen';
import { theme } from './theme/theme';

export type RootStackParamList = {
  NotesList: undefined;
  NoteEditor: { id?: string } | undefined;
  ViewNote: { id: string };
};

const Stack = createNativeStackNavigator<RootStackParamList>();

const navTheme: Theme = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    background: theme.colors.background,
    card: theme.colors.surface,
    primary: theme.colors.primary,
    text: theme.colors.text,
    border: '#E5E7EB',
    notification: theme.colors.secondary
  }
};

export default function App() {
  return (
    <NavigationContainer theme={navTheme}>
      <StatusBar style="dark" />
      <Stack.Navigator>
        <Stack.Screen
          name="NotesList"
          component={NotesListScreen}
          options={{
            title: 'Ocean Notes',
            headerStyle: { backgroundColor: theme.colors.surface },
            headerShadowVisible: true,
            headerTitleStyle: { color: theme.colors.text }
          }}
        />
        <Stack.Screen
          name="NoteEditor"
          component={NoteEditorScreen}
          options={{
            title: 'Edit Note',
            headerStyle: { backgroundColor: theme.colors.surface },
            headerTitleStyle: { color: theme.colors.text }
          }}
        />
        <Stack.Screen
          name="ViewNote"
          component={ViewNoteScreen}
          options={{
            title: 'View Note',
            headerStyle: { backgroundColor: theme.colors.surface },
            headerTitleStyle: { color: theme.colors.text }
          }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
