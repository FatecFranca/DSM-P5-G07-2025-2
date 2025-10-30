import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/components/ui/input.dart';
import 'package:PetDex/components/ui/button.dart';
import 'package:PetDex/data/enums/input_size.dart';

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

  String get _javaApiBaseUrl => dotenv.env['API_JAVA_URL']!;

  Future<void> _registrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // 1️⃣ Cria o usuário
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

      // 2️⃣ Cria o animal
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
          "raca": "507f1f77bcf86cd799439011"
        }),
      );

      if (animalResponse.statusCode != 201) {
        throw Exception("Erro ao cadastrar animal (${animalResponse.statusCode})");
      }

      final animal = jsonDecode(animalResponse.body);
      final String animalId = animal["id"];

      // 3️⃣ Cria a coleira
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

      // 4️⃣ Login automático
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

      final token = jsonDecode(loginResponse.body)["token"];
      print("✅ Login efetuado! Token JWT: $token");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cadastro realizado com sucesso!")),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print("Erro: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao realizar cadastro: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.orange200),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Primeiro, o seu\ncadastro:",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.orange200,
                          ),
                        ),
                        const SizedBox(height: 30),

                        /// Inputs substituídos pelo componente Input
                        Input(
                          label: "Nome",
                          hintText: "Insira seu nome completo",
                          icon: Icons.person_outline,
                          controller: _nomeController,
                          size: InputSize.large,
                        ),
                        const SizedBox(height: 16),
                        Input(
                          label: "Número de telefone",
                          hintText: "+55 • Insira seu número",
                          icon: Icons.phone_outlined,
                          controller: _telefoneController,
                          keyboardType: TextInputType.phone,
                          size: InputSize.large,
                        ),
                        const SizedBox(height: 16),
                        Input(
                          label: "E-mail",
                          hintText: "Insira seu e-mail",
                          icon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          size: InputSize.large,
                        ),
                        const SizedBox(height: 16),
                        Input(
                          label: "Senha",
                          hintText: "Crie uma senha",
                          icon: Icons.lock_outline,
                          controller: _senhaController,
                          obscureText: true,
                          size: InputSize.large,
                        ),
                        const SizedBox(height: 40),

                        /// Botão substituído pelo componente Button
                        _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(color: AppColors.orange200),
                              )
                            : Button(
                                text: "Continuar",
                                onPressed: _registrarUsuario,
                                size: ButtonSize.large,
                              ),
                        const SizedBox(height: 30),
                        Text(
                          "Ao se registrar, você concorda com nossa Política de Privacidade e Termos de Serviço.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
