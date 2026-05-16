import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/auth/jwt_manager.dart';

class AdminProductsTab extends StatefulWidget {
  const AdminProductsTab({super.key});

  @override
  State<AdminProductsTab> createState() => _AdminProductsTabState();
}

class _AdminProductsTabState extends State<AdminProductsTab> {
  // Listing State (Catalog)
  List<dynamic> _products = [];
  bool _isLoading = true;
  final ApiClient _apiClient = ApiClient(JwtManager());

  // Published Products State
  List<dynamic> _publishedProducts = [];
  bool _isLoadingPublished = true;

  // Form State
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  String? _selectedCategory;
  XFile? _imageFile;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  static const List<Map<String, dynamic>> _categoriesList = [
    {'label': 'Cereais & Grãos', 'icon': Icons.grain_rounded, 'id': 'CEREAIS_E_GRAOS'},
    {'label': 'Frutas Tropicais', 'icon': Icons.apple_rounded, 'id': 'FRUTAS'},
    {'label': 'Hortícolas', 'icon': Icons.eco_rounded, 'id': 'HORTALICAS'},
    {'label': 'Tubérculos & Raízes', 'icon': Icons.spa_rounded, 'id': 'RAIZES_TUBERCULOS'},
    {'label': 'Leguminosas', 'icon': Icons.grass_rounded, 'id': 'LEGUMINOSAS'},
    {'label': 'Oleaginosas', 'icon': Icons.water_drop_rounded, 'id': 'OLEAGINOSAS'},
    {'label': 'Especiarias', 'icon': Icons.local_florist_rounded, 'id': 'ESPECIARIAS'},
    {'label': 'Produtos Animais', 'icon': Icons.pets_rounded, 'id': 'PRODUTOS_ANIMAIS'},
    {'label': 'Insumos', 'icon': Icons.handyman_rounded, 'id': 'INSUMOS_AGRICOLAS'},
    {'label': 'Forragens', 'icon': Icons.agriculture_rounded, 'id': 'FORRAGENS'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchPublishedProducts();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get('/produtos');
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _products = jsonDecode(utf8.decode(response.bodyBytes));
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchPublishedProducts() async {
    setState(() => _isLoadingPublished = true);
    try {
      final response = await _apiClient.get('/listings/products');
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _publishedProducts = jsonDecode(utf8.decode(response.bodyBytes));
            _isLoadingPublished = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingPublished = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() => _imageFile = pickedFile);
      }
    } catch (e) {
      _showSnack('Erro ao abrir galeria: $e');
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      _showSnack('Selecione uma categoria');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? base64Image;
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        base64Image = "data:image/jpeg;base64,${base64Encode(bytes)}";
      }

      final Map<String, dynamic> body = {
        "nome": _productNameController.text.trim(),
        "categoriaId": _selectedCategory,
        "imageUrl": base64Image,
      };

      final response = await _apiClient.post('/produtos', body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccess();
        _fetchProducts(); // Refresh list
      } else {
        _showSnack('Erro ao salvar: ${response.body}');
      }
    } catch (e) {
      _showSnack('Erro: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.warning),
    );
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produto adicionado ao catálogo!'), backgroundColor: AppTheme.success),
    );
    _productNameController.clear();
    setState(() {
      _selectedCategory = null;
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: AppTheme.surface,
            child: TabBar(
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.outline,
              indicatorColor: AppTheme.primary,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(text: 'Catálogo', icon: Icon(Icons.inventory_2_rounded, size: 20)),
                Tab(text: 'Publicados', icon: Icon(Icons.shopping_bag_rounded, size: 20)),
                Tab(text: 'Adicionar Tipo', icon: Icon(Icons.add_circle_outline_rounded, size: 20)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildListingTab(),
                _buildPublishedTab(),
                _buildAddTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: AppTheme.outline.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('Nenhum produto no catálogo'),
            TextButton(onPressed: _fetchProducts, child: const Text('Actualizar')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchProducts,
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 2;
          double aspectRatio = 0.75;
          
          if (constraints.maxWidth >= 900) {
            crossAxisCount = 4;
            aspectRatio = 0.85;
          } else if (constraints.maxWidth >= 600) {
            crossAxisCount = 3;
            aspectRatio = 0.8;
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: aspectRatio,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _products.length,
            itemBuilder: (context, index) => _buildProductCard(_products[index]),
          );
        },
      ),
    );
  }

  Widget _buildPublishedTab() {
    if (_isLoadingPublished) return const Center(child: CircularProgressIndicator());
    if (_publishedProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: AppTheme.outline.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('Nenhum produto publicado'),
            TextButton(onPressed: _fetchPublishedProducts, child: const Text('Actualizar')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchPublishedProducts,
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 2;
          double aspectRatio = 0.75;
          
          if (constraints.maxWidth >= 900) {
            crossAxisCount = 4;
            aspectRatio = 0.85;
          } else if (constraints.maxWidth >= 600) {
            crossAxisCount = 3;
            aspectRatio = 0.8;
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: aspectRatio,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _publishedProducts.length,
            itemBuilder: (context, index) => _buildPublishedProductCard(_publishedProducts[index]),
          );
        },
      ),
    );
  }

  Widget _buildPublishedProductCard(dynamic listing) {
    final name = listing['productName'] ?? 'Produto';
    final farmer = listing['farmerName'] ?? 'Agricultor';
    final price = listing['preco'] ?? 0.0;
    final unit = listing['unidade'] ?? 'kg';
    final quantity = listing['quantidade'] ?? 0;
    final id = listing['id'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: _buildProductImage(listing['imageUrl']),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    IconButton(
                      onPressed: () => _editListing(listing),
                      icon: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _confirmDeleteListing(id, name),
                      icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('Por: $farmer', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.outline), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('AOA $price/$unit', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 11, color: AppTheme.primary)),
                    Text('Qtd: $quantity', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.outline)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteListing(dynamic id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover Publicação?'),
        content: Text('Deseja remover a publicação de "$name"?'),
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
      try {
        final response = await _apiClient.delete('/listings/$id');
        if (response.statusCode == 200 || response.statusCode == 204) {
          _showSnack('Publicação removida com sucesso');
          _fetchPublishedProducts();
        } else {
          _showSnack('Erro ao remover: ${response.statusCode}');
        }
      } catch (e) {
        _showSnack('Erro: $e');
      }
    }
  }

  Future<void> _editListing(dynamic listing) async {
    final priceController = TextEditingController(text: listing['preco'].toString());
    final quantityController = TextEditingController(text: listing['quantidade'].toString());
    final name = listing['productName'] ?? 'Produto';

    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Editar $name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Preço (AOA)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (updated == true) {
      try {
        final Map<String, dynamic> body = {
          "preco": double.tryParse(priceController.text) ?? listing['preco'],
          "quantidade": int.tryParse(quantityController.text) ?? listing['quantidade'],
          "unidade": listing['unidade'],
          "provincia": listing['provincia'],
          "descricao": listing['descricao'],
          "nivelFrescura": listing['nivelFrescura'],
        };

        final response = await _apiClient.put('/listings/${listing['id']}', body);
        if (response.statusCode == 200) {
          _showSnack('Publicação atualizada com sucesso');
          _fetchPublishedProducts();
        } else {
          _showSnack('Erro ao atualizar: ${response.statusCode}');
        }
      } catch (e) {
        _showSnack('Erro: $e');
      }
    }
  }

  Widget _buildAddTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Informação Básica'),
            const SizedBox(height: 16),
            _buildImagePicker(),
            const SizedBox(height: 24),
            TextFormField(
              controller: _productNameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Produto',
                hintText: 'Ex: Tomate Cereja, Milho Branco',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
              validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Categoria'),
            const SizedBox(height: 12),
            _buildCategorySelector(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _handleSave,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Gravar no Catálogo', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.onSurface),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outlineVariant, style: BorderStyle.solid),
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: kIsWeb
                    ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                    : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 40, color: AppTheme.primary),
                  const SizedBox(height: 8),
                  Text('Foto do Produto', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: AppTheme.primary)),
                ],
              ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        double aspectRatio = 3.5;
        
        if (constraints.maxWidth >= 900) {
          crossAxisCount = 5;
          aspectRatio = 2.5;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 3;
          aspectRatio = 3.0;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _categoriesList.length,
          itemBuilder: (context, index) {
            final cat = _categoriesList[index];
            final isSelected = _selectedCategory == cat['id'];
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat['id'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.outlineVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cat['icon'] as IconData, size: 16, color: isSelected ? Colors.white : AppTheme.outline),
                    const SizedBox(width: 8),
                    Text(
                      cat['label'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppTheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductCard(dynamic product) {
    final name = product['productName'] ?? product['nome'] ?? product['name'] ?? 'Produto';
    final category = product['categoriaId'] ?? 'Outros';
    final id = product['id'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: _buildProductImage(product['imageUrl']),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => _confirmDelete(id, name),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.delete_outline_rounded, size: 16, color: AppTheme.errorColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppTheme.primaryContainer, borderRadius: BorderRadius.circular(4)),
                  child: Text(category, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(dynamic id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover do Catálogo?'),
        content: Text('Deseja remover "$name" do catálogo oficial?'),
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
      try {
        final response = await _apiClient.delete('/produtos/$id');
        if (response.statusCode == 200 || response.statusCode == 204) {
          _showSnack('Produto removido com sucesso');
          _fetchProducts();
        } else {
          _showSnack('Erro ao remover: ${response.statusCode}');
        }
      } catch (e) {
        _showSnack('Erro: $e');
      }
    }
  }

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Center(child: Icon(Icons.grass_rounded, color: AppTheme.primary, size: 32));
    }
    if (imageUrl.startsWith('http')) {
      return Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity);
    }
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64String = imageUrl.split(',').last;
        return Image.memory(base64Decode(base64String), fit: BoxFit.cover, width: double.infinity);
      } catch (e) {
        return const Icon(Icons.broken_image_rounded);
      }
    }
    return const Icon(Icons.broken_image_rounded);
  }
}
