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
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      province: json['province'] ?? '',
      pricePerKg: (json['pricePerKg'] as num?)?.toDouble() ?? 0.0,
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
    };
  }
}
