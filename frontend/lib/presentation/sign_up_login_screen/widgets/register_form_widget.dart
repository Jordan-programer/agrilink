import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Importação essencial

import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import 'role_selector_widget.dart';

// Variável global ou atalho para o cliente Supabase
final supabase = Supabase.instance.client;

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
  
  // Mapeamento para os valores do seu ENUM tipo_usuario no banco
  String _selectedRole = 'AGRICULTOR'; 
  String _selectedProvince = 'Luanda';

  static const List<String> _provinces = [
    'Luanda', 'Benguela', 'Uíge', 'Bengo', 'Kwanza Sul', 'Huambo', 'Malanje', 'Cabinda', 
    'Namibe', 'Bié', 'Moxico', 'Cunene', 'Cuando Cubango', 'Lunda Norte', 'Lunda Sul', 
    'Zaire', 'Huíla'
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

  // --- LÓGICA DE CADASTRO REAL ---
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Criar Usuário no Supabase Auth (E-mail e Senha)
      // Nota: O Supabase exige um e-mail válido. Se o usuário não fornecer, 
      // você pode gerar um e-mail falso baseado no telefone (ex: 9xx@agrilink.com)
      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text.trim().isEmpty 
               ? '${_phoneController.text.replaceAll(' ', '')}@agrilink.com' 
               : _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = res.user;

      if (user != null) {
        // 2. Inserir dados na tabela 'usuarios' vinculando pelo ID do Auth (UUID)
        await supabase.from('usuarios').insert({
          'id': user.id,
          'nome': _nameController.text.trim(),
          'telefone': _phoneController.text.trim(),
          'tipo': _selectedRole.toUpperCase(), // Deve bater com o ENUM do SQL
          'provincia': _selectedProvince,
        });

        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta criada com sucesso!'), backgroundColor: Colors.green),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.homeMarketplaceScreen,
          (route) => false,
        );
      }
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError('Ocorreu um erro inesperado. Verifique sua conexão.');
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
            _buildFieldLabel('E-mail'),
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
