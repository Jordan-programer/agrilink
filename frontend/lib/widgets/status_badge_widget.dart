import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AgriStatus {
  available,
  reserved,
  sold,
  inTransit,
  delivered,
  pending,
  confirmed,
  lowStock,
  premium,
  verified,
}

class StatusBadgeWidget extends StatelessWidget {
  final AgriStatus status;
  final bool compact;

  const StatusBadgeWidget({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 5 : 6,
            height: compact ? 5 : 6,
            decoration: BoxDecoration(
              color: config.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: compact ? 4 : 5),
          Text(
            config.label,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: config.textColor,
              letterSpacing: 0.3,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _statusConfig(AgriStatus status) {
    switch (status) {
      case AgriStatus.available:
        return _StatusConfig(
          label: 'Disponível',
          backgroundColor: const Color(0xFFE8F5E9),
          borderColor: const Color(0xFFA5D6A7),
          dotColor: AppTheme.success,
          textColor: AppTheme.success,
        );
      case AgriStatus.reserved:
        return _StatusConfig(
          label: 'Reservado',
          backgroundColor: const Color(0xFFFFF8E1),
          borderColor: const Color(0xFFFFCC02),
          dotColor: AppTheme.amber,
          textColor: const Color(0xFF856404),
        );
      case AgriStatus.sold:
        return _StatusConfig(
          label: 'Vendido',
          backgroundColor: const Color(0xFFF3E5F5),
          borderColor: const Color(0xFFCE93D8),
          dotColor: const Color(0xFF7B1FA2),
          textColor: const Color(0xFF7B1FA2),
        );
      case AgriStatus.inTransit:
        return _StatusConfig(
          label: 'Em Trânsito',
          backgroundColor: const Color(0xFFE3F2FD),
          borderColor: const Color(0xFF90CAF9),
          dotColor: const Color(0xFF1565C0),
          textColor: const Color(0xFF1565C0),
        );
      case AgriStatus.delivered:
        return _StatusConfig(
          label: 'Entregue',
          backgroundColor: const Color(0xFFE8F5E9),
          borderColor: const Color(0xFF81C784),
          dotColor: const Color(0xFF1B5E20),
          textColor: const Color(0xFF1B5E20),
        );
      case AgriStatus.pending:
        return _StatusConfig(
          label: 'Pendente',
          backgroundColor: const Color(0xFFFFF3E0),
          borderColor: const Color(0xFFFFB74D),
          dotColor: AppTheme.warning,
          textColor: AppTheme.warning,
        );
      case AgriStatus.confirmed:
        return _StatusConfig(
          label: 'Confirmado',
          backgroundColor: const Color(0xFFE8F5E9),
          borderColor: const Color(0xFF66BB6A),
          dotColor: AppTheme.primaryLight,
          textColor: AppTheme.primaryLight,
        );
      case AgriStatus.lowStock:
        return _StatusConfig(
          label: 'Pouco Estoque',
          backgroundColor: const Color(0xFFFBE9E7),
          borderColor: const Color(0xFFFF8A65),
          dotColor: AppTheme.warning,
          textColor: AppTheme.warning,
        );
      case AgriStatus.premium:
        return _StatusConfig(
          label: 'Premium',
          backgroundColor: const Color(0xFFFFF8E1),
          borderColor: const Color(0xFFFFD54F),
          dotColor: const Color(0xFFF9A825),
          textColor: const Color(0xFF856404),
        );
      case AgriStatus.verified:
        return _StatusConfig(
          label: 'Verificado',
          backgroundColor: const Color(0xFFE8EAF6),
          borderColor: const Color(0xFF9FA8DA),
          dotColor: const Color(0xFF283593),
          textColor: const Color(0xFF283593),
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color dotColor;
  final Color textColor;

  const _StatusConfig({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.dotColor,
    required this.textColor,
  });
}
