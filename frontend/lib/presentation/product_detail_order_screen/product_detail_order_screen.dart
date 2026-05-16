import 'dart:convert';
import 'package:agrilink_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/cart_item_model.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_image_widget.dart';
import '../../widgets/status_badge_widget.dart';
import 'widgets/ai_price_badge_widget.dart';
import 'widgets/farmer_profile_card_widget.dart';
import 'widgets/order_summary_bar_widget.dart';
import 'widgets/payment_method_widget.dart';
import 'widgets/product_specs_widget.dart';
import 'widgets/quantity_selector_widget.dart';
import 'widgets/transport_options_widget.dart';
import '../payment_screen/payment_screen.dart';
import '../cart_screen/cart_screen.dart';
import '../product_manage_screen/product_manage_screen.dart';

class ProductDetailOrderScreen extends StatefulWidget {
  final Map<String, dynamic>? productArgs;
  final String viewerRole;
  final String viewerUserId;

  const ProductDetailOrderScreen({
    super.key,
    this.productArgs,
    this.viewerRole = 'COMPRADOR',
    this.viewerUserId = '',
  });

  @override
  State<ProductDetailOrderScreen> createState() =>
      _ProductDetailOrderScreenState();
}

class _ProductDetailOrderScreenState extends State<ProductDetailOrderScreen>
    with TickerProviderStateMixin {
  // TODO: Replace with [Riverpod/Bloc] for production
  double _selectedQuantity = 10.0;
  String _selectedPayment = 'Multicaixa Express';
  String? _selectedTransportId;
  bool _isBookmarked = false;
  late AnimationController _entranceController;
  late Animation<double> _entranceAnimation;
  late Animation<Offset> _slideAnimation;

  // Fallback product data if no args passed
  late Map<String, dynamic> _product;

  @override
  void initState() {
    super.initState();
    _product =
        widget.productArgs ??
        {
          'id': 'p001',
          'name': 'Tomate Fresco',
          'category': 'Vegetais',
          'farmerName': 'Manuel António Ferreira',
          'farmerRating': 4.8,
          'province': 'Bengo',
          'pricePerKg': 350.0,
          'provinceAvgPrice': 420.0,
          'quantityKg': 480.0,
          'harvestDate': '2026-04-08',
          'imageUrl':
              'https://images.unsplash.com/photo-1693946565918-72325e27e4af',
          'semanticLabel':
              'Fresh red tomatoes in a wooden crate on a farm in Angola',
          'status': 'available',
          'isFeatured': true,
          'isOrganic': false,
          'aiRecommended': true,
        };

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(_entranceAnimation);
    _entranceController.forward();

    // Redirect AGRICULTOR to manage screen if they own this product
    final farmerId = _product['farmerId'] as String? ?? '';
    final isOwner = widget.viewerRole == 'AGRICULTOR' &&
        farmerId.isNotEmpty &&
        farmerId == widget.viewerUserId;
    if (isOwner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProductManageScreen(product: _product),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  double get _totalPrice =>
      _selectedQuantity * (_product['pricePerKg'] as double);

  Future<void> _handleAddToCart(BuildContext context) async {
    final cart = context.read<CartProvider>();
    final item = CartItemModel(
      productId: _product['id'] as String? ?? DateTime.now().toString(),
      productName: _product['name'] as String? ?? 'Produto',
      farmerName: _product['farmerName'] as String? ?? 'Agricultor',
      farmerId: _product['farmerId'] as String? ?? _product['farmerName'] as String? ?? 'f0',
      farmerProvince: _product['province'] as String? ?? 'Luanda',
      pricePerUnit: _product['pricePerKg'] as double,
      unit: _product['unit'] as String? ?? 'kg',
      quantity: _selectedQuantity,
      imageUrl: _product['imageUrl'] as String?,
      category: _product['category'] as String? ?? 'Geral',
    );
    await cart.addItem(item);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${item.productName} adicionado ao carrinho!',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.fixed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Ver Carrinho',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
      bottomNavigationBar: OrderSummaryBarWidget(
        totalPrice: _totalPrice,
        quantity: _selectedQuantity,
        unit: _product['unit'] as String? ?? 'kg',
        selectedPayment: _selectedPayment,
        onOrder: _handleOrder,
        onAddToCart: () => _handleAddToCart(context),
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _entranceAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AiPriceBadgeWidget(
                    currentPrice: _product['pricePerKg'] as double,
                    avgPrice: _product['provinceAvgPrice'] as double,
                    province: _product['province'] as String,
                  ),
                  const SizedBox(height: 12),
                  FarmerProfileCardWidget(
                    farmerName: _product['farmerName'] as String,
                    rating: _product['farmerRating'] as double,
                    province: _product['province'] as String,
                    isVerified: true,
                    memberSince: 'Março 2024',
                    totalSales: 142,
                  ),
                  const SizedBox(height: 12),
                  ProductSpecsWidget(
                    category: _product['category'] as String,
                    quantityKg: _product['quantityKg'] as double,
                    harvestDate: _product['harvestDate'] as String,
                    isOrganic: _product['isOrganic'] as bool? ?? false,
                    province: _product['province'] as String,
                  ),
                  const SizedBox(height: 12),
                  QuantitySelectorWidget(
                    maxQuantity: _product['quantityKg'] as double,
                    pricePerUnit: _product['pricePerKg'] as double,
                    selectedQuantity: _selectedQuantity,
                    unit: _product['unit'] as String? ?? 'kg',
                    onQuantityChanged: (q) =>
                        setState(() => _selectedQuantity = q),
                  ),
                  const SizedBox(height: 12),
                  TransportOptionsWidget(
                    province: _product['province'] as String,
                    selectedTransportId: _selectedTransportId,
                    onTransportSelected: (id) =>
                        setState(() => _selectedTransportId = id),
                  ),
                  const SizedBox(height: 12),
                  PaymentMethodWidget(
                    selectedMethod: _selectedPayment,
                    onMethodChanged: (m) =>
                        setState(() => _selectedPayment = m),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: hero image + farmer card
        Expanded(
          flex: 5,
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    FarmerProfileCardWidget(
                      farmerName: _product['farmerName'] as String,
                      rating: _product['farmerRating'] as double,
                      province: _product['province'] as String,
                      isVerified: true,
                      memberSince: 'Março 2024',
                      totalSales: 142,
                    ),
                    const SizedBox(height: 12),
                    ProductSpecsWidget(
                      category: _product['category'] as String,
                      quantityKg: _product['quantityKg'] as double,
                      harvestDate: _product['harvestDate'] as String,
                      isOrganic: _product['isOrganic'] as bool? ?? false,
                      province: _product['province'] as String,
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Right: order form
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 16, 16, 120),
            child: Column(
              children: [
                AiPriceBadgeWidget(
                  currentPrice: _product['pricePerKg'] as double,
                  avgPrice: _product['provinceAvgPrice'] as double,
                  province: _product['province'] as String,
                ),
                const SizedBox(height: 12),
                QuantitySelectorWidget(
                  maxQuantity: _product['quantityKg'] as double,
                  pricePerUnit: _product['pricePerKg'] as double,
                  selectedQuantity: _selectedQuantity,
                  unit: _product['unit'] as String? ?? 'kg',
                  onQuantityChanged: (q) =>
                      setState(() => _selectedQuantity = q),
                ),
                const SizedBox(height: 12),
                TransportOptionsWidget(
                  province: _product['province'] as String,
                  selectedTransportId: _selectedTransportId,
                  onTransportSelected: (id) =>
                      setState(() => _selectedTransportId = id),
                ),
                const SizedBox(height: 12),
                PaymentMethodWidget(
                  selectedMethod: _selectedPayment,
                  onMethodChanged: (m) => setState(() => _selectedPayment = m),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppTheme.surface,
      scrolledUnderElevation: 2,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(230),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.onSurface,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(230),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  _isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  key: ValueKey(_isBookmarked),
                  color: _isBookmarked
                      ? AppTheme.secondary
                      : AppTheme.onSurface,
                  size: 20,
                ),
              ),
              onPressed: () => setState(() => _isBookmarked = !_isBookmarked),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(230),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.share_outlined,
                color: AppTheme.onSurface,
                size: 20,
              ),
              onPressed: () {},
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'product-image-${_product['id']}',
              child: CustomImageWidget(
                imageUrl: _product['imageUrl'] as String,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                semanticLabel:
                    _product['semanticLabel'] as String? ?? 'Product image',
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(26),
                    Colors.black.withAlpha(128),
                  ],
                  stops: const [0.4, 0.75, 1.0],
                ),
              ),
            ),
            // Product name overlay at bottom
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusBadgeWidget(
                        status: _statusFromString(
                          _product['status'] as String? ?? 'available',
                        ),
                        compact: true,
                      ),
                      const SizedBox(width: 8),
                      if (_product['isOrganic'] as bool? ?? false)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Biológico',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _product['name'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withAlpha(128),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_product['province']} · ${_product['category']}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.white.withAlpha(230),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AgriStatus _statusFromString(String s) {
    switch (s) {
      case 'reserved':
        return AgriStatus.reserved;
      case 'sold':
        return AgriStatus.sold;
      case 'low_stock':
        return AgriStatus.lowStock;
      default:
        return AgriStatus.available;
    }
  }

  void _handleOrder() {
    if (_selectedTransportId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor seleccione uma opção de transporte.',
            style: GoogleFonts.plusJakartaSans(fontSize: 13),
          ),
          backgroundColor: AppTheme.warning,
          behavior: SnackBarBehavior.fixed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOrderConfirmationSheet(),
    );
  }

  Widget _buildOrderConfirmationSheet() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_basket_rounded,
              color: AppTheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Confirmar Pedido',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_product['name']} · ${_selectedQuantity.toInt()} ${_product['unit'] ?? 'kg'}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppTheme.outline,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _buildConfirmRow('Produto', _product['name'] as String),
                _buildConfirmRow(
                  'Agricultor',
                  _product['farmerName'] as String,
                ),
                _buildConfirmRow(
                  'Quantidade',
                  '${_selectedQuantity.toInt()} ${_product['unit'] ?? 'kg'}',
                ),
                _buildConfirmRow(
                  'Preço/${_product['unit'] ?? 'kg'}',
                  'AOA ${(_product['pricePerKg'] as double).toInt()}',
                ),
                _buildConfirmRow('Pagamento', _selectedPayment),
                const Divider(height: 16),
                _buildConfirmRow(
                  'Total',
                  'AOA ${_totalPrice.toStringAsFixed(0)}',
                  isTotal: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close sheet
                
                final String userId = widget.viewerUserId;
                if (userId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro: Utilizador não autenticado.')),
                  );
                  return;
                }

                // Prepare items for backend
                final List<Map<String, dynamic>> items = [
                  {
                    "produtoId": _product['id'],
                    "quantidade": _selectedQuantity.toInt(),
                    "preco": _product['pricePerKg']
                  }
                ];

                final Map<String, dynamic> body = {
                  "compradorId": userId,
                  "items": items
                };

                try {
                  final response = await ApiService().post('/orders', body);
                  if (response.statusCode == 200) {
                    final data = jsonDecode(response.body);
                    final orderId = data['id']; // This is the Long ID from backend

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(
                          orderId: orderId,
                          totalAmount: _totalPrice,
                        ),
                      ),
                    );
                    if (result == true) {
                      // Payment successful, go back or show success
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Pedido feito e pago com sucesso!',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13),
                          ),
                          backgroundColor: AppTheme.success,
                          behavior: SnackBarBehavior.fixed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                      Navigator.pop(context); // go back to marketplace
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'Confirmar e Fazer Pedido',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.outline,
                side: const BorderSide(color: AppTheme.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Cancelar',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.outline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal ? AppTheme.onSurface : AppTheme.outline,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color: isTotal ? AppTheme.primary : AppTheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
