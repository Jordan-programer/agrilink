import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/jwt_manager.dart';

class ApiClient {
  final String baseUrl = "https://agrilink-production-c9e6.up.railway.app";
  final JwtManager jwtManager;

  ApiClient(this.jwtManager);

  Future<Map<String, String>> _headers() async {
    final token = await jwtManager.getToken();

    print("Token recuperado para a requisição: $token");

    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  Future<http.Response> get(String endpoint) async {
    return http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _headers(),
    );
  }

  Future<http.Response> post(String endpoint, dynamic body) async {
    return http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _headers(),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(String endpoint, dynamic body) async {
    return http.put(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _headers(),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String endpoint) async {
    return http.delete(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _headers(),
    );
  }
}