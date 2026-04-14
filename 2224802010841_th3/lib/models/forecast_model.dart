class ForecastModel {
  final String date;  // vd: "Thứ 2", "08:00"
  final String iconCode;
  final double temperature;
  final double tempMin;
  final double tempMax;
  final int probabilityOfPrecipitation; // Dạng %

  ForecastModel({
    required this.date,
    required this.iconCode,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    this.probabilityOfPrecipitation = 0,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json, String dateLabel) {
    return ForecastModel(
      date: dateLabel,
      iconCode: json['weather'] != null && json['weather'].isNotEmpty 
          ? json['weather'][0]['icon'] 
          : '01d',
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      tempMin: (json['main']['temp_min'] ?? 0).toDouble(),
      tempMax: (json['main']['temp_max'] ?? 0).toDouble(),
      probabilityOfPrecipitation: ((json['pop'] ?? 0) * 100).toInt(),
    );
  }
}
