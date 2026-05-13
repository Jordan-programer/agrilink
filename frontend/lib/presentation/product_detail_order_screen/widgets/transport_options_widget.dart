import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class TransportOptionsWidget extends StatelessWidget {
  final String province;
  final String? selectedTransportId;
  final ValueChanged<String> onTransportSelected;

  const TransportOptionsWidget({
    super.key,
    required this.province,
    required this.selectedTransportId,
    required this.onTransportSelected,
  });

  static final List<Map<String, dynamic>> _transportMaps = [
    {
      'id': 't001',
      'driverName': 'Carlos Domingos Muamba',
      'vehicleType': 'Caminhão 5T',
      'plate': 'LD-23-45-AB',
      'rating': 4.7,
      'etaHours': 3,
      'costPerKm': 85.0,
      'estimatedCost': 2550.0,
      'route': 'Bengo → Luanda',
      'departureTime': '14:00',
      'availableKg': 3200.0,
      'isGrouped': true,
      'groupCount': 3,
    },
    {
      'id': 't002',
      'driverName': 'Augusto Neto Kiala',
      'vehicleType': 'Pickup 1T',
      'plate': 'BG-11-78-CD',
      'rating': 4.4,
      'etaHours': 2,
      'costPerKm': 110.0,
      'estimatedCost': 3300.0,
      'route': 'Bengo → Luanda',
      'departureTime': '12:30',
      'availableKg': 850.0,
      'isGrouped': false,
      'groupCount': 0,
    },
    {
      'id': 't003',
      'driverName': 'Filipe Sebastião Lopes',
      'vehicleType': 'Caminhão 10T',
      'plate': 'LD-88-32-EF',
      'rating': 4.9,
      'etaHours': 4,
      'costPerKm': 70.0,
      'estimatedCost': 2100.0,
      'route': 'Bengo → Luanda (via Viana)',
      'departureTime': '16:00',
      'availableKg': 7500.0,
      'isGrouped': true,
      'groupCount': 5,
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
                  Icons.local_shipping_rounded,
                  size: 16,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Transporte Disponível',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 10,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'IA Agrupada',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Rota: $province → Luanda · Hoje',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppTheme.outline,
              ),
            ),
            const SizedBox(height: 14),
            ..._transportMaps.asMap().entries.map((entry) {
              final i = entry.key;
              final transport = entry.value;
              final isSelected = selectedTransportId == transport['id'];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: i < _transportMaps.length - 1 ? 10 : 0,
                ),
                child: _TransportOptionCard(
                  transport: transport,
                  isSelected: isSelected,
                  onTap: () => onTransportSelected(transport['id'] as String),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TransportOptionCard extends StatelessWidget {
  final Map<String, dynamic> transport;
  final bool isSelected;
  final VoidCallback onTap;

  const _TransportOptionCard({
    required this.transport,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isGrouped = transport['isGrouped'] as bool;
    final groupCount = transport['groupCount'] as int;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryContainer.withAlpha(128)
              : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.outline.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.local_shipping_rounded,
                    size: 18,
                    color: isSelected ? Colors.white : AppTheme.outline,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transport['driverName'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      Text(
                        '${transport['vehicleType']} · ${transport['plate']}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppTheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'AOA ${(transport['estimatedCost'] as double).toInt()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.onSurface,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      'estimado',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: AppTheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppTheme.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.outline,
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
            const SizedBox(height: 10),
            Row(
              children: [
                _buildTag(
                  icon: Icons.access_time_rounded,
                  label:
                      '${transport['etaHours']}h · Saída ${transport['departureTime']}',
                  color: const Color(0xFF1565C0),
                ),
                const SizedBox(width: 8),
                _buildTag(
                  icon: Icons.star_rounded,
                  label: '${transport['rating']}',
                  color: AppTheme.amber,
                ),
                const SizedBox(width: 8),
                if (isGrouped)
                  _buildTag(
                    icon: Icons.group_rounded,
                    label: '$groupCount cargas agrupadas',
                    color: AppTheme.primary,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
