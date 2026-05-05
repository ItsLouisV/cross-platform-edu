# Quick Reference Guide

## Essential Commands

### Project Management
```bash
# Create new project
flutter create --org com.example notes_app
cd notes_app

# Get dependencies
flutter pub get

# Clean project
flutter clean

# Upgrade Flutter
flutter upgrade
```

### Development
```bash
# Run app
flutter run

# Run with specific device
flutter run -d "device-id"
flutter devices  # List devices

# Run in release mode
flutter run --release

# Run in profile mode (performance)
flutter run --profile

# Hot reload (during flutter run)
r    # Hot reload
R    # Hot restart
q    # Quit
```

### Building
```bash
# iOS
flutter build ios --release
# Output: build/ios/iphoneos/Runner.app

# Android APK
flutter build apk --release
# Output: build/app/outputs/flutter-app.apk

# Android App Bundle (Play Store)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab

# Web
flutter build web --release
# Output: build/web
```

### Testing & Debugging
```bash
# Run tests
flutter test

# Run specific test file
flutter test test/models/note_test.dart

# Run with coverage
flutter test --coverage

# View logs
flutter logs

# Analyze code
flutter analyze

# Format code
dart format lib/

# Check dependencies
flutter pub outdated
```

---

## Essential Packages

### State Management
| Package | Purpose | Version |
|---------|---------|---------|
| `riverpod` | State management (non-UI) | ^2.4.0 |
| `flutter_riverpod` | State management (UI) | ^2.4.0 |
| `provider` | Simple state management (alternative) | ^6.0.0 |
| `getx` | State + Navigation (alternative) | ^4.6.0 |

### UI & Design
| Package | Purpose | Version |
|---------|---------|---------|
| `cupertino_icons` | iOS icons | ^1.0.2 |
| `flutter_slidable` | Swipe actions | ^3.0.0 |
| `intl` | Date/time formatting | ^0.19.0 |
| `timeago` | Relative time display | ^3.4.0 |

### Database & Storage
| Package | Purpose | Version |
|---------|---------|---------|
| `supabase_flutter` | Supabase backend | ^1.10.0 |
| `hive` | Local storage | ^2.2.3 |
| `hive_flutter` | Hive for Flutter | ^1.1.0 |
| `sqflite` | SQLite (alternative) | ^2.3.0 |

### Utilities
| Package | Purpose | Version |
|---------|---------|---------|
| `uuid` | Generate UUIDs | ^4.0.0 |
| `flutter_dotenv` | Environment variables | ^5.1.0 |
| `image_picker` | Pick images | ^1.0.0 |
| `image_cropper` | Crop images | ^5.0.0 |

### Advanced
| Package | Purpose | Version |
|---------|---------|---------|
| `firebase_messaging` | Push notifications | ^14.0.0 |
| `flutter_local_notifications` | Local notifications | ^16.0.0 |
| `connectivity_plus` | Check internet | ^5.0.0 |
| `shared_preferences` | Simple key-value | ^2.2.0 |

### Testing
| Package | Purpose | Version |
|---------|---------|---------|
| `flutter_test` | Unit/widget tests | Built-in |
| `mockito` | Mocking | ^5.4.0 |
| `integration_test` | Integration tests | Built-in |

---

## pubspec.yaml Template

```yaml
name: notes_app
description: Personal notes application with Flutter and Supabase
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Supabase & Backend
  supabase_flutter: ^1.10.0
  
  # State Management
  flutter_riverpod: ^2.4.0
  riverpod: ^2.4.0
  
  # UI
  cupertino_icons: ^1.0.2
  flutter_slidable: ^3.0.0
  intl: ^0.19.0
  timeago: ^3.4.0
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Utilities
  uuid: ^4.0.0
  flutter_dotenv: ^5.1.0
  image_picker: ^1.0.0
  connectivity_plus: ^5.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
  mockito: ^5.4.0

flutter:
  uses-material-design: false

  # Assets
  assets:
    - assets/images/
    - .env

  # Fonts (optional)
  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
```

---

## Folder Structure Checklist

```
notes_app/
├── android/              # Android native code
├── ios/                  # iOS native code
├── lib/
│   ├── main.dart         # Entry point
│   ├── models/           # Data models
│   │   ├── note.dart
│   │   ├── user.dart
│   │   └── category.dart
│   ├── providers/        # Riverpod providers
│   │   ├── auth_provider.dart
│   │   ├── notes_provider.dart
│   │   └── settings_provider.dart
│   ├── screens/          # UI screens
│   │   ├── auth/
│   │   ├── notes/
│   │   └── settings/
│   ├── services/         # Business logic
│   │   ├── supabase_service.dart
│   │   ├── auth_service.dart
│   │   ├── notes_service.dart
│   │   └── hive_service.dart
│   ├── widgets/          # Reusable widgets
│   │   ├── note_card.dart
│   │   ├── swipeable_note.dart
│   │   ├── custom_app_bar.dart
│   │   └── note_list_empty.dart
│   ├── constants/        # Constants
│   │   ├── colors.dart
│   │   ├── strings.dart
│   │   └── styles.dart
│   └── utils/            # Helper functions
│       ├── date_formatter.dart
│       ├── validators.dart
│       └── extensions.dart
├── test/                 # Unit tests
│   ├── models/
│   ├── services/
│   └── widgets/
├── assets/               # Images, fonts, etc.
│   ├── images/
│   └── fonts/
├── .env                  # Environment variables
├── .env.example          # Example .env
├── .gitignore
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

---

## Git Setup

### .gitignore
```
# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/

# iOS/macOS
ios/.symlinks/
ios/.generated/
ios/Flutter/Flutter.framework
ios/Flutter/Flutter.podspec
ios/Flutter/Generated.xcconfig
ios/Runner/GeneratedPluginRegistrant.*
macos/Flutter/Flutter-Debug.xcconfig
macos/Flutter/Flutter-Release.xcconfig

# Android
android/local.properties
android/.gradle/
android/gradlew
android/gradlew.bat

# IDE
.idea/
.vscode/
*.swp
*.swo
*~
.DS_Store

# Environment
.env
.env.local
.env.*.local

# Coverage
coverage/

# Dependencies
*.log
```

### Initial Commit
```bash
git init
git add .
git commit -m "Initial commit: Notes app setup"
git branch -M main
git remote add origin https://github.com/username/notes-app.git
git push -u origin main
```

---

## Supabase SQL Snippets

### Verify RLS
```sql
-- Check RLS status
SELECT tablename, rowsecurity FROM pg_tables 
WHERE schemaname = 'public';

-- View policies
SELECT * FROM pg_policies 
WHERE tablename = 'notes';

-- Test query with RLS (as authenticated user)
SELECT * FROM public.notes;
```

### Data Cleanup
```sql
-- Soft delete (mark as deleted)
UPDATE public.notes 
SET is_deleted = true 
WHERE id = 'note-id';

-- Hard delete (permanent)
DELETE FROM public.notes 
WHERE id = 'note-id';

-- Clear all deleted notes
DELETE FROM public.notes 
WHERE is_deleted = true;

-- Reset table (careful!)
TRUNCATE TABLE public.notes CASCADE;
```

### Useful Queries
```sql
-- Count notes per user
SELECT user_id, COUNT(*) 
FROM public.notes 
WHERE is_deleted = false
GROUP BY user_id;

-- Find notes with upcoming deadlines
SELECT * FROM public.notes 
WHERE deadline > NOW() 
AND deadline < NOW() + INTERVAL '7 days'
ORDER BY deadline ASC;

-- Search notes
SELECT * FROM public.notes 
WHERE (title ILIKE '%search%' OR content ILIKE '%search%')
AND is_deleted = false;
```

---

## Debugging Checklist

### Supabase Connection
```dart
// Test Supabase connection
void testSupabaseConnection() async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    print('[v0] Current user: $user');
    
    final data = await Supabase.instance.client
        .from('notes')
        .select()
        .limit(1);
    print('[v0] Sample query result: $data');
  } catch (e) {
    print('[v0] Supabase error: $e');
  }
}
```

### RLS Verification
```sql
-- In Supabase Console, run:
SELECT auth.uid() as current_user;
SELECT * FROM public.notes LIMIT 1;
```

### Common Errors
| Error | Solution |
|-------|----------|
| "PGRST116: relation does not exist" | Table not created in Supabase |
| "new row violates row-level security policy" | RLS issue - check user_id |
| "permission denied for table" | RLS not properly configured |
| "42501: permission denied" | No SELECT policy for user |
| "Unauthorized" | Invalid ANON_KEY |

---

## Performance Tips

### Optimize Queries
```dart
// ❌ Slow - Fetches all columns
await _client.from('notes').select();

// ✅ Fast - Only needed columns
await _client.from('notes').select('id, title, created_at');

// ❌ Slow - No limits
await _client.from('notes').select();

// ✅ Fast - With limits and pagination
await _client.from('notes')
    .select()
    .limit(20)
    .range(0, 19);
```

### Optimize UI
```dart
// ❌ Rebuilds whole list
ListView(children: [for (note in notes) NoteCard(note: note)])

// ✅ Efficient
ListView.builder(
  itemCount: notes.length,
  itemBuilder: (context, index) => NoteCard(note: notes[index]),
)
```

### Memory Management
```dart
// Always dispose controllers
@override
void dispose() {
  _titleController.dispose();
  _contentController.dispose();
  super.dispose();
}

// Cancel subscriptions
@override
void dispose() {
  _subscription?.cancel();
  super.dispose();
}
```

---

## Deployment Checklist

### Before Release
- [ ] Update app version in pubspec.yaml
- [ ] Remove debug print statements
- [ ] Test on real device
- [ ] Check RLS policies
- [ ] Verify error handling
- [ ] Check app icons (iOS + Android)
- [ ] Write app description & screenshots
- [ ] Create privacy policy & terms

### iOS App Store
```bash
# Build for iOS
flutter build ios --release

# Create archive in Xcode
# Upload using Transporter or Xcode
```

### Google Play Store
```bash
# Build App Bundle
flutter build appbundle --release

# Upload to Google Play Console
# build/app/outputs/bundle/release/app-release.aab
```

---

## Useful Resources

### Official Documentation
- Flutter: https://flutter.dev/docs
- Dart: https://dart.dev/guides
- Supabase: https://supabase.com/docs
- Riverpod: https://riverpod.dev

### Community
- Flutter Community: https://github.com/fluttercommunity
- Supabase Discord: https://discord.supabase.io
- Stack Overflow: [flutter] tag

### Tools
- Flutter DevTools: `flutter pub global activate devtools`
- Dart Analyzer: `dart analyze`
- Pub.dev: https://pub.dev (search packages)

---

## Version Numbers

As of May 2026:
- **Flutter**: 3.26.0+ (stable)
- **Dart**: 3.6.0+
- **Supabase Flutter**: 1.10.0+
- **Riverpod**: 2.4.0+
- **iOS**: 12.0+ (minimum)
- **Android**: API 21+ (minimum)

---

## Notes

- Always backup your Supabase database
- Use `.env` for sensitive keys (never commit to git)
- Test RLS policies thoroughly before production
- Monitor Supabase project for rate limits
- Keep dependencies updated regularly
- Use semantic versioning for your app
