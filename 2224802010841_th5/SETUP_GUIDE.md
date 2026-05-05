# Hướng dẫn Cài đặt Chi tiết

## Phase 1: Chuẩn bị

### 1.1 Cài đặt Flutter SDK

#### macOS
```bash
# Sử dụng Homebrew (khuyến khích)
brew install flutter

# Hoặc cài đặt thủ công từ https://flutter.dev/docs/get-started/install/macos
# Sau đó thêm vào PATH:
export PATH="$PATH:/path/to/flutter/bin"
```

#### Windows
1. Tải Flutter SDK từ: https://flutter.dev/docs/get-started/install/windows
2. Extract vào folder (vd: `C:\dev\flutter`)
3. Thêm vào Environment Variables:
   - `Path`: `C:\dev\flutter\bin`

#### Linux
```bash
sudo apt-get update
sudo apt-get install git curl bash xz-utils zip libglu1-mesa
cd ~
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:~/flutter/bin"
```

### 1.2 Kiểm tra cài đặt
```bash
flutter doctor

# Output mong đợi:
# ✓ Flutter (version X.X.X)
# ✓ Dart
# ✓ iOS toolchain
# ✓ Xcode
# ✓ Android toolchain (nếu cần)
```

---

## Phase 2: Tạo Project Flutter

### 2.1 Tạo project mới
```bash
# Cách 1: Với organization
flutter create --org com.example.notesapp notes_app
cd notes_app

# Cách 2: Với iOS + Android
flutter create --platforms ios,android notes_app
cd notes_app
```

### 2.2 Project structure
```
notes_app/
├── android/           # Native Android code
├── ios/               # Native iOS code
├── lib/
│   └── main.dart      # Entry point
├── test/              # Unit tests
├── pubspec.yaml       # Dependencies
└── pubspec.lock       # Lock file
```

---

## Phase 3: Setup Supabase

### 3.1 Tạo Supabase Project
1. Truy cập https://supabase.com
2. Đăng ký tài khoản
3. Click **"New Project"**
4. Chọn region (gần nhất với bạn)
5. Lưu lại:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **Anon Key**: `eyJ...` (public key)
   - **Service Role Key**: (private key - không share)

### 3.2 SQL Migrations - Chạy lần lượt

#### Step 1: Enable UUID extension
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

#### Step 2: Tạo bảng notes
```sql
CREATE TABLE public.notes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  deadline TIMESTAMP WITH TIME ZONE,
  is_pinned BOOLEAN DEFAULT FALSE,
  is_archived BOOLEAN DEFAULT FALSE,
  is_deleted BOOLEAN DEFAULT FALSE
);
```

#### Step 3: Tạo indexes
```sql
CREATE INDEX idx_notes_user_id ON public.notes(user_id);
CREATE INDEX idx_notes_created_at ON public.notes(created_at DESC);
CREATE INDEX idx_notes_deadline ON public.notes(deadline);
CREATE INDEX idx_notes_updated_at ON public.notes(updated_at DESC);
```

#### Step 4: Enable RLS
```sql
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;
```

#### Step 5: Tạo RLS Policies

**Policy 1: SELECT - Users xem ghi chú của mình**
```sql
CREATE POLICY "Users can select their own notes"
  ON public.notes
  FOR SELECT
  USING (auth.uid() = user_id);
```

**Policy 2: INSERT - Users tạo ghi chú của mình**
```sql
CREATE POLICY "Users can insert their own notes"
  ON public.notes
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

**Policy 3: UPDATE - Users cập nhật ghi chú của mình**
```sql
CREATE POLICY "Users can update their own notes"
  ON public.notes
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

**Policy 4: DELETE - Users xóa ghi chú của mình**
```sql
CREATE POLICY "Users can delete their own notes"
  ON public.notes
  FOR DELETE
  USING (auth.uid() = user_id);
```

### 3.3 Kiểm tra RLS policies
```sql
-- Xem tất cả policies
SELECT * FROM pg_policies 
WHERE tablename = 'notes';

-- Test query với RLS
SELECT * FROM public.notes;
```

---

## Phase 4: Setup Flutter Project với Supabase

### 4.1 Cài đặt Supabase Flutter package

**pubspec.yaml:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^1.10.0
  flutter_riverpod: ^2.4.0
  riverpod: ^2.4.0
  flutter_slidable: ^3.0.0
  intl: ^0.19.0
  timeago: ^3.4.0
  uuid: ^4.0.0
```

```bash
flutter pub get
```

### 4.2 Khởi tạo Supabase trong main.dart

```dart
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://YOUR_SUPABASE_URL.supabase.co',
    anonKey: 'YOUR_ANON_KEY',
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Notes App',
      theme: const CupertinoThemeData(
        primaryColor: Color(0xFF007AFF), // iOS blue
      ),
      home: const SplashScreen(),
    );
  }
}
```

### 4.3 Environment Variables (tùy chọn - Best Practice)

**Create `.env` file:**
```
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

**Use dengan flutter_dotenv:**
```bash
flutter pub add flutter_dotenv
```

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  runApp(const ProviderScope(child: MyApp()));
}
```

---

## Phase 5: Authentication Setup

### 5.1 Tạo Auth Service

**lib/services/auth_service.dart:**
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _supabase = Supabase.instance.client;
  
  // Sign Up
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Sign In
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign Out
  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get Current User
  static User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Listen to auth changes
  static Stream<AuthState> authStateStream() {
    return _supabase.auth.onAuthStateChange;
  }

  // Reset Password
  static Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
```

### 5.2 Auth Provider (Riverpod)

**lib/providers/auth_provider.dart:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

// Current user provider
final currentUserProvider = StreamProvider<User?>((ref) {
  return AuthService.authStateStream().map((state) => state.session?.user);
});

// Auth state provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  return AuthService.authStateStream();
});

// Sign in provider
final signInProvider = FutureProvider.family<void, ({String email, String password})>(
  (ref, params) async {
    await AuthService.signIn(
      email: params.email,
      password: params.password,
    );
  },
);

// Sign up provider
final signUpProvider = FutureProvider.family<void, ({String email, String password})>(
  (ref, params) async {
    await AuthService.signUp(
      email: params.email,
      password: params.password,
    );
  },
);

// Sign out provider
final signOutProvider = FutureProvider<void>((ref) async {
  await AuthService.signOut();
});
```

---

## Phase 6: Testing

### 6.1 Chạy ứng dụng trên Simulator/Emulator

#### iOS Simulator
```bash
# Mở simulator
open -a Simulator

# Chạy ứng dụng
flutter run -d "iPhone 15 Pro"

# Hoặc chọn device
flutter devices
flutter run -d <device-id>
```

#### Android Emulator
```bash
# Mở Android Emulator
emulator -list-avds
emulator -avd Pixel_6_API_31

# Chạy ứng dụng
flutter run -d emulator-5554
```

### 6.2 Hot Reload & Hot Restart
```bash
# Trong flutter run session:
r          # Hot reload (code changes)
R          # Hot restart (state reset)
q          # Quit
```

### 6.3 Build & Release

#### iOS
```bash
# Build
flutter build ios --release

# Output: build/ios/iphoneos/Runner.app
```

#### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

---

## Phase 7: Debugging

### 7.1 Logs & Console
```bash
# Xem logs
flutter logs

# Xem device logs
flutter logs -d <device-id>

# Debug release build
flutter run -d <device-id> --release
```

### 7.2 Flutter DevTools
```bash
# Mở DevTools
flutter pub global activate devtools
devtools

# Hoặc sử dụng VS Code extension
```

### 7.3 Supabase Logs
1. Truy cập Supabase Console
2. Chọn **Database** → **Logs**
3. Xem SQL queries và errors

---

## Troubleshooting

### Build Errors

**Error: "Xcode build failed"**
```bash
# Clean build
flutter clean
flutter pub get

# Cập nhật pods
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..

flutter run
```

**Error: "CocoaPods could not find compatible versions"**
```bash
pod repo update
cd ios
pod install --repo-update
cd ..
```

### Supabase Connection Issues

**Error: "Failed to connect to Supabase"**
1. Kiểm tra SUPABASE_URL và ANON_KEY
2. Kiểm tra internet connection
3. Kiểm tra Supabase project status

**Test connection:**
```dart
final response = await Supabase.instance.client
    .from('notes')
    .select()
    .limit(1);
print('Connection successful: $response');
```

### RLS Errors

**Error: "new row violates row-level security policy"**
- Kiểm tra user_id match với auth.uid()
- Verify RLS policies được enable
- Check policy syntax

```sql
-- Debug: Xem current user
SELECT auth.uid();

-- Test INSERT
INSERT INTO public.notes (user_id, title, content)
VALUES (auth.uid(), 'Test', 'Test content')
RETURNING *;
```

---

## Final Checklist

- [x] Flutter SDK cài đặt
- [x] Supabase project tạo
- [x] Database schema tạo
- [x] RLS policies cấu hình
- [x] Project Flutter khởi tạo
- [x] Dependencies cài đặt
- [x] Supabase initialized trong main.dart
- [x] Auth Service & Providers cấu hình
- [x] Test trên Simulator/Emulator
- [x] Logs & debugging ready

---

## Next Steps

1. Implement login/register screens
2. Implement notes CRUD screens
3. Test RLS policies
4. Add error handling
5. Optimize performance
6. Prepare for App Store/Play Store submission
