<p align="center">
  <img src="../docs/img/capa-dex.svg" alt="Capa do Projeto" width="100%" />
</p>

# 📱 PetDex Mobile — Aplicativo de Monitoramento de Pets

Aplicativo móvel desenvolvido em **Flutter** para monitoramento em tempo real da saúde e segurança de cães e gatos através da coleira inteligente PetDex.

---

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado em sua máquina:

* **Flutter SDK** (versão 3.0 ou superior)
  - [Guia de instalação oficial](https://docs.flutter.dev/get-started/install)
* **Android Studio** ou **Xcode** (para emuladores)
* **Git** para clonar o repositório
* **Editor de código** (recomendado: VS Code ou Android Studio)

---

## 🚀 Como Executar o Aplicativo

### **1. Clone o Repositório**

```bash
git clone https://github.com/FatecFranca/DSM-P4-G07-2025-1.git
cd DSM-P4-G07-2025-1/mobile
```

### **2. Configure as Variáveis de Ambiente**

Crie um arquivo `.env` na raiz do projeto mobile (copie do `.env.example`):

```bash
cp .env.example .env
```

Edite o arquivo `.env` e configure as URLs das APIs:

```env
# URL da API Java (servidor Azure)
API_JAVA_URL=http://172.206.27.122:8080

# URL da API Python (servidor Azure)
API_PYTHON_URL=http://172.206.27.122:8083

# Chave da API do Google Maps
GOOGLE_MAPS_API_KEY=sua_chave_aqui
```

**Importante:** Para obter uma chave da API do Google Maps, acesse o [Google Cloud Console](https://console.cloud.google.com/) e ative a API do Google Maps.

### **3. Instale as Dependências**

```bash
flutter pub get
```

### **4. Execute o Aplicativo**

**Em um emulador ou dispositivo conectado:**

```bash
flutter run
```

**Para compilar para produção:**

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 📱 Funcionalidades do Aplicativo

### **🏠 Tela Inicial**

Exibe em tempo real:
- Última localização do pet no mapa
- Batimento cardíaco mais recente
- Gráfico com médias das últimas 5 horas

### **❤️ Tela de Saúde**

Apresenta análises detalhadas:
- Média de batimentos diários
- Gráficos de tendências por data
- Estatísticas descritivas (média, moda, mediana, desvio padrão)
- Probabilidade de batimentos atípicos

### **🩺 Checkup Inteligente**

Sistema de análise baseado em IA:
- Questionário sobre sintomas observados
- Sugestões de possíveis condições de saúde
- Orientações preventivas (não substitui consulta veterinária)

### **📍 Localização e Área Segura**

Monitoramento geográfico:
- Visualização em tempo real no mapa
- Configuração de perímetro de segurança
- Alertas automáticos de fuga ou retorno

### **🔔 Notificações**

Sistema de alertas:
- Batimentos cardíacos anormais
- Pet saiu da área segura
- Pet retornou à área segura
- Anomalias detectadas pela IA

---

## 🔐 Autenticação

O aplicativo utiliza autenticação **JWT (JSON Web Tokens)**:

1. **Login:** Usuário insere email e senha
2. **Token:** API Java gera e retorna um token JWT
3. **Armazenamento:** Token é armazenado localmente de forma segura
4. **Uso:** Token é enviado em todas as requisições para as APIs

O token é automaticamente renovado quando necessário, mantendo a sessão do usuário ativa.

### **🔑 Credenciais de Teste**

Para testar o aplicativo, utilize as seguintes credenciais:

```json
{
  "email": "henriquealmeidaflorentino@gmail.com",
  "senha": "senha123"
}
```

**Como usar:**

1. Abra o aplicativo
2. Na tela de login, insira o email: `henriquealmeidaflorentino@gmail.com`
3. Insira a senha: `senha123`
4. Clique em **"Entrar"**
5. Você terá acesso completo a todas as funcionalidades do aplicativo

---

## 🗂️ Estrutura do Projeto

```
mobile/
├── lib/
│   ├── main.dart              # Ponto de entrada do aplicativo
│   ├── models/                # Modelos de dados
│   ├── services/              # Serviços de comunicação com APIs
│   ├── screens/               # Telas do aplicativo
│   ├── widgets/               # Componentes reutilizáveis
│   └── utils/                 # Utilitários e helpers
├── assets/                    # Imagens, ícones e recursos
├── android/                   # Configurações Android
├── ios/                       # Configurações iOS
├── .env                       # Variáveis de ambiente (não versionado)
├── .env.example               # Exemplo de variáveis de ambiente
└── pubspec.yaml               # Dependências do projeto
```

---

## 🛠️ Tecnologias Utilizadas

* **Flutter** — Framework multiplataforma
* **Dart** — Linguagem de programação
* **Google Maps API** — Visualização de mapas
* **HTTP/Dio** — Comunicação com APIs REST
* **Provider** — Gerenciamento de estado
* **Shared Preferences** — Armazenamento local
* **Flutter Local Notifications** — Sistema de notificações

---

## 📞 Suporte

Em caso de dúvidas ou problemas:

1. Verifique se as URLs das APIs no arquivo `.env` estão corretas
2. Certifique-se de que as APIs estão online e acessíveis
3. Verifique se você tem uma conexão de internet ativa
4. Consulte a documentação das APIs:
   - [API Java (Swagger)](http://172.206.27.122:8080/swagger)
   - [API Python (Docs)](http://172.206.27.122:8083/docs)

---

## 📄 Licença

Este projeto foi desenvolvido como parte das atividades acadêmicas da **FATEC** – Faculdade de Tecnologia.

---

> **PetDex** — Cuidando do seu pet com tecnologia e amor 🐾💙
