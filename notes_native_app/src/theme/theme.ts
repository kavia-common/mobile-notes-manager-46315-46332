export const theme = {
  colors: {
    primary: '#2563EB',
    secondary: '#F59E0B',
    success: '#F59E0B',
    error: '#EF4444',
    background: '#f9fafb',
    surface: '#ffffff',
    text: '#111827',
    muted: '#6B7280',
    border: '#E5E7EB'
  },
  spacing: (n: number) => n * 8,
  radius: {
    sm: 8,
    md: 12,
    lg: 16,
    pill: 999
  },
  shadow: {
    card: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.08,
      shadowRadius: 6,
      elevation: 3
    }
  },
  typography: {
    title: 20,
    subtitle: 16,
    body: 14,
    caption: 12
  }
};
