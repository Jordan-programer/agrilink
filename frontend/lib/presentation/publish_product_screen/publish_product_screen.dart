import 'dart:convert';
import 'package:agrilink_app/data/models/product_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agrilink_app/services/api_service.dart';
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
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedProvince;
  int _freshnessLevel =
      3; // 1=Colhido Hoje, 2=1-2 dias, 3=3-5 dias, 4=1 semana, 5=+1 semana
  String _selectedUnit = 'kg';
  bool _isSubmitting = false;
  List<dynamic> _availableProducts = [];
  bool _isLoadingProducts = true;
  bool _isFetchingAiPrice = false;
  int? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _checkSession();
    _fetchProducts();
  }

  Future<void> _checkSession() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: "token");
    if (token == null || token.isEmpty) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/sign-up-login-screen', (route) => false);
      }
    }
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await ApiService().get('/produtos');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _availableProducts = data;
          _isLoadingProducts = false;
        });
      } else {
        setState(() => _isLoadingProducts = false);
      }
    } catch (e) {
      setState(() => _isLoadingProducts = false);
    }
  }

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
    _quantityController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchAiPrice() async {
    if (_selectedProductId == null) {
      _showSnack('Selecione um produto primeiro');
      return;
    }
    if (_selectedProvince == null) {
      _showSnack('Selecione a província de origem primeiro');
      return;
    }

    setState(() => _isFetchingAiPrice = true);

    try {
      final productObj = _availableProducts.firstWhere((p) => p['id'] == _selectedProductId);
      final productName = productObj['nome'];
      final mappedUnit = _mapUnit(_selectedUnit);

      final response = await ApiService().get('/ai/recommend-price?product=$productName&province=$_selectedProvince&unit=$mappedUnit');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['recommendedPrice'] != null) {
          setState(() {
            _priceController.text = data['recommendedPrice'].toString();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Preço sugerido pela IA: ${data['recommendedPrice']} AOA\nMotivo: ${data['reason']}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.fixed,
            ),
          );
        }
      }
    } catch (e) {
      _showSnack('Erro ao contactar a IA');
    } finally {
      setState(() => _isFetchingAiPrice = false);
    }
  }

  String _mapProvince(String province) {
    switch (province) {
      case 'Bengo': return 'BENGO';
      case 'Benguela': return 'BENGUELA';
      case 'Bié': return 'BIE';
      case 'Cabinda': return 'CABINDA';
      case 'Cuando Cubango': return 'CUANDO_CUBANGO';
      case 'Cuanza Norte': return 'CUANZA_NORTE';
      case 'Cuanza Sul': return 'CUANZA_SUL';
      case 'Cunene': return 'CUNENE';
      case 'Huambo': return 'HUAMBO';
      case 'Huíla': return 'HUILA';
      case 'Luanda': return 'LUANDA';
      case 'Lunda Norte': return 'LUNDA_NORTE';
      case 'Lunda Sul': return 'LUNDA_SUL';
      case 'Malanje': return 'MALANJE';
      case 'Moxico': return 'MOXICO';
      case 'Namibe': return 'NAMIBE';
      case 'Uíge': return 'UIGE';
      case 'Zaire': return 'ZAIRE';
      default: return 'LUANDA';
    }
  }

  String _mapCategory(String category) {
    switch (category) {
      case 'Cereais & Grãos': return 'CEREAIS_E_GRAOS';
      case 'Frutas Tropicais': return 'FRUTAS';
      case 'Hortícolas': return 'HORTALICAS';
      case 'Tubérculos & Raízes': return 'RAIZES_TUBERCULOS';
      case 'Leguminosas': return 'LEGUMINOSAS';
      case 'Oleaginosas': return 'OLEAGINOSAS';
      case 'Especiarias': return 'ESPECIARIAS';
      case 'Produtos Animais': return 'PRODUTOS_ANIMAIS';
      default: return 'OUTROS';
    }
  }

  String _mapUnit(String unit) {
    switch (unit) {
      case 'kg': return 'KG';
      case 'tonelada': return 'TONELADA';
      case 'saco (50kg)': return 'SACO';
      case 'caixa': return 'CAIXA';
      case 'unidade': return 'UNIDADE';
      case 'litro': return 'LITRO';
      default: return 'KG';
    }
  }

  String _mapFreshness(int level) {
    return 'NIVEL_$level';
  }

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProductId == null) {
      _showSnack('Selecione um produto');
      return;
    }

    if (_selectedProvince == null) {
      _showSnack('Selecione a província');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final storage = const FlutterSecureStorage();
      final userId = await storage.read(key: "userId");

      if (userId == null) {
        _showSnack('Utilizador não autenticado');
        setState(() => _isSubmitting = false);
        return;
      }

      /// =========================
      /// PAYLOAD PARA O BACKEND
      /// =========================
      final Map<String, dynamic> body = {
        "agricultorId": userId,
        "productId": _selectedProductId!,
        "provincia": _mapProvince(_selectedProvince!),
        "preco": double.parse(_priceController.text),
        "quantidade": int.parse(double.parse(_quantityController.text).round().toString()),
        "unidade": _mapUnit(_selectedUnit),
        "descricao": _descriptionController.text,
        "nivelFrescura": _mapFreshness(_freshnessLevel),
        "newProduct": false,
      };

      /// =========================
      /// CHAMADA API SPRING BOOT
      /// =========================
      final response = await ApiService().post('/listings', body);

      setState(() => _isSubmitting = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        _showSnack('Erro do servidor: ${response.body}');
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              'Produto publicado no mercado com sucesso.',
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
              _buildProductSelection(),
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

  Widget _buildProductSelection() {
    if (_isLoadingProducts) {
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return DropdownButtonFormField<int?>(
      value: _selectedProductId,
      isExpanded: true,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: AppTheme.onSurface,
      ),
      decoration: const InputDecoration(
        labelText: 'Selecionar Produto',
        hintText: 'Escolha um produto ou crie um novo',
        prefixIcon: Icon(
          Icons.inventory_2_outlined,
          size: 20,
          color: AppTheme.primary,
        ),
      ),
      items: [
        ..._availableProducts.map((p) {
          return DropdownMenuItem<int?>(
            value: p['id'] as int,
            child: Text(
              p['nome'] as String,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
            ),
          );
        }),
      ],
      onChanged: (v) {
        setState(() {
          _selectedProductId = v;
        });
      },
      validator: (v) {
        if (v == null) return 'Selecione um produto';
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
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
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 56, // Match standard text field height
            child: Tooltip(
              message: 'Sugerir preço com Inteligência Artificial',
              child: FilledButton(
                onPressed: _isFetchingAiPrice ? null : _fetchAiPrice,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryContainer,
                  foregroundColor: AppTheme.primary,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isFetchingAiPrice
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_awesome_rounded, color: AppTheme.primary),
              ),
            ),
          ),
        ),
      ],
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
