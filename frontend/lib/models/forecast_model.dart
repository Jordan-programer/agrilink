import 'package:flutter/material.dart';

class ForecastModel {
  final String product;
  final String demand;
  final String change;
  final Color color;
  final Color bgColor;
  final IconData icon;

  ForecastModel({
    required this.product,
    required this.demand,
    required this.change,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final changeValue = json['variacao'] as double;

    return ForecastModel(
      product: json['produto'],
      demand: _getDemandLevel(changeValue),
      change: '${changeValue.toStringAsFixed(0)}%',
      color: _getColor(changeValue),
      bgColor: _getBgColor(changeValue),
      icon: changeValue >= 0
          ? Icons.trending_up_rounded
          : Icons.trending_down_rounded,
    );
  }

  static String _getDemandLevel(double value) {
    if (value > 25) return 'Muito Alta';
    if (value > 10) return 'Alta';
    if (value > 0) return 'Média';
    return 'Baixa';
  }

  static Color _getColor(double value) {
    if (value > 25) return const Color(0xFFE65100);
    if (value > 10) return const Color(0xFF2E7D32);
    if (value > 0) return const Color(0xFF856404);
    return const Color(0xFF6A1B9A);
  }

  static Color _getBgColor(double value) {
    if (value > 25) return const Color(0xFFFBE9E7);
    if (value > 10) return const Color(0xFFE8F5E9);
    if (value > 0) return const Color(0xFFFFF8E1);
    return const Color(0xFFF3E5F5);
  }
}