import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt & Thông tin'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Tùy chỉnh',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.thermostat, color: AppTheme.primaryBlue),
              title: const Text('Đơn vị nhiệt độ'),
              trailing: const Text('°C', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang được phát triển')),
                );
              },
            ),
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.notifications, color: AppTheme.primaryBlue),
              title: const Text('Thông báo thời tiết'),
              trailing: Switch(
                value: true,
                onChanged: (val) {},
                activeThumbColor: AppTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Thông tin sinh viên',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: const ListTile(
              leading: Icon(Icons.person, color: AppTheme.primaryBlue),
              title: Text('Mã sinh viên'),
              subtitle: Text('2224802010841'),
            ),
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: const ListTile(
              leading: Icon(Icons.info, color: AppTheme.primaryBlue),
              title: Text('Phiên bản ứng dụng'),
              subtitle: Text('1.0.0 (Build 1)'),
            ),
          ),
        ],
      ),
    );
  }
}
