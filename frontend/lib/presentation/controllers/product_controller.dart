import 'package:agrilink_app/presentation/controllers/product_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../core/api/api_client.dart';
import '../../core/auth/jwt_manager.dart';

final productControllerProvider =
    StateNotifierProvider<ProductController, ProductState>((ref) {
  final repository = ProductRepository(ApiClient(JwtManager()));
  return ProductController(repository);
});

class ProductController extends StateNotifier<ProductState> {
  final ProductRepository repository;

  ProductController(this.repository) : super(ProductState.initial());

  Future<void> loadProducts() async {
    try {
      state = state.copyWith(isLoading: true);

      final products = await repository.getProducts();

      state = state.copyWith(
        products: products,
        filteredProducts: products,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void filter(String query, String category) {
    final filtered = state.products.where((p) {
      final matchesCategory =
          category == 'Todos' || p.category == category;

      final q = query.toLowerCase();

      final matchesSearch =
          q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.farmerName.toLowerCase().contains(q) ||
          p.province.toLowerCase().contains(q);

      return matchesCategory && matchesSearch;
    }).toList();

    state = state.copyWith(filteredProducts: filtered);
  }
}