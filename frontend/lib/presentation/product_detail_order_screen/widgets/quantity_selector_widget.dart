import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class QuantitySelectorWidget extends StatefulWidget {
  final double maxQuantityKg;
  final double pricePerKg;
  final double selectedQuantity;
  final ValueChanged<double> onQuantityChanged;

  const QuantitySelectorWidget({
    super.key,
    required this.maxQuantityKg,
    required this.pricePerKg,
    required this.selectedQuantity,
    required this.onQuantityChanged,
  });

  @override
  State<QuantitySelectorWidget> createState() => _QuantitySelectorWidgetState();
}

class _QuantitySelectorWidgetState extends State<QuantitySelectorWidget> {
  late TextEditingController _controller;

  final List<double> _quickAmounts = [5, 10, 25, 50, 100];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.selectedQuantity.toInt().toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateQuantity(double qty) {
    final clamped = qty.clamp(1.0, widget.maxQuantityKg);
    _controller.text = clamped.toInt().toString();
    widget.onQuantityChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.selectedQuantity * widget.pricePerKg;

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
              'Seleccionar Quantidade',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Máximo disponível: ${widget.maxQuantityKg.toInt()} kg',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppTheme.outline,
              ),
            ),
            const SizedBox(height: 14),
            // Quick amount chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAmounts.map((amount) {
                final isSelected = widget.selectedQuantity == amount;
                final isAvailable = amount <= widget.maxQuantityKg;
                return InkWell(
                  onTap: isAvailable ? () => _updateQuantity(amount) : null,
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary
                          : isAvailable
                          ? AppTheme.surfaceVariant
                          : AppTheme.outlineVariant.withAlpha(77),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${amount.toInt()} kg',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : isAvailable
                            ? AppTheme.onSurface
                            : AppTheme.outline,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            // Custom amount row
            Row(
              children: [
                InkWell(
                  onTap: () => _updateQuantity(widget.selectedQuantity - 5),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.remove_rounded,
                      size: 20,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    decoration: InputDecoration(
                      suffixText: 'kg',
                      suffixStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AppTheme.outline,
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppTheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppTheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppTheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (v) {
                      final qty = double.tryParse(v);
                      if (qty != null) _updateQuantity(qty);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => _updateQuantity(widget.selectedQuantity + 5),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.primary.withAlpha(77),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 20,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Total price
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withAlpha(128),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(
                    'Total estimado:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'AOA ${total.toStringAsFixed(0)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                      fontFeatures: const [FontFeature.tabularFigures()],
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
