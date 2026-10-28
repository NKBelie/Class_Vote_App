
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final double windSpeed;
  final int weatherCode;

  const WeatherData({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
  });

  String get description {
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode <= 3) return 'Partly cloudy';
    if (weatherCode <= 48) return 'Foggy';
    if (weatherCode <= 67) return 'Rainy';
    if (weatherCode <= 77) return 'Snowy';
    if (weatherCode <= 82) return 'Rain showers';
    if (weatherCode <= 86) return 'Snow showers';
    if (weatherCode <= 99) return 'Thunderstorm';
    return 'Unknown weather';
  }
}

class WeatherService {
  static final Uri _url = Uri.https(
    'api.open-meteo.com',
    '/v1/forecast',
    {
      'latitude': '-1.9441',
      'longitude': '30.0619',
      'current':
      'temperature_2m,wind_speed_10m,weather_code',
      'timezone': 'Africa/Kigali',
    },
  );

  static Future<WeatherData> getCurrentWeather() async {
    try {
      final response = await http
          .get(_url)
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw Exception(
          'Weather server returned ${response.statusCode}',
        );
      }

      final json = jsonDecode(response.body)
      as Map<String, dynamic>;

      final current = json['current']
      as Map<String, dynamic>;

      return WeatherData(
        temperature:
        (current['temperature_2m'] as num).toDouble(),
        windSpeed:
        (current['wind_speed_10m'] as num).toDouble(),
        weatherCode:
        (current['weather_code'] as num).toInt(),
      );
    } catch (_) {
      throw Exception(
        'Unable to load live weather. '
            'Check your internet connection and retry.',
      );
    }
  }
}
