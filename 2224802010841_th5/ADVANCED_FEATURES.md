# Advanced Features & Tips

## 1. Real-time Sync với Supabase Realtime

Đồng bộ ghi chú theo thời gian thực khi có thay đổi trên device khác:

### Setup Realtime

**lib/services/supabase_service.dart - Add Realtime:**
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;
  
  // Listen to changes in real-time
  static Stream<List<Note>> watchNotes() {
    return _client
        .from('notes')
        .on(
          RealtimeListenOptions(
            event: RealtimeListenEvent.all,
            schema: 'public',
          ),
          SupabaseStreamBuilder<List<Note>>(
            builder: (snapshot) {
              if (snapshot.hasData) {
                return (snapshot.data as List)
                    .map((json) => Note.fromJson(json as Map<String, dynamic>))
                    .toList();
              }
              return [];
            },
          ),
        )
        .asStream();
  }
}
```

### Riverpod Provider cho Realtime:
```dart
// lib/providers/notes_provider.dart
final notesRealtimeProvider = StreamProvider<List<Note>>((ref) {
  return SupabaseService.watchNotes();
});
```

---

## 2. Offline Support with Local Caching (Hive)

Cho phép users xem notes offline:

### Setup Hive

**pubspec.yaml:**
```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

**lib/services/hive_service.dart:**
```dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';

class HiveService {
  static const String notesBox = 'notes';
  
  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(notesBox);
  }
  
  // Save notes locally
  static Future<void> saveNotes(List<Note> notes) async {
    final box = Hive.box<Map>(notesBox);
    final notesMap = {
      for (var note in notes) note.id: note.toJson()
    };
    await box.putAll(notesMap);
  }
  
  // Get cached notes
  static List<Note> getCachedNotes() {
    final box = Hive.box<Map>(notesBox);
    return box.values
        .map((json) => Note.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }
  
  // Clear cache
  static Future<void> clearCache() async {
    final box = Hive.box<Map>(notesBox);
    await box.clear();
  }
  
  // Check if offline
  static bool isOffline() {
    // Implement connectivity check
    return false;
  }
}
```

**Update Notes Provider:**
```dart
final notesProvider = FutureProvider<List<Note>>((ref) async {
  try {
    final notes = await SupabaseService.fetchNotes();
    // Cache locally
    await HiveService.saveNotes(notes);
    return notes;
  } catch (e) {
    // Return cached data if offline
    return HiveService.getCachedNotes();
  }
});
```

---

## 3. Search & Filter

### Full-text Search

**lib/services/supabase_service.dart:**
```dart
static Future<List<Note>> searchNotes(String query) async {
  if (query.isEmpty) {
    return fetchNotes();
  }
  
  try {
    final response = await _client
        .from('notes')
        .select()
        .eq('is_deleted', false)
        .or('title.ilike.%$query%,content.ilike.%$query%')
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((json) => Note.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print('Search error: $e');
    rethrow;
  }
}

// Filter by deadline
static Future<List<Note>> getUpcomingNotes() async {
  try {
    final now = DateTime.now();
    final response = await _client
        .from('notes')
        .select()
        .eq('is_deleted', false)
        .gt('deadline', now.toIso8601String())
        .order('deadline', ascending: true);
    
    return (response as List)
        .map((json) => Note.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print('Upcoming notes error: $e');
    rethrow;
  }
}

// Get pinned notes
static Future<List<Note>> getPinnedNotes() async {
  try {
    final response = await _client
        .from('notes')
        .select()
        .eq('is_deleted', false)
        .eq('is_pinned', true)
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((json) => Note.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print('Pinned notes error: $e');
    rethrow;
  }
}
```

### Filter Providers:
```dart
// lib/providers/notes_provider.dart

// Search
final noteSearchProvider = FutureProvider.family<List<Note>, String>((ref, query) async {
  return SupabaseService.searchNotes(query);
});

// Upcoming deadlines
final upcomingNotesProvider = FutureProvider<List<Note>>((ref) async {
  return SupabaseService.getUpcomingNotes();
});

// Pinned
final pinnedNotesProvider = FutureProvider<List<Note>>((ref) async {
  return SupabaseService.getPinnedNotes();
});
```

---

## 4. Categories/Tags

### Add Categories Table

```sql
CREATE TABLE public.categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(50) NOT NULL,
  color VARCHAR(7) DEFAULT '#007AFF',
  icon VARCHAR(50),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, name)
);

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their categories"
  ON public.categories
  FOR ALL
  USING (auth.uid() = user_id);

-- Add category_id to notes
ALTER TABLE public.notes ADD COLUMN category_id UUID 
  REFERENCES public.categories(id) ON DELETE SET NULL;

CREATE INDEX idx_notes_category_id ON public.notes(category_id);
```

### Category Model:
```dart
// lib/models/category.dart
class Category {
  final String id;
  final String name;
  final String color;
  final String? icon;
  
  Category({
    required this.id,
    required this.name,
    this.color = '#007AFF',
    this.icon,
  });
  
  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'],
    name: json['name'],
    color: json['color'],
    icon: json['icon'],
  );
}
```

---

## 5. Rich Text Editing

Thêm formatting (bold, italic, underline):

### Setup markdown_flutter
```yaml
dependencies:
  markdown_flutter: ^0.1.2
  flutter_markdown: ^0.6.0
```

### Rich Editor Widget:
```dart
import 'package:flutter/cupertino.dart';

class RichTextEditor extends StatefulWidget {
  final TextEditingController controller;
  
  const RichTextEditor({required this.controller});

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Formatting toolbar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Bold
              CupertinoButton(
                onPressed: () => _applyStyle('**', '**'),
                child: const Text('B'),
              ),
              // Italic
              CupertinoButton(
                onPressed: () => _applyStyle('_', '_'),
                child: const Text('I'),
              ),
              // Underline
              CupertinoButton(
                onPressed: () => _applyStyle('__', '__'),
                child: const Text('U'),
              ),
            ],
          ),
        ),
        // Editor
        CupertinoTextField(
          controller: widget.controller,
          minLines: 10,
          maxLines: null,
          placeholder: 'Content',
        ),
      ],
    );
  }
  
  void _applyStyle(String start, String end) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    
    if (selection.start == selection.end) {
      return; // No text selected
    }
    
    final selectedText = text.substring(selection.start, selection.end);
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$start$selectedText$end',
    );
    
    widget.controller.text = newText;
  }
}
```

---

## 6. Image Support

Thêm hình ảnh vào ghi chú:

### Dependency:
```yaml
dependencies:
  image_picker: ^1.0.0
  image_cropper: ^5.0.0
```

### Image Service:
```dart
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class ImageService {
  static final _picker = ImagePicker();
  static final _supabase = Supabase.instance.client;
  
  // Pick image
  static Future<File?> pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  }
  
  // Upload to Supabase Storage
  static Future<String> uploadImage(File file, String noteId) async {
    try {
      final fileName = '${noteId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      await _supabase.storage.from('note_images').upload(
        'public/$fileName',
        file,
        fileOptions: const FileOptions(cacheControl: '3600'),
      );
      
      final publicUrl = _supabase.storage
          .from('note_images')
          .getPublicUrl('public/$fileName');
      
      return publicUrl;
    } catch (e) {
      print('Upload error: $e');
      rethrow;
    }
  }
}
```

### Update Note Model:
```dart
class Note {
  // ... existing fields
  final List<String>? imageUrls;
  
  Note({
    // ... existing params
    this.imageUrls,
  });
}
```

---

## 7. Notifications & Reminders

Remind users tentang deadlines:

### Setup Firebase Cloud Messaging
```yaml
dependencies:
  firebase_messaging: ^14.0.0
  flutter_local_notifications: ^16.0.0
```

### Notification Service:
```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  
  static Future<void> init() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    
    const initializationSettingsIOS = DarwinInitializationSettings();
    
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _localNotifications.initialize(initializationSettings);
  }
  
  // Schedule reminder
  static Future<void> scheduleReminder({
    required int id,
    required String title,
    required DateTime scheduledTime,
  }) async {
    await _localNotifications.zonedSchedule(
      id,
      'Deadline Reminder',
      title,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        iOS: DarwinNotificationDetails(),
        android: AndroidNotificationDetails(
          'notes_channel',
          'Notes Reminders',
        ),
      ),
      uiLocalNotificationDateInterpretationMethod:
          UILocalNotificationDateInterpretationMethod.absoluteTime,
      matchGeometryCallback: true,
    );
  }
  
  // Cancel reminder
  static Future<void> cancelReminder(int id) async {
    await _localNotifications.cancel(id);
  }
}
```

---

## 8. Data Export/Backup

Export ghi chú sang PDF hoặc JSON:

### PDF Export:
```yaml
dependencies:
  pdf: ^3.10.0
  printing: ^5.10.0
```

```dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExportService {
  static Future<void> exportToPdf(List<Note> notes) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('My Notes', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            ...notes.map((note) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(note.title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text(note.content),
                pw.SizedBox(height: 10),
              ],
            )),
          ],
        ),
      ),
    );
    
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
```

### JSON Export:
```dart
class ExportService {
  static Future<void> exportToJson(List<Note> notes) async {
    final jsonData = notes.map((note) => note.toJson()).toList();
    final jsonString = jsonEncode(jsonData);
    
    // Save to file atau share
    // Use: share_plus package
  }
}
```

---

## 9. Performance Optimization

### Pagination
```dart
// Fetch notes with pagination
static Future<List<Note>> fetchNotesPaginated({
  required int page,
  int pageSize = 20,
}) async {
  final start = (page - 1) * pageSize;
  final end = start + pageSize;
  
  try {
    final response = await _client
        .from('notes')
        .select()
        .eq('is_deleted', false)
        .order('created_at', ascending: false)
        .range(start, end);
    
    return (response as List)
        .map((json) => Note.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    rethrow;
  }
}
```

### Lazy Loading
```dart
// Riverpod pagination provider
final notesPageProvider = FutureProvider.family<List<Note>, int>((ref, page) {
  return SupabaseService.fetchNotesPaginated(page: page);
});
```

### Image Optimization
```dart
// Compress before upload
import 'package:image/image.dart' as img;

Future<File> compressImage(File imageFile) async {
  final image = img.decodeImage(await imageFile.readAsBytes());
  final compressed = img.encodeJpg(image!, quality: 80);
  return File(imageFile.path)..writeAsBytesSync(compressed);
}
```

---

## 10. Dark Mode Support

### Implement Dark Mode
```dart
// lib/constants/colors.dart
class AppColors {
  // Light mode
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF000000);
  
  // Dark mode
  static const Color darkBackground = Color(0xFF1C1C1E);
  static const Color darkText = Color(0xFFFFFFFF);
}

// Use CupertinoTheme
CupertinoApp(
  theme: const CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFF007AFF),
  ),
  // ...
)
```

---

## 11. Testing

### Unit Tests
```bash
flutter test
```

```dart
// test/models/note_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/models/note.dart';

void main() {
  group('Note Model', () {
    test('Note.toJson should convert Note to Map', () {
      final note = Note(
        title: 'Test',
        content: 'Test content',
      );
      
      final json = note.toJson();
      
      expect(json['title'], 'Test');
      expect(json['content'], 'Test content');
    });
    
    test('Note.fromJson should create Note from Map', () {
      final json = {
        'id': '123',
        'title': 'Test',
        'content': 'Test content',
        'created_at': DateTime.now().toIso8601String(),
        'is_pinned': false,
      };
      
      final note = Note.fromJson(json);
      
      expect(note.title, 'Test');
      expect(note.content, 'Test content');
    });
  });
}
```

### Widget Tests
```dart
// test/widgets/note_card_test.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/widgets/note_card.dart';

void main() {
  testWidgets('NoteCard displays note information', (WidgetTester tester) async {
    final note = Note(
      title: 'Test Note',
      content: 'Test content',
    );
    
    await tester.pumpWidget(
      CupertinoApp(
        home: NoteCard(note: note),
      ),
    );
    
    expect(find.text('Test Note'), findsOneWidget);
    expect(find.text('Test content'), findsOneWidget);
  });
}
```

---

## Key Takeaways

| Feature | Priority | Complexity |
|---------|----------|-----------|
| Basic CRUD | High | Low |
| Real-time Sync | High | Medium |
| Offline Support | High | Medium |
| Search/Filter | Medium | Low |
| Categories | Medium | Medium |
| Rich Text | Medium | Medium |
| Images | Medium | High |
| Notifications | Low | High |
| Export | Low | Medium |
| Dark Mode | Low | Low |

**Recommended Implementation Order:**
1. Basic CRUD
2. Search/Filter
3. Categories
4. Offline Support
5. Real-time Sync
6. Images
7. Rich Text
8. Notifications
9. Export
10. Dark Mode
