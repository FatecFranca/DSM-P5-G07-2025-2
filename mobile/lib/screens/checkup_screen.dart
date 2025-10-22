import 'package:PetDex/data/enums/input_size.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/components/ui/disease_prediction.dart';
import 'package:PetDex/components/ui/yes_or_no_question.dart';
import 'package:PetDex/components/ui/input.dart';
import 'package:PetDex/components/ui/button.dart';
import 'package:PetDex/services/animal_service.dart';
import 'package:PetDex/main.dart';

class CheckupScreen extends StatefulWidget {
  const CheckupScreen({super.key});

  @override
  State<CheckupScreen> createState() => _CheckupScreenState();
}

class _CheckupScreenState extends State<CheckupScreen> {
  final AnimalService _animalService = AnimalService();
  final petNome = authService.getPetName();
  int _etapaAtual = 0; // 0..5 perguntas, 6 = resultado
  bool _enviando = false;
  bool _mostrouResultado = false;
  String? _resultadoRotulo; // Texto apresentado no DiseasePrediction

  final TextEditingController _duracaoController = TextEditingController(
    text: '0',
  );
  final ScrollController _scrollController = ScrollController();
  final FocusNode _duracaoFocusNode = FocusNode();
  final GlobalKey _duracaoInputKey = GlobalKey();

  // Respostas dos 34 campos (duracao = int em dias, demais 0/1)
  late Map<String, dynamic> respostas;

  @override
  void initState() {
    super.initState();
    _resetarFluxo();

    // Listener para rolar a tela quando o input de duração receber foco
    _duracaoFocusNode.addListener(() {
      if (_duracaoFocusNode.hasFocus) {
        _scrollToInput();
      }
    });
  }

  void _scrollToInput() {
    // Aguarda o teclado aparecer e a renderização completar
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;

      final inputContext = _duracaoInputKey.currentContext;
      if (inputContext == null) return;

      // Obtém a posição do Input na tela
      final RenderBox? renderBox = inputContext.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      // Posição do Input relativa ao topo da tela
      final position = renderBox.localToGlobal(Offset.zero);
      final inputHeight = renderBox.size.height;

      // Altura do teclado (aproximadamente)
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

      // Altura visível da tela (sem o teclado)
      final screenHeight = MediaQuery.of(context).size.height;
      final visibleHeight = screenHeight - keyboardHeight;

      // Calcula onde o Input deve estar (centralizado na área visível)
      final targetPosition = position.dy - (visibleHeight / 2) + (inputHeight / 2);

      // Scroll atual
      final currentScroll = _scrollController.offset;

      // Nova posição de scroll
      final newScroll = currentScroll + targetPosition - 100; // -100 para dar um espaço extra no topo

      // Anima para a nova posição
      _scrollController.animateTo(
        newScroll.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _duracaoController.dispose();
    _scrollController.dispose();
    _duracaoFocusNode.dispose();
    super.dispose();
  }

  void _resetarFluxo() {
    respostas = {
      'duracao': 0,
      'perda_de_apetite': null,
      'vomito': null,
      'diarreia': null,
      'tosse': null,
      'dificuldade_para_respirar': null,
      'dificuldade_para_locomover': null,
      'problemas_na_pele': null,
      'secrecao_nasal': null,
      'secrecao_ocular': null,
      'agitacao': null,
      'andar_em_circulos': null,
      'aumento_apetite': null,
      'cera_excessiva_nas_orelhas': null,
      'coceira': null,
      'desidratacao': null,
      'desmaio': null,
      'dificuldade_para_urinar': null,
      'dor': null,
      'espamos_musculares': null,
      'espirros': null,
      'febre': null,
      'fraqueza': null,
      'inchaco': null,
      'lambedura': null,
      'letargia': null,
      'lingua_azulada': null,
      'perda_de_pelos': null,
      'perda_de_peso': null,
      'ranger_de_dentes': null,
      'ronco': null,
      'salivacao': null,
      'suor_alterado': null,
    };
    _duracaoController.text = '0';
    _etapaAtual = 0;
    _enviando = false;
    _mostrouResultado = false;
    _resultadoRotulo = null;
  }

  // Mapeia os códigos de resultado da API para rótulos amigáveis
  String _mapResultadoParaRotulo(String resultado) {
    switch (resultado) {
      case 'gastrointestinal':
        return 'Problemas gastrointestinais';
      case 'respiratoria':
        return 'Problemas respiratórios';
      case 'cutanea':
        return 'Problemas cutâneos';
      case 'urogenital':
        return 'Problemas urogenitais';
      case 'neuro_musculoesqueletica':
        return 'Doenças neuro-musculoesqueléticas';
      case 'cardiovascular_hematologica':
        return 'Problemas cardiovasculares/hematológicos';
      case 'nenhuma':
      default:
        return 'Nenhum problema de saúde identificado';
    }
  }

  void _atualizarResposta(String chave, bool? valor) {
    setState(() {
      if (valor == null) {
        respostas[chave] = null; // ainda não respondida
      } else {
        respostas[chave] = valor ? 1 : 0;
      }
    });
  }

  bool? _iv(String chave) {
    final v = respostas[chave];
    if (v == null) return null;
    return v == 1;
  }

  // Retorna as chaves das perguntas para cada etapa
  List<String> _perguntasDaEtapa(int etapa) {
    switch (etapa) {
      case 0:
        return [
          'agitacao',
          'letargia',
          'fraqueza',
          'andar_em_circulos',
          'ranger_de_dentes',
          'lambedura',
        ];
      case 1:
        return [
          'perda_de_apetite',
          'aumento_apetite',
          'vomito',
          'diarreia',
          'perda_de_peso',
          'desidratacao',
        ];
      case 2:
        return [
          'tosse',
          'dificuldade_para_respirar',
          'ronco',
          'espirros',
          'lingua_azulada',
          'febre',
        ];
      case 3:
        return [
          'dificuldade_para_locomover',
          'dor',
          'espamos_musculares',
          'desmaio',
          'inchaco',
        ];
      case 4:
        return [
          'problemas_na_pele',
          'coceira',
          'perda_de_pelos',
          'cera_excessiva_nas_orelhas',
          'suor_alterado',
          'salivacao',
        ];
      case 5:
        return ['secrecao_nasal', 'secrecao_ocular', 'dificuldade_para_urinar'];
      default:
        return [];
    }
  }

  // Verifica se todas as perguntas da etapa atual foram respondidas
  bool _todasPerguntasRespondidas() {
    final perguntas = _perguntasDaEtapa(_etapaAtual);
    for (final chave in perguntas) {
      if (respostas[chave] == null) {
        return false;
      }
    }
    return true;
  }

  Widget _tituloTopo() {
    String titulo;
    if (_mostrouResultado) {
      titulo = 'Resultado da Análise';
    } else {
      switch (_etapaAtual) {
        case 0:
          titulo = 'Comportamento e Rotina';
          break;
        case 1:
          titulo = 'Alimentação e Digestão';
          break;
        case 2:
          titulo = 'Respiração e Circulação';
          break;
        case 3:
          titulo = 'Movimento e Coordenação';
          break;
        case 4:
          titulo = 'Pele, Orelhas e Pelos';
          break;
        case 5:
        default:
          titulo = 'Sintomas Específicos';
      }
    }
    return Column(
      children: [
        Text(
          titulo,
          style: GoogleFonts.poppins(
            color: AppColors.orange,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _etapa1() {
    return Column(
      children: [
        YesOrNoQuestion(
          questionText: '$petNome está agitado ou mais inquieto que o normal?',
          initialValue: _iv('agitacao'),
          onChanged: (v) => _atualizarResposta('agitacao', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: 'Você notou letargia?',
          descriptionQuestion: 'Desânimo, cansaço ou dorme mais que o normal',
          initialValue: _iv('letargia'),
          onChanged: (v) => _atualizarResposta('letargia', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText:
              '$petNome demonstra fraqueza ou dificuldade em se levantar?',
          initialValue: _iv('fraqueza'),
          onChanged: (v) => _atualizarResposta('fraqueza', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: 'Está andando em círculos, sem motivo aparente?',
          initialValue: _iv('andar_em_circulos'),
          onChanged: (v) => _atualizarResposta('andar_em_circulos', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: 'Está rangendo os dentes com frequência?',
          initialValue: _iv('ranger_de_dentes'),
          onChanged: (v) => _atualizarResposta('ranger_de_dentes', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText:
              'Apresenta lambedura excessiva em alguma parte do corpo?',
          initialValue: _iv('lambedura'),
          onChanged: (v) => _atualizarResposta('lambedura', v),
        ),
      ],
    );
  }

  Widget _etapa2() {
    return Column(
      children: [
        YesOrNoQuestion(
          questionText: '$petNome perdeu o apetite recentemente?',
          initialValue: _iv('perda_de_apetite'),
          onChanged: (v) => _atualizarResposta('perda_de_apetite', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: 'Houve aumento no apetite, comendo mais que o normal?',
          initialValue: _iv('aumento_apetite'),
          onChanged: (v) => _atualizarResposta('aumento_apetite', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: 'Está vomitando com frequência?',
          initialValue: _iv('vomito'),
          onChanged: (v) => _atualizarResposta('vomito', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: 'Apresenta diarreia ou fezes muito moles?',
          initialValue: _iv('diarreia'),
          onChanged: (v) => _atualizarResposta('diarreia', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: 'Você notou perda de peso sem motivo aparente?',
          initialValue: _iv('perda_de_peso'),
          onChanged: (v) => _atualizarResposta('perda_de_peso', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: '$petNome está com sinais de desidratação?',
          descriptionQuestion:
              ' Boca, olhos ou nariz secos, urina escura e em menor quantidade, boca quente.',
          initialValue: _iv('desidratacao'),
          onChanged: (v) => _atualizarResposta('desidratacao', v),
        ),
      ],
    );
  }

  Widget _etapa3() {
    return Column(
      children: [
        YesOrNoQuestion(
          questionText: '$petNome está com tosse?',
          initialValue: _iv('tosse'),
          onChanged: (v) => _atualizarResposta('tosse', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText:
              'Tem dificuldade para respirar ou respiração ofegante em repouso?',
          initialValue: _iv('dificuldade_para_respirar'),
          onChanged: (v) => _atualizarResposta('dificuldade_para_respirar', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: 'Você notou roncos ou barulhos diferentes ao respirar?',
          initialValue: _iv('ronco'),
          onChanged: (v) => _atualizarResposta('ronco', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: 'Está espirrando com frequência?',
          initialValue: _iv('espirros'),
          onChanged: (v) => _atualizarResposta('espirros', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: 'A língua ou gengivas estão azuladas?',
          initialValue: _iv('lingua_azulada'),
          onChanged: (v) => _atualizarResposta('lingua_azulada', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: '$petNome parece ter febre?',
          descriptionQuestion:
              'Aparenta estar com o corpo mais quente, especialmente as orelhas.',
          initialValue: _iv('febre'),
          onChanged: (v) => _atualizarResposta('febre', v),
        ),
      ],
    );
  }

  Widget _etapa4() {
    return Column(
      children: [
        YesOrNoQuestion(
          questionText: '$petNome tem dificuldade para se locomover?',
          descriptionQuestion: 'Manca ou evita andar?',
          initialValue: _iv('dificuldade_para_locomover'),
          onChanged: (v) => _atualizarResposta('dificuldade_para_locomover', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: 'Demonstra dor ao ser tocado ou ao se mover?',
          initialValue: _iv('dor'),
          onChanged: (v) => _atualizarResposta('dor', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: 'Você percebeu espasmos musculares?',
          descriptionQuestion: 'Tremores involuntários',
          initialValue: _iv('espamos_musculares'),
          onChanged: (v) => _atualizarResposta('espamos_musculares', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: '$petNome já teve algum desmaio recentemente?',
          initialValue: _iv('desmaio'),
          onChanged: (v) => _atualizarResposta('desmaio', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: 'Há inchaços visíveis em alguma parte do corpo?',
          initialValue: _iv('inchaco'),
          onChanged: (v) => _atualizarResposta('inchaco', v),
        ),
      ],
    );
  }

  Widget _etapa5() {
    return Column(
      children: [
        YesOrNoQuestion(
          questionText:
              'Há problemas na pele, como feridas, irritações ou manchas?',
          initialValue: _iv('problemas_na_pele'),
          onChanged: (v) => _atualizarResposta('problemas_na_pele', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: '$petNome está com coceira constante?',
          initialValue: _iv('coceira'),
          onChanged: (v) => _atualizarResposta('coceira', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: 'Há perda de pelos excessiva ou em áreas específicas?',
          initialValue: _iv('perda_de_pelos'),
          onChanged: (v) => _atualizarResposta('perda_de_pelos', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: 'Há cera excessiva nas orelhas ou mau cheiro?',
          initialValue: _iv('cera_excessiva_nas_orelhas'),
          onChanged: (v) => _atualizarResposta('cera_excessiva_nas_orelhas', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: 'Você notou suor alterado?',
          descriptionQuestion: 'Áreas úmidas ou odor incomum',
          initialValue: _iv('suor_alterado'),
          onChanged: (v) => _atualizarResposta('suor_alterado', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: 'Está com salivação maior que o normal?',
          initialValue: _iv('salivacao'),
          onChanged: (v) => _atualizarResposta('salivacao', v),
        ),
      ],
    );
  }

  Widget _etapa6() {
    return Column(
      children: [
        YesOrNoQuestion(
          questionText: 'Há secreção nasal?',
          descriptionQuestion: 'Corrimento pelo nariz',
          initialValue: _iv('secrecao_nasal'),
          onChanged: (v) => _atualizarResposta('secrecao_nasal', v),
        ),
        const SizedBox(height: 16),
        YesOrNoQuestion(
          questionText: 'Há secreção ocular?',
          descriptionQuestion: 'Olhos lacrimejando ou com crostas',
          initialValue: _iv('secrecao_ocular'),
          onChanged: (v) => _atualizarResposta('secrecao_ocular', v),
        ),
        const SizedBox(height: 16),

        YesOrNoQuestion(
          questionText: '$petNome demonstra dificuldade para urinar?',
          initialValue: _iv('dificuldade_para_urinar'),
          onChanged: (v) => _atualizarResposta('dificuldade_para_urinar', v),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.sand,
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Text(
            'Qual é a duração dos sintomas?',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.orange900,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Duração dos sintomas (dias)
        const SizedBox(height: 2),
        Input(
          key: _duracaoInputKey,
          hintText: '3 ',
          controller: _duracaoController,
          focusNode: _duracaoFocusNode,
          centerText: true,
          suffixText: ' dias',
          size: InputSize.large,
          keyboardType: TextInputType.number,
          onChanged: (text) {
            final n = int.tryParse(text.trim());
            setState(() {
              respostas['duracao'] = n ?? 0;
            });
          },
        ),
      ],
    );
  }

  Future<void> _enviarRespostas() async {
    final animalId = authService.getAnimalId();
    if (animalId == null || animalId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID do pet não encontrado. Faça login novamente.'),
        ),
      );
      return;
    }

    setState(() {
      _enviando = true;
    });

    try {
      print('[CheckupScreen] 📤 Preparando envio de respostas...');
      print('[CheckupScreen] Animal ID: $animalId');
      print('[CheckupScreen] Respostas: $respostas');

      final result = await _animalService.postCheckup(animalId, respostas);
      final rotulo = _mapResultadoParaRotulo(result.resultado);
      if (!mounted) return;
      setState(() {
        _resultadoRotulo = rotulo;
        _mostrouResultado = true;
        _etapaAtual = 6; // etapa de resultado
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao enviar: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _enviando = false;
        });
      }
    }
  }

  Widget _conteudoPorEtapa() {
    if (_mostrouResultado) {
      return Column(
        children: [
          DiseasePrediction(
            diseaseText: _resultadoRotulo ?? 'Análise indisponível',
          ),
        ],
      );
    }

    switch (_etapaAtual) {
      case 0:
        return _etapa1();
      case 1:
        return _etapa2();
      case 2:
        return _etapa3();
      case 3:
        return _etapa4();
      case 4:
        return _etapa5();
      case 5:
      default:
        return _etapa6();
    }
  }

  String _textoBotao() {
    if (_mostrouResultado) return 'Começar Novamente';
    if (_etapaAtual < 5) return 'Continuar';
    return 'Enviar Respostas';
  }

  void _onPressBotao() {
    if (_mostrouResultado) {
      setState(() {
        _resetarFluxo();
      });
      return;
    }

    // Validar se todas as perguntas foram respondidas antes de continuar
    if (!_todasPerguntasRespondidas()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor, responda todas as perguntas antes de continuar.',
          ),
          backgroundColor: AppColors.orange900,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 150,
            left: 16,
            right: 16,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_etapaAtual < 5) {
      setState(() {
        _etapaAtual += 1;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } else {
      _enviarRespostas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            bottomInset > 0 ? bottomInset + 20 : 250,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 6),
              _tituloTopo(),
              const SizedBox(height: 16),

              _conteudoPorEtapa(),

              const SizedBox(height: 28),
              Button(
                text: _enviando ? 'Enviando...' : _textoBotao(),
                onPressed: _enviando ? () {} : _onPressBotao,
              ),
              const SizedBox(height: 20),
              if (_enviando)
                const CircularProgressIndicator(color: AppColors.orange900),
            ],
          ),
        ),
      ),
    );
  }
}
