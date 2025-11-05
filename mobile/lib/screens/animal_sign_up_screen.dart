// lib/screens/animal_sign_up_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/screens/app_shell.dart';
import 'package:PetDex/services/auth_service.dart';

class AnimalSignUpScreen extends StatefulWidget {
  final String usuarioId;
  const AnimalSignUpScreen({super.key, required this.usuarioId});

  @override
  State<AnimalSignUpScreen> createState() => _AnimalSignUpScreenState();
}

class _AnimalSignUpScreenState extends State<AnimalSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();

  String? _sexoSelecionado;
  bool _castrado = false;
  String? _racaId; // pode vir de dropdown depois
  bool _isLoading = false;
  String? _errorMessage;

  String get _javaApiBaseUrl => dotenv.env['API_JAVA_URL']!;

  Future<void> _cadastrarAnimal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      await authService.init();
      final token = authService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception("Token JWT não encontrado. Faça login novamente.");
      }

      // ✅ Log para verificar se o token está sendo recuperado corretamente
      print('[AnimalSignUp] Token atual: $token');

      final response = await http.post(
        Uri.parse('$_javaApiBaseUrl/animais'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ✅ token JWT
        },
        body: jsonEncode({
          "nome": _nomeController.text.trim(),
          "dataNascimento": _dataController.text.trim(),
          "sexo": _sexoSelecionado,
          "peso": double.parse(_pesoController.text.trim()),
          "castrado": _castrado,
          "usuario": widget.usuarioId,
          "raca": _racaId ?? "507f1f77bcf86cd799439011", // temporário
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Animal cadastrado com sucesso!")),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AppShell()),
          (route) => false,
        );
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage =
              "Usuário não autenticado. Faça login novamente.\n${response.body}";
        });
      } else {
        setState(() {
          _errorMessage =
              "Erro ao cadastrar animal: ${response.statusCode} ${response.body}";
        });
      }
    } catch (e) {
      setState(() => _errorMessage = "Erro inesperado: $e");
    } finally {
      setState(() => _isLoading = false);
    }
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
        title: Text(
          "Cadastrar Animal",
          style: GoogleFonts.poppins(
            color: AppColors.orange900,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLabel('Nome do Animal', Icons.pets),
                const SizedBox(height: 8),
                _buildTextField(
                  hintText: 'Ex: Rex',
                  controller: _nomeController,
                ),
                const SizedBox(height: 16),

                _buildLabel('Data de Nascimento', Icons.calendar_today),
                const SizedBox(height: 8),
                _buildTextField(
                  hintText: 'AAAA-MM-DD',
                  controller: _dataController,
                ),
                const SizedBox(height: 16),

                _buildLabel('Sexo', Icons.transgender),
                DropdownButtonFormField<String>(
                  value: _sexoSelecionado,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Macho", child: Text("Macho")),
                    DropdownMenuItem(value: "Fêmea", child: Text("Fêmea")),
                  ],
                  onChanged: (value) => setState(() => _sexoSelecionado = value),
                ),
                const SizedBox(height: 16),

                _buildLabel('Peso (kg)', Icons.monitor_weight),
                const SizedBox(height: 8),
                _buildTextField(
                  hintText: 'Ex: 12.5',
                  controller: _pesoController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Checkbox(
                      value: _castrado,
                      activeColor: AppColors.orange900,
                      onChanged: (value) =>
                          setState(() => _castrado = value ?? false),
                    ),
                    Text(
                      "Castrado",
                      style: GoogleFonts.poppins(
                        color: AppColors.orange900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),

                _isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.orange),
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
                        onPressed: _cadastrarAnimal,
                        child: Text(
                          'Cadastrar Animal',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: AppColors.black200, fontSize: 16),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: AppColors.orange, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: AppColors.orange900, width: 2.5),
        ),
      ),
    );
  }
}
