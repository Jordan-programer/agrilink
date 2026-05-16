import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../theme/app_theme.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/auth/jwt_manager.dart';
import 'dart:convert';

class AdminKpiTab extends StatefulWidget {
  const AdminKpiTab({super.key});

  @override
  State<AdminKpiTab> createState() => _AdminKpiTabState();
}

class _AdminKpiTabState extends State<AdminKpiTab> {
  bool _isLoading = true;
  final ApiClient _apiClient = ApiClient(JwtManager());
  
  int _totalUsers = 0;
  double _totalRevenue = 0;
  double _totalProfit = 0;
  int _totalProducts = 0;
  int _totalOrders = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final usersRes = await _apiClient.get('/users');
      final ordersRes = await _apiClient.get('/orders/all');
      final productsRes = await _apiClient.get('/produtos');

      if (mounted) {
        setState(() {
          if (usersRes.statusCode == 200) {
            _totalUsers = (jsonDecode(usersRes.body) as List).length;
          }
          if (ordersRes.statusCode == 200) {
            final orders = jsonDecode(ordersRes.body) as List;
            _totalOrders = orders.length;
            _totalRevenue = orders.fold(0.0, (sum, item) => sum + (item['totalAoa'] ?? 0.0));
            
            final approvedOrders = orders.where((o) => o['status'] == 'aprovado').toList();
            final approvedRevenue = approvedOrders.fold(0.0, (sum, item) => sum + (item['totalAoa'] ?? 0.0));
            _totalProfit = approvedRevenue * 0.05;
          }
          if (productsRes.statusCode == 200) {
            _totalProducts = (jsonDecode(productsRes.body) as List).length;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildMetricGrid(),
            const SizedBox(height: 32),
            _buildChartSection(),
            const SizedBox(height: 32),
            _buildRecentActivitySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Olá, Administrador',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.onSurface,
            letterSpacing: -1,
          ),
        ),
        Text(
          'Aqui está o resumo do desempenho da AgriLink hoje.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppTheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        double aspectRatio = 1.4;
        
        if (constraints.maxWidth >= 900) {
          crossAxisCount = 4;
          aspectRatio = 1.6;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: aspectRatio,
          children: [
            _buildKpiCard(
              'Vendas Totais',
              'AOA ${_totalRevenue.toStringAsFixed(0)}',
              Icons.payments_rounded,
              [AppTheme.primary, AppTheme.primaryLight],
            ),
            _buildKpiCard(
              'Utilizadores',
              '$_totalUsers',
              Icons.people_alt_rounded,
              [AppTheme.secondary, AppTheme.amber],
            ),
            _buildKpiCard(
              'Encomendas',
              '$_totalOrders',
              Icons.shopping_cart_rounded,
              [const Color(0xFF673AB7), const Color(0xFF9575CD)],
            ),
            _buildKpiCard(
              'Produtos',
              '$_totalProducts',
              Icons.inventory_2_rounded,
              [const Color(0xFF009688), const Color(0xFF4DB6AC)],
            ),
            _buildKpiCard(
              'Lucro (Comissões)',
              'AOA ${_totalProfit.toStringAsFixed(0)}',
              Icons.trending_up_rounded,
              [const Color(0xFFE91E63), const Color(0xFFF06292)],
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Volume de Vendas',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(Icons.more_horiz, color: AppTheme.outline),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppTheme.outlineVariant.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
                        if (value >= 0 && value < days.length) {
                          return Text(days[value.toInt()], style: const TextStyle(fontSize: 10, color: AppTheme.outline));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(1, 1),
                      FlSpot(2, 4),
                      FlSpot(3, 2),
                      FlSpot(4, 5),
                      FlSpot(5, 3),
                      FlSpot(6, 4),
                    ],
                    isCurved: true,
                    gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryLight]),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [AppTheme.primary.withOpacity(0.3), AppTheme.primary.withOpacity(0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acções Rápidas',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionItem(
          'Rever Novos Utilizadores',
          '3 agricultores aguardam aprovação',
          Icons.person_add_rounded,
          AppTheme.primary,
        ),
        const SizedBox(height: 12),
        _buildActionItem(
          'Relatório de Vendas',
          'Exportar dados do último mês em PDF',
          Icons.file_download_rounded,
          AppTheme.secondary,
        ),
      ],
    );
  }

  Widget _buildActionItem(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppTheme.outline,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.outline),
        ],
      ),
    );
  }
}
