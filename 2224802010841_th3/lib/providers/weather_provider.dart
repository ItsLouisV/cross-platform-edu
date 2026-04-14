import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../utils/city_data.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  List<WeatherModel> featuredCities = [];
  bool isLoading = false;
  String errorMessage = '';

  // Default cities as per requirements
  final List<String> _defaultCityNames = [
    'Hà Nội',
    'Hồ Chí Minh',
    'Đà Nẵng',
    'Tokyo',
    'Paris',
    'New York'
  ];

  // Các thành phố gợi ý khi người dùng gõ
  final List<String> availableCities = CityData.cities;

  WeatherProvider() {
    loadFeaturedCities();
  }

  Future<void> loadFeaturedCities() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      List<WeatherModel> results = [];
      for (String city in _defaultCityNames) {
        try {
          final weather = await _weatherService.fetchWeather(city);
          results.add(weather);
        } catch (e) {
          results.add(WeatherModel(
             cityName: city,
             temperature: 0,
             description: 'Đang cập nhật...',
             iconCode: '03d',
             feelsLike: 0,
             tempMin: 0,
             tempMax: 0,
             humidity: 0,
             windSpeed: 0,
             pressure: 0,
          ));
        }
      }
      featuredCities = results;
    } catch (e) {
      errorMessage = 'Không thể tải danh sách thành phố nổi bật.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<WeatherModel?> searchWeather(String query) async {
    try {
      return await _weatherService.fetchWeather(query);
    } catch (e) {
      return null;
    }
  }

  // Lọc danh sách thành phố tự động
  List<String> getSuggestions(String query) {
    if (query.isEmpty) return [];
    return availableCities
        .where((city) => city.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
