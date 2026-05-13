import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class MarketplaceSearchWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const MarketplaceSearchWidget({super.key, required this.onChanged});

  @override
  State<MarketplaceSearchWidget> createState() =>
      _MarketplaceSearchWidgetState();
}

class _MarketplaceSearchWidgetState extends State<MarketplaceSearchWidget> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outlineVariant, width: 1),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              Icons.search_rounded,
              size: 20,
              color: AppTheme.outline,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (v) {
                setState(() => _hasText = v.isNotEmpty);
                widget.onChanged(v);
              },
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppTheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar produto, agricultor, província...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppTheme.outline,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
              ),
            ),
          ),
          if (_hasText)
            IconButton(
              onPressed: () {
                _controller.clear();
                setState(() => _hasText = false);
                widget.onChanged('');
              },
              icon: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppTheme.outline,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.tune_rounded,
                  size: 14,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Filtros',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
