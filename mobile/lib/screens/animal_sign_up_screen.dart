import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
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
  String? _racaId;
  bool _isLoading = false;
  String? _errorMessage;
  File? _animalImage;

  String get _javaApiBaseUrl => dotenv.env['API_JAVA_URL']!;

  // 📸 Selecionar imagem
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _animalImage = File(pickedFile.path);
      });
    }
  }

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

      print('[AnimalSignUp] Token atual recuperado: $token');

      if (token == null || token.isEmpty) {
        throw Exception("Token JWT não encontrado. Faça login novamente.");
      }

      // 🐾 Delay de segurança para garantir inicialização completa
      await Future.delayed(const Duration(milliseconds: 500));

      // 🐾 Cadastrar o animal
      final response = await http.post(
        Uri.parse('$_javaApiBaseUrl/animais'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "nome": _nomeController.text.trim(),
          "dataNascimento": _dataController.text.trim(),
          "sexo": _sexoSelecionado,
          "peso": double.parse(_pesoController.text.trim()),
          "castrado": _castrado,
          "usuario": widget.usuarioId,
          "raca": _racaId ?? "507f1f77bcf86cd799439011",
        }),
      );

      print('[AnimalSignUp] Resposta do servidor (${response.statusCode}): ${response.body}');

     if (response.statusCode == 201) {
  final jsonResponse = jsonDecode(response.body);
  final animalId = jsonResponse["id"];
  print('[AnimalSignUp] Animal criado com ID: $animalId');

  // 🔗 Atualiza o usuário com o animal criado
  await authService.updateUserWithAnimal(widget.usuarioId, animalId);
  print('[AnimalSignUp] Usuário atualizado com o animal vinculado.');

  // 🖼️ Se tiver imagem, envia
  if (_animalImage != null && animalId != null) {
    final uploadUrl = Uri.parse('$_javaApiBaseUrl/animais/$animalId/imagem');
    final request = http.MultipartRequest('POST', uploadUrl)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath(
        'imagem',
        _animalImage!.path,
      ));

    final uploadResponse = await request.send();
    if (uploadResponse.statusCode == 200) {
      print('[AnimalSignUp] Imagem enviada com sucesso!');
    } else {
      print('[AnimalSignUp] Falha ao enviar imagem: ${uploadResponse.statusCode}');
    }
  }

  // 🐕‍🦺 Criar e vincular coleira automaticamente
  await _criarColeiraParaAnimal(token, animalId);

        // 🕒 Delay para estabilidade antes da navegação
        await Future.delayed(const Duration(milliseconds: 700));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Animal cadastrado com sucesso!")),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AppShell()),
          (route) => false,
        );
      } else if (response.statusCode == 401) {
        // Se o token estiver expirado, tenta relogin
        print('[AnimalSignUp] Token inválido, tentando relogar...');
        await authService.relogin();

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
      print('[AnimalSignUp] Erro: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 🔗 Cria uma coleira vinculada ao animal recém cadastrado
  Future<void> _criarColeiraParaAnimal(String token, String? animalId) async {
    if (animalId == null) {
      print('[Coleira] ID do animal é nulo, não foi possível criar a coleira.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_javaApiBaseUrl/coleiras'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "descricao": "Coleira GPS padrão",
          "animal": animalId,
        }),
      );

      if (response.statusCode == 201) {
        print('[Coleira] Coleira criada e vinculada ao animal $animalId com sucesso!');
      } else {
        print('[Coleira] Falha ao criar coleira: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('[Coleira] Erro ao criar coleira: $e');
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
                // 📸 Imagem do animal
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.orange200,
                          backgroundImage: _animalImage != null
                              ? FileImage(_animalImage!)
                              : null,
                          child: _animalImage == null
                              ? const Icon(Icons.camera_alt,
                                  size: 40, color: AppColors.orange900)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _pickImage,
                        child: Text(
                          "Selecionar Imagem",
                          style: GoogleFonts.poppins(
                            color: AppColors.orange900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
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
