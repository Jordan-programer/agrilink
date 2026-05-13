import 'package:agrilink_app/core/api/api_client.dart';
import 'package:agrilink_app/core/auth/jwt_manager.dart';
import 'package:agrilink_app/data/models/product_model.dart';
import 'package:agrilink_app/data/repositories/product_repository.dart';
import 'package:agrilink_app/presentation/publish_product_screen/publish_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_skeleton_widget.dart';
import './widgets/ai_forecast_widget.dart';
import './widgets/kpi_metrics_widget.dart';
import './widgets/marketplace_search_widget.dart';
import './widgets/price_chart_widget.dart';
import './widgets/product_card_widget.dart';


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

  // Animações
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  // Dados
  late final ProductRepository _repository;
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];

  final List<String> _categories = [
    'Todos', 'Cereais e Grãos', 'Hortaliças', 'Frutas', 'Raízes e Tubérculos', 'Insumos Agrícolas', 'Forragens','Outros',
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

    _loadProducts();
  }

@override
void dispose() {
  _fabAnimationController.dispose();
  super.dispose();
}

Future<void> _loadProducts() async {
  if (!mounted) return;

  setState(() => _isLoading = true);

  try {
    final data = await _repository.getProducts();

    if (!mounted) return;

    _products = data;

    _applyFilters(); // ✔ mais claro

    _fabAnimationController.forward();

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


  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: isTablet ? _buildTabletLayout(theme) : _buildPhoneLayout(theme),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton.extended(
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
            'Publicar Produto',
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
      bottomNavigationBar: _buildBottomNav(theme),
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
                const KpiMetricsWidget(),
                const SizedBox(height: 16),
                const AiForecastWidget(),
                const SizedBox(height: 16),
                const PriceChartWidget(),
                const SizedBox(height: 20),
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

  Widget _buildTabletLayout(ThemeData theme) {
    return Row(
      children: [
        NavigationRail(
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
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront_rounded),
              label: Text('Mercado'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: Text('Pedidos'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.local_shipping_outlined),
              selectedIcon: Icon(Icons.local_shipping_rounded),
              label: Text('Transporte'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: Text('Perfil'),
            ),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(child: _buildPhoneLayout(theme)),
      ],
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
        Stack(
          children: [
            IconButton(
              onPressed: () {},
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
                'M',
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
                'Produtos Disponíveis',
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
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
                  arguments: product,
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
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.storefront_outlined),
          selectedIcon: Icon(Icons.storefront_rounded),
          label: 'Mercado',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long_rounded),
          label: 'Pedidos',
        ),
        NavigationDestination(
          icon: Icon(Icons.local_shipping_outlined),
          selectedIcon: Icon(Icons.local_shipping_rounded),
          label: 'Transporte',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Perfil',
        ),
      ],
    );
  }
}
