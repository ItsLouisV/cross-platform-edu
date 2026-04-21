import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/news_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/app_theme.dart';
import 'widgets/main_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ReadNews());
}

class ReadNews extends StatelessWidget {
  const ReadNews({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'VanLinh News',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode,
          home: const MainWrapper(),
        ),
      ),
    );
  }
}
