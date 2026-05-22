import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../theme/app_theme.dart';
import '../../../services/api_service.dart';
import '../../../services/tcp_client_service.dart';

class LoginFormWidget extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginFormWidget({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();

  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _loginError;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 🔐 LOGIN COM JWT (SPRING BOOT)
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _loginError = null;
    });

    try {
      final api = ApiService();

      String identifier = _identifierController.text.trim();
      if (!identifier.contains('@')) {
        identifier = identifier.replaceAll(' ', '');
      }

      final result = await api.login(
        identifier,
        _passwordController.text.trim(),
      );

      // 💾 guardar token JWT
      await api.saveToken(result["token"]);

      // 💾 opcional: guardar user localmente
      await storage.write(
        key: "user",
        value: jsonEncode(result),
      );
      
      // 💾 guardar userId para compatibilidade com outras telas
      await storage.write(
        key: "userId",
        value: result["id"].toString(),
      );

      // 🛡️ TENTATIVA DE LOGIN SEGURO TCP (RSC01)
      final tcpService = TcpClientService();
      bool isConnected = await tcpService.connect();
      if (isConnected) {
        tcpService.sendLogin(identifier, _passwordController.text.trim());
      }

      if (!mounted) return;

      widget.onLoginSuccess();

    } catch (e) {
      setState(() {
        _loginError = "Telefone ou senha inválidos";
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

            // 🚨 ERRO
            if (_loginError != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.redAccent),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _loginError!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 📞 TELEFONE
            Text(
              "Telefone ou E-mail",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _identifierController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: "Número do telefone ou email",
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) =>
                  value!.isEmpty ? "Campo obrigatório" : null,
            ),

            const SizedBox(height: 16),

            // 🔑 PASSWORD
            Text(
              "Senha",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: "••••••••",
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) =>
                  value!.length < 4 ? "Senha muito curta" : null,
            ),

            const SizedBox(height: 24),

            // 🔘 BOTÃO LOGIN
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Entrar",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}