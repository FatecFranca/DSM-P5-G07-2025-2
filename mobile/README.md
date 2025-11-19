<p align="center">
  <img src="../docs/img/capa-dex.svg" alt="Capa do Projeto" width="100%" />
</p>

# 📱 PetDex Mobile — Aplicativo de Monitoramento de Pets

Aplicativo móvel desenvolvido em **Flutter** para monitoramento em tempo real da saúde e segurança de cães e gatos através da coleira inteligente PetDex.

---

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado em sua máquina:

### **Ferramentas Essenciais**

* **Flutter SDK** (versão 3.0 ou superior)
  - [Guia de instalação oficial](https://docs.flutter.dev/get-started/install)
  - Verifique a instalação: `flutter --version`
  - Execute: `flutter doctor` para verificar dependências

* **Git** para clonar o repositório
  - [Download do Git](https://git-scm.com/downloads)

* **Editor de código** (escolha um):
  - [Visual Studio Code](https://code.visualstudio.com/) + [Extensão Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
  - [Android Studio](https://developer.android.com/studio) + Plugin Flutter

### **Para Desenvolvimento Android**

* **Android Studio** (recomendado)
  - [Download do Android Studio](https://developer.android.com/studio)
  - Instale o Android SDK (API 21 ou superior)
  - Configure um emulador Android ou conecte um dispositivo físico

* **Java Development Kit (JDK)** 11 ou superior
  - Geralmente instalado com o Android Studio

### **Para Desenvolvimento iOS** (apenas macOS)

* **Xcode** (versão 12.0 ou superior)
  - Disponível na [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835)
  - Execute: `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
  - Execute: `sudo xcodebuild -runFirstLaunch`

* **CocoaPods** (gerenciador de dependências iOS)
  - Instale com: `sudo gem install cocoapods`

### **Verificação de Ambiente**

Após instalar as ferramentas, execute:

```bash
flutter doctor
```

Este comando verifica se todas as dependências estão instaladas corretamente e fornece instruções para resolver problemas.

---

## 🚀 Como Executar o Aplicativo

### **1. Clone o Repositório**

```bash
git clone https://github.com/FatecFranca/DSM-P4-G07-2025-1.git
cd DSM-P4-G07-2025-1/mobile
```

### **2. Configure a API do Google Maps**

O aplicativo utiliza o **Google Maps** para exibir a localização do pet em tempo real e configurar áreas seguras.

**Como obter a API Key do Google Maps:**

1. Acesse o [Google Cloud Console](https://console.cloud.google.com/)
2. Crie um novo projeto ou selecione um existente
3. Ative as seguintes APIs:
   - **Maps SDK for Android** (para Android)
   - **Maps SDK for iOS** (para iOS)
4. Vá em **Credenciais** → **Criar Credenciais** → **Chave de API**
5. Copie a chave gerada
6. (Recomendado) Restrinja a chave para maior segurança:
   - Restrições de aplicativo: Android/iOS
   - Restrições de API: Maps SDK

**Onde configurar a API Key no projeto:**

**Para Android:**

Edite o arquivo `android/app/src/main/AndroidManifest.xml` e adicione:

```xml
<manifest ...>
    <application ...>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="SUA_CHAVE_API_AQUI"/>
    </application>
</manifest>
```

**Para iOS:**

Edite o arquivo `ios/Runner/AppDelegate.swift` e adicione:

```swift
import GoogleMaps

GMSServices.provideAPIKey("SUA_CHAVE_API_AQUI")
```

📚 **Documentação oficial:** [Google Maps Platform](https://developers.google.com/maps/documentation)

### **3. Configure as Variáveis de Ambiente**

Crie um arquivo `.env` na raiz do projeto mobile (copie do `.env.example`):

```bash
cp .env.example .env
```

Edite o arquivo `.env` e configure as URLs das APIs:

```env
# URL da API Java (servidor Azure - Produção)
API_JAVA_URL=http://172.206.27.122:8080

# URL da API Python (servidor Azure - Produção)
API_PYTHON_URL=http://172.206.27.122:8083

# Para desenvolvimento local, use:
# API_JAVA_URL=http://localhost:8080
# API_PYTHON_URL=http://localhost:8000
```

**Variáveis de Ambiente Disponíveis:**

| Variável | Descrição | Exemplo |
|:---------|:----------|:--------|
| `API_JAVA_URL` | URL base da API Java (Spring Boot) | `http://172.206.27.122:8080` |
| `API_PYTHON_URL` | URL base da API Python (FastAPI) | `http://172.206.27.122:8083` |

**URLs do Servidor Azure (Produção):**

- **API Java:** `http://172.206.27.122:8080`
  - Swagger: `http://172.206.27.122:8080/swagger`
- **API Python:** `http://172.206.27.122:8083`
  - Docs: `http://172.206.27.122:8083/docs`

### **4. Instale as Dependências**

```bash
flutter pub get
```

### **5. Execute o Aplicativo**

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

## ⚠️ Limitação Atual - Usuário de Teste

**AVISO IMPORTANTE:** No momento, quando um novo usuário é cadastrado e um animal também é cadastrado, o aplicativo **não carregará corretamente** devido à falta de conexão com a coleira física.

Para testar todas as funcionalidades do aplicativo, utilize as credenciais do usuário padrão que já possui um animal cadastrado e conectado à coleira:

### **🔑 Credenciais de Teste**

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
5. Você terá acesso completo a todas as funcionalidades do aplicativo com dados reais da coleira

**Por que essa limitação existe?**

O aplicativo depende de dados enviados pela coleira física (batimentos cardíacos, localização GPS, movimento). Sem uma coleira conectada ao animal cadastrado, o aplicativo não receberá dados e não funcionará corretamente. Estamos trabalhando para melhorar essa experiência no futuro.

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

## 📥 Download do APK (Android)

**Quer testar o aplicativo sem compilar?** Baixe o APK pronto para instalação!

### **🔗 Link para Download**

📦 **[Baixar PetDex APK (Google Drive)](https://drive.google.com/file/d/1qfmFwAp55BwcIVp8BA7cER1gD2TSqYkW/view?usp=sharing)**

### **📲 Como Instalar o APK**

1. **Baixe o arquivo APK** do link acima
2. **Transfira o APK** para seu dispositivo Android (se baixou no computador)
3. **Habilite instalação de fontes desconhecidas:**
   - Vá em **Configurações** → **Segurança** → **Fontes desconhecidas**
   - Ou **Configurações** → **Aplicativos** → **Acesso especial** → **Instalar apps desconhecidos**
   - Permita a instalação para o navegador ou gerenciador de arquivos que você está usando
4. **Abra o arquivo APK** no seu dispositivo
5. **Toque em "Instalar"** e aguarde a conclusão
6. **Abra o aplicativo** e faça login com as credenciais de teste

### **⚠️ Requisitos do Dispositivo**

- **Android 5.0 (Lollipop)** ou superior
- **Conexão com a internet** para comunicação com as APIs
- **GPS ativado** para funcionalidades de localização
- **Permissões necessárias:** Localização, Notificações

---

## 🔐 Autenticação

O aplicativo utiliza autenticação **JWT (JSON Web Tokens)**:

1. **Login:** Usuário insere email e senha
2. **Token:** API Java gera e retorna um token JWT
3. **Armazenamento:** Token é armazenado localmente de forma segura
4. **Uso:** Token é enviado em todas as requisições para as APIs

O token é automaticamente renovado quando necessário, mantendo a sessão do usuário ativa.

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
