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

  String? _especieSelecionada;
  String? _racaSelecionada;
  List<Map<String, dynamic>> _racas = [];

  bool _isLoading = false;
  String? _errorMessage;
  File? _animalImage;

  String get _javaApiBaseUrl => dotenv.env['API_JAVA_URL']!;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() => _animalImage = File(pickedFile.path));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.orange,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dataController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _buscarRacas(String especieId) async {
    try {
      final auth = AuthService();
      await auth.init();
      final token = auth.getToken();

      final url =
          "$_javaApiBaseUrl/racas/especie/$especieId?page=0&size=50&sortBy=nome&direction=asc";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final lista = data["content"] as List;

        setState(() {
          _racas = lista
              .map((r) => {
                    "id": r["id"].toString(), // 🔥 AQUI — resolve o erro
                    "nome": r["nome"],
                  })
              .toList();
          _racaSelecionada = null;
        });
      } else {
        setState(() => _errorMessage = "Erro ao buscar raças: ${response.body}");
      }
    } catch (e) {
      setState(() => _errorMessage = "Erro inesperado ao buscar raças: $e");
    }
  }

  Future<void> _cadastrarAnimal() async {
    if (!_formKey.currentState!.validate()) return;

    if (_especieSelecionada == null) {
      setState(() => _errorMessage = "Selecione a espécie do animal.");
      return;
    }

    if (_racaSelecionada == null) {
      setState(() => _errorMessage = "Selecione a raça do animal.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      await authService.init();
      final token = authService.getToken();

      final response = await http.post(
        Uri.parse("$_javaApiBaseUrl/animais"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "nome": _nomeController.text.trim(),
          "dataNascimento": _dataController.text.trim(),
          "sexo": _sexoSelecionado,
          "peso": double.parse(_pesoController.text.trim()),
          "castrado": _castrado,
          "usuario": widget.usuarioId,
          "especie": _especieSelecionada,
          "raca": _racaSelecionada,
        }),
      );

      if (response.statusCode == 201) {
        final parsed = jsonDecode(response.body);
        final animalId = parsed["id"];

        if (_animalImage != null) {
          final upload = http.MultipartRequest(
            "POST",
            Uri.parse("$_javaApiBaseUrl/animais/$animalId/imagem"),
          )
            ..headers["Authorization"] = "Bearer $token"
            ..files.add(
              await http.MultipartFile.fromPath("imagem", _animalImage!.path),
            );

          await upload.send();
        }

        await http.post(
          Uri.parse("$_javaApiBaseUrl/coleiras"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "descricao": "Coleira GPS padrão",
            "animal": animalId,
          }),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AppShell()),
          (_) => false,
        );
      } else {
        setState(() {
          _errorMessage =
              "Erro ao cadastrar animal (${response.statusCode}): ${response.body}";
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
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.orange200,
                          backgroundImage:
                              _animalImage != null ? FileImage(_animalImage!) : null,
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

                _label("Nome do Animal", Icons.pets),
                const SizedBox(height: 8),
                _input(hint: "Ex: Rex", controller: _nomeController),
                const SizedBox(height: 16),

                _label("Data de Nascimento", Icons.calendar_today),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: _input(
                      hint: "AAAA-MM-DD",
                      controller: _dataController,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _label("Espécie", Icons.pets),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _especieSelecionada,
                  decoration: _selectDecoration(),
                  items: const [
                    DropdownMenuItem(
                      value: "68193ec5636f719fcd5ee598",
                      child: Text("Cachorro"),
                    ),
                    DropdownMenuItem(
                      value: "68193ec5636f719fcd5ee597",
                      child: Text("Gato"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _especieSelecionada = value;
                      _racas = [];
                      _racaSelecionada = null;
                    });
                    _buscarRacas(value!);
                  },
                ),
                const SizedBox(height: 16),

                _label("Raça", Icons.list),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _racaSelecionada,
                  decoration: _selectDecoration(),
                  items: _racas
                      .map(
                        (r) => DropdownMenuItem<String>(
                          value: r["id"], // já é String
                          child: Text(r["nome"]),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _racaSelecionada = value);
                  },
                ),
                const SizedBox(height: 16),

                _label("Sexo", Icons.transgender),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _sexoSelecionado,
                  decoration: _selectDecoration(),
                  items: const [
                    DropdownMenuItem(value: "Macho", child: Text("Macho")),
                    DropdownMenuItem(value: "Fêmea", child: Text("Fêmea")),
                  ],
                  onChanged: (value) => setState(() => _sexoSelecionado = value),
                ),
                const SizedBox(height: 16),

                _label("Peso (kg)", Icons.monitor_weight),
                const SizedBox(height: 8),
                _input(
                  hint: "Ex: 12.5",
                  controller: _pesoController,
                  keyboard: TextInputType.number,
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Checkbox(
                      value: _castrado,
                      activeColor: AppColors.orange900,
                      onChanged: (v) => setState(() => _castrado = v ?? false),
                    ),
                    Text("Castrado", style: GoogleFonts.poppins(fontSize: 16)),
                  ],
                ),

                const SizedBox(height: 24),

                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 8),

                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.orange),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange900,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _cadastrarAnimal,
                        child: Text(
                          "Cadastrar Animal",
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text, IconData icon) {
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

  Widget _input({
    required String hint,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.orange),
        ),
      ),
    );
  }

  InputDecoration _selectDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    );
  }
}
