import 'dart:convert';

class CartItemModel {
  final String productId;
  final String productName;
  final String farmerName;
  final String farmerId;
  final String farmerProvince;
  final double pricePerUnit;
  final String unit;
  double quantity;
  final String? imageUrl;
  final String category;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.farmerName,
    required this.farmerId,
    required this.farmerProvince,
    required this.pricePerUnit,
    required this.unit,
    required this.quantity,
    this.imageUrl,
    required this.category,
  });

  double get subtotal => pricePerUnit * quantity;

  CartItemModel copyWith({double? quantity}) {
    return CartItemModel(
      productId: productId,
      productName: productName,
      farmerName: farmerName,
      farmerId: farmerId,
      farmerProvince: farmerProvince,
      pricePerUnit: pricePerUnit,
      unit: unit,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl,
      category: category,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'farmerName': farmerName,
    'farmerId': farmerId,
    'farmerProvince': farmerProvince,
    'pricePerUnit': pricePerUnit,
    'unit': unit,
    'quantity': quantity,
    'imageUrl': imageUrl,
    'category': category,
  };

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    productId: json['productId'] as String,
    productName: json['productName'] as String,
    farmerName: json['farmerName'] as String,
    farmerId: json['farmerId'] as String,
    farmerProvince: json['farmerProvince'] as String,
    pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
    unit: json['unit'] as String,
    quantity: (json['quantity'] as num).toDouble(),
    imageUrl: json['imageUrl'] as String?,
    category: json['category'] as String? ?? 'Geral',
  );

  static String encodeList(List<CartItemModel> items) =>
      jsonEncode(items.map((i) => i.toJson()).toList());

  static List<CartItemModel> decodeList(String raw) {
    final list = jsonDecode(raw) as List;
    return list.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
