import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../services/weather_service.dart';
import '../utils/app_theme.dart';

class DetailScreen extends StatefulWidget {
  final WeatherModel weather;

  const DetailScreen({super.key, required this.weather});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final WeatherService _weatherService = WeatherService();
  List<ForecastModel> forecastList = [];
  List<ForecastModel> hourlyList = [];
  bool isLoadingForecast = true;

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    final map = await _weatherService.fetchForecast(widget.weather.cityName);
    if (mounted) {
      setState(() {
        hourlyList = map['hourly'] ?? [];
        forecastList = map['daily'] ?? [];
        isLoadingForecast = false;
      });
    }
  }

  IconData _getIconData(String iconCode) {
    if (iconCode.contains('01')) return Icons.wb_sunny;
    if (iconCode.contains('02') || iconCode.contains('03') || iconCode.contains('04')) return Icons.cloud;
    if (iconCode.contains('09') || iconCode.contains('10')) return Icons.beach_access;
    if (iconCode.contains('11')) return Icons.thunderstorm;
    if (iconCode.contains('13')) return Icons.ac_unit;
    return Icons.wb_sunny;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.weather.cityName, style: const TextStyle(color: Colors.white, fontSize: 24)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.weatherGradient(widget.weather.iconCode),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Header (Nhiệt độ to, trạng thái)
                Text(
                  widget.weather.description == 'Đang cập nhật...'
                      ? '--°'
                      : '${widget.weather.temperature.toStringAsFixed(0)}°',
                  style: const TextStyle(
                    fontSize: 96,
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.weather.description.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'C: ${widget.weather.tempMax.toStringAsFixed(0)}°  T: ${widget.weather.tempMin.toStringAsFixed(0)}°',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),

                // Card Dự báo theo giờ
                _buildGlassContainer(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       const Row(
                         children: [
                           Icon(Icons.schedule, color: Colors.white70, size: 16),
                           SizedBox(width: 8),
                           Text(
                             'DỰ BÁO HÀNG GIỜ',
                             style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
                           ),
                         ],
                       ),
                       const Divider(color: Colors.white30, height: 16),
                       if (isLoadingForecast)
                         const Center(child: Padding(
                           padding: EdgeInsets.all(20.0),
                           child: CircularProgressIndicator(color: Colors.white),
                         ))
                       else if (hourlyList.isEmpty)
                         const Center(child: Padding(
                           padding: EdgeInsets.all(20.0),
                           child: Text("Đang cập nhật...", style: TextStyle(color: Colors.white70)),
                         ))
                       else
                         SizedBox(
                           height: 100,
                           child: ListView.builder(
                             scrollDirection: Axis.horizontal,
                             physics: const BouncingScrollPhysics(),
                             itemCount: hourlyList.length,
                             itemBuilder: (context, index) {
                               return _buildHourlyItem(hourlyList[index]);
                             },
                           ),
                         ),
                     ],
                   )
                ),
                const SizedBox(height: 16),

                // Card Dự báo nhiều ngày (Frost Glass)
                _buildGlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.calendar_month, color: Colors.white70, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'DỰ BÁO NHIỀU NGÀY TỚI',
                            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white30, height: 24),
                      if (isLoadingForecast)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: Colors.white),
                        ))
                      else if (forecastList.isEmpty)
                        const Center(child: Padding(
                           padding: EdgeInsets.all(20.0),
                           child: Text("Đang cập nhật...", style: TextStyle(color: Colors.white70)),
                        ))
                      else
                        ...forecastList.map((day) => _buildForecastRow(day)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Card lưới thông số 2 cột
                Row(
                  children: [
                    Expanded(child: _buildSquareGlassItem(Icons.water_drop, 'ĐỘ ẨM', '${widget.weather.humidity}%')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSquareGlassItem(Icons.air, 'SỨC GIÓ', '${widget.weather.windSpeed} m/s')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildSquareGlassItem(Icons.thermostat, 'CẢM GIÁC', '${widget.weather.feelsLike.toStringAsFixed(0)}°')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSquareGlassItem(Icons.speed, 'ÁP SUẤT', '${widget.weather.pressure} hPa')),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildHourlyItem(ForecastModel hour) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(hour.date, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Icon(_getIconData(hour.iconCode), color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text('${hour.temperature.toStringAsFixed(0)}°', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildForecastRow(ForecastModel day) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              day.date,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          Row(
            children: [
              Icon(_getIconData(day.iconCode), color: Colors.white, size: 24),
              if (day.probabilityOfPrecipitation > 0) ...[
                const SizedBox(width: 4),
                Text(
                  '${day.probabilityOfPrecipitation}%',
                  style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 13, fontWeight: FontWeight.bold),
                )
              ]
            ],
          ),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${day.tempMin.toStringAsFixed(0)}°', style: const TextStyle(color: Colors.white70, fontSize: 18)),
                Text('${day.tempMax.toStringAsFixed(0)}°', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSquareGlassItem(IconData icon, String title, String value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
