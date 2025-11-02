import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/services/auth_service.dart';
import '/theme/app_theme.dart';
import '/main.dart'; // Importa a instância global do authService
import '/screens/app_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _doLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final bool success = await authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AppShell()),
          (route) => false,
        );
      } else {
        setState(() {
          _errorMessage = 'E-mail ou senha inválidos. Tente novamente.';
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.orange900),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // CAMADA 1: A IMAGEM DE FUNDO
          Positioned(
            bottom: 0,
            left: -50,
            right: 0,
            child: Container(
              height:
                  MediaQuery.of(context).size.height *
                  0.6,
              child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  'assets/images/cao-dex.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // CAMADA 2: O CONTEÚDO DO FORMULÁRIO COM ROLAGEM
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Acesse sua conta:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orange,
                  ),
                ),
                const SizedBox(height: 40),

                _buildLabel('E-mail', Icons.email_outlined),
                const SizedBox(height: 8),
                _buildTextField(
                  hintText: 'Insira seu e-mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),

                _buildLabel('Senha', Icons.lock_outline),
                const SizedBox(height: 8),
                _buildTextField(
                  hintText: 'Insira sua senha',
                  controller: _passwordController,
                  obscureText: true,
                ),

                const SizedBox(height: 20),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                const SizedBox(height: 248),
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.orange,
                        ),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange900,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: _doLogin,
                        child: Text(
                          'Entrar',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                // Espaço no final para rolagem sobre a imagem
                const SizedBox(height: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- NOVO MÉTODO PARA CRIAR O LABEL (COMO NO SEU DESIGN) ---
  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.orange, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            color: AppColors.orange,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // --- NOVO MÉTODO PARA CRIAR O CAMPO DE TEXTO (TEXTFORMFIELD) ---
  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      // --- FIX PRINCIPAL: Garante que o campo não cresça ---
      maxLines: 1,
      minLines: 1,
      // --- FIM DO FIX ---
      style: GoogleFonts.poppins(color: AppColors.black400, fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: AppColors.black200),
        // Preenchimento interno
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 24,
        ),

        // Borda padrão (cilindro)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(
            color: AppColors.orange, // Cor da borda
            width: 2.0,
          ),
        ),

        // Borda habilitada (quando não está focado)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(
            color: AppColors.orange, // Cor da borda
            width: 2.0,
          ),
        ),

        // Borda focada (quando está digitando)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(
            color: AppColors.orange900, // Cor da borda mais forte
            width: 2.5,
          ),
        ),
      ),
    );
  }
}
