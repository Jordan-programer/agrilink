import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import 'tabs/admin_users_tab.dart';
import 'tabs/admin_orders_tab.dart';
import 'tabs/admin_products_tab.dart';
import 'tabs/admin_kpi_tab.dart';
import 'tabs/admin_transports_tab.dart';
import 'tabs/admin_payments_tab.dart';
import '../profile_screen/profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  List<Widget> get _tabs => [
    const AdminKpiTab(),
    const AdminUsersTab(),
    const AdminOrdersTab(),
    const AdminPaymentsTab(),
    const AdminProductsTab(),
    const AdminTransportsTab(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Safety check for index out of bounds (common in hot reloads with changed lists)
    if (_selectedIndex >= _tabs.length) {
      _selectedIndex = 0;
    }

    final isTablet = MediaQuery.of(context).size.width >= 600;
    final showMainAppBar = !isTablet && _selectedIndex != 4;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: showMainAppBar ? _buildAppBar() : null,
      body: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
      bottomNavigationBar: isTablet ? null : _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AgriLink Admin',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'Centro de Comando',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.outline,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined, color: AppTheme.onSurface),
        ),
        const SizedBox(width: 8),
        const Padding(
          padding: EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryContainer,
            child: Icon(Icons.admin_panel_settings_rounded, size: 20, color: AppTheme.primary),
          ),
        ),
      ],
      backgroundColor: AppTheme.surface,
      elevation: 0,
      scrolledUnderElevation: 2,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.primaryContainer.withOpacity(0.5),
        height: 70,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon: Icon(Icons.grid_view_rounded, color: AppTheme.primary),
            label: 'Resumo',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded, color: AppTheme.primary),
            label: 'Utilizadores',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded, color: AppTheme.primary),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments_rounded, color: AppTheme.primary),
            label: 'Pagamentos',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded, color: AppTheme.primary),
            label: 'Catálogo',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping_rounded, color: AppTheme.primary),
            label: 'Rotas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primary),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneLayout() {
    final tabs = _tabs;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: tabs[_selectedIndex < tabs.length ? _selectedIndex : 0],
    );
  }

  Widget _buildTabletLayout() {
    final tabs = _tabs;
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          labelType: NavigationRailLabelType.all,
          backgroundColor: AppTheme.surface,
          elevation: 4,
          useIndicator: true,
          indicatorColor: AppTheme.primaryContainer,
          selectedIconTheme: const IconThemeData(color: AppTheme.primary, size: 28),
          unselectedIconTheme: const IconThemeData(color: AppTheme.outline),
          selectedLabelTextStyle: GoogleFonts.plusJakartaSans(
            color: AppTheme.primary,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
          unselectedLabelTextStyle: GoogleFonts.plusJakartaSans(
            color: AppTheme.outline,
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Image.asset(
              'assets/agrilink_admin_logo.png', 
              width: 40, 
              errorBuilder: (c, e, s) => const Icon(Icons.agriculture_rounded, color: AppTheme.primary, size: 32)
            ),
          ),
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.grid_view_rounded),
              label: Text('Resumo'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.people_rounded),
              label: Text('Utilizadores'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.receipt_long_rounded),
              label: Text('Pedidos'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.payments_rounded),
              label: Text('Pagamentos'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.inventory_2_rounded),
              label: Text('Catálogo'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.local_shipping_rounded),
              label: Text('Rotas'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person_rounded),
              label: Text('Perfil'),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: tabs[_selectedIndex < tabs.length ? _selectedIndex : 0],
          ),
        ),
      ],
    );
  }
}


