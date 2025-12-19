# Logbloc - Simple & Scalable Habit Tracker

Logbloc is a Flutter-based habit tracking application designed for simplicity and scalability. It allows users to create customizable habit models (referred to as "logbooks" in documentation) and log entries (referred to as "items" in code) with various feature types.

## Key Concepts and Terminology

- **Model** (Logbook in docs): A habit template defining what to track, including features, schedules, and tags.
- **Item** (Entry in docs): A logged instance of a model, containing data for each feature.
- **Feature**: Modular components within a model (e.g., text, number, timer) that define what data to collect.
- **Record**: The data stored for each item, persisted in the database.
- **Pool**: Reactive state management system using streams for UI updates.

## Features

- **Multiple Feature Types**: Support for text, numbers, timers, chronometers, mood ratings, pictures, voice notes, task lists, and reminders.
- **Flexible Scheduling**: Customizable schedules with daily, weekly, monthly, and yearly options.
- **Tagging System**: Organize models with tags for better categorization.
- **Statistics and Charts**: Visualize progress with various chart types (weekly, monthly, grid).
- **Notifications**: Reminder notifications for scheduled habits.
- **Themes**: Light and dark mode support with customizable colors.
- **Localization**: English and Spanish language support.
- **Offline-First**: Local storage using Hive database.
- **In-App Purchases**: Premium features and membership options.

## Architecture

### State Management
- **Pools**: Custom reactive state containers using `StreamController` for broadcasting changes.
- **Swimmer/LazySwimmer**: Widgets that rebuild on pool changes, with optional lazy loading.
- **Event Processor**: Centralized event handling system.

### Data Layer
- **Hive Database**: NoSQL local database for models, records, and tags.
- **APIs**: Modular API classes for database operations, notifications, and membership.

### UI Structure
- **Root Screens**: Three main screens (Models, Daily, Settings) with nested navigation.
- **Feature System**: Pluggable feature widgets for different data types.
- **Design System**: Reusable UI components in `widgets/design/`.

## Code Structure

```
lib/
├── apis/              # API classes (db, notifications, membership)
├── assets/            # App assets (icons)
├── config/            # Configuration (locales)
├── features/          # Feature implementations
│   ├── [feature_type]/ # Each feature has class, stats, and widget
│   ├── feature_class.dart
│   ├── feature_switch.dart
│   └── feature_widget.dart
├── pools/             # State management
│   ├── models/        # Model-related pools
│   ├── pools.dart     # Base pool classes
│   ├── screen_index_pool.dart
│   └── theme_mode_pool.dart
├── screens/           # UI screens
│   ├── daily/         # Daily logging screens
│   ├── models/        # Model management screens
│   └── settings/      # Settings screens
├── utils/             # Utility functions
└── widgets/           # Reusable UI components
    ├── design/        # Design system components
    └── large_screen/  # Responsive components
```

## Setup

1. **Prerequisites**:
   - Flutter SDK ^3.8.1
   - Dart SDK compatible with Flutter

2. **Installation**:
   ```bash
   flutter pub get
   ```

3. **Run**:
   ```bash
   flutter run
   ```

4. **Build**:
   ```bash
   flutter build apk  # Android
   flutter build ios  # iOS
   flutter build web  # Web
   ```

## Key Classes

### Model (lib/pools/models/model_class.dart)
Represents a habit template with features, schedules, and metadata.

### Feature (lib/features/feature_class.dart)
Base class for all feature types. Each feature implements:
- `completeness`: Progress calculation
- `onSave/onDelete`: Lifecycle hooks
- `serialize`: Data persistence

### Pool (lib/pools/pools.dart)
Reactive state container:
```dart
class Pool<T> {
  StreamController controller = StreamController.broadcast();
  T data;
  // Methods: emit(), set(Function(T) change)
}
```

### Database (lib/apis/db.dart)
Hive-based persistence with transaction support for data integrity.

## Development Guidelines

### Adding New Features
1. Create feature directory in `lib/features/[feature_name]/`
2. Implement `[feature_name]_ft_class.dart` extending `Feature`
3. Create `[feature_name]_ft_widget.dart` for UI
4. Add `[feature_name]_ft_stats.dart` for statistics
5. Update `feature_switch.dart` to include new feature type

### State Management
- Use pools for shared state
- Prefer `Swimmer` for simple rebuilds, `LazySwimmer` for performance
- Emit changes through pool methods

### Database Operations
- Use transactions for multi-step operations
- Follow naming conventions: `saveModel`, `deleteRecord`, etc.
- Handle errors gracefully with feedback system

### UI Patterns
- Use design system components from `widgets/design/`
- Follow responsive design with `large_screen/` components
- Implement proper navigation with root screen system

## Testing

Run tests:
```bash
flutter test
```

## Contributing

1. Follow existing code style and patterns
2. Use meaningful commit messages
3. Test changes thoroughly
4. Update documentation as needed

## Dependencies

Key dependencies include:
- `hive_ce`: Local database
- `flutter_local_notifications`: Push notifications
- `fl_chart`: Data visualization
- `shared_preferences`: Simple key-value storage
- `in_app_purchase`: Monetization
- `workmanager`: Background tasks

For full list, see `pubspec.yaml`.
