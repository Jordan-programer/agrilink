import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import 'dart:convert';
import '../../../../core/api/api_client.dart';
import '../../../../core/auth/jwt_manager.dart';

class AdminTransportsTab extends StatefulWidget {
  const AdminTransportsTab({super.key});

  @override
  State<AdminTransportsTab> createState() => _AdminTransportsTabState();
}

class _AdminTransportsTabState extends State<AdminTransportsTab> {
  List<dynamic> _transports = [];
  bool _isLoading = true;
  final ApiClient _apiClient = ApiClient(JwtManager());

  @override
  void initState() {
    super.initState();
    _fetchTransports();
  }

  Future<void> _fetchTransports() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get('/transports');
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _transports = jsonDecode(utf8.decode(response.bodyBytes));
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTransport(dynamic id) async {
    try {
      final response = await _apiClient.delete('/transports/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        _fetchTransports();
        _showSnack('Rota removida com sucesso');
      }
    } catch (e) {
      _showSnack('Erro ao remover: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.warning),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_transports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined, size: 64, color: AppTheme.outline.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('Nenhuma rota cadastrada'),
            TextButton(onPressed: _fetchTransports, child: const Text('Actualizar')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchTransports,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;
          final isDesktop = constraints.maxWidth >= 900;
          
          if (isTablet) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 3 : 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _transports.length,
              itemBuilder: (context, index) => _buildTransportCard(_transports[index]),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _transports.length,
            itemBuilder: (context, index) => _buildTransportCard(_transports[index]),
          );
        },
      ),
    );
  }

  Widget _buildTransportCard(dynamic transport) {
    final id = transport['id'];
    final origem = transport['origem'] ?? 'N/A';
    final destino = transport['destino'] ?? 'N/A';
    final status = transport['transporte'] ?? 'DESCONHECIDO';
    final dataPartida = transport['dataPartida'] ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryContainer.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.local_shipping_rounded, color: AppTheme.primary),
        ),
        title: Text('$origem ➔ $destino', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Partida: $dataPartida', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.outline)),
            const SizedBox(height: 4),
            _buildStatusChip(status),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor),
          onPressed: () => _confirmDelete(id, '$origem ➔ $destino'),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = AppTheme.outline;
    if (status == 'EM_TRANSITO') color = AppTheme.primary;
    if (status == 'ENTREGUE') color = AppTheme.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Future<void> _confirmDelete(dynamic id, String route) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover Rota?'),
        content: Text('Deseja remover a rota "$route"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteTransport(id);
    }
  }
}
