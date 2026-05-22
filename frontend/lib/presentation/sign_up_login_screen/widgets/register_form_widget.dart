import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import 'role_selector_widget.dart';

class RegisterFormWidget extends StatefulWidget {
  const RegisterFormWidget({super.key});

  @override
  State<RegisterFormWidget> createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends State<RegisterFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  
  String _selectedRole = 'AGRICULTOR'; 
  String _selectedProvince = 'Luanda';

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
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final String phoneClean = _phoneController.text.replaceAll(' ', '').trim();
      final payload = {
        "nome": _nameController.text.trim(),
        "telefone": phoneClean,
        "email": _emailController.text.trim().isEmpty 
               ? '$phoneClean@agrilink.com' 
               : _emailController.text.trim(),
        "senha": _passwordController.text.trim(),
        "tipo": _selectedRole.toUpperCase(),
        "provincia": _mapProvinceToEnum(_selectedProvince),
      };

      await ApiService().register(payload);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso! Por favor, inicie sessão.'), backgroundColor: Colors.green),
      );

      // Limpar campos
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();

      // NOTA: Para uma experiência ideal, o utilizador deverá trocar de aba manualmente 
      // ou podemos invocar um callback do parente. Por agora, apenas mostramos o sucesso
      // já que regressar à Home não faz sentido se eles precisam fazer Login primeiro.

    } catch (error) {
      _showError('Ocorreu um erro ao criar conta. Verifique os seus dados ou ligação.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RoleSelectorWidget(
              selectedRole: _selectedRole,
              onRoleChanged: (role) => setState(() => _selectedRole = role),
            ),
            const SizedBox(height: 20),
            _buildFieldLabel('Nome Completo'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: 'Ex: Manuel António Ferreira',
              icon: Icons.person_outline_rounded,
              validator: (v) => v == null || v.isEmpty ? 'Insira o nome completo' : null,
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('Número de Telefone'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _phoneController,
              hint: '9XX XXX XXX',
              icon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.length < 9 ? 'Número inválido' : null,
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('E-mail (Opcional)'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              hint: 'exemplo@email.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v != null && v.isNotEmpty && !v.contains('@')) ? 'E-mail inválido' : null,
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('Província'),
            const SizedBox(height: 8),
            _buildProvinceDropdown(),
            const SizedBox(height: 16),
            _buildFieldLabel('Palavra-passe'),
            const SizedBox(height: 8),
            _buildPasswordField(
              controller: _passwordController,
              hint: 'Mínimo 8 caracteres',
              obscure: _obscurePassword,
              onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
              validator: (v) => v == null || v.length < 8 ? 'Mínimo 8 caracteres' : null,
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('Confirmar Palavra-passe'),
            const SizedBox(height: 8),
            _buildPasswordField(
              controller: _confirmPasswordController,
              hint: 'Repita a palavra-passe',
              obscure: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
              validator: (v) => v != _passwordController.text ? 'As palavras-passe não coincidem' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        'Criar Conta Gratuitamente',
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvinceDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedProvince,
          isExpanded: true,
          items: _provinces.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (v) => setState(() => _selectedProvince = v!),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceVariant));
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppTheme.primary),
        filled: true,
        fillColor: AppTheme.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.outlineVariant)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({required TextEditingController controller, required String hint, required bool obscure, required VoidCallback onToggle, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppTheme.primary),
        suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20), onPressed: onToggle),
        filled: true,
        fillColor: AppTheme.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.outlineVariant)),
      ),
      validator: validator,
    );
  }
}
