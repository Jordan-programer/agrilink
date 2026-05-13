import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class DemoCredentialsWidget extends StatelessWidget {
  const DemoCredentialsWidget({super.key});

  static const List<Map<String, String>> _credentials = [
    {
      'role': 'Agricultor',
      'email': 'agricultor.silva@agrilink.ao',
      'password': 'AgriLink2026!',
      'icon': 'grass',
    },
    {
      'role': 'Comprador',
      'email': 'comprador.santos@agrilink.ao',
      'password': 'AgriLink2026!',
      'icon': 'shopping_basket',
    },
    {
      'role': 'Transportador',
      'email': 'transporte.paulo@agrilink.ao',
      'password': 'AgriLink2026!',
      'icon': 'local_shipping',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF90CAF9).withAlpha(128),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Color(0xFF1565C0),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Contas de demonstração',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFBBDEFB)),
            ..._credentials.asMap().entries.map((entry) {
              final cred = entry.value;
              return _CredentialRow(credential: cred);
            }),
          ],
        ),
      ),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  final Map<String, String> credential;

  const _CredentialRow({required this.credential});

  @override
  Widget build(BuildContext context) {
    final roleColors = {
      'Agricultor': AppTheme.primary,
      'Comprador': const Color(0xFF1565C0),
      'Transportador': const Color(0xFF6A1B9A),
    };
    final color = roleColors[credential['role']] ?? AppTheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _roleIcon(credential['role'] ?? ''),
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  credential['role'] ?? '',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  credential['email'] ?? '',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Clipboard.setData(
                ClipboardData(
                  text: '${credential['email']}\n${credential['password']}',
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Credenciais copiadas!',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13),
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy_rounded, size: 13, color: color),
                  const SizedBox(width: 4),
                  Text(
                    'Usar',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'Agricultor':
        return Icons.grass_rounded;
      case 'Comprador':
        return Icons.shopping_basket_rounded;
      case 'Transportador':
        return Icons.local_shipping_rounded;
      default:
        return Icons.person_rounded;
    }
  }
}
