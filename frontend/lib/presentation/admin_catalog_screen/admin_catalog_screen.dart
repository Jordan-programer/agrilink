import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class AdminCatalogScreen extends StatefulWidget {
  const AdminCatalogScreen({super.key});

  @override
  State<AdminCatalogScreen> createState() => _AdminCatalogScreenState();
}

class _AdminCatalogScreenState extends State<AdminCatalogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  
  String? _selectedCategory;
  XFile? _imageFile;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

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

  @override
  void dispose() {
    _productNameController.dispose();
    super.dispose();
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

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
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
        base64Image = base64Encode(bytes);
        // Opcional: Adicionar prefixo data:image/jpeg;base64,
        base64Image = "data:image/jpeg;base64,$base64Image";
      }

      final Map<String, dynamic> body = {
        "nome": _productNameController.text.trim(),
        "categoriaId": _mapCategory(_selectedCategory!),
        "imageUrl": base64Image,
      };

      final response = await ApiService().post('/produtos', body);

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
      _showSnack('Erro ao guardar: $e');
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
            const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 60),
            const SizedBox(height: 16),
            Text(
              'Produto Adicionado!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_productNameController.text} foi adicionado ao catálogo.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _productNameController.clear();
                _selectedCategory = null;
                _imageFile = null;
              });
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Adicionar Novo'),
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
        title: Text(
          'Catálogo de Produtos',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adicionar Novo Produto Oficial',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Os agricultores poderão escolher este produto para vender.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              _buildImagePicker(),
              const SizedBox(height: 24),
              TextFormField(
                controller: _productNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome do Produto',
                  hintText: 'Ex: Batata Rena, Tomate, etc.',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (v) => v!.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 24),
              Text(
                'Categoria',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              _buildCategorySelector(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _handleSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Gravar no Catálogo',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outlineVariant, style: BorderStyle.solid),
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: kIsWeb
                    ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                    : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 48, color: AppTheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    'Tocar para adicionar foto',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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
          onTap: () => setState(() => _selectedCategory = cat['label'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryContainer : AppTheme.surfaceVariant,
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
                  color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cat['label'] as String,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
}
