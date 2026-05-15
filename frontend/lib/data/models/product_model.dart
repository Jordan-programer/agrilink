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
  final String farmerId;
  final int quantity;
  final String unit;
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
    this.farmerId = '',
    required this.quantity,
    required this.unit,
    required this.rating,
  });

  static String _translateCategory(String? raw) {
    if (raw == null) return 'Outros';
    switch (raw.toUpperCase()) {
      case 'CEREAIS_E_GRAOS': return 'Cereais e Grãos';
      case 'HORTALICAS': return 'Hortaliças';
      case 'FRUTAS': return 'Frutas';
      case 'RAIZES_TUBERCULOS': return 'Raízes e Tubérculos';
      case 'INSUMOS_AGRICOLAS': return 'Insumos Agrícolas';
      case 'FORRAGENS': return 'Forragens';
      case 'LEGUMINOSAS': return 'Leguminosas';
      case 'OLEAGINOSAS': return 'Oleaginosas';
      case 'ESPECIARIAS': return 'Especiarias';
      case 'PRODUTOS_ANIMAIS': return 'Produtos Animais';
      case 'OUTROS': return 'Outros';
      default: return raw;
    }
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['productName'] ?? json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: _translateCategory(json['categoriaId']?.toString() ?? json['category']?.toString()),
      province: json['provincia'] ?? json['province'] ?? '',
      pricePerKg: (json['preco'] as num?)?.toDouble() ?? (json['pricePerKg'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantidade'] as num?)?.toInt() ?? (json['quantity'] as num?)?.toInt() ?? 0,
      unit: json['unidade']?.toString().toLowerCase() ?? json['unit']?.toString() ?? 'kg',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      status: json['status'],
      // Mapeamento dos campos novos:
      provinceAvgPrice: (json['provinceAvgPrice'] as num?)?.toDouble() ?? 0.0,
      aiRecommended: json['aiRecommended'] ?? false,
      isOrganic: json['isOrganic'] ?? false,
      farmerName: json['farmerName'] ?? 'Produtor Local',
      farmerId: json['farmerId']?.toString() ?? json['agricultor_id']?.toString() ?? json['userId']?.toString() ?? '',
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
      'farmerId': farmerId,
      'quantity': quantity,
      'unit': unit,
      'rating': rating,
    };
  }
}
