import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/forecast_model.dart';

class AiForecastService {
  final String baseUrl = "http://localhost:5050";

  Future<List<ForecastModel>> getForecasts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/demanda/global'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => ForecastModel.fromJson(e)).toList();
    } else {
      throw Exception("Erro ao carregar previsão IA");
    }
  }
}