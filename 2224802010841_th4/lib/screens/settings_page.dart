import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // ===== THÔNG TIN SINH VIÊN =====
  static const String studentName = 'Nguyễn Văn Linh';
  static const String studentId = '2224802010841';
  static const String studentClass = 'CNTT02 - TDMU'; 
  static const String appVersion = '2.0.26';
  // ================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          // === GIAO DIỆN ===
          _SectionHeader(title: 'Giao diện'),

          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => Column(
              children: [
                _SettingsTile(
                  leading: Icon(
                    themeProvider.isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: colorScheme.primary,
                  ),
                  title: 'Chế độ tối',
                  subtitle: themeProvider.isDark ? 'Đang bật' : 'Đang tắt',
                  trailing: Switch(
                    value: themeProvider.isDark,
                    onChanged: (_) => themeProvider.toggleTheme(),
                  ),
                ),
                _SettingsTile(
                  leading: Icon(Icons.palette_rounded, color: colorScheme.primary),
                  title: 'Chủ đề',
                  subtitle: themeProvider.isDark ? 'Tối' : 'Sáng',
                  trailing: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 11),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    segments: const [
                      ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.wb_sunny_rounded, size: 16),
                          label: Text('Sáng')),
                      ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.nights_stay_rounded, size: 16),
                          label: Text('Tối')),
                    ],
                    selected: {themeProvider.themeMode},
                    onSelectionChanged: (modes) =>
                        themeProvider.setTheme(modes.first),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // === THÔNG TIN SINH VIÊN ===
          _SectionHeader(title: 'Thông tin sinh viên'),

          _InfoTile(
            icon: Icons.person_rounded,
            label: 'Họ và tên',
            value: studentName,
            color: colorScheme.primary,
          ),
          _InfoTile(
            icon: Icons.badge_rounded,
            label: 'MSSV',
            value: studentId,
            color: colorScheme.primary,
          ),
          _InfoTile(
            icon: Icons.class_rounded,
            label: 'Lớp',
            value: studentClass,
            color: colorScheme.primary,
          ),

          const SizedBox(height: 8),

          // === THÔNG TIN ỨNG DỤNG ===
          _SectionHeader(title: 'Thông tin ứng dụng'),

          _InfoTile(
            icon: Icons.rss_feed_rounded,
            label: 'Nguồn dữ liệu',
            value: 'VnExpress RSS',
            color: Colors.orange,
          ),
          _InfoTile(
            icon: Icons.info_outline_rounded,
            label: 'Phiên bản',
            value: appVersion,
            color: Colors.grey,
          ),

          const SizedBox(height: 32),

          // Credits
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'VanLinh News · Bài tập lập trình\nFlutter · VnExpress RSS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle:
          Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: trailing,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label,
          style: const TextStyle(fontSize: 13, color: Colors.grey)),
      subtitle: Text(
        value,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }
}
