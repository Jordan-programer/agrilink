import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class OrderSummaryBarWidget extends StatelessWidget {
  final double totalPrice;
  final double quantityKg;
  final String selectedPayment;
  final VoidCallback onOrder;

  const OrderSummaryBarWidget({
    super.key,
    required this.totalPrice,
    required this.quantityKg,
    required this.selectedPayment,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: AppTheme.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total a Pagar',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppTheme.outline,
                ),
              ),
              Text(
                'AOA ${totalPrice.toStringAsFixed(0)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                '${quantityKg.toInt()} kg · $selectedPayment',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppTheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: onOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_basket_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Fazer Pedido',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
