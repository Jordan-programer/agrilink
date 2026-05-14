import '../models/product_model.dart';
import '../../core/api/api_client.dart';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProductRepository {
  final ApiClient apiClient;

  ProductRepository(this.apiClient);

  Future<List<ProductModel>> getProducts() async {
    const storage = FlutterSecureStorage();
    final userStr = await storage.read(key: "user");
    
    String role = '';
    String userId = '';
    
    if (userStr != null) {
      final userJson = jsonDecode(userStr);
      role = userJson['tipo'] ?? '';
      userId = userJson['id'] ?? '';
    }

    String url = "/listings/products";
    if (role.isNotEmpty && userId.isNotEmpty) {
      url += "?role=$role&userId=$userId";
    }

    final response = await apiClient.get(url);

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