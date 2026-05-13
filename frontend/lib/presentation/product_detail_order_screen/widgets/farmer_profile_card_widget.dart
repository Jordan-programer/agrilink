import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/status_badge_widget.dart';

class FarmerProfileCardWidget extends StatelessWidget {
  final String farmerName;
  final double rating;
  final String province;
  final bool isVerified;
  final String memberSince;
  final int totalSales;

  const FarmerProfileCardWidget({
    super.key,
    required this.farmerName,
    required this.rating,
    required this.province,
    required this.isVerified,
    required this.memberSince,
    required this.totalSales,
  });

  @override
  Widget build(BuildContext context) {
    final initials = farmerName
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person_rounded,
                  size: 13,
                  color: AppTheme.outline,
                ),
                const SizedBox(width: 6),
                Text(
                  'Agricultor',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.outline,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                if (isVerified)
                  const StatusBadgeWidget(
                    status: AgriStatus.verified,
                    compact: true,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primary, Color(0xFF2E7D32)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmerName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 12,
                            color: AppTheme.outline,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            province,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppTheme.outline,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: AppTheme.outline,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Desde $memberSince',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppTheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Ver Perfil',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppTheme.outlineVariant),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStat(
                  icon: Icons.star_rounded,
                  iconColor: AppTheme.amber,
                  value: rating.toStringAsFixed(1),
                  label: 'Avaliação',
                ),
                _buildStatDivider(),
                _buildStat(
                  icon: Icons.shopping_bag_rounded,
                  iconColor: AppTheme.primary,
                  value: '$totalSales',
                  label: 'Vendas',
                ),
                _buildStatDivider(),
                _buildStat(
                  icon: Icons.thumb_up_rounded,
                  iconColor: const Color(0xFF1565C0),
                  value: '97%',
                  label: 'Satisfação',
                ),
                _buildStatDivider(),
                _buildStat(
                  icon: Icons.timer_rounded,
                  iconColor: const Color(0xFF6A1B9A),
                  value: '< 2h',
                  label: 'Resposta',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: AppTheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 36, color: AppTheme.outlineVariant);
  }
}
