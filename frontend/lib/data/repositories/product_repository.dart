import '../models/product_model.dart';
import '../../core/api/api_client.dart';
import 'dart:convert';

class ProductRepository {
  final ApiClient apiClient;

  ProductRepository(this.apiClient);

  Future<List<ProductModel>> getProducts() async {
    final response = await apiClient.get("/listings/products");

    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200) {
      final String decodedBody = utf8.decode(response.bodyBytes);
      final List data = jsonDecode(decodedBody);

      return data.map((e) => ProductModel.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw Exception("Sessão expirada. Por favor, faça login novamente.");
    } else {
      throw Exception("Erro ao carregar produtos: ${response.statusCode}");
    }
  }

}