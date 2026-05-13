import 'package:agrilink_app/data/models/product_model.dart';
import 'package:agrilink_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class PublishProductScreen extends StatefulWidget {
  const PublishProductScreen({super.key});

  @override
  State<PublishProductScreen> createState() => _PublishProductScreenState();
}

class _PublishProductScreenState extends State<PublishProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedProvince;
  int _freshnessLevel =
      3; // 1=Colhido Hoje, 2=1-2 dias, 3=3-5 dias, 4=1 semana, 5=+1 semana
  String _selectedUnit = 'kg';
  bool _isSubmitting = false;

  static const List<Map<String, dynamic>> _categories = [
    {'label': 'Cereais & Grãos', 'icon': Icons.grain_rounded},
    {'label': 'Frutas Tropicais', 'icon': Icons.apple_rounded},
    {'label': 'Hortícolas', 'icon': Icons.eco_rounded},
    {'label': 'Tubérculos & Raízes', 'icon': Icons.spa_rounded},
    {'label': 'Leguminosas', 'icon': Icons.grass_rounded},
    {'label': 'Oleaginosas', 'icon': Icons.water_drop_rounded},
    {'label': 'Especiarias', 'icon': Icons.local_florist_rounded},
    {'label': 'Produtos Animais', 'icon': Icons.pets_rounded},
  ];

  static const List<String> _provinces = [
    'Bengo',
    'Benguela',
    'Bié',
    'Cabinda',
    'Cuando Cubango',
    'Cuanza Norte',
    'Cuanza Sul',
    'Cunene',
    'Huambo',
    'Huíla',
    'Luanda',
    'Lunda Norte',
    'Lunda Sul',
    'Malanje',
    'Moxico',
    'Namibe',
    'Uíge',
    'Zaire',
  ];

  static const List<String> _units = [
    'kg',
    'tonelada',
    'saco (50kg)',
    'caixa',
    'unidade',
    'litro',
  ];

  static const List<Map<String, dynamic>> _freshnessOptions = [
    {
      'level': 1,
      'label': 'Colhido Hoje',
      'color': Color(0xFF1B7A3E),
      'icon': Icons.star_rounded,
    },
    {
      'level': 2,
      'label': '1-2 Dias',
      'color': Color(0xFF2D6A4F),
      'icon': Icons.check_circle_rounded,
    },
    {
      'level': 3,
      'label': '3-5 Dias',
      'color': Color(0xFF52B788),
      'icon': Icons.schedule_rounded,
    },
    {
      'level': 4,
      'label': '1 Semana',
      'color': Color(0xFFE9A825),
      'icon': Icons.warning_amber_rounded,
    },
    {
      'level': 5,
      'label': '+1 Semana',
      'color': Color(0xFFB45309),
      'icon': Icons.info_outline_rounded,
    },
  ];

  @override
  void dispose() {
    _productNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handlePublish() async {
  if (!_formKey.currentState!.validate()) return;

  bool _isNewProduct = false;
  ProductModel? _selectedProduct;

  if (_selectedProduct == null && !_isNewProduct) {
    _showSnack('Selecione um produto ou crie um novo');
    return;
  }

  if (_selectedProvince == null) {
    _showSnack('Selecione a província');
    return;
  }

  setState(() => _isSubmitting = true);

  try {
    final user = supabase.auth.currentUser;

    if (user == null) {
      _showSnack('Utilizador não autenticado');
      return;
    }

    /// =========================
    /// PAYLOAD PARA O BACKEND
    /// =========================
    final body = {
      "agricultorId": user.id,
      "provincia": _selectedProvince,
      "preco": double.parse(_priceController.text),
      "quantidade": double.parse(_quantityController.text),
      "unidade": _selectedUnit,
      "descricao": _descriptionController.text,
      "frescuraLevel": _freshnessLevel,
      "status": "ATIVO",
    };

    /// =========================
    /// PRODUTO EXISTENTE
    /// =========================
    if (!_isNewProduct) {
      body["productId"] = _selectedProduct!.id;
    }

    /// =========================
    /// PRODUTO NOVO
    /// =========================
    else {
      body["novoProduto"] = {
        "nome": _productNameController.text.trim(),
        "categoria": _selectedCategory,
      };
    }

    /// =========================
    /// CHAMADA API SPRING BOOT
    /// =========================
    final response = await supabase.functions.invoke(
      'create-listing', // ou teu endpoint REST
      body: body,
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      _showSuccessDialog();
    }
  } catch (e) {
    setState(() => _isSubmitting = false);
    _showSnack('Erro ao publicar: $e');
  }
}

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        backgroundColor: AppTheme.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.successContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppTheme.success,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Produto Publicado!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_productNameController.text} foi publicado no mercado com sucesso.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Ver no Mercado',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppTheme.onSurface,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Publicar Produto',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.agriculture_rounded,
                    color: AppTheme.primary,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Agricultor',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                'Informações do Produto',
                Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 12),
              _buildProductNameField(),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildQuantityField()),
                  const SizedBox(width: 10),
                  Expanded(flex: 2, child: _buildUnitSelector()),
                ],
              ),
              const SizedBox(height: 14),
              _buildPriceField(),
              const SizedBox(height: 14),
              _buildDescriptionField(),
              const SizedBox(height: 22),
              _buildSectionHeader('Categoria', Icons.category_outlined),
              const SizedBox(height: 12),
              _buildCategorySelector(),
              const SizedBox(height: 22),
              _buildSectionHeader('Localização', Icons.location_on_outlined),
              const SizedBox(height: 12),
              _buildProvinceSelector(),
              const SizedBox(height: 22),
              _buildSectionHeader('Indicador de Frescura', Icons.eco_outlined),
              const SizedBox(height: 4),
              Text(
                'Quando foi colhido este produto?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              _buildFreshnessIndicator(),
              const SizedBox(height: 28),
              _buildPublishButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildProductNameField() {
    return TextFormField(
      controller: _productNameController,
      textCapitalization: TextCapitalization.words,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: AppTheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: 'Nome do Produto',
        hintText: 'Ex: Milho Branco, Mandioca, Tomate...',
        prefixIcon: const Icon(
          Icons.inventory_2_outlined,
          size: 20,
          color: AppTheme.primary,
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Informe o nome do produto';
        if (v.trim().length < 3) return 'Nome muito curto';
        return null;
      },
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      controller: _quantityController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: AppTheme.onSurface,
      ),
      decoration: const InputDecoration(
        labelText: 'Quantidade',
        hintText: '0',
        prefixIcon: Icon(
          Icons.scale_outlined,
          size: 20,
          color: AppTheme.primary,
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Informe a quantidade';
        if (double.tryParse(v) == null || double.parse(v) <= 0) {
          return 'Quantidade inválida';
        }
        return null;
      },
    );
  }

  Widget _buildUnitSelector() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedUnit,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        color: AppTheme.onSurface,
      ),
      decoration: const InputDecoration(labelText: 'Unidade'),
      items: _units
          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
          .toList(),
      onChanged: (v) => setState(() => _selectedUnit = v!),
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: AppTheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: 'Preço por Unidade',
        hintText: '0,00',
        prefixIcon: const Icon(
          Icons.payments_outlined,
          size: 20,
          color: AppTheme.primary,
        ),
        suffixText: 'AOA',
        suffixStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.primary,
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Informe o preço em AOA';
        if (double.tryParse(v) == null || double.parse(v) <= 0) {
          return 'Preço inválido';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      maxLength: 200,
      textCapitalization: TextCapitalization.sentences,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: AppTheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: 'Descrição (opcional)',
        hintText: 'Descreva a qualidade, variedade ou condições do produto...',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 48),
          child: Icon(Icons.notes_rounded, size: 20, color: AppTheme.primary),
        ),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        final isSelected = _selectedCategory == cat['label'];
        return GestureDetector(
          onTap: () =>
              setState(() => _selectedCategory = cat['label'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryContainer
                  : AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primary : AppTheme.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  cat['icon'] as IconData,
                  size: 18,
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cat['label'] as String,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected ? AppTheme.primary : AppTheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProvinceSelector() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedProvince,
      isExpanded: true,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: AppTheme.onSurface,
      ),
      decoration: const InputDecoration(
        labelText: 'Província de Origem',
        hintText: 'Selecione a província',
        prefixIcon: Icon(
          Icons.location_on_outlined,
          size: 20,
          color: AppTheme.primary,
        ),
      ),
      items: _provinces
          .map(
            (p) => DropdownMenuItem(
              value: p,
              child: Text(p, style: GoogleFonts.plusJakartaSans(fontSize: 14)),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _selectedProvince = v),
      validator: (v) => v == null ? 'Selecione a província' : null,
    );
  }

  Widget _buildFreshnessIndicator() {
    final selected = _freshnessOptions.firstWhere(
      (f) => f['level'] == _freshnessLevel,
    );
    final selectedColor = selected['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current selection badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: selectedColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selectedColor.withAlpha(80)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selected['icon'] as IconData,
                      size: 16,
                      color: selectedColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      selected['label'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selectedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: selectedColor,
              inactiveTrackColor: selectedColor.withAlpha(40),
              thumbColor: selectedColor,
              overlayColor: selectedColor.withAlpha(30),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _freshnessLevel.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (v) => setState(() => _freshnessLevel = v.round()),
            ),
          ),
          // Labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _freshnessOptions.map((f) {
              final isActive = f['level'] == _freshnessLevel;
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _freshnessLevel = f['level'] as int),
                  child: Column(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? (f['color'] as Color)
                              : AppTheme.outlineVariant,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (f['label'] as String).split(' ').first,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isActive
                              ? (f['color'] as Color)
                              : AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: _isSubmitting ? null : _handlePublish,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.primary,
          disabledBackgroundColor: AppTheme.primary.withAlpha(120),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.publish_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Publicar no Mercado',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
