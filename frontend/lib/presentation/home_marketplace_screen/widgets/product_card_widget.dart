import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/product_model.dart'; // Certifique-se de que o caminho está correto
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_image_widget.dart';
import '../../../widgets/status_badge_widget.dart';

class ProductCardWidget extends StatelessWidget {
  final ProductModel product; // Alterado de Map para ProductModel
  final VoidCallback onTap;

  const ProductCardWidget({
    super.key,
    required this.product,
    required this.onTap,
  });

  AgriStatus _statusFromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'reserved':
        return AgriStatus.reserved;
      case 'sold':
        return AgriStatus.sold;
      case 'low_stock':
        return AgriStatus.lowStock;
      default:
        return AgriStatus.available;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusFromString(product.status);
    final pricePerKg = product.pricePerKg;
    final avgPrice = product.provinceAvgPrice;
    final isBelowAvg = pricePerKg < avgPrice;
    final isAiRecommended = product.aiRecommended;
    final isOrganic = product.isOrganic;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppTheme.primary.withAlpha(20),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              Stack(
                children: [
                  Hero(
                    tag: 'product-image-${product.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: CustomImageWidget(
                        imageUrl: product.imageUrl,
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                        semanticLabel: product.name,
                      ),
                    ),
                  ),
                  // Top badges row
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      children: [
                        StatusBadgeWidget(status: status, compact: true),
                        const Spacer(),
                        if (isAiRecommended)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(230),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              size: 12,
                              color: AppTheme.secondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Organic badge
                  if (isOrganic)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Bio',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Content section
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 11,
                          color: AppTheme.outline,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            product.province,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppTheme.outline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'AOA ${pricePerKg.toInt()}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          '/kg',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: AppTheme.outline,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isBelowAvg
                                ? AppTheme.successContainer
                                : AppTheme.errorContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isBelowAvg ? 'Abaixo média' : 'Acima média',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isBelowAvg 
                                  ? AppTheme.success 
                                  : AppTheme.errorColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
