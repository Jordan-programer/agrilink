import '../widgets/status_badge_widget.dart';

class OrderModel {
  final String id;
  final String productName;
  final String sellerName;
  final String sellerProvince;
  final double totalAoa;
  final double quantity;
  final String unit;
  final AgriStatus status;
  final String deliveryDate;
  final String placedAt;
  final String category;

  const OrderModel({
    required this.id,
    required this.productName,
    required this.sellerName,
    required this.sellerProvince,
    required this.totalAoa,
    required this.quantity,
    required this.unit,
    required this.status,
    required this.deliveryDate,
    required this.placedAt,
    required this.category,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? '',
      productName: json['productName'] as String? ?? 'Desconhecido',
      sellerName: json['sellerName'] as String? ?? 'Desconhecido',
      sellerProvince: json['sellerProvince'] as String? ?? 'Desconhecido',
      totalAoa: (json['totalAoa'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'kg',
      status: _parseStatus(json['status'] as String?),
      deliveryDate: _formatDate(json['deliveryDate'] as String?),
      placedAt: _formatDate(json['placedAt'] as String?),
      category: json['category'] as String? ?? 'Geral',
    );
  }

  static AgriStatus _parseStatus(String? statusStr) {
    switch (statusStr?.toLowerCase()) {
      case 'pendente': return AgriStatus.pendente;
      case 'confirmado': return AgriStatus.confirmado;
      case 'aprovado': return AgriStatus.confirmado; // Map aprovado to confirmado
      case 'enviado': return AgriStatus.enviado;
      case 'entregue': return AgriStatus.entregue;
      case 'cancelado': return AgriStatus.cancelado;
      default: return AgriStatus.pendente;
    }
  }

  static String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Desconhecida';
    // If it's a full ISO string from backend, maybe we format it nicely
    try {
      final date = DateTime.parse(dateStr);
      final day = date.day.toString().padLeft(2, '0');
      final monthStr = _getMonth(date.month);
      final year = date.year;
      return '$day $monthStr $year';
    } catch (e) {
      return dateStr;
    }
  }

  static String _getMonth(int month) {
    const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}
