# Flutter Notes App - Complete Development Guide

Bộ hướng dẫn **hoàn chỉnh** để xây dựng ứng dụng ghi chú cá nhân với **Flutter** (giao diện iOS) và **Supabase** backend.

## 📱 Tính năng Chính

✅ **Danh sách ghi chú** - Hiển thị tiêu đề, nội dung, thời gian, deadline  
✅ **Thêm ghi chú** - Nhập tiêu đề + nội dung, lưu vào database  
✅ **Chỉnh sửa ghi chú** - Nhấn vào ghi chú để sửa, cập nhật trên server  
✅ **Xóa ghi chú** - Vuốt (swipe) để xóa với xác nhận  
✅ **Giao diện iOS** - Sử dụng Cupertino widgets cho native iOS look  
✅ **Backend Supabase** - PostgreSQL + Authentication + RLS  

## 📚 Tài liệu Hướng dẫn

| File | Nội dung |
|------|----------|
| **FLUTTER_NOTES_APP_GUIDE.md** | 📖 **Hướng dẫn chính** - Kiến trúc, models, services, screens, code examples |
| **SETUP_GUIDE.md** | 🔧 **Hướng dẫn cài đặt** - Từng bước cài Flutter, Supabase, database schema |
| **ADVANCED_FEATURES.md** | 🚀 **Tính năng nâng cao** - Real-time sync, offline, search, notifications, export |
| **QUICK_REFERENCE.md** | ⚡ **Tham khảo nhanh** - Commands, packages, snippets, debugging |

## 🚀 Bắt đầu Nhanh

### 1. Cài đặt Flutter
```bash
# macOS
brew install flutter

# Linux/Windows: https://flutter.dev/docs/get-started/install
flutter doctor  # Kiểm tra cài đặt
```

### 2. Tạo Project
```bash
flutter create --org com.example.notesapp notes_app
cd notes_app
```

### 3. Setup Supabase
1. Truy cập https://supabase.com
2. Tạo project mới
3. Chạy SQL migrations từ **SETUP_GUIDE.md**
4. Lưu lại **Project URL** và **Anon Key**

### 4. Cài Dependencies
```yaml
# pubspec.yaml - Copy từ QUICK_REFERENCE.md
flutter pub get
```

### 5. Khởi tạo Supabase trong main.dart
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_ANON_KEY',
  );
  
  runApp(const MyApp());
}
```

### 6. Chạy ứng dụng
```bash
flutter run
# Hoặc chỉ định device: flutter run -d "iPhone 15 Pro"
```

## 📁 Project Structure

```
lib/
├── main.dart                 # Entry point
├── models/
│   ├── note.dart            # Note data model
│   └── user.dart            # User model
├── providers/
│   ├── auth_provider.dart   # Authentication (Riverpod)
│   └── notes_provider.dart  # Notes state management
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   └── notes/
│       ├── notes_list_screen.dart
│       ├── add_note_screen.dart
│       ├── edit_note_screen.dart
│       └── note_detail_screen.dart
├── services/
│   ├── supabase_service.dart    # Database operations
│   ├── auth_service.dart        # Authentication logic
│   └── hive_service.dart        # Local cache
├── widgets/
│   ├── note_card.dart
│   ├── swipeable_note.dart
│   └── custom_app_bar.dart
├── constants/
│   ├── colors.dart
│   └── strings.dart
└── utils/
    ├── date_formatter.dart
    └── validators.dart
```

## 🏗️ Kiến trúc Ứng dụng

### Model-View-Provider Pattern
```
┌─────────────────────────────────────────────┐
│         UI Screens (CupertinoPageScaffold)  │
│  • notes_list_screen.dart                   │
│  • add_note_screen.dart                     │
│  • edit_note_screen.dart                    │
└────────────────────┬────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────┐
│     Riverpod Providers (State Management)   │
│  • notesProvider                            │
│  • noteAddProvider                          │
│  • noteUpdateProvider                       │
│  • noteDeleteProvider                       │
└────────────────────┬────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────┐
│       Services (Business Logic)             │
│  • SupabaseService.fetchNotes()             │
│  • SupabaseService.createNote()             │
│  • SupabaseService.updateNote()             │
│  • SupabaseService.deleteNote()             │
└────────────────────┬────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────┐
│       Supabase Backend (Database)           │
│  • PostgreSQL Database                      │
│  • Row Level Security (RLS)                 │
│  • Real-time Subscriptions                  │
│  • Authentication                           │
└─────────────────────────────────────────────┘
```

## 📊 Database Schema

```sql
-- Bảng notes
CREATE TABLE public.notes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  deadline TIMESTAMP WITH TIME ZONE,
  is_pinned BOOLEAN DEFAULT FALSE,
  is_deleted BOOLEAN DEFAULT FALSE
);

-- RLS Policies (Users chỉ xem ghi chú của mình)
CREATE POLICY "Users can select their own notes"
  ON public.notes FOR SELECT
  USING (auth.uid() = user_id);
```

## 🔑 Key Classes & Functions

### Note Model
```dart
class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? deadline;
  final bool isPinned;
  
  Note.toJson()      // Convert to JSON
  Note.fromJson()    // Create from JSON
  Note.copyWith()    // Update fields
}
```

### SupabaseService
```dart
// Fetch all notes
List<Note> notes = await SupabaseService.fetchNotes();

// Create note
await SupabaseService.createNote(note);

// Update note
await SupabaseService.updateNote(note);

// Delete note
await SupabaseService.deleteNote(noteId);

// Search
List<Note> results = await SupabaseService.searchNotes(query);
```

### Riverpod Providers
```dart
// Get all notes
final notesAsync = ref.watch(notesProvider);

// Add new note (auto refresh list)
await ref.read(noteAddProvider(note).future);

// Update note
await ref.read(noteUpdateProvider(note).future);

// Delete note
await ref.read(noteDeleteProvider(noteId).future);
```

## 🎯 Development Workflow

### Day 1-2: Setup & Basics
- ✅ Install Flutter SDK
- ✅ Create Supabase project
- ✅ Create Flutter project
- ✅ Setup database schema
- ✅ Implement Note model
- ✅ Implement SupabaseService (CRUD)
- ✅ Test database connection

### Day 3-4: Core UI
- ✅ Implement NotesListScreen
- ✅ Implement AddNoteScreen  
- ✅ Implement EditNoteScreen
- ✅ Implement SwipeableNote widget
- ✅ Wire up providers
- ✅ Test basic CRUD operations

### Day 5-6: Polish & Features
- ✅ Add search & filter
- ✅ Add deadline handling
- ✅ Add offline support (Hive)
- ✅ Test error handling
- ✅ Optimize performance

### Day 7: Testing & Deployment
- ✅ Write unit tests
- ✅ Write widget tests
- ✅ Test on real device
- ✅ Prepare for App Store/Play Store

## 📱 Testing & Debugging

### Run App
```bash
# Development
flutter run

# Release mode (performance)
flutter run --release

# With specific device
flutter run -d "device-id"
```

### Debug Tools
```bash
# View logs
flutter logs

# Analyze code
flutter analyze

# Format code
dart format lib/

# Check dependencies
flutter pub outdated
```

### Supabase Testing
```bash
# In Supabase Console:
# 1. Open SQL Editor
# 2. Test your queries
# 3. Check RLS policies
# 4. View logs

SELECT * FROM public.notes;  -- Should work for authenticated user
```

## 🚀 Deployment

### iOS App Store
```bash
# Build for iOS
flutter build ios --release

# Follow Xcode/Transporter to upload
```

### Google Play Store
```bash
# Build App Bundle
flutter build appbundle --release

# Upload to Google Play Console
```

## 🔒 Security Best Practices

✅ **Always enable Row Level Security (RLS)** - Users chỉ access ghi chú của mình  
✅ **Use ANON_KEY for client app** - Không bao giờ expose SERVICE_ROLE_KEY  
✅ **Validate input** - Trim, validate email, check deadlines  
✅ **Hash passwords** - Supabase Auth tự động hash  
✅ **Use HTTPS** - Supabase tự động HTTPS  
✅ **Limit API calls** - Implement rate limiting nếu cần  

## 📈 Performance Tips

| Optimization | Benefit |
|--------------|---------|
| Pagination | Reduce data transfer |
| Indexes | Faster queries |
| Caching (Hive) | Offline support |
| Lazy loading | Better UX |
| Image compression | Reduce storage |

## 🐛 Common Issues & Solutions

### "Xcode build failed"
```bash
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
flutter run
```

### "Permission denied for table"
- Check RLS policies in Supabase
- Verify `user_id` matches `auth.uid()`
- Test query: `SELECT auth.uid();`

### "Supabase connection failed"
- Verify URL and ANON_KEY
- Check internet connection
- Check Supabase project status

## 📚 Resources

### Official Docs
- **Flutter**: https://flutter.dev/docs
- **Dart**: https://dart.dev
- **Supabase**: https://supabase.com/docs
- **Riverpod**: https://riverpod.dev

### Community
- **Flutter Community**: https://github.com/fluttercommunity
- **Supabase Discord**: https://discord.supabase.io
- **Stack Overflow**: `[flutter]` tag

### Tools
- **Pub.dev**: https://pub.dev (package search)
- **Dart Analyzer**: `dart analyze`
- **Flutter DevTools**: `flutter pub global activate devtools`

## 💡 Next Steps After MVP

1. **Real-time Sync** - Implement Supabase Realtime for live updates
2. **Offline Support** - Add Hive caching layer
3. **Search & Filter** - Full-text search, categories, tags
4. **Rich Text** - Bold, italic, underline formatting
5. **Images** - Upload & store images in notes
6. **Notifications** - Remind users about deadlines
7. **Export** - PDF/JSON export functionality
8. **Dark Mode** - Support system dark mode
9. **Collaboration** - Share notes with other users
10. **Cloud Backup** - Automatic backup & sync

## 📞 Support

Nếu gặp vấn đề:
1. Kiểm tra **QUICK_REFERENCE.md** - Troubleshooting section
2. Xem **FLUTTER_NOTES_APP_GUIDE.md** - Code examples
3. Check Supabase logs trong Console
4. Search Stack Overflow hoặc Flutter Community

## 📋 Checklist Hoàn Thành

### Phase 1: Setup
- [ ] Flutter SDK cài đặt
- [ ] Supabase project tạo
- [ ] Database schema tạo
- [ ] Flutter project tạo
- [ ] Dependencies cài đặt

### Phase 2: Core Features
- [ ] Note model implement
- [ ] SupabaseService implement
- [ ] NotesListScreen implement
- [ ] AddNoteScreen implement
- [ ] EditNoteScreen implement
- [ ] CRUD operations test

### Phase 3: Polish
- [ ] Swipe to delete
- [ ] Error handling
- [ ] Loading states
- [ ] Search & filter
- [ ] Offline caching
- [ ] UI improvements

### Phase 4: Testing & Release
- [ ] Unit tests
- [ ] Widget tests
- [ ] Test on real device
- [ ] Prepare app store
- [ ] Create screenshots
- [ ] Write description

## 📄 License

Dự án này là cho mục đích học tập. Tự do sử dụng, sửa đổi theo nhu cầu.

---

## 📝 Tổng Kết

Bạn có đầy đủ tài liệu để:
1. **Hiểu kiến trúc** - Models, Services, Providers, Screens
2. **Setup backend** - Supabase schema, RLS, queries
3. **Xây dựng UI** - iOS-style Flutter components
4. **Quản lý state** - Riverpod providers
5. **Deploy** - App Store / Play Store

**Lời khuyên cuối cùng:**
- Start simple (basic CRUD)
- Test thường xuyên
- Commit code regularly
- Follow Flutter best practices
- Hỏi khi không hiểu

**Good luck! 🚀**

Bất kỳ câu hỏi nào, hãy tham khảo các file hướng dẫn chi tiết hoặc tìm kiếm trên:
- https://flutter.dev
- https://supabase.com
- https://pub.dev
- https://stackoverflow.com (tag: `[flutter]`)
