import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  File? _animalImage;

  String get _javaApiBaseUrl => dotenv.env['API_JAVA_URL']!;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _animalImage = File(image.path);
      });
    }
  }

  Future<void> _registrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1️⃣ CADASTRAR USUÁRIO
      final userResponse = await http.post(
        Uri.parse('$_javaApiBaseUrl/usuarios'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "nome": _nomeController.text.trim(),
          "cpf": "00000000000",
          "whatsApp": _telefoneController.text.trim(),
          "email": _emailController.text.trim(),
          "senha": _senhaController.text.trim(),
        }),
      );

      if (userResponse.statusCode != 201) {
        throw Exception("Erro ao criar usuário (${userResponse.statusCode})");
      }

      final usuario = jsonDecode(userResponse.body);
      final String usuarioId = usuario["id"];

      // 2️⃣ CADASTRAR ANIMAL
      final animalResponse = await http.post(
        Uri.parse('$_javaApiBaseUrl/animais'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "nome": "Rex",
          "dataNascimento": "2022-01-01",
          "sexo": "Macho",
          "peso": 10.0,
          "castrado": false,
          "usuario": usuarioId,
          "raca": "507f1f77bcf86cd799439011",
        }),
      );

      if (animalResponse.statusCode != 201) {
        throw Exception("Erro ao cadastrar animal (${animalResponse.statusCode})");
      }

      final animal = jsonDecode(animalResponse.body);
      final String animalId = animal["id"];

      // 3️⃣ ENVIAR IMAGEM DO ANIMAL (caso o usuário tenha selecionado)
      if (_animalImage != null) {
        final imageRequest = http.MultipartRequest(
          'POST',
          Uri.parse('$_javaApiBaseUrl/animais/$animalId/imagem'),
        );
        imageRequest.files.add(await http.MultipartFile.fromPath('file', _animalImage!.path));
        final imageResponse = await imageRequest.send();

        if (imageResponse.statusCode != 201) {
          throw Exception("Erro ao enviar imagem (${imageResponse.statusCode})");
        }
      }

      // 4️⃣ CRIAR COLEIRA
      final coleiraResponse = await http.post(
        Uri.parse('$_javaApiBaseUrl/coleiras'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "descricao": "Coleira GPS Azul",
          "animal": animalId,
        }),
      );

      if (coleiraResponse.statusCode != 201) {
        throw Exception("Erro ao criar coleira (${coleiraResponse.statusCode})");
      }

      // 5️⃣ LOGIN AUTOMÁTICO
      final loginResponse = await http.post(
        Uri.parse('$_javaApiBaseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": _emailController.text.trim(),
          "senha": _senhaController.text.trim(),
        }),
      );

      if (loginResponse.statusCode != 200) {
        throw Exception("Erro ao autenticar usuário (${loginResponse.statusCode})");
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cadastro realizado com sucesso!")),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erro ao realizar cadastro: $e";
      });
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
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: -50,
            right: 0,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/images/cao-dex.png',
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height * 0.6,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Crie sua conta:',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.orange,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildLabel('Nome', Icons.person_outline),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hintText: 'Insira seu nome completo',
                      controller: _nomeController,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Telefone', Icons.phone_outlined),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hintText: 'Insira seu número de telefone',
                      controller: _telefoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('E-mail', Icons.email_outlined),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hintText: 'Insira seu e-mail',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Senha', Icons.lock_outline),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hintText: 'Crie sua senha',
                      controller: _senhaController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),

                    // --- IMAGEM DO ANIMAL ---
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add_a_photo, color: AppColors.orange900),
                      label: Text(
                        _animalImage == null ? 'Selecionar imagem do animal' : 'Imagem selecionada!',
                        style: GoogleFonts.poppins(
                          color: AppColors.orange900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),

                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: AppColors.orange),
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
                            onPressed: _registrarUsuario,
                            child: Text(
                              'Cadastrar',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Já tem conta? Entrar',
                        style: GoogleFonts.poppins(
                          color: AppColors.orange900,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.poppins(color: AppColors.black400, fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          color: AppColors.black200,
          fontSize: 16,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: AppColors.orange, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
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
