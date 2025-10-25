# Theme Usage in Fluence Pay Merchant App

## ✅ Centralized Theme System

### Overview
The entire app uses a centralized theme system located in `lib/core/theme/` that follows Material Design 3 principles.

## 🎨 Theme Files

### 1. **app_colors.dart**
- Defines all colors used throughout the app
- Fluence Pay brand colors (golden/bronze palette)
- Status colors (success, warning, error, info)
- Neutral grays and background colors
- **Usage**: `AppColors.fluenceGold`, `AppColors.background`, etc.

### 2. **app_text_styles.dart**
- Complete typography scale following Material Design 3
- Consistent text styles (display, headline, title, body, label)
- **Usage**: `AppTextStyles.headlineLarge`, `AppTextStyles.bodyMedium`, etc.

### 3. **app_theme.dart**
- Complete ThemeData configuration with Material Design 3 enabled
- Component theming (buttons, inputs, cards, dialogs, etc.)
- Light and dark theme support
- **Usage**: Applied globally in `main.dart`

### 4. **theme.dart**
- Export file for easy imports
- **Usage**: `import '../../core/theme/theme.dart';`

## 📱 Where Theme is Used

### Main App (main.dart)
```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  ...
)
```

### Splash Screen (splash_page_simple.dart)
- ✅ Uses `AppColors.background`
- ✅ Uses `AppColors.fluenceGold`
- ✅ Uses `AppColors.white`
- ✅ Uses `AppTextStyles.headlineLarge`
- ✅ Uses `AppTextStyles.titleMedium`
- ✅ Uses Material Design 3 button styling

### Signup Page (sign_up_page.dart)
- ✅ Uses `AppColors.background`
- ✅ Uses `AppColors.fluenceGold`
- ✅ Uses `AppTextStyles` for all text
- ✅ Uses centralized theme colors

### Onboarding Page (onboarding_page.dart)
- ✅ Uses `AppColors` for all UI elements
- ✅ Uses `AppTextStyles` for typography
- ✅ Uses theme-based form fields
- ✅ Uses themed buttons and navigation

### Custom Widgets
#### CustomTextField (presentation/widgets/custom_text_field.dart)
- ✅ Uses `AppColors` for borders, backgrounds
- ✅ Uses `AppTextStyles` for labels and hints
- ✅ Consistent styling across all form fields

#### CustomElevatedButton (presentation/widgets/custom_elevated_button.dart)
- ✅ Uses `AppColors.primary` for background
- ✅ Uses `AppTextStyles.buttonText`
- ✅ Material Design 3 compliant

## 🎯 Material Design 3 Features

### Enabled Globally
```dart
useMaterial3: true
```

### MD3 Features Used:
1. **Modern Color System**
   - ColorScheme.fromSeed() for dynamic colors
   - Surface containers and variants
   - Proper contrast ratios

2. **Typography Scale**
   - Display, Headline, Title, Body, Label styles
   - Consistent letter spacing and line heights

3. **Component Styling**
   - Rounded corners (8-12px)
   - Modern elevation and shadows
   - Better padding and spacing

4. **Accessibility**
   - High contrast ratios
   - Larger touch targets
   - Focus indicators

## 🔄 How to Update Theme

### To Change Brand Colors:
1. Update `lib/core/theme/app_colors.dart`
2. Modify the Fluence Pay color constants
3. Changes reflect across the entire app automatically

### To Update Typography:
1. Update `lib/core/theme/app_text_styles.dart`
2. Modify text style definitions
3. All text in the app updates automatically

### To Change Component Styles:
1. Update `lib/core/theme/app_theme.dart`
2. Modify the relevant theme data (e.g., elevatedButtonTheme)
3. All components of that type update globally

## ✅ Benefits

1. **Consistency**: One source of truth for all styling
2. **Maintainability**: Easy to update brand colors
3. **Type Safety**: Compile-time checking of styles
4. **Performance**: No runtime style processing
5. **Scalability**: Easy to add new themed components
6. **Material Design 3**: Modern, accessible design
7. **Brand Alignment**: Golden/bronze Fluence Pay colors throughout

## 📋 Usage Checklist

- ✅ All pages use `AppColors` for colors
- ✅ All text uses `AppTextStyles` for typography
- ✅ All buttons use themed styles
- ✅ All form fields use themed inputs
- ✅ Material Design 3 enabled globally
- ✅ Custom components follow theme system
- ✅ Consistent spacing and layout patterns
