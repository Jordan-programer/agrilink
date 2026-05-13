import 'dart:convert';
import 'api_service.dart';

class ProductService {
  final api = ApiService();

  Future<List<dynamic>> getProducts() async {
    final response = await api.get("/products");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }
}