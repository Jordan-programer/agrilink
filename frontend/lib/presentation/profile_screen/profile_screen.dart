import 'dart:convert';
import 'package:agrilink_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../theme/app_theme.dart';
import '../sign_up_login_screen/sign_up_login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedProvince;
  bool _isLoading = true;
  bool _isSaving = false;
  String _userId = '';
  bool _isPremium = false;
  bool _isFarmer = false;
  double _totalSales = 0.0;
  double _netSales = 0.0;
  bool _isUpgrading = false;

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

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _mapProvinceToEnum(String province) {
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

  String _mapEnumToProvince(String enumValue) {
    switch (enumValue) {
      case 'BENGO': return 'Bengo';
      case 'BENGUELA': return 'Benguela';
      case 'BIE': return 'Bié';
      case 'CABINDA': return 'Cabinda';
      case 'CUANDO_CUBANGO': return 'Cuando Cubango';
      case 'CUANZA_NORTE': return 'Cuanza Norte';
      case 'CUANZA_SUL': return 'Cuanza Sul';
      case 'CUNENE': return 'Cunene';
      case 'HUAMBO': return 'Huambo';
      case 'HUILA': return 'Huíla';
      case 'LUANDA': return 'Luanda';
      case 'LUNDA_NORTE': return 'Lunda Norte';
      case 'LUNDA_SUL': return 'Lunda Sul';
      case 'MALANJE': return 'Malanje';
      case 'MOXICO': return 'Moxico';
      case 'NAMIBE': return 'Namibe';
      case 'UIGE': return 'Uíge';
      case 'ZAIRE': return 'Zaire';
      default: return 'Luanda';
    }
  }

  Future<void> _loadProfile() async {
    try {
      final id = await _storage.read(key: "userId");
      if (id == null) {
        _handleLogout();
        return;
      }
      _userId = id;

      final response = await ApiService().get('/auth/user/$id');
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _nameController.text = data['nome'] ?? '';
          _phoneController.text = data['telefone'] ?? '';
          _emailController.text = data['email'] ?? '';
          
          if (data['provincia'] != null) {
            _selectedProvince = _mapEnumToProvince(data['provincia']);
          }
          if (data['plano'] == 'PREMIUM') {
            _isPremium = true;
          }
          _isFarmer = data['tipo'] == 'AGRICULTOR';
          if (_isFarmer) {
            _loadFarmerSales();
          }
          _isLoading = false;
        });
      } else {
        _showSnack('Erro ao carregar perfil.', isError: true);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnack('Falha de conexão.', isError: true);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFarmerSales() async {
    try {
      final response = await ApiService().get('/orders/farmer/$_userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        double total = 0.0;
        for (var order in data) {
          if (order['status'] == 'aprovado') {
            total += order['totalAoa'];
          }
        }
        setState(() {
          _totalSales = total;
          _netSales = total * 0.95; // 5% commission
        });
      }
    } catch (e) {
      print('Erro ao carregar vendas: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);

    try {
      final Map<String, dynamic> body = {
        "nome": _nameController.text.trim(),
        "telefone": _phoneController.text.trim(),
        "email": _emailController.text.trim(),
        "provincia": _selectedProvince != null ? _mapProvinceToEnum(_selectedProvince!) : null,
      };

      if (_passwordController.text.isNotEmpty) {
        body["senha"] = _passwordController.text;
      }

      final token = await _storage.read(key: "token");
      final uri = Uri.parse("https://api.ruitinerante.com/users/$_userId");
      
      final response = await http.put(
        uri,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token"
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        _showSnack('Perfil atualizado com sucesso!');
        _passwordController.clear();
      } else {
        _showSnack('Erro ao atualizar perfil.', isError: true);
      }
    } catch (e) {
      _showSnack('Erro de conexão.', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _upgradeToPremium() async {
    setState(() => _isUpgrading = true);
    try {
      final response = await ApiService().post('/users/$_userId/upgrade', {});
      if (response.statusCode == 200) {
        setState(() => _isPremium = true);
        _showSnack('Parabéns! Agora é Premium!', isError: false);
      } else {
        _showSnack('Erro ao atualizar plano.', isError: true);
      }
    } catch (e) {
      _showSnack('Falha de conexão.', isError: true);
    } finally {
      setState(() => _isUpgrading = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.plusJakartaSans()),
        backgroundColor: isError ? AppTheme.warning : AppTheme.success,
      ),
    );
  }

  Future<void> _handleLogout() async {
    await _storage.deleteAll();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignUpLoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Widget _buildSalesStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.outline)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.onSurface)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Meu Perfil',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryContainer,
                  child: Text(
                    _nameController.text.isNotEmpty 
                        ? _nameController.text[0].toUpperCase() 
                        : 'U',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              if (_isPremium)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          'Membro Premium',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.amber[700],
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              
              if (_isFarmer) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryContainer),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumo de Vendas',
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSalesStat('Vendas Brutas', '${_totalSales.toStringAsFixed(2)} AOA'),
                          _buildSalesStat('Vendas Líquidas', '${_netSales.toStringAsFixed(2)} AOA'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '* Descontando 5% de comissão da plataforma.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.outline),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              Text(
                'DADOS PESSOAIS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.outline,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Opcional)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedProvince,
                decoration: const InputDecoration(
                  labelText: 'Província',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
                items: _provinces.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setState(() => _selectedProvince = v),
                validator: (v) => v == null ? 'Obrigatório' : null,
              ),
              
              const SizedBox(height: 30),
              Text(
                'SEGURANÇA',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.outline,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nova Senha (deixe vazio para manter)',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),

              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Guardar Alterações', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                ),
              ),
              
              if (!_isPremium) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: _isUpgrading ? null : _upgradeToPremium,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.brown[900],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _isUpgrading 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.workspace_premium_rounded),
                    label: Text('Tornar-se Premium', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],

              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.warning),
                  label: Text(
                    'Sair da Conta', 
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.warning,
                      fontWeight: FontWeight.bold,
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
}
