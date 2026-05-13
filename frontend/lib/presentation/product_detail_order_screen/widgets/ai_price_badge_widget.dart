import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class AiPriceBadgeWidget extends StatelessWidget {
  final double currentPrice;
  final double avgPrice;
  final String province;

  const AiPriceBadgeWidget({
    super.key,
    required this.currentPrice,
    required this.avgPrice,
    required this.province,
  });

  @override
  Widget build(BuildContext context) {
    final isBelowAvg = currentPrice < avgPrice;
    final diff = ((avgPrice - currentPrice) / avgPrice * 100).abs();
    final saving = avgPrice - currentPrice;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isBelowAvg
                ? [AppTheme.primaryContainer, const Color(0xFFDCEDC8)]
                : [AppTheme.warningContainer, const Color(0xFFFFE0B2)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isBelowAvg
                ? AppTheme.primary.withAlpha(51)
                : AppTheme.warning.withAlpha(51),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isBelowAvg
                    ? AppTheme.primary.withAlpha(26)
                    : AppTheme.warning.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 22,
                color: isBelowAvg ? AppTheme.primary : AppTheme.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Análise de Preço IA',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isBelowAvg
                              ? AppTheme.primary
                              : AppTheme.warning,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isBelowAvg
                              ? AppTheme.primary
                              : AppTheme.warning,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isBelowAvg ? 'Bom negócio' : 'Acima média',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                      ),
                      children: [
                        TextSpan(
                          text: isBelowAvg
                              ? 'Poupa AOA ${saving.toInt()}/kg '
                              : 'AOA ${(-saving).toInt()}/kg acima ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isBelowAvg
                                ? AppTheme.success
                                : AppTheme.errorColor,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        TextSpan(
                          text:
                              'vs média da província $province (AOA ${avgPrice.toInt()}/kg)',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
