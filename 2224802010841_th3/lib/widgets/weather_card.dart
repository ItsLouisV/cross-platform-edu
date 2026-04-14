import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../utils/app_theme.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final VoidCallback onTap;

  const WeatherCard({
    super.key,
    required this.weather,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData = Icons.wb_sunny;
    Color baseColor = Colors.orange;

    if (weather.iconCode.contains('02') || weather.iconCode.contains('03') || weather.iconCode.contains('04')) {
      iconData = Icons.cloud;
      baseColor = Colors.blueGrey;
    } else if (weather.iconCode.contains('09') || weather.iconCode.contains('10')) {
      iconData = Icons.beach_access;
      baseColor = Colors.blue;
    } else if (weather.iconCode.contains('11')) {
      iconData = Icons.thunderstorm;
      baseColor = Colors.deepPurple;
    } else if (weather.iconCode.contains('13')) {
      iconData = Icons.ac_unit;
      baseColor = Colors.cyan;
    } else if (weather.iconCode.contains('01n')) {
      iconData = Icons.nightlight_round;
      baseColor = Colors.indigo;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          // Nền màu trắng tinh xen lẫn chút xíu ánh màu (tint) 4% để không bị chóe mắt
          color: baseColor.withValues(alpha: 0.04), 
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: baseColor.withValues(alpha: 0.1)), // Viền siêu mờ
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: baseColor.withValues(alpha: 0.15),
              radius: 24,
              child: Icon(iconData, color: baseColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.cityName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weather.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.secondaryText.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              weather.description == 'Đang cập nhật...' 
                  ? '-- °C'
                  : '${weather.temperature.toStringAsFixed(1)}°C',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                // Nhiệt độ cùng tone màu với thời tiết sẽ rất liên kết
                color: baseColor, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}
