import 'package:agrilink_app/data/models/product_model.dart';

class ProductState {
  final List<ProductModel> products;
  final List<ProductModel> filteredProducts;
  final bool isLoading;
  final String? error;

  ProductState({
    required this.products,
    required this.filteredProducts,
    required this.isLoading,
    this.error,
  });

  factory ProductState.initial() => ProductState(
        products: [],
        filteredProducts: [],
        isLoading: false,
      );

  ProductState copyWith({
    List<ProductModel>? products,
    List<ProductModel>? filteredProducts,
    bool? isLoading,
    String? error,
  }) {
    return ProductState(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}