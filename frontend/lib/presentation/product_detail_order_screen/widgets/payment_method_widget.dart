import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class PaymentMethodWidget extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onMethodChanged;

  const PaymentMethodWidget({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  static const List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'Multicaixa Express',
      'label': 'Multicaixa Express',
      'subtitle': 'Pagamento instantâneo via ATM/MB',
      'icon': Icons.credit_card_rounded,
      'color': 0xFF1B5E20,
      'badge': 'Recomendado',
    },
    {
      'id': 'Paypay',
      'label': 'Paypay',
      'subtitle': 'Carteira digital Paypay',
      'icon': Icons.account_balance_wallet_rounded,
      'color': 0xFF1565C0,
      'badge': null,
    },
    {
      'id': 'Unitel Money',
      'label': 'Unitel Money',
      'subtitle': 'Mobile money Unitel',
      'icon': Icons.phone_android_rounded,
      'color': 0xFFE65100,
      'badge': null,
    },
    {
      'id': 'Transferência Bancária',
      'label': 'Transferência Bancária',
      'subtitle': 'TPA / Transferência entre contas',
      'icon': Icons.account_balance_rounded,
      'color': 0xFF6A1B9A,
      'badge': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                const Icon(
                  Icons.payment_rounded,
                  size: 16,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Método de Pagamento',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.lock_rounded,
                  size: 11,
                  color: AppTheme.success,
                ),
                const SizedBox(width: 4),
                Text(
                  'Pagamentos encriptados e seguros via TCP/TLS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppTheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ..._paymentMethods.asMap().entries.map((entry) {
              final i = entry.key;
              final method = entry.value;
              final isSelected = selectedMethod == method['id'];
              final color = Color(method['color'] as int);

              return Padding(
                padding: EdgeInsets.only(
                  bottom: i < _paymentMethods.length - 1 ? 8 : 0,
                ),
                child: InkWell(
                  onTap: () => onMethodChanged(method['id'] as String),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withAlpha(13)
                          : AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : AppTheme.outlineVariant,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withAlpha(26)
                                : AppTheme.outline.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            method['icon'] as IconData,
                            size: 20,
                            color: isSelected ? color : AppTheme.outline,
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
                                    method['label'] as String,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? color
                                          : AppTheme.onSurface,
                                    ),
                                  ),
                                  if (method['badge'] != null) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.secondary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        method['badge'] as String,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                method['subtitle'] as String,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppTheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? color : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? color : AppTheme.outline,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
