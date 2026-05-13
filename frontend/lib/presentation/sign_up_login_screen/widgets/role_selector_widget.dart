import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class RoleSelectorWidget extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;

  const RoleSelectorWidget({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final roles = [
      _RoleItem('Agricultor', Icons.grass_rounded, 'Venda a sua produção'),
      _RoleItem(
        'Comprador',
        Icons.shopping_basket_rounded,
        'Encontre fornecedores',
      ),
      _RoleItem(
        'Transportador',
        Icons.local_shipping_rounded,
        'Transporte cargas',
      ),
      _RoleItem('Fornecedor', Icons.storefront_rounded, 'Forneça insumos'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sou um...',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.6,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: roles.length,
          itemBuilder: (context, index) {
            final role = roles[index];
            final isSelected = selectedRole == role.name;
            return InkWell(
              onTap: () => onRoleChanged(role.name),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryContainer
                      : AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.outlineVariant,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      role.icon,
                      size: 20,
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            role.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.onSurface,
                            ),
                          ),
                          Text(
                            role.subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.outline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppTheme.primary,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RoleItem {
  final String name;
  final IconData icon;
  final String subtitle;
  _RoleItem(this.name, this.icon, this.subtitle);
}
