# Hướng dẫn Xây dựng Ứng dụng Ghi chú Flutter

## 📋 Mục lục
1. [Thiết lập Supabase](#thiết-lập-supabase)
2. [Kiến trúc Ứng dụng](#kiến-trúc-ứng-dụng)
3. [Hướng dẫn Cài đặt Flutter](#hướng-dẫn-cài-đặt-flutter)
4. [Các Tính năng Chính](#các-tính-năng-chính)
5. [Dependency và Package](#dependency-và-package)
6. [Best Practices](#best-practices)

---

## Thiết lập Supabase

### Bước 1: Tạo Supabase Project
1. Truy cập https://supabase.com
2. Tạo tài khoản & project mới
3. Lưu lại **Supabase URL** và **Anon Key** (sẽ dùng trong Flutter)

### Bước 2: Tạo Database Schema

Chạy các SQL query sau trong Supabase SQL Editor:

```sql
-- Tạo bảng notes
CREATE TABLE notes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  deadline TIMESTAMP WITH TIME ZONE,
  is_pinned BOOLEAN DEFAULT FALSE,
  is_deleted BOOLEAN DEFAULT FALSE
);

-- Tạo index cho tìm kiếm nhanh
CREATE INDEX idx_notes_user_id ON notes(user_id);
CREATE INDEX idx_notes_created_at ON notes(created_at DESC);
CREATE INDEX idx_notes_deadline ON notes(deadline);

-- Bật Row Level Security (RLS)
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

-- Policy: Users chỉ có thể xem ghi chú của mình
CREATE POLICY "Users can view their own notes"
  ON notes FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users chỉ có thể chèn ghi chú của mình
CREATE POLICY "Users can insert their own notes"
  ON notes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users chỉ có thể cập nhật ghi chú của mình
CREATE POLICY "Users can update their own notes"
  ON notes FOR UPDATE
  USING (auth.uid() = user_id);

-- Policy: Users chỉ có thể xóa ghi chú của mình
CREATE POLICY "Users can delete their own notes"
  ON notes FOR DELETE
  USING (auth.uid() = user_id);
```

### Bước 3: Tạo Bảng Danh mục (Tùy chọn)

```sql
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  color VARCHAR(7) DEFAULT '#007AFF',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their categories"
  ON categories
  USING (auth.uid() = user_id);
```

---

## Kiến trúc Ứng dụng

### Cấu trúc Thư mục Khuyến nghị

```
lib/
├── main.dart
├── models/
│   ├── note.dart
│   ├── category.dart
│   └── user.dart
├── providers/
│   ├── auth_provider.dart
│   ├── notes_provider.dart
│   └── settings_provider.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── splash_screen.dart
│   ├── notes/
│   │   ├── notes_list_screen.dart
│   │   ├── add_note_screen.dart
│   │   ├── edit_note_screen.dart
│   │   └── note_detail_screen.dart
│   └── settings/
│       └── settings_screen.dart
├── services/
│   ├── supabase_service.dart
│   ├── auth_service.dart
│   └── notes_service.dart
├── widgets/
│   ├── note_card.dart
│   ├── swipeable_note.dart
│   ├── custom_app_bar.dart
│   └── note_list_empty.dart
├── constants/
│   ├── colors.dart
│   └── strings.dart
└── utils/
    ├── date_formatter.dart
    └── validators.dart
```

---

## Hướng dẫn Cài đặt Flutter

### Bước 1: Cài đặt Flutter SDK
```bash
# macOS
brew install flutter

# Linux/Windows: Tải từ https://flutter.dev/docs/get-started/install
```

### Bước 2: Tạo Project Flutter
```bash
flutter create notes_app --org com.example
cd notes_app
```

### Bước 3: Cài đặt Dependencies

Thêm vào `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Supabase
  supabase_flutter: ^1.10.0
  
  # State Management
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
  
  # UI & Animations
  cupertino_icons: ^1.0.2
  flutter_slidable: ^3.0.0  # Swipe gesture
  intl: ^0.19.0  # Date formatting
  
  # Storage & Cache
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Utilities
  uuid: ^4.0.0
  timeago: ^3.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
```

Cài đặt:
```bash
flutter pub get
```

---

## Các Tính năng Chính

### 1. Models

**lib/models/note.dart**
```dart
import 'package:uuid/uuid.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? deadline;
  final bool isPinned;
  final String? category;

  Note({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    this.deadline,
    this.isPinned = false,
    this.category,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // Convert to JSON (lưu vào Supabase)
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'created_at': createdAt.toIso8601String(),
    'deadline': deadline?.toIso8601String(),
    'is_pinned': isPinned,
    'category': category,
  };

  // Tạo từ JSON (nhận từ Supabase)
  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    createdAt: DateTime.parse(json['created_at']),
    deadline: json['deadline'] != null 
      ? DateTime.parse(json['deadline']) 
      : null,
    isPinned: json['is_pinned'] ?? false,
    category: json['category'],
  );

  // Copy with để cập nhật một số field
  Note copyWith({
    String? title,
    String? content,
    DateTime? deadline,
    bool? isPinned,
    String? category,
  }) => Note(
    id: id,
    title: title ?? this.title,
    content: content ?? this.content,
    createdAt: createdAt,
    deadline: deadline ?? this.deadline,
    isPinned: isPinned ?? this.isPinned,
    category: category ?? this.category,
  );
}
```

### 2. Supabase Service

**lib/services/supabase_service.dart**
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Lấy tất cả ghi chú của user
  static Future<List<Note>> fetchNotes() async {
    try {
      final response = await _client
          .from('notes')
          .select()
          .eq('is_deleted', false)
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Note.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Lỗi fetch notes: $e');
      rethrow;
    }
  }

  // Tạo ghi chú mới
  static Future<Note> createNote(Note note) async {
    try {
      await _client.from('notes').insert(note.toJson());
      return note;
    } catch (e) {
      print('Lỗi tạo note: $e');
      rethrow;
    }
  }

  // Cập nhật ghi chú
  static Future<void> updateNote(Note note) async {
    try {
      await _client
          .from('notes')
          .update(note.toJson())
          .eq('id', note.id);
    } catch (e) {
      print('Lỗi update note: $e');
      rethrow;
    }
  }

  // Xóa ghi chú (soft delete)
  static Future<void> deleteNote(String noteId) async {
    try {
      await _client
          .from('notes')
          .update({'is_deleted': true})
          .eq('id', noteId);
    } catch (e) {
      print('Lỗi xóa note: $e');
      rethrow;
    }
  }

  // Tìm kiếm ghi chú
  static Future<List<Note>> searchNotes(String query) async {
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
      print('Lỗi tìm kiếm: $e');
      rethrow;
    }
  }
}
```

### 3. State Management với Riverpod

**lib/providers/notes_provider.dart**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../services/supabase_service.dart';

// Provider lấy danh sách ghi chú
final notesProvider = FutureProvider<List<Note>>((ref) async {
  return SupabaseService.fetchNotes();
});

// Provider quản lý việc thêm ghi chú
final noteAddProvider = FutureProvider.family<Note, Note>((ref, note) async {
  final newNote = await SupabaseService.createNote(note);
  // Refresh danh sách sau khi thêm
  ref.refresh(notesProvider);
  return newNote;
});

// Provider quản lý việc cập nhật ghi chú
final noteUpdateProvider = FutureProvider.family<void, Note>((ref, note) async {
  await SupabaseService.updateNote(note);
  ref.refresh(notesProvider);
});

// Provider quản lý việc xóa ghi chú
final noteDeleteProvider = FutureProvider.family<void, String>((ref, noteId) async {
  await SupabaseService.deleteNote(noteId);
  ref.refresh(notesProvider);
});

// Provider tìm kiếm
final noteSearchProvider = FutureProvider.family<List<Note>, String>((ref, query) async {
  if (query.isEmpty) {
    return ref.watch(notesProvider).value ?? [];
  }
  return SupabaseService.searchNotes(query);
});
```

### 4. Notes List Screen

**lib/screens/notes/notes_list_screen.dart**
```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/note.dart';
import '../../providers/notes_provider.dart';
import '../../widgets/note_card.dart';
import '../../widgets/swipeable_note.dart';
import 'add_note_screen.dart';
import 'edit_note_screen.dart';

class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Notes'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => const AddNoteScreen(),
              ),
            );
          },
          child: const Icon(CupertinoIcons.plus),
        ),
      ),
      child: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.doc_text,
                    size: 64,
                    color: CupertinoColors.systemGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notes yet',
                    style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first note',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              CupertinoSliverRefreshControl(
                onRefresh: () => ref.refresh(notesProvider.future),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => SwipeableNote(
                    note: notes[index],
                    onDelete: (note) {
                      _showDeleteConfirmation(context, ref, note);
                    },
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => EditNoteScreen(note: notes[index]),
                        ),
                      );
                    },
                  ),
                  childCount: notes.length,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CupertinoActivityIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Note?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              ref.read(noteDeleteProvider(note.id));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
```

### 5. Add Note Screen

**lib/screens/notes/add_note_screen.dart**
```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/note.dart';
import '../../providers/notes_provider.dart';

class AddNoteScreen extends ConsumerStatefulWidget {
  const AddNoteScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends ConsumerState<AddNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  DateTime? _deadline;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty) {
      _showError('Please enter a title');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final note = Note(
        title: _titleController.text,
        content: _contentController.text,
        deadline: _deadline,
      );

      await ref.read(noteAddProvider(note).future);
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Failed to save note: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('New Note'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isLoading ? null : _saveNote,
          child: _isLoading
              ? const CupertinoActivityIndicator()
              : const Text('Save'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title field
            CupertinoTextField(
              controller: _titleController,
              placeholder: 'Title',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            const SizedBox(height: 16),
            // Content field
            CupertinoTextField(
              controller: _contentController,
              placeholder: 'Content',
              minLines: 10,
              maxLines: null,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            const SizedBox(height: 16),
            // Deadline picker
            GestureDetector(
              onTap: () => _selectDeadline(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _deadline != null
                          ? 'Deadline: ${_deadline?.toString().split(' ')[0]}'
                          : 'Set deadline (optional)',
                      style: TextStyle(
                        color: _deadline != null
                            ? CupertinoColors.black
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                    const Icon(CupertinoIcons.calendar),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDeadline() async {
    final now = DateTime.now();
    final picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (context) => CupertinoDatePicker(
        mode: CupertinoDatePickerMode.dateAndTime,
        initialDateTime: _deadline ?? now,
        minimumDate: now,
        onDateTimeChanged: (DateTime value) {
          setState(() => _deadline = value);
        },
      ),
    );

    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }
}
```

### 6. Swipeable Note Widget

**lib/widgets/swipeable_note.dart**
```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/note.dart';
import 'note_card.dart';

class SwipeableNote extends StatelessWidget {
  final Note note;
  final Function(Note) onDelete;
  final VoidCallback? onTap;

  const SwipeableNote({
    Key? key,
    required this.note,
    required this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: Key(note.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(note),
            backgroundColor: CupertinoColors.systemRed,
            foregroundColor: CupertinoColors.white,
            icon: CupertinoIcons.trash,
            label: 'Delete',
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: NoteCard(note: note),
      ),
    );
  }
}
```

### 7. Note Card Widget

**lib/widgets/note_card.dart**
```dart
import 'package:flutter/cupertino.dart';
import '../models/note.dart';
import '../utils/date_formatter.dart';

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemGrey4,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            note.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // Content preview
          Text(
            note.content,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Footer: created date + deadline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatter.formatCreatedDate(note.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              if (note.deadline != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    DateFormatter.formatDeadline(note.deadline!),
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## Best Practices

### 1. Authentication Flow
```dart
// Sử dụng Supabase Auth
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> signUp(String email, String password) async {
  try {
    await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
  } catch (e) {
    print('Sign up error: $e');
  }
}

Future<void> signIn(String email, String password) async {
  try {
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  } catch (e) {
    print('Sign in error: $e');
  }
}
```

### 2. Error Handling
- Luôn sử dụng try-catch trong các async functions
- Hiển thị user-friendly error messages
- Log lỗi để debugging

### 3. Performance
- Sử dụng `flutter_riverpod` để quản lý state hiệu quả
- Implement pagination cho danh sách dài
- Cache dữ liệu cục bộ với Hive

### 4. iOS Design Pattern
- Sử dụng CupertinoPageScaffold thay vì Scaffold
- CupertinoNavigationBar thay vì AppBar
- CupertinoButton, CupertinoAlertDialog cho consistent iOS feel

### 5. Testing
```bash
# Chạy tests
flutter test

# Build iOS
flutter build ios

# Run trên simulator
open -a Simulator
flutter run -d "iPhone 15 Pro"
```

---

## Tài liệu Tham khảo

- **Flutter Docs**: https://flutter.dev/docs
- **Supabase Flutter**: https://supabase.com/docs/reference/flutter/introduction
- **Riverpod**: https://riverpod.dev
- **Cupertino Widgets**: https://flutter.dev/docs/development/ui/widgets/cupertino

---

## Tổng Kết

Bạn đã có đủ thông tin để xây dựng ứng dụng ghi chú hoàn chỉnh:

1. **Database**: Schema Supabase đã được thiết lập
2. **Models**: Note model với serialization
3. **Services**: Supabase service cho CRUD operations
4. **UI**: Giao diện iOS-style với Flutter Cupertino
5. **State Management**: Riverpod providers cho quản lý state

**Bước tiếp theo:**
- Cài đặt Flutter SDK
- Tạo Supabase project & chạy SQL migrations
- Setup authentication (email/password hoặc OAuth)
- Implement các screens theo hướng dẫn
- Test trên iOS simulator hoặc device thực
