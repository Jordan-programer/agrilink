import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class KpiMetricsWidget extends StatefulWidget {
  const KpiMetricsWidget({super.key});

  @override
  State<KpiMetricsWidget> createState() => _KpiMetricsWidgetState();
}

class _KpiMetricsWidgetState extends State<KpiMetricsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _KpiData(
        label: 'Produtos Activos',
        value: '1.847',
        icon: Icons.inventory_2_rounded,
        color: AppTheme.primary,
        bgColor: AppTheme.primaryContainer,
        trend: '+12%',
        trendUp: true,
      ),
      _KpiData(
        label: 'Pedidos Hoje',
        value: '63',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF1565C0),
        bgColor: const Color(0xFFE3F2FD),
        trend: '+8%',
        trendUp: true,
      ),
      _KpiData(
        label: 'Tomate (AOA/kg)',
        value: '385',
        icon: Icons.trending_down_rounded,
        color: AppTheme.warning,
        bgColor: AppTheme.warningContainer,
        trend: '-9%',
        trendUp: false,
      ),
      _KpiData(
        label: 'Rotas Activas',
        value: '18',
        icon: Icons.route_rounded,
        color: const Color(0xFF6A1B9A),
        bgColor: const Color(0xFFF3E5F5),
        trend: '+3',
        trendUp: true,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: metrics.asMap().entries.map((entry) {
          final i = entry.key;
          final metric = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Opacity(
                    opacity: (_animation.value - i * 0.1).clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        12 * (1 - (_animation.value - i * 0.1).clamp(0.0, 1.0)),
                      ),
                      child: child,
                    ),
                  );
                },
                child: _KpiCard(metric: metric),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final _KpiData metric;

  const _KpiCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: metric.color.withAlpha(38), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: metric.bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(metric.icon, size: 16, color: metric.color),
          ),
          const SizedBox(height: 8),
          Text(
            metric.value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            metric.label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: AppTheme.outline,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: metric.trendUp
                  ? AppTheme.successContainer
                  : AppTheme.warningContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  metric.trendUp
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 9,
                  color: metric.trendUp ? AppTheme.success : AppTheme.warning,
                ),
                Text(
                  metric.trend,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: metric.trendUp ? AppTheme.success : AppTheme.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String trend;
  final bool trendUp;

  const _KpiData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.trend,
    required this.trendUp,
  });
}
