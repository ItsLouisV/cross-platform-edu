import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherService {
  // Đặt API key của bạn ở đây, hoặc để trống để dùng dữ liệu mẫu
  static const String apiKey = '41c6dfeffa6073c2f2fb4ac4ec9f0357';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherModel> fetchWeather(String cityName) async {
    final url = Uri.parse('$baseUrl?q=$cityName&appid=$apiKey&units=metric&lang=vi');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather for $cityName');
    }
  }

  // --- HÀM MỚI: FETCH DỰ BÁO 5-7 NGÀY & TỪNG GIỜ ---
  Future<Map<String, List<ForecastModel>>> fetchForecast(String cityName) async {
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey&units=metric&lang=vi');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> listData = data['list'];
      
      List<ForecastModel> dailyList = [];
      List<ForecastModel> hourlyList = [];
      String currentDay = "";
      
      // --- TẠO DỮ LIỆU TỪNG GIỜ (1-hour interval) ---
      // Vì bản miễn phí của OWM trả dữ liệu mỗi 3 tiếng, ta sẽ nội suy (chia trung bình) 
      for (int i = 0; i < 8 && (i + 1) < listData.length; i++) {
        final item1 = listData[i];
        final item2 = listData[i+1];
        final dt1 = DateTime.fromMillisecondsSinceEpoch(item1['dt'] * 1000);
        final temp1 = (item1['main']['temp'] ?? 0).toDouble();
        final temp2 = (item2['main']['temp'] ?? 0).toDouble();

        for (int j = 0; j < 3; j++) {
          DateTime interpolatedDate = dt1.add(Duration(hours: j));
          double interpolatedTemp = temp1 + (temp2 - temp1) * (j / 3.0);
          String timeStr = (i == 0 && j == 0) ? "Bây giờ" : "${interpolatedDate.hour.toString().padLeft(2, '0')}:00";
          
          hourlyList.add(ForecastModel(
             date: timeStr,
             iconCode: item1['weather'][0]['icon'], 
             temperature: interpolatedTemp,
             tempMin: interpolatedTemp,
             tempMax: interpolatedTemp,
             probabilityOfPrecipitation: ((item1['pop'] ?? 0) * 100).toInt(),
          ));
        }
      }
      
      // Chỉ lấy 1 giá trị mỗi ngày cho dự báo ngày
      for (var item in listData) {
        final DateTime date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        final String weekDay = _getWeekdayLabel(date.weekday);
        
        if (currentDay != weekDay) {
          dailyList.add(ForecastModel.fromJson(item, weekDay));
          currentDay = weekDay;
        }
      }
      return {'hourly': hourlyList, 'daily': dailyList};
    } else {
      throw Exception('Failed to load forecast for $cityName');
    }
  }

  String _getWeekdayLabel(int weekday) {
    if (weekday == 7) return "CN";
    return "T${weekday + 1}";
  }
}
