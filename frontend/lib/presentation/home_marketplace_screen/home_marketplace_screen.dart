import 'dart:convert';
import 'package:agrilink_app/core/api/api_client.dart';
import 'package:agrilink_app/core/auth/jwt_manager.dart';
import 'package:agrilink_app/data/models/product_model.dart';
import 'package:agrilink_app/data/repositories/product_repository.dart';
import 'package:agrilink_app/presentation/publish_product_screen/publish_product_screen.dart';
import 'package:agrilink_app/presentation/profile_screen/profile_screen.dart';
import 'package:agrilink_app/presentation/transporter_screen/transporter_screen.dart';
import 'package:agrilink_app/presentation/comprador_orders_screen/comprador_orders_screen.dart';
import 'package:agrilink_app/presentation/admin_catalog_screen/admin_catalog_screen.dart';
import 'package:agrilink_app/presentation/admin_dashboard_screen/admin_dashboard_screen.dart';
import 'package:agrilink_app/presentation/notifications_screen/notifications_screen.dart';
import 'package:agrilink_app/presentation/chatbot_screen/chatbot_screen.dart';
import 'package:agrilink_app/presentation/cart_screen/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_skeleton_widget.dart';
import './widgets/ai_forecast_widget.dart';
import './widgets/kpi_metrics_widget.dart';
import './widgets/marketplace_search_widget.dart';
import './widgets/price_chart_widget.dart';
import './widgets/product_card_widget.dart';
import './widgets/farmers_list_tab_widget.dart';

class NavItemDef {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget screen;

  NavItemDef(this.icon, this.selectedIcon, this.label, this.screen);
}

class HomeMarketplaceScreen extends StatefulWidget {
  const HomeMarketplaceScreen({super.key});

  @override
  State<HomeMarketplaceScreen> createState() => _HomeMarketplaceScreenState();
}

class _HomeMarketplaceScreenState extends State<HomeMarketplaceScreen>
    with TickerProviderStateMixin {
  int _selectedNavIndex = 0;
  String _selectedCategory = 'Todos';
  String _searchQuery = '';
  bool _isLoading = true;

  String _userRole = 'COMPRADOR'; // Default
  String _userId = '';           // Current logged-in user ID
  List<NavItemDef> _navItems = [];

  // Animações
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  // Dados
  late final ProductRepository _repository;
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];

  final List<String> _categories = [
    'Todos', 
    'Cereais e Grãos', 
    'Hortaliças', 
    'Frutas', 
    'Raízes e Tubérculos', 
    'Insumos Agrícolas', 
    'Forragens',
    'Leguminosas',
    'Oleaginosas',
    'Especiarias',
    'Produtos Animais',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();

    _repository = ProductRepository(
      ApiClient(JwtManager()),
    );

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _loadUserRole();
    _loadProducts();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: "token");
    if (token == null || token.isEmpty) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signUpLoginScreen, (route) => false);
      }
      return;
    }

    final userStr = await storage.read(key: "user");
    if (userStr != null) {
      final userJson = jsonDecode(userStr);
      if (mounted) {
        setState(() {
          _userRole = userJson['tipo'] ?? 'COMPRADOR';
          _userId = userJson['id']?.toString() ?? '';
          _buildNavItems();
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _buildNavItems();
        });
      }
    }
  }

  void _buildNavItems() {
    _navItems = [];
    
    // Configuração baseada na função RBAC
    if (_userRole == 'AGRICULTOR') {
      _navItems.add(NavItemDef(Icons.storefront_outlined, Icons.storefront_rounded, 'Mercado', const SizedBox.shrink()));
      _navItems.add(NavItemDef(Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Pedidos', const CompradorOrdersScreen()));
      _navItems.add(NavItemDef(Icons.person_outline_rounded, Icons.person_rounded, 'Perfil', const ProfileScreen()));
    } else if (_userRole == 'TRANSPORTADOR') {
      _navItems.add(NavItemDef(Icons.local_shipping_outlined, Icons.local_shipping_rounded, 'Logística', const TransporterScreen()));
      _navItems.add(NavItemDef(Icons.person_outline_rounded, Icons.person_rounded, 'Perfil', const ProfileScreen()));
    } else if (_userRole == 'ADMIN') {
      // ADMIN routing is handled directly in the build method, but we add a dummy item to avoid empty state
      _navItems.add(NavItemDef(Icons.admin_panel_settings, Icons.admin_panel_settings, 'Admin', const SizedBox.shrink()));
    } else {
      // COMPRADOR
      _navItems.add(NavItemDef(Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Produtos', const SizedBox.shrink()));
      _navItems.add(NavItemDef(Icons.groups_outlined, Icons.groups_rounded, 'Agricultores', const SizedBox.shrink()));
      _navItems.add(NavItemDef(Icons.local_shipping_outlined, Icons.local_shipping_rounded, 'Rastreamento', const CompradorOrdersScreen()));
      _navItems.add(NavItemDef(Icons.person_outline_rounded, Icons.person_rounded, 'Perfil', const ProfileScreen()));
    }
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final data = await _repository.getProducts();

      if (!mounted) return;

      _products = data;
      _applyFilters(); 
      
      if (_userRole == 'AGRICULTOR') {
        _fabAnimationController.forward();
      }
    } catch (e) {
      debugPrint("Erro ao carregar produtos: $e");
      if (!mounted) return;
      _products = [];
      _filteredProducts = [];
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilters() {
    final query = _searchQuery.toLowerCase();

    final filtered = _products.where((p) {
      final matchesCategory =
          _selectedCategory == 'Todos' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.farmerName.toLowerCase().contains(query) ||
          p.province.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();

    if (!mounted) return;

    setState(() {
      _filteredProducts = filtered;
    });
  }

  Widget _getActiveScreen(ThemeData theme, bool isTablet) {
    if (_navItems.isEmpty) return const SizedBox.shrink();
    if (_selectedNavIndex >= _navItems.length) {
      // Fallback in case of role change
      return const SizedBox.shrink(); 
    }
    
    final label = _navItems[_selectedNavIndex].label;
    
    if (label == 'Mercado' || label == 'Produtos') {
      return _buildPhoneLayout(theme);
    } else if (label == 'Agricultores') {
      return FarmersListTabWidget(allProducts: _products);
    } else {
      return _navItems[_selectedNavIndex].screen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final theme = Theme.of(context);

    if (_navItems.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_userRole == 'ADMIN') {
      return const AdminDashboardScreen();
    }

    if (_selectedNavIndex >= _navItems.length) {
      _selectedNavIndex = 0;
    }

    if (isTablet) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Row(
          children: [
            _buildNavigationRail(theme),
            const VerticalDivider(width: 1),
            Expanded(
              child: _getActiveScreen(theme, isTablet),
            ),
          ],
        ),
        floatingActionButton: _buildFloatingActionButtons(),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _getActiveScreen(theme, isTablet),
      floatingActionButton: _buildFloatingActionButtons(),
      bottomNavigationBar: _buildBottomNav(theme),
    );
  }

  Widget? _buildFloatingActionButtons() {
    // Se não for a aba principal, só mostra o Chatbot
    if (_navItems.isEmpty || _selectedNavIndex >= _navItems.length) return null;

    final isMarket = _navItems[_selectedNavIndex].label == 'Mercado';

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // FAB do Chatbot (Sempre visível para todos os perfis)
        FloatingActionButton(
          heroTag: 'chatbot_fab',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatbotScreen()),
            );
          },
          backgroundColor: Colors.teal,
          child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
        ),
        
        // FAB de Publicar Produto (Só para Agricultor no Mercado)
        if (_userRole == 'AGRICULTOR' && isMarket) ...[
          const SizedBox(height: 16),
          ScaleTransition(
            scale: _fabScaleAnimation,
            child: FloatingActionButton.extended(
              heroTag: 'publish_fab',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PublishProductScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'Publicar',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppTheme.primary,
              elevation: 4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhoneLayout(ThemeData theme) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(theme),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MarketplaceSearchWidget(
                  onChanged: (q) {
                    _searchQuery = q;
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading) ...[
                _buildSkeletonContent(),
              ] else ...[
                if (_userRole != 'COMPRADOR') ...[
                  const KpiMetricsWidget(),
                  const SizedBox(height: 16),
                  const AiForecastWidget(),
                  const SizedBox(height: 16),
                  const PriceChartWidget(),
                  const SizedBox(height: 20),
                ],
                _buildCategoryFilter(theme),
                const SizedBox(height: 16),
                _buildProductGrid(theme),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationRail(ThemeData theme) {
    return NavigationRail(
      selectedIndex: _selectedNavIndex,
      onDestinationSelected: (i) => setState(() => _selectedNavIndex = i),
      labelType: NavigationRailLabelType.all,
      backgroundColor: AppTheme.surface,
      selectedIconTheme: const IconThemeData(
        color: AppTheme.primary,
        size: 24,
      ),
      unselectedIconTheme: const IconThemeData(
        color: AppTheme.outline,
        size: 24,
      ),
      selectedLabelTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppTheme.primary,
      ),
      unselectedLabelTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppTheme.outline,
      ),
      leading: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.agriculture_rounded,
                color: AppTheme.primary,
                size: 22,
              ),
            ),
          ],
        ),
      ),
      destinations: _navItems.map((item) {
        return NavigationRailDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon),
          label: Text(item.label),
        );
      }).toList(),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      pinned: true,
      snap: false,
      backgroundColor: AppTheme.surface,
      scrolledUnderElevation: 2,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.agriculture_rounded,
              color: AppTheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'AgriLink',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Angola',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppTheme.outline,
            ),
          ),
        ],
      ),
      actions: [
        // Cart icon with live badge — only for COMPRADOR
        if (_userRole == 'COMPRADOR')
          Consumer<CartProvider>(
            builder: (context, cart, _) => Stack(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: AppTheme.onSurface,
                    size: 24,
                  ),
                ),
                if (cart.totalItems > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppTheme.warning,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${cart.totalItems}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        Stack(
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                );
              },
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppTheme.onSurface,
                size: 24,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.warning,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () {},
            child: CircleAvatar(
              radius: 17,
              backgroundColor: AppTheme.primaryContainer,
              child: Text(
                _userRole.substring(0, 1),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                _userRole == 'AGRICULTOR' ? 'Os Meus Produtos' : 'Produtos Disponíveis',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${_filteredProducts.length} itens',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat;
              return InkWell(
                onTap: () {
                  setState(() => _selectedCategory = cat);
                  _applyFilters();
                },
                borderRadius: BorderRadius.circular(100),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(ThemeData theme) {
    if (_filteredProducts.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.grass_outlined,
        title: 'Nenhum produto encontrado',
        description:
            'Não há produtos nesta categoria actualmente. Tente outra categoria ou volte mais tarde.',
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    double childAspectRatio = 0.72;

    if (screenWidth >= 1200) {
      crossAxisCount = 5;
      childAspectRatio = 0.85;
    } else if (screenWidth >= 900) {
      crossAxisCount = 4;
      childAspectRatio = 0.8;
    } else if (screenWidth >= 600) {
      crossAxisCount = 3;
      childAspectRatio = 0.75;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 400)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: ProductCardWidget(
              product: product,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.productDetailOrderScreen,
                  arguments: {
                    'product': product,
                    'viewerRole': _userRole,
                    'viewerUserId': _userId,
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: List.generate(
              4,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                  child: const LoadingSkeletonWidget(
                    width: double.infinity,
                    height: 72,
                    borderRadius: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const LoadingSkeletonWidget(
            width: double.infinity,
            height: 56,
            borderRadius: 12,
          ),
          const SizedBox(height: 16),
          const LoadingSkeletonWidget(
            width: double.infinity,
            height: 180,
            borderRadius: 16,
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 4,
            itemBuilder: (_, __) => const ProductCardSkeletonWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(ThemeData theme) {
    return NavigationBar(
      selectedIndex: _selectedNavIndex,
      onDestinationSelected: (i) => setState(() => _selectedNavIndex = i),
      backgroundColor: AppTheme.surface,
      indicatorColor: AppTheme.primaryContainer,
      elevation: 8,
      shadowColor: Colors.black.withAlpha(26),
      destinations: _navItems.map((item) {
        return NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon),
          label: item.label,
        );
      }).toList(),
    );
  }
}
