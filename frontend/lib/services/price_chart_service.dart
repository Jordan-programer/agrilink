import 'dart:convert';
import 'package:agrilink_app/models/price_point.dart';
import 'package:http/http.dart' as http;

class PriceChartService {
  final String baseUrl = "http://127.0.0.1:8000/preco/previsao";

  Future<List<PricePoint>> getForecast(String produto) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "produto": produto,
          "provincia": "Luanda",
          "clima": "limpo",
          "mes": 5,
          "ano": 2026,
          "quantidade_produzida": 100.0,
          "custo_transporte": 50.0,
          "inflacao": 10.0,
          "demanda_historica": 150.0
        }),
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData is List) {
          return List.generate(
            decodedData.length,
            (i) => PricePoint.fromJson(decodedData[i], i),
          );
        }
      }
      print("Erro no servidor: ${response.statusCode} - ${response.body}");
    return [];
  } catch (e) {
    print("Erro na requisição IA: $e");
    return [];
    }
  }
}
