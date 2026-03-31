---
inclusion: always
---

# Flutter Design System Rules

## Framework & Language
- Framework: Flutter (Dart)
- SDK: ^3.9.0
- Styling: Material Design via `ThemeData`

## Token Definitions
- Colors: Defined via `ColorScheme.fromSeed()` in `ThemeData`. Use `Theme.of(context).colorScheme` to access colors.
- Typography: Use `Theme.of(context).textTheme` for text styles (e.g., `headlineMedium`, `bodyLarge`).
- Spacing: No custom spacing tokens yet. Use `const EdgeInsets` and `SizedBox` for spacing. Prefer multiples of 4/8.

## Component Architecture
- Components live in `lib/` directory
- Use `StatelessWidget` for presentational components, `StatefulWidget` when local state is needed
- All widget constructors should use `const` where possible and accept a `Key? key` parameter via `super.key`
- Prefer composition over inheritance

## Styling Approach
- Use `Theme.of(context)` to access design tokens — never hardcode colors or text styles
- Use `ColorScheme` properties: `primary`, `onPrimary`, `surface`, `onSurface`, `error`, etc.
- Use `TextTheme` properties: `displayLarge`, `headlineMedium`, `bodyLarge`, `labelSmall`, etc.
- Responsive layouts: Use `MediaQuery`, `LayoutBuilder`, `Flexible`, `Expanded`

## Asset Management
- Assets go in the project root `assets/` directory (images, fonts, etc.)
- Register assets in `pubspec.yaml` under `flutter.assets`
- Reference via `AssetImage('assets/...')` or `Image.asset('assets/...')`

## Icon System
- Primary: Material Icons via `Icons.*` (enabled by `uses-material-design: true`)
- Cupertino Icons available via `cupertino_icons` package
- Custom icons: Add SVG/PNG to `assets/icons/` and register in pubspec

## Project Structure
```
lib/
  main.dart          # App entry point, theme, routing
  screens/           # Full-page screens/views
  widgets/           # Reusable UI components
  models/            # Data models
  services/          # Business logic, API calls
  utils/             # Helpers, constants
```

## Figma-to-Flutter Translation Rules
- Figma MCP returns React + Tailwind reference code — treat as design intent, not final code
- Map Tailwind colors → `Theme.of(context).colorScheme.*`
- Map Tailwind typography → `Theme.of(context).textTheme.*`
- Map Tailwind spacing (p-4 = 16px) → `EdgeInsets.all(16)` or `SizedBox(height: 16)`
- Map flexbox → `Row`, `Column`, `Wrap`, `Flex`
- Map `border-radius` → `BorderRadius.circular(value)`
- Map `box-shadow` → `BoxShadow` in `BoxDecoration`
- Map `opacity` → `Opacity` widget or color `.withOpacity()`
- Map `position: absolute` → `Stack` + `Positioned`
- Map `grid` → `GridView` or `Wrap`
- Reuse existing Flutter widgets instead of creating duplicates
- Aim for 1:1 visual parity with the Figma screenshot
