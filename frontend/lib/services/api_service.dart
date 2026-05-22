import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = "https://api.ruitinerante.com";

  final storage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await storage.read(key: "token");
  }

  Future<void> saveToken(String token) async {
    await storage.write(key: "token", value: token);
  }

  Future<Map<String, dynamic>> login(String identifier, String senha) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "identifier": identifier,
        "senha": senha,
      }),
    ).timeout(const Duration(seconds: 10)); // Boa prática para redes móveis

    if (response.statusCode == 200) {
      // Decodifica como UTF-8 para evitar problemas com acentos (ex: nomes de Províncias)
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      // Opcional: tratar erros 401 ou 403 especificamente
      throw Exception("Credenciais inválidas");
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception("Falha ao criar conta");
    }
  }



  Future<http.Response> get(String endpoint) async {
    final token = await getToken();

    return http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token"
      },
    );
  }

  Future<http.Response> post(String endpoint, dynamic data) async {
    final token = await getToken();

    return http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token"
      },
      body: jsonEncode(data),
    );
  }
}