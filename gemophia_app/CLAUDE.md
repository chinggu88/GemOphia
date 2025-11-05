# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**GemOphia Couple Diary** - A Flutter mobile app for managing couple diary entries with tags, calendar views, and todo tracking. Built with Clean Architecture and manual implementations (no code generation).

- **Package**: `gemophia_app`
- **Organization**: `com.gemophia`
- **Platforms**: Android (Kotlin), iOS (Swift)
- **SDK**: Dart ^3.7.2

## Essential Commands

```bash
# Run the app
flutter run

# Run with specific device
flutter run -d <device-id>

# Build for iOS (no codesign)
flutter build ios --no-codesign

# Build for Android
flutter build apk
flutter build appbundle

# Analyze code (should show only info-level issues)
flutter analyze

# Clean build artifacts
flutter clean

# Get dependencies
flutter pub get

# Update dependencies
flutter pub outdated
flutter pub upgrade
```

## Architecture Overview

### Clean Architecture Layers

```
lib/
├── core/               # Cross-cutting concerns
│   ├── router/         # GoRouter configuration
│   ├── theme/          # AppTheme (light/dark with Google Fonts)
│   └── utils/
├── domain/             # Business logic layer
│   ├── entities/       # Plain Dart classes (manual, no Freezed)
│   └── repositories/   # Repository interfaces
├── data/               # Data layer
│   ├── datasources/    # SharedPreferences JSON storage
│   └── repositories/   # Repository implementations with FPDart Either
└── presentation/       # UI layer
    ├── providers/      # Riverpod state management (manual, no codegen)
    ├── screens/        # Feature-based screen folders
    └── widgets/
```

### Key Architectural Decisions

1. **No Code Generation**: This project deliberately avoids build_runner due to analyzer compatibility issues. All models, providers, and serialization are manually implemented.

2. **SharedPreferences for Storage**: Uses JSON serialization with SharedPreferences instead of Drift/SQLite. Data is stored as a JSON array under the key `'couple_diaries'`.

3. **Manual Riverpod Providers**: Uses `AsyncNotifierProvider` and `FutureProvider.family` instead of riverpod_generator. No `.g.dart` files.

4. **FPDart for Error Handling**: All repository methods return `Either<String, T>` for functional error handling.

5. **Bottom Navigation**: Three-tab structure (Home/Calendar/Todo) using Material 3 `NavigationBar`.

## State Management Pattern

### Riverpod Providers (Manual)

```dart
// Data source provider
final dataSourceProvider = Provider<DataSource>((ref) => DataSource());

// Repository provider
final repositoryProvider = Provider<Repository>((ref) {
  final dataSource = ref.watch(dataSourceProvider);
  return RepositoryImpl(dataSource);
});

// Async state provider
final listProvider = AsyncNotifierProvider<ListNotifier, List<T>>(() => ListNotifier());

// Family provider for filtered data
final filteredProvider = FutureProvider.family<List<T>, Filter>((ref, filter) async {
  final data = await ref.watch(listProvider.future);
  return data.where(...).toList();
});
```

### Notifier Pattern

```dart
class ListNotifier extends AsyncNotifier<List<T>> {
  @override
  Future<List<T>> build() async {
    final repository = ref.watch(repositoryProvider);
    final result = await repository.getItems();
    return result.fold(
      (error) => throw Exception(error),
      (items) => items,
    );
  }

  Future<void> createItem(T item) async {
    final repository = ref.read(repositoryProvider);
    final result = await repository.createItem(item);
    result.fold(
      (error) => throw Exception(error),
      (_) => ref.invalidateSelf(),
    );
  }
}
```

## Domain Model Pattern

All entities are plain Dart classes with:
- Immutable fields (final)
- `copyWith` method for updates
- `toJson` / `fromJson` for serialization
- No external dependencies (no Freezed, no json_serializable)

Example:
```dart
class CoupleDiary {
  final int id;
  final List<String> tags;
  final DateTime dueDate;
  final String todo;
  final bool isCompleted;

  const CoupleDiary({required this.id, ...});

  CoupleDiary copyWith({int? id, ...}) => CoupleDiary(...);
  Map<String, dynamic> toJson() => {...};
  factory CoupleDiary.fromJson(Map<String, dynamic> json) => CoupleDiary(...);
}
```

## Data Persistence

### SharedPreferences JSON Storage

The `CoupleDiaryLocalDataSource` manages all CRUD operations:

```dart
// Key used for storage
static const String _key = 'couple_diaries';

// Auto-incrementing ID generation
final newId = diaries.isEmpty ? 1 : diaries.map((d) => d.id).reduce((a, b) => a > b ? a : b) + 1;
```

All operations:
1. Read JSON from SharedPreferences
2. Deserialize to `List<CoupleDiary>`
3. Modify in memory
4. Serialize back to JSON
5. Save to SharedPreferences

## Navigation Structure

### GoRouter Setup

Routes defined in `lib/core/router/app_router.dart`:
- `/` → `MainScreen` (bottom nav container)
- `/diary/:id` → `CoupleDiaryDetailScreen` (with extra: CoupleDiary)

### Bottom Navigation Tabs

`MainScreen` manages three tabs:
1. **Home** (`HomeScreen`) - Dashboard with stats and today's tasks
2. **Calendar** (`CalendarScreen`) - Monthly calendar with diary dots
3. **Todo** (`CoupleDiaryListScreen`) - Full list with filters

Each tab shares the same FAB for adding new diaries.

## Localization

Uses Easy Localization with two locales:
- English (en) - fallback
- Korean (ko)

Translation files: `assets/translations/en.json` and `ko.json`

Usage: `'key'.tr()` (e.g., `'couple_diary_list'.tr()`)

## UI Standards

1. **Icons**: FluentUI System Icons exclusively (e.g., `FluentIcons.home_24_regular`)
2. **Typography**: Google Fonts Noto Sans via `AppTheme`
3. **Theme**: Material 3 with light/dark modes (system follows OS)
4. **Cards**: Used for list items and stat displays with elevation
5. **Dialogs**: `AlertDialog` for forms and confirmations

## Common Patterns

### Adding a New Screen

1. Create screen file in `lib/presentation/screens/feature_name/`
2. Add route in `app_router.dart` if needed
3. Import and use in navigation
4. Use `ConsumerWidget` or `ConsumerStatefulWidget` for Riverpod

### Adding a New Entity

1. Create entity class in `lib/domain/entities/` with manual serialization
2. Create data source in `lib/data/datasources/local/`
3. Create repository interface in `lib/domain/repositories/`
4. Implement repository in `lib/data/repositories/` using FPDart Either
5. Create Riverpod providers in `lib/presentation/providers/`

### Error Handling

Repository methods use FPDart Either:
```dart
Future<Either<String, T>> method() async {
  try {
    // operation
    return Right(result);
  } catch (e) {
    return Left('Error message: $e');
  }
}
```

In UI, fold the Either:
```dart
result.fold(
  (error) => showError(error),
  (data) => showData(data),
);
```

## Known Constraints

1. **No build_runner**: Incompatible analyzer versions between packages. Use manual implementations.
2. **No Drift/SQLite**: SharedPreferences is used instead for simplicity.
3. **No code generation**: All Freezed, Riverpod, and JSON serialization is manual.
4. **Platform support**: Android and iOS only (no web/desktop).

## Testing

Currently no tests implemented. When adding tests:
- Use `flutter_test` for widget tests
- Mock Riverpod providers with `ProviderContainer`
- Test repository implementations with mock data sources
- Test UI with `WidgetTester`

Run tests: `flutter test`
