import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class ProductSpecsWidget extends StatelessWidget {
  final String category;
  final double quantityKg;
  final String harvestDate;
  final bool isOrganic;
  final String province;

  const ProductSpecsWidget({
    super.key,
    required this.category,
    required this.quantityKg,
    required this.harvestDate,
    required this.isOrganic,
    required this.province,
  });

  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return dateStr;
    } catch (_) {
      return dateStr;
    }
  }

  String _freshnessLabel(String dateStr) {
    try {
      final parts = dateStr.split('-');
      final harvestDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final diff = DateTime.now().difference(harvestDate).inDays;
      if (diff == 0) return 'Colhido hoje';
      if (diff == 1) return 'Colhido ontem';
      if (diff <= 3) return 'Muito fresco ($diff dias)';
      if (diff <= 7) return 'Fresco ($diff dias)';
      return '$diff dias após colheita';
    } catch (_) {
      return 'Data não disponível';
    }
  }

  Color _freshnessColor(String dateStr) {
    try {
      final parts = dateStr.split('-');
      final harvestDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final diff = DateTime.now().difference(harvestDate).inDays;
      if (diff <= 1) return AppTheme.success;
      if (diff <= 3) return AppTheme.success;
      if (diff <= 7) return AppTheme.amber;
      return AppTheme.warning;
    } catch (_) {
      return AppTheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final freshnessColor = _freshnessColor(harvestDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalhes do Produto',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 14),
            _buildSpecRow(
              icon: Icons.category_rounded,
              iconColor: AppTheme.primary,
              label: 'Categoria',
              value: category,
            ),
            const SizedBox(height: 10),
            _buildSpecRow(
              icon: Icons.scale_rounded,
              iconColor: const Color(0xFF1565C0),
              label: 'Quantidade Disponível',
              value: '${quantityKg.toInt()} kg',
            ),
            const SizedBox(height: 10),
            _buildSpecRow(
              icon: Icons.agriculture_rounded,
              iconColor: AppTheme.earthBrown,
              label: 'Data de Colheita',
              value: _formatDate(harvestDate),
            ),
            const SizedBox(height: 10),
            _buildSpecRow(
              icon: Icons.eco_rounded,
              iconColor: freshnessColor,
              label: 'Frescura',
              value: _freshnessLabel(harvestDate),
              valueColor: freshnessColor,
            ),
            const SizedBox(height: 10),
            _buildSpecRow(
              icon: Icons.location_on_rounded,
              iconColor: AppTheme.secondary,
              label: 'Origem',
              value: province,
            ),
            const SizedBox(height: 10),
            _buildSpecRow(
              icon: Icons.spa_rounded,
              iconColor: isOrganic ? AppTheme.primary : AppTheme.outline,
              label: 'Produção',
              value: isOrganic ? 'Biológica / Orgânica' : 'Convencional',
              valueColor: isOrganic ? AppTheme.primary : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppTheme.outline,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.onSurface,
          ),
        ),
      ],
    );
  }
}
