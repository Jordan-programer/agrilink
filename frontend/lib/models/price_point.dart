class PricePoint {
  final int index;
  final double price;
  final String label;

  PricePoint({
    required this.index,
    required this.price,
    required this.label,
  });

  factory PricePoint.fromJson(Map<String, dynamic> json, int index) {
    return PricePoint(
      index: index,
      price: (json['preco'] as num).toDouble(),
      label: json['mes'].toString(),
    );
  }
}