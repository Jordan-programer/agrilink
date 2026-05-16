import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_image_widget.dart';
import '../../widgets/status_badge_widget.dart';

/// Tela de gestão do produto — exclusiva para o Agricultor dono do produto.
/// Permite Visualizar, Editar e Remover (RUD).
class ProductManageScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductManageScreen({super.key, required this.product});

  @override
  State<ProductManageScreen> createState() => _ProductManageScreenState();
}

class _ProductManageScreenState extends State<ProductManageScreen>
    with SingleTickerProviderStateMixin {
  late Map<String, dynamic> _product;
  bool _isEditing = false;
  bool _isSaving = false;
  late AnimationController _animController;

  // Controllers for editing
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _descController;
  String _selectedStatus = 'available';

  @override
  void initState() {
    super.initState();
    _product = Map<String, dynamic>.from(widget.product);
    _nameController = TextEditingController(text: _product['name'] as String? ?? '');
    _priceController = TextEditingController(
      text: (_product['pricePerKg'] as double?)?.toStringAsFixed(0) ?? '0',
    );
    _quantityController = TextEditingController(
      text: (_product['quantityKg'] as double?)?.toStringAsFixed(0) ??
          (_product['quantity']?.toString() ?? '0'),
    );
    _descController = TextEditingController(
      text: _product['description'] as String? ?? '',
    );
    _selectedStatus = _product['status'] as String? ?? 'available';
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    // TODO: Connect to API — PATCH /listings/products/{id}
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate API
    setState(() {
      _product['name'] = _nameController.text;
      _product['pricePerKg'] = double.tryParse(_priceController.text) ?? _product['pricePerKg'];
      _product['quantityKg'] = double.tryParse(_quantityController.text) ?? _product['quantityKg'];
      _product['description'] = _descController.text;
      _product['status'] = _selectedStatus;
      _isSaving = false;
      _isEditing = false;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              'Produto actualizado com sucesso!',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.fixed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Remover Produto',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppTheme.onSurface),
        ),
        content: Text(
          'Tem a certeza que deseja remover "${_product['name']}"? Esta acção não pode ser desfeita.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.outline, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: GoogleFonts.plusJakartaSans(color: AppTheme.outline)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Remover', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      // TODO: Connect to API — DELETE /listings/products/{id}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Produto removido.',
            style: GoogleFonts.plusJakartaSans(fontSize: 13),
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.fixed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context, true); // Return true = deleted
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status & Quick Stats
                  _buildStatusBar(),
                  const SizedBox(height: 20),
                  // Edit / View content
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isEditing
                        ? _buildEditForm()
                        : _buildViewDetails(),
                  ),
                  const SizedBox(height: 32),
                  // Action Buttons
                  _buildActionButtons(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final imageUrl = _product['imageUrl'] as String? ?? '';
    final productName = _product['name'] as String? ?? 'Produto';

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppTheme.surface,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // Edit toggle button
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: _isEditing
                ? TextButton.icon(
                    onPressed: () => setState(() => _isEditing = false),
                    icon: const Icon(Icons.close_rounded, size: 16, color: AppTheme.outline),
                    label: Text(
                      'Cancelar',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.outline,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  )
                : IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                    ),
                    onPressed: () => setState(() => _isEditing = true),
                  ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            imageUrl.isNotEmpty
                ? CustomImageWidget(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary, Color(0xFF1B5E20)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.eco_rounded, size: 80, color: Colors.white54),
                  ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Product name overlay
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'O Meu Produto',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isEditing ? _nameController.text : productName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      shadows: [
                        const Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2)),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preço Actual',
                style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.outline),
              ),
              Text(
                'AOA ${(_product['pricePerKg'] as double?)?.toStringAsFixed(0) ?? '—'}/kg',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          _statChip(
            icon: Icons.scale_rounded,
            label: '${(_product['quantityKg'] ?? _product['quantity'] ?? 0).toString()} kg',
            color: const Color(0xFF1565C0),
          ),
          const SizedBox(width: 8),
          StatusBadgeWidget(
            status: _statusFromString(_product['status'] as String?),
            compact: false,
          ),
        ],
      ),
    );
  }

  Widget _statChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewDetails() {
    return Column(
      key: const ValueKey('view'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Detalhes do Produto'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              _detailRow(Icons.category_rounded, 'Categoria', _product['category'] as String? ?? '—'),
              _divider(),
              _detailRow(Icons.location_on_rounded, 'Província', _product['province'] as String? ?? '—'),
              _divider(),
              _detailRow(Icons.calendar_today_rounded, 'Data de Colheita', _product['harvestDate'] as String? ?? '—'),
              _divider(),
              _detailRow(
                Icons.eco_rounded,
                'Produto Orgânico',
                (_product['isOrganic'] as bool? ?? false) ? 'Sim ✓' : 'Não',
              ),
              if (_product['description'] != null && (_product['description'] as String).isNotEmpty) ...[
                _divider(),
                _detailRow(Icons.notes_rounded, 'Descrição', _product['description'] as String),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Análise de Preço'),
        const SizedBox(height: 12),
        _buildPriceAnalysis(),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      key: const ValueKey('edit'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Editar Produto'),
        const SizedBox(height: 16),
        _buildField(
          label: 'Nome do Produto',
          controller: _nameController,
          icon: Icons.eco_rounded,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildField(
                label: 'Preço (AOA/kg)',
                controller: _priceController,
                icon: Icons.attach_money_rounded,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildField(
                label: 'Quantidade (kg)',
                controller: _quantityController,
                icon: Icons.scale_rounded,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatusSelector(),
        const SizedBox(height: 16),
        _buildField(
          label: 'Descrição (opcional)',
          controller: _descController,
          icon: Icons.notes_rounded,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.outline,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: AppTheme.primary),
            filled: true,
            fillColor: AppTheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.outlineVariant.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.outlineVariant.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    final statuses = [
      {'value': 'available', 'label': 'Disponível', 'color': AppTheme.success},
      {'value': 'low_stock', 'label': 'Stock Baixo', 'color': AppTheme.warning},
      {'value': 'reserved', 'label': 'Reservado', 'color': AppTheme.secondary},
      {'value': 'sold', 'label': 'Vendido', 'color': AppTheme.outline},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado do Produto',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.outline,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: statuses.map((s) {
            final val = s['value'] as String;
            final label = s['label'] as String;
            final color = s['color'] as Color;
            final isSelected = _selectedStatus == val;
            return GestureDetector(
              onTap: () => setState(() => _selectedStatus = val),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.15) : AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color : AppTheme.outlineVariant,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? color : AppTheme.outline,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceAnalysis() {
    final price = _product['pricePerKg'] as double? ?? 0;
    final avgPrice = _product['provinceAvgPrice'] as double? ?? 0;
    final diff = price - avgPrice;
    final isBelowAvg = diff < 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _priceColumn('O Seu Preço', 'AOA ${price.toStringAsFixed(0)}', AppTheme.primary),
              ),
              Container(width: 1, height: 48, color: AppTheme.outlineVariant),
              Expanded(
                child: _priceColumn('Média da Província', 'AOA ${avgPrice.toStringAsFixed(0)}', AppTheme.outline),
              ),
              Container(width: 1, height: 48, color: AppTheme.outlineVariant),
              Expanded(
                child: _priceColumn(
                  isBelowAvg ? 'Abaixo Média' : 'Acima Média',
                  '${isBelowAvg ? '-' : '+'}AOA ${diff.abs().toStringAsFixed(0)}',
                  isBelowAvg ? AppTheme.success : AppTheme.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isBelowAvg
                  ? AppTheme.successContainer.withOpacity(0.5)
                  : AppTheme.errorContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  isBelowAvg ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                  size: 16,
                  color: isBelowAvg ? AppTheme.success : AppTheme.errorColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isBelowAvg
                        ? 'O seu preço está abaixo da média. Boa competitividade!'
                        : 'O seu preço está acima da média. Considere ajustar para mais vendas.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isBelowAvg ? AppTheme.success : AppTheme.errorColor,
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

  Widget _priceColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.outline),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_isEditing) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _isSaving ? null : _saveChanges,
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.save_rounded, color: Colors.white),
          label: Text(
            _isSaving ? 'A guardar...' : 'Guardar Alterações',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => setState(() => _isEditing = true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.edit_rounded, color: Colors.white),
            label: Text(
              'Editar Produto',
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
          child: OutlinedButton.icon(
            onPressed: _deleteProduct,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
              side: const BorderSide(color: AppTheme.errorColor),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text(
              'Remover Produto',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) => Text(
    title,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: AppTheme.onSurface,
      letterSpacing: -0.3,
    ),
  );

  Widget _detailRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppTheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.outline),
              ),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _divider() => const Divider(height: 1, indent: 16, endIndent: 16, color: AppTheme.outlineVariant);

  AgriStatus _statusFromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'reserved': return AgriStatus.reserved;
      case 'sold': return AgriStatus.sold;
      case 'low_stock': return AgriStatus.lowStock;
      default: return AgriStatus.available;
    }
  }
}
