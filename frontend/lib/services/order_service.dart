import 'dart:convert';
import 'api_service.dart';
import '../models/order_model.dart';

class OrderService {
  final api = ApiService();

  Future<bool> createOrder(List items, String userId) async {
    final response = await api.post("/orders", {
      "compradorId": userId,
      "items": items
    });

    return response.statusCode == 200;
  }

  Future<List<OrderModel>> getBuyerOrders(String userId) async {
    try {
      final response = await api.get("/orders/comprador/$userId");
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => OrderModel.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching orders: $e");
    }
    return [];
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      // id string looks like PED-1, so we parse it or pass directly if backend handles it
      // our backend expects Long id, so extract number
      final numericId = orderId.replaceAll(RegExp(r'[^0-9]'), '');
      if (numericId.isEmpty) return false;

      final response = await api.post("/orders/$numericId/cancel", {}); // The method I created was PUT, I should change backend to PUT or frontend to put. Wait, api_service only has get and post! 
      return response.statusCode == 200;
    } catch (e) {
      print("Error canceling order: $e");
      return false;
    }
  }
}