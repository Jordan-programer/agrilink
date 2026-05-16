import 'dart:convert';
import 'package:agrilink_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/cart_item_model.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_image_widget.dart';
import '../payment_screen/payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: _buildAppBar(context, cart),
          body: cart.isEmpty
              ? _buildEmptyState(context)
              : _buildCartList(context, cart),
          bottomNavigationBar: cart.isEmpty
              ? null
              : _buildCheckoutBar(context, cart),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, CartProvider cart) {
    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      scrolledUnderElevation: 2,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meu Carrinho',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          if (!cart.isEmpty)
            Text(
              '${cart.totalItems} ${cart.totalItems == 1 ? 'produto' : 'produtos'}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.outline,
              ),
            ),
        ],
      ),
      actions: [
        if (!cart.isEmpty)
          TextButton.icon(
            onPressed: () => _confirmClearCart(context, cart),
            icon: const Icon(Icons.delete_sweep_rounded, size: 18, color: AppTheme.warning),
            label: Text(
              'Limpar',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.warning,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 56,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Carrinho Vazio',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione produtos do mercado\npara começar a sua encomenda.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppTheme.outline,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.storefront_rounded, color: Colors.white),
            label: Text(
              'Explorar Mercado',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(BuildContext context, CartProvider cart) {
    final farmerMap = cart.itemsByFarmer;
    final farmerIds = farmerMap.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: farmerIds.length + 1, // +1 for order summary
      itemBuilder: (context, index) {
        if (index < farmerIds.length) {
          final farmerId = farmerIds[index];
          final farmerItems = farmerMap[farmerId]!;
          return _buildFarmerSection(context, cart, farmerId, farmerItems);
        }
        return _buildOrderSummary(cart);
      },
    );
  }

  Widget _buildFarmerSection(
    BuildContext context,
    CartProvider cart,
    String farmerId,
    List<CartItemModel> items,
  ) {
    final farmer = items.first;
    final farmerSubtotal = items.fold(0.0, (sum, i) => sum + i.subtotal);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Farmer header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, Color(0xFF1B5E20)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      farmer.farmerName.isNotEmpty
                          ? farmer.farmerName[0].toUpperCase()
                          : 'A',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmer.farmerName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 11, color: AppTheme.outline),
                          const SizedBox(width: 3),
                          Text(
                            farmer.farmerProvince,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.outline,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${items.length} ${items.length == 1 ? 'produto' : 'produtos'}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Subtotal',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: AppTheme.outline,
                      ),
                    ),
                    Text(
                      '${farmerSubtotal.toStringAsFixed(0)} AOA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Items
          ...items.map(
            (item) => _buildCartItem(context, cart, item, isLast: item == items.last),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartProvider cart,
    CartItemModel item, {
    required bool isLast,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: item.imageUrl != null
                      ? CustomImageWidget(
                          imageUrl: item.imageUrl!,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppTheme.primaryContainer.withOpacity(0.3),
                          child: const Icon(
                            Icons.eco_rounded,
                            color: AppTheme.primary,
                            size: 32,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.productName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => cart.removeItem(item.productId),
                          icon: const Icon(Icons.close_rounded, size: 18),
                          color: AppTheme.outline,
                          style: IconButton.styleFrom(
                            minimumSize: const Size(28, 28),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.pricePerUnit.toStringAsFixed(0)} AOA / ${item.unit}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.outline,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Quantity controls
                        _QuantityControl(
                          item: item,
                          onChanged: (qty) => cart.updateQuantity(item.productId, qty),
                        ),
                        const Spacer(),
                        Text(
                          '${item.subtotal.toStringAsFixed(0)} AOA',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.onSurface,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 14, endIndent: 14, color: AppTheme.outlineVariant),
      ],
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo da Encomenda',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _summaryRow('Subtotal', '${cart.totalAoa.toStringAsFixed(0)} AOA'),
          const SizedBox(height: 8),
          _summaryRow('Taxa de serviço (2%)', '${(cart.totalAoa * 0.02).toStringAsFixed(0)} AOA'),
          const SizedBox(height: 8),
          const Divider(color: AppTheme.outlineVariant),
          const SizedBox(height: 8),
          _summaryRow(
            'Total',
            '${(cart.totalAoa * 1.02).toStringAsFixed(0)} AOA',
            isTotal: true,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Um único pedido será criado com todos os produtos dos ${cart.itemsByFarmer.length} agricultores.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w400,
            color: isTotal ? AppTheme.onSurface : AppTheme.outline,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isTotal ? 17 : 13,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            color: isTotal ? AppTheme.primary : AppTheme.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartProvider cart) {
    final total = cart.totalAoa * 1.02;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total a pagar',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppTheme.outline,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${total.toStringAsFixed(0)} AOA',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _handleCheckout(context, cart, total),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.shopping_bag_rounded, color: Colors.white),
              label: Text(
                'Confirmar Encomenda',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _handleCheckout(BuildContext context, CartProvider cart, double total) async {
    const storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Utilizador não autenticado.')),
      );
      return;
    }

    // Prepare items for backend
    final List<Map<String, dynamic>> items = cart.items.map((item) => {
      "produtoId": int.tryParse(item.productId) ?? 0,
      "quantidade": item.quantity.toInt(),
      "preco": item.pricePerUnit
    }).toList();

    final Map<String, dynamic> body = {
      "compradorId": userId,
      "items": items
    };

    try {
      final response = await ApiService().post('/orders', body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final orderId = data['id']; // This is the Long ID from backend

        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentScreen(
              orderId: orderId,
              totalAmount: total,
              cartItems: cart.items,
            ),
          ),
        );
        if (result == true && context.mounted) {
          await cart.clearCart();
          if (context.mounted) Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar pedido: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha de conexão: $e')),
      );
    }
  }

  Future<void> _confirmClearCart(BuildContext context, CartProvider cart) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Limpar Carrinho',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Tem certeza que deseja remover todos os produtos do carrinho?',
          style: GoogleFonts.plusJakartaSans(color: AppTheme.outline, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: GoogleFonts.plusJakartaSans()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.warning),
            child: Text('Limpar', style: GoogleFonts.plusJakartaSans()),
          ),
        ],
      ),
    );
    if (confirmed == true) await cart.clearCart();
  }
}

// ── Quantity Control Widget ──────────────────────────────────────────────────

class _QuantityControl extends StatefulWidget {
  final CartItemModel item;
  final ValueChanged<double> onChanged;

  const _QuantityControl({required this.item, required this.onChanged});

  @override
  State<_QuantityControl> createState() => _QuantityControlState();
}

class _QuantityControlState extends State<_QuantityControl> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.item.quantity.toStringAsFixed(
        widget.item.quantity % 1 == 0 ? 0 : 1,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleButton(
          icon: Icons.remove_rounded,
          onTap: () {
            final newQty = widget.item.quantity - 1;
            if (newQty >= 1) {
              _controller.text = newQty.toStringAsFixed(newQty % 1 == 0 ? 0 : 1);
              widget.onChanged(newQty);
            }
          },
        ),
        SizedBox(
          width: 52,
          child: TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
            ],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              border: InputBorder.none,
              suffixText: widget.item.unit,
              suffixStyle: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: AppTheme.outline,
              ),
            ),
            onSubmitted: (v) {
              final qty = double.tryParse(v) ?? widget.item.quantity;
              widget.onChanged(qty < 1 ? 1 : qty);
            },
          ),
        ),
        _CircleButton(
          icon: Icons.add_rounded,
          onTap: () {
            final newQty = widget.item.quantity + 1;
            _controller.text = newQty.toStringAsFixed(newQty % 1 == 0 ? 0 : 1);
            widget.onChanged(newQty);
          },
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppTheme.primaryContainer.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 16, color: AppTheme.primary),
      ),
    );
  }
}
