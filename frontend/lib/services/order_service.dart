import 'api_service.dart';

class OrderService {
  final api = ApiService();

  Future<bool> createOrder(List items, String userId) async {
    final response = await api.post("/orders", {
      "compradorId": userId,
      "items": items
    });

    return response.statusCode == 200;
  }
}