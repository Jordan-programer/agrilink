import 'package:agrilink_app/models/forecast_model.dart';
import 'package:agrilink_app/services/ai_forecast_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/udp_client_service.dart';
import '../../../theme/app_theme.dart';

class AiForecastWidget extends StatefulWidget {
  const AiForecastWidget({super.key});

  @override
  State<AiForecastWidget> createState() => _AiForecastWidgetState();
}

class _AiForecastWidgetState extends State<AiForecastWidget> {
  final AiForecastService _service = AiForecastService();

  List<ForecastModel> _forecasts = [];
  bool _loading = true;
  String _liveUdpStatus = "A aguardar satélite...";
  double _liveAvgPrice = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _service.getForecasts();

      setState(() {
        _forecasts = data;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Erro IA: $e");
      setState(() => _loading = false);
    }
    
    // Fetch Live UDP Data (RSC06)
    _fetchLiveUdp();
  }

  Future<void> _fetchLiveUdp() async {
    final udpData = await UdpClientService.fetchMarketPrices();
    if (udpData != null && mounted) {
      setState(() {
        _liveAvgPrice = (udpData['avgPrice'] ?? 0).toDouble();
        _liveUdpStatus = "Conectado · Atualização em Tempo Real (UDP)";
      });
    } else if (mounted) {
      setState(() {
        _liveUdpStatus = "Offline (Sem conexão UDP)";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 15,
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Previsão de Demanda IA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Baseado em Machine Learning · Atualizado',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppTheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        if (_liveAvgPrice > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.satellite_alt_rounded, size: 14, color: AppTheme.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$_liveUdpStatus | Preço Médio Global: $_liveAvgPrice AOA/kg',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppTheme.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 10),

        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _forecasts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = _forecasts[index];

              return Container(
                width: 120,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.bgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: item.color.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(item.icon, size: 14, color: item.color),
                        const SizedBox(width: 4),
                        Text(
                          item.change,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: item.color,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      item.product,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item.demand,
                      style: TextStyle(
                        fontSize: 11,
                        color: item.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}