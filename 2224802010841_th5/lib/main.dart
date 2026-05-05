import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'screens/notes/notes_list_screen.dart';
import 'constants/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup timeago locale for Vietnamese
  timeago.setLocaleMessages('vi', timeago.ViMessages());

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  } catch (e) {
    debugPrint('Failed to initialize Supabase: $e');
  }

  runApp(
    // ProviderScope is required for Riverpod
    const ProviderScope(child: NotesApp()),
  );
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Ghi chú',
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        barBackgroundColor: AppColors.cardBackground,
        textTheme: CupertinoTextThemeData(
          primaryColor: AppColors.textPrimary,
          textStyle: TextStyle(
            fontFamily: '.SF Pro Text',
            color: AppColors.textPrimary,
          ),
        ),
      ),
      home: NotesListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
