import 'dart:convert';
import 'package:agrilink_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import 'package:http/http.dart' as http;

class TransporterScreen extends StatefulWidget {
  const TransporterScreen({super.key});

  @override
  State<TransporterScreen> createState() => _TransporterScreenState();
}

class _TransporterScreenState extends State<TransporterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _storage = const FlutterSecureStorage();
  
  bool _isLoading = true;
  String _userId = '';
  List<dynamic> _availableLoads = [];
  List<dynamic> _myLoads = [];
  bool _isOptimizing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final id = await _storage.read(key: "userId");
      if (id != null) {
        _userId = id;
      }

      final api = ApiService();
      
      // Carregar cargas disponíveis
      final availableRes = await api.get('/orders/transport/available');
      if (availableRes.statusCode == 200) {
        _availableLoads = jsonDecode(utf8.decode(availableRes.bodyBytes));
      }

      // Carregar meus fretes se logado
      if (_userId.isNotEmpty) {
        final myRes = await api.get('/orders/transport/transporter/$_userId');
        if (myRes.statusCode == 200) {
          _myLoads = jsonDecode(utf8.decode(myRes.bodyBytes));
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar fretes: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptLoad(int orderId) async {
    if (_userId.isEmpty) {
      _showSnack('Tem de iniciar sessão primeiro.', isError: true);
      return;
    }

    try {
      final token = await _storage.read(key: "token");
      final uri = Uri.parse("http://72.62.83.244:8080/orders/$orderId/transport/accept/$_userId");
      
      final response = await http.put(
        uri,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        _showSnack('Carga aceite com sucesso!');
        _loadData(); // recarrega as listas
        _tabController.animateTo(1); // Mudar para a aba dos meus fretes
      } else {
        _showSnack('Falha ao aceitar carga. Alguém já pode ter aceite.', isError: true);
      }
    } catch (e) {
      _showSnack('Erro de ligação.', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.plusJakartaSans()),
        backgroundColor: isError ? AppTheme.warning : AppTheme.success,
      )
    );
  }

  Future<void> _optimizeRoutesWithAI() async {
    setState(() => _isOptimizing = true);
    try {
      final response = await ApiService().get('/ai/optimize-routes?province=Luanda');
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(child: Text(data['aiMessage'], style: GoogleFonts.plusJakartaSans(fontSize: 13))),
              ],
            ),
            backgroundColor: Colors.teal.shade700,
            duration: const Duration(seconds: 4),
          )
        );
        
        // Mock reorganization of list (just reversing it to simulate change)
        setState(() {
          _availableLoads = _availableLoads.reversed.toList();
        });
      }
    } catch (e) {
      _showSnack('Erro ao contactar a IA Logística', isError: true);
    } finally {
      setState(() => _isOptimizing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text(
          'Logística & Transporte',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.outline,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [
            Tab(text: 'Cargas Disponíveis'),
            Tab(text: 'Meus Fretes'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAvailableLoadsList(),
                _buildMyLoadsList(),
              ],
            ),
    );
  }

  Widget _buildAvailableLoadsList() {
    if (_availableLoads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined, size: 64, color: AppTheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'Nenhuma carga disponível',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isOptimizing ? null : _optimizeRoutesWithAI,
              icon: _isOptimizing 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome_rounded, size: 18),
              label: Text(
                'Otimizar Rotas com IA (Agrupar)',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _availableLoads.length,
            itemBuilder: (context, index) {
              final load = _availableLoads[index];
              return _buildLoadCard(load, isAvailable: true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMyLoadsList() {
    if (_userId.isEmpty) {
      return Center(
        child: Text(
          'Inicie sessão para ver os seus fretes',
          style: GoogleFonts.plusJakartaSans(fontSize: 16, color: AppTheme.outline),
        ),
      );
    }

    if (_myLoads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: AppTheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'Não tem fretes em curso',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myLoads.length,
      itemBuilder: (context, index) {
        final load = _myLoads[index];
        return _buildLoadCard(load, isAvailable: false);
      },
    );
  }

  Widget _buildLoadCard(dynamic load, {required bool isAvailable}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CABEÇALHO DO CARD
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isAvailable ? AppTheme.primaryContainer : Colors.orange.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 20,
                      color: isAvailable ? AppTheme.primary : Colors.orange.shade800,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      load['productName'] ?? 'Carga',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isAvailable ? AppTheme.primary : Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${load['totalWeight']} kg',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          
          // CORPO DO CARD
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ROTA
                Row(
                  children: [
                    Column(
                      children: [
                        Icon(Icons.radio_button_checked, size: 16, color: AppTheme.primary),
                        Container(width: 2, height: 24, color: AppTheme.outlineVariant),
                        const Icon(Icons.location_on, size: 16, color: AppTheme.warning),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRoutePoint('Recolha', load['pickupProvince'], load['farmerName']),
                          const SizedBox(height: 12),
                          _buildRoutePoint('Entrega', load['dropoffProvince'], load['buyerName']),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1),
                ),
                
                // RODAPÉ COM VALOR E BOTÃO
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Valor a Receber',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppTheme.outline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${load['transportPayout']} AOA',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    if (isAvailable)
                      FilledButton.icon(
                        onPressed: () => _acceptLoad(load['numericId']),
                        icon: const Icon(Icons.local_shipping_rounded, size: 18),
                        label: Text('Aceitar', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      )
                    else
                       Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'EM TRÂNSITO',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutePoint(String label, String? province, String? person) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.outline,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          province ?? 'Desconhecido',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurface,
          ),
        ),
        Text(
          person ?? '',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppTheme.outline,
          ),
        ),
      ],
    );
  }
}
