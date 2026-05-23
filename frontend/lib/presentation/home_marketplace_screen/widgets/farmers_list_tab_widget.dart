import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/auth/jwt_manager.dart';
import '../../../../data/models/product_model.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/empty_state_widget.dart';
import '../../../../widgets/loading_skeleton_widget.dart';
import 'package:agrilink_app/presentation/product_detail_order_screen/product_detail_order_screen.dart';

class FarmersListTabWidget extends StatefulWidget {
  final List<ProductModel> allProducts;
  const FarmersListTabWidget({super.key, required this.allProducts});

  @override
  State<FarmersListTabWidget> createState() => _FarmersListTabWidgetState();
}

class _FarmersListTabWidgetState extends State<FarmersListTabWidget> {
  List<dynamic> _farmers = [];
  List<dynamic> _filteredFarmers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedProvince = 'Todas';

  final ApiClient _apiClient = ApiClient(JwtManager());

  // Lista de províncias para filtro rápido
  final List<String> _provinces = [
    'Todas',
    'Luanda',
    'Bengo',
    'Benguela',
    'Bié',
    'Cabinda',
    'Cunene',
    'Huambo',
    'Huíla',
    'Kuando Kubango',
    'Kwanza Norte',
    'Kwanza Sul',
    'Lunda Norte',
    'Lunda Sul',
    'Malanje',
    'Moxico',
    'Namibe',
    'Uíge',
    'Zaire',
  ];

  @override
  void initState() {
    super.initState();
    _fetchFarmers();
  }

  Future<void> _fetchFarmers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await _apiClient.get('/users');
      if (response.statusCode == 200) {
        final List<dynamic> allUsers = jsonDecode(response.body);
        
        // Filtra apenas os usuários que são AGRICULTORES
        final farmersList = allUsers
            .where((u) => u['tipo']?.toString().toUpperCase() == 'AGRICULTOR')
            .toList();

        if (mounted) {
          setState(() {
            _farmers = farmersList;
            _applyFilters();
            _isLoading = false;
          });
        }
      } else {
        throw Exception("Erro ao carregar usuários: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Erro ao carregar agricultores: $e");
      if (mounted) {
        setState(() {
          _farmers = [];
          _filteredFarmers = [];
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    final query = _searchQuery.toLowerCase();
    
    final filtered = _farmers.where((farmer) {
      final matchesProvince = _selectedProvince == 'Todas' ||
          (farmer['provincia']?.toString().toLowerCase() == _selectedProvince.toLowerCase());

      final matchesSearch = query.isEmpty ||
          (farmer['nome']?.toString().toLowerCase().contains(query) ?? false) ||
          (farmer['email']?.toString().toLowerCase().contains(query) ?? false) ||
          (farmer['telefone']?.toString().toLowerCase().contains(query) ?? false);

      return matchesProvince && matchesSearch;
    }).toList();

    if (mounted) {
      setState(() {
        _filteredFarmers = filtered;
      });
    }
  }

  int _getProductCountForFarmer(String farmerId) {
    return widget.allProducts.where((p) => p.farmerId == farmerId).length;
  }

  List<ProductModel> _getProductsForFarmer(String farmerId) {
    return widget.allProducts.where((p) => p.farmerId == farmerId).toList();
  }

  Future<void> _makeCall(String phone) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint("Não foi possível realizar chamada para $phone");
    }
  }

  Future<void> _sendEmail(String email, String farmerName) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=AgriLink - Interesse em sua Produção&body=Olá $farmerName, vi o seu perfil no AgriLink...',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint("Não foi possível enviar e-mail para $email");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildProvinceFilter(),
            Expanded(
              child: _isLoading
                  ? _buildSkeletonGrid()
                  : _buildFarmersGrid(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agricultores Parceiros',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Apoie o produtor local de Angola comprando diretamente da fonte com total transparência.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppTheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (val) {
          _searchQuery = val;
          _applyFilters();
        },
        decoration: InputDecoration(
          hintText: 'Pesquisar por nome, telefone ou email...',
          hintStyle: GoogleFonts.plusJakartaSans(color: AppTheme.outline, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.outline),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildProvinceFilter() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _provinces.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prov = _provinces[index];
          final isSelected = _selectedProvince == prov;
          return InkWell(
            onTap: () {
              setState(() => _selectedProvince = prov);
              _applyFilters();
            },
            borderRadius: BorderRadius.circular(100),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: Text(
                prov,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFarmersGrid(ThemeData theme) {
    if (_filteredFarmers.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.people_outline_rounded,
        title: 'Nenhum agricultor encontrado',
        description: 'Não foram encontrados produtores que correspondam aos filtros de pesquisa selecionados.',
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 1;
    double childAspectRatio = 2.1;

    if (screenWidth >= 1200) {
      crossAxisCount = 3;
      childAspectRatio = 1.6;
    } else if (screenWidth >= 750) {
      crossAxisCount = 2;
      childAspectRatio = 1.5;
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: _filteredFarmers.length,
      itemBuilder: (context, index) {
        final farmer = _filteredFarmers[index];
        final String name = farmer['nome'] ?? 'Produtor Local';
        final String phone = farmer['telefone'] ?? 'Sem telefone';
        final String email = farmer['email'] ?? 'Sem email';
        final String province = farmer['provincia'] ?? 'Província Geral';
        final String plan = farmer['plano'] ?? 'Básico';
        final String farmerId = farmer['id']?.toString() ?? '';
        final int activeProducts = _getProductCountForFarmer(farmerId);

        return _buildFarmerCard(theme, farmerId, name, phone, email, province, plan, activeProducts);
      },
    );
  }

  Widget _buildFarmerCard(
    ThemeData theme,
    String id,
    String name,
    String phone,
    String email,
    String province,
    String plan,
    int activeProducts,
  ) {
    final String initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'A';
    final isPremium = plan.toUpperCase() == 'PREMIUM' || plan.toUpperCase() == 'OURO' || plan.toUpperCase() == 'PRO';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isPremium ? AppTheme.primary.withOpacity(0.2) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showFarmerDetails(name, phone, email, province, plan, id),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: isPremium ? AppTheme.primaryContainer : AppTheme.surfaceVariant,
                        child: Text(
                          initial,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: AppTheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isPremium)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      'PREMIUM',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.outline),
                                const SizedBox(width: 4),
                                Text(
                                  province,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppTheme.outline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // KPI do agricultor
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.grass_rounded, size: 16, color: AppTheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          '$activeProducts produtos ativos',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Ver Produção',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.outline,
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 16, color: AppTheme.outline),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Botões de contato rápidos
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _makeCall(phone),
                          icon: const Icon(Icons.phone_outlined, size: 15),
                          label: Text(
                            'Ligar',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            side: const BorderSide(color: AppTheme.primaryContainer),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _sendEmail(email, name),
                          icon: const Icon(Icons.mail_outline_rounded, size: 15),
                          label: Text(
                            'E-mail',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.secondary,
                            side: const BorderSide(color: AppTheme.secondaryContainer),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFarmerDetails(
    String name,
    String phone,
    String email,
    String province,
    String plan,
    String farmerId,
  ) {
    final products = _getProductsForFarmer(farmerId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                controller: scrollController,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppTheme.outlineVariant,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Header de perfil
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppTheme.primaryContainer,
                        child: Text(
                          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'A',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                'Plano ${plan.toUpperCase()}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Dados de contato
                  Text(
                    'Informações do Produtor',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildContactRow(Icons.location_on_outlined, 'Província', province),
                  _buildContactRow(Icons.phone_outlined, 'Telefone', phone, onTap: () => _makeCall(phone)),
                  _buildContactRow(Icons.mail_outline_rounded, 'E-mail', email, onTap: () => _sendEmail(email, name)),
                  const SizedBox(height: 24),
                  // Produtos dele
                  Row(
                    children: [
                      Text(
                        'Produção Disponível no Mercado',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryContainer,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '${products.length} itens',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (products.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Este agricultor não possui produtos publicados actualmente.',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.outline,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _buildProductItemCard(product);
                      },
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primary),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: AppTheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w700,
                    decoration: onTap != null ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItemCard(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pop(context); // fecha modal
              Navigator.pushNamed(
                context,
                '/product-detail-order-screen', // rota estendida
                arguments: {
                  'product': product,
                  'viewerRole': 'COMPRADOR',
                  'viewerUserId': '',
                },
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagem
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                        ),
                        child: product.imageUrl.isNotEmpty
                            ? Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.image_not_supported_outlined, size: 24, color: AppTheme.outline),
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.image_outlined, size: 24, color: AppTheme.outline),
                              ),
                      ),
                      if (product.isOrganic)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.success,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'Orgânico',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Descrição básica
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: AppTheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '${product.pricePerKg.toStringAsFixed(0)} Kz',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: AppTheme.primary,
                            ),
                          ),
                          Text(
                            ' / ${product.unit}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: AppTheme.outline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 10, color: AppTheme.outline),
                          const SizedBox(width: 4),
                          Text(
                            'Qtd: ${product.quantity} ${product.unit}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              color: AppTheme.outline,
                              fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 2.1,
      ),
      itemCount: 4,
      itemBuilder: (_, __) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const LoadingSkeletonWidget(width: 52, height: 52, borderRadius: 100),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        LoadingSkeletonWidget(width: 120, height: 16, borderRadius: 4),
                        SizedBox(height: 6),
                        LoadingSkeletonWidget(width: 80, height: 12, borderRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const LoadingSkeletonWidget(width: double.infinity, height: 32, borderRadius: 12),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Expanded(child: LoadingSkeletonWidget(width: double.infinity, height: 28, borderRadius: 8)),
                  SizedBox(width: 8),
                  Expanded(child: LoadingSkeletonWidget(width: double.infinity, height: 28, borderRadius: 8)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
