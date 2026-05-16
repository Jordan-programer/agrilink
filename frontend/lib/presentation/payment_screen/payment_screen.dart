import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/cart_item_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class PaymentScreen extends StatefulWidget {
  final int orderId;
  final double totalAmount;
  final List<CartItemModel> cartItems;

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
    this.cartItems = const [],
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  XFile? _proofImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _proofImage = image;
      });
    }
  }

  Future<void> _handlePayment() async {
    if (_proofImage == null) {
      _showSnack('Por favor, carregue o comprovativo de pagamento.');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final bytes = await _proofImage!.readAsBytes();
      final base64String = base64Encode(bytes);
      
      final body = {
        "comprovativo": "data:image/jpeg;base64,$base64String"
      };

      final response = await ApiService().post('/orders/${widget.orderId}/upload-comprovativo', body);

      setState(() => _isProcessing = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        _showSnack('Erro ao enviar comprovativo: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showSnack('Erro: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.warning,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppTheme.surface,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.successContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'Comprovativo Enviado!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'O seu pagamento está em análise pelo administrador. A encomenda #${widget.orderId} será aprovada em breve.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(ctx); // fecha dialog
                Navigator.pop(context, true); // fecha ecrã de pagamento e retorna true
              },
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
              child: const Text('Voltar ao Início'),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Pagamento', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'Total a Pagar',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.totalAmount.toStringAsFixed(2)} AOA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Bank Coordinates
            Text(
              'Coordenadas Bancárias',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _buildCoordinateCard('BAI', '0040 0000 46975749101 70'),
            _buildCoordinateCard('BCI', '0005 0000 89119721101 97'),
            _buildCoordinateCard('Unitel Money', '934266089'),
            _buildCoordinateCard('Pagamento por Referência', 'Entidade: 10116\nReferência: 934266089\n\nEntidade: 00930\nReferência: 934266089'),
            
            const SizedBox(height: 24),
            
            // Upload Section
            Text(
              'Comprovativo',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.outlineVariant, style: BorderStyle.solid),
                ),
                child: _proofImage != null
                    ? Column(
                        children: [
                          const Icon(Icons.file_present_rounded, color: AppTheme.success, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            _proofImage!.name,
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          TextButton(
                            onPressed: _pickImage,
                            child: const Text('Alterar'),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          const Icon(Icons.cloud_upload_outlined, color: AppTheme.primary, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            'Carregar Comprovativo (Imagem ou PDF)',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Selecione a foto da transferência ou print screen',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.outline),
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: _isProcessing ? null : _handlePayment,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Enviar Comprovativo',
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinateCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.account_balance_rounded, size: 16, color: AppTheme.outline),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.outline)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
