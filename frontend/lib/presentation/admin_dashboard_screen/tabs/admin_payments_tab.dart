import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import 'dart:convert';

class AdminPaymentsTab extends StatefulWidget {
  const AdminPaymentsTab({super.key});

  @override
  State<AdminPaymentsTab> createState() => _AdminPaymentsTabState();
}

class _AdminPaymentsTabState extends State<AdminPaymentsTab> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService().get('/orders/all');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          // Filter orders that have a proof of payment and are still pending
          _orders = data.where((order) => 
            order['comprovativoBase64'] != null
          ).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack('Erro ao carregar pagamentos: $e');
    }
  }

  Future<void> _approvePayment(String orderId) async {
    final numericId = orderId.replaceAll('PED-', '');
    
    try {
      final response = await ApiService().post('/orders/$numericId/approve-payment', {});
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnack('Pagamento aprovado com sucesso!', isError: false);
        _loadOrders(); // Reload list
      } else {
        _showSnack('Erro ao aprovar pagamento: ${response.statusCode}');
      }
    } catch (e) {
      _showSnack('Erro: $e');
    }
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppTheme.warning : AppTheme.success,
      ),
    );
  }

  void _viewProof(String? base64) {
    if (base64 == null) return;

    Widget content;
    if (base64.startsWith('data:image')) {
      final base64Clean = base64.split(',')[1];
      final bytes = base64Decode(base64Clean);
      content = Image.memory(bytes, fit: BoxFit.contain);
    } else {
      content = const Center(child: Text('Formato de arquivo não suportado para visualização direta.'));
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Comprovativo', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: double.maxFinite,
          child: content,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          )
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color containerColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'aprovado':
        containerColor = AppTheme.successContainer;
        textColor = AppTheme.success;
        label = 'Aprovado';
        break;
      case 'cancelado':
        containerColor = AppTheme.errorContainer;
        textColor = AppTheme.errorColor;
        label = 'Cancelado';
        break;
      case 'pendente':
      default:
        containerColor = AppTheme.warningContainer;
        textColor = AppTheme.warning;
        label = 'Pendente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: textColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded, size: 64, color: AppTheme.outline),
            const SizedBox(height: 16),
            Text(
              'Nenhum pagamento encontrado',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.outline),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order['id'],
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppTheme.primary),
                  ),
                  _buildStatusBadge(order['status']),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                order['productName'] ?? 'Produto',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Text(
                'Por: ${order['sellerName'] ?? 'Agricultor'}',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.outline),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order['totalAoa'].toStringAsFixed(2)} AOA',
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.onSurface),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _viewProof(order['comprovativoBase64']),
                        icon: const Icon(Icons.visibility_outlined, size: 16),
                        label: const Text('Ver'),
                      ),
                      const SizedBox(width: 8),
                      if (order['status'] == 'pendente')
                        FilledButton(
                          onPressed: () => _approvePayment(order['id']),
                          style: FilledButton.styleFrom(backgroundColor: AppTheme.success),
                          child: const Text('Aprovar'),
                        ),
                    ],
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
