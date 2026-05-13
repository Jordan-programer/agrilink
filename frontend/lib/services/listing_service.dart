import 'dart:convert';
import 'api_service.dart';

class ListingService {
  final api = ApiService();

  Future<List<dynamic>> getListings() async {
    final response = await api.get("/listings");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }
}