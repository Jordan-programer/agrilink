class ProductModel {
  final String id;
  final String name;
  final String imageUrl;
  final String category;
  final String province;
  final double pricePerKg;
  final String? status;
  final double provinceAvgPrice; 
  final bool aiRecommended;
  final bool isOrganic;
  final String farmerName;
  final int quantity;
  final double rating;

  ProductModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.province,
    required this.pricePerKg,
    this.status,
    required this.provinceAvgPrice,
    required this.aiRecommended,
    required this.isOrganic,
    required this.farmerName,
    required this.quantity,
    required this.rating,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['productName'] ?? json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['categoriaId'] ?? json['category'] ?? '',
      province: json['provincia'] ?? json['province'] ?? '',
      pricePerKg: (json['preco'] as num?)?.toDouble() ?? (json['pricePerKg'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantidade'] as num?)?.toInt() ?? (json['quantity'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      status: json['status'],
      // Mapeamento dos campos novos:
      provinceAvgPrice: (json['provinceAvgPrice'] as num?)?.toDouble() ?? 0.0,
      aiRecommended: json['aiRecommended'] ?? false,
      isOrganic: json['isOrganic'] ?? false,
      farmerName: json['farmerName'] ?? 'Produtor Local',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'category': category,
      'province': province,
      'pricePerKg': pricePerKg,
      'status': status,
      'provinceAvgPrice': provinceAvgPrice,
      'aiRecommended': aiRecommended,
      'isOrganic': isOrganic,
      'farmerName': farmerName,
      'quantity': quantity,
      'rating': rating,
    };
  }
}
