import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class CompradorOrdersScreen extends StatefulWidget {
  const CompradorOrdersScreen({super.key});

  @override
  State<CompradorOrdersScreen> createState() => _CompradorOrdersScreenState();
}

class _CompradorOrdersScreenState extends State<CompradorOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderService _orderService = OrderService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  final List<_TabFilter> _tabs = const [
    _TabFilter(label: 'Todos', status: null),
    _TabFilter(label: 'Pendente', status: AgriStatus.pendente),
    _TabFilter(label: 'Confirmado', status: AgriStatus.confirmado),
    _TabFilter(label: 'Enviado', status: AgriStatus.enviado),
    _TabFilter(label: 'Entregue', status: AgriStatus.entregue),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final userStr = await _storage.read(key: "user");
      if (userStr != null) {
        final userData = jsonDecode(userStr);
        final userId = userData['id'];
        if (userId != null) {
          final orders = await _orderService.getBuyerOrders(userId);
          if (mounted) {
            setState(() {
              _orders = orders;
              _isLoading = false;
            });
          }
          return;
        }
      }
    } catch (e) {
      print('Erro ao carregar pedidos: $e');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderModel> _filteredOrders(AgriStatus? status) {
    if (status == null) return _orders;
    return _orders.where((o) => o.status == status).toList();
  }

  void _cancelOrder(String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Cancelar Pedido',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppTheme.onSurface,
          ),
        ),
        content: Text(
          'Tem certeza que deseja cancelar o pedido $orderId? Esta ação não pode ser desfeita.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Manter',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              
              // Show loading or optimistic update
              final success = await _orderService.cancelOrder(orderId);
              
              if (success && mounted) {
                setState(() {
                  final idx = _orders.indexWhere((o) => o.id == orderId);
                  if (idx != -1) {
                    _orders[idx] = OrderModel(
                      id: _orders[idx].id,
                      productName: _orders[idx].productName,
                      sellerName: _orders[idx].sellerName,
                      sellerProvince: _orders[idx].sellerProvince,
                      totalAoa: _orders[idx].totalAoa,
                      quantity: _orders[idx].quantity,
                      unit: _orders[idx].unit,
                      status: AgriStatus.cancelado,
                      deliveryDate: _orders[idx].deliveryDate,
                      placedAt: _orders[idx].placedAt,
                      category: _orders[idx].category,
                    );
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Pedido $orderId cancelado.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: AppTheme.errorColor,
                    behavior: SnackBarBehavior.fixed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Erro ao cancelar pedido.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: AppTheme.errorColor,
                    behavior: SnackBarBehavior.fixed,
                  ),
                );
              }
            },
            child: Text(
              'Cancelar Pedido',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Meus Pedidos',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filtrar',
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.onSurfaceVariant,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 2.5,
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) {
          final filtered = _filteredOrders(tab.status);
          if (filtered.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: 'Nenhum pedido encontrado',
              description: 'Os seus pedidos aparecerão aqui.',
            );
          }
          return isTablet
              ? _TabletOrderList(orders: filtered, onCancel: _cancelOrder)
              : _PhoneOrderList(orders: filtered, onCancel: _cancelOrder);
        }).toList() as List<Widget>,
      ),
    );
  }
}

class _TabFilter {
  final String label;
  final AgriStatus? status;
  const _TabFilter({required this.label, required this.status});
}

// ── Phone Layout ──────────────────────────────────────────────────────────────

class _PhoneOrderList extends StatelessWidget {
  final List<OrderModel> orders;
  final void Function(String) onCancel;

  const _PhoneOrderList({required this.orders, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _OrderCard(order: orders[index], onCancel: onCancel),
    );
  }
}

// ── Tablet Layout ─────────────────────────────────────────────────────────────

class _TabletOrderList extends StatelessWidget {
  final List<OrderModel> orders;
  final void Function(String) onCancel;

  const _TabletOrderList({required this.orders, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.55,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) =>
          _OrderCard(order: orders[index], onCancel: onCancel),
    );
  }
}

// ── Order Card ────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final void Function(String) onCancel;

  const _OrderCard({required this.order, required this.onCancel});

  static String _formatAoa(double v) {
    final parts = v.toStringAsFixed(0).split('');
    final result = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) result.write('.');
      result.write(parts[i]);
    }
    return result.toString();
  }

  bool get _canCancel =>
      order.status == AgriStatus.pendente ||
      order.status == AgriStatus.confirmado;

  Color get _categoryColor {
    switch (order.category) {
      case 'Cereais':
        return const Color(0xFFE9A825);
      case 'Leguminosas':
        return const Color(0xFF52B788);
      case 'Hortícolas':
        return const Color(0xFF2D6A4F);
      case 'Tubérculos':
        return const Color(0xFFB45309);
      case 'Oleaginosas':
        return const Color(0xFF1565C0);
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _categoryColor.withAlpha(20),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _categoryColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.category,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _categoryColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  order.id,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name + status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        order.productName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadgeWidget(status: order.status, compact: true),
                  ],
                ),
                const SizedBox(height: 6),

                // Quantity + total
                Row(
                  children: [
                    Icon(
                      Icons.scale_rounded,
                      size: 13,
                      color: AppTheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${order.quantity.toStringAsFixed(0)} ${order.unit}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_formatAoa(order.totalAoa)} AOA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Divider
                Divider(
                  height: 1,
                  color: AppTheme.outlineVariant.withAlpha(120),
                ),
                const SizedBox(height: 10),

                // Seller info
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: AppTheme.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.sellerName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 10,
                                color: AppTheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                order.sellerProvince,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Delivery date + placed at
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Entrega: ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      order.deliveryDate,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      order.placedAt,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Cancel button (only for cancellable statuses)
          if (_canCancel)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => onCancel(order.id),
                  icon: const Icon(Icons.cancel_outlined, size: 15),
                  label: Text(
                    'Cancelar Pedido',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    side: BorderSide(
                      color: AppTheme.errorColor.withAlpha(160),
                      width: 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 14),
        ],
      ),
    );
  }
}