<p align="center">
  <img src="docs/img/capa-dex.svg" alt="Capa do Projeto" width="100%" />
</p>

# 🐾 PetDex

Repositório do **Grupo 07** do Projeto Interdisciplinar do **5º semestre** do curso de **Desenvolvimento de Software Multiplataforma - DSM** (Turma 2025/2).

---

## 🎬 Veja o vídeo do projeto

<p align="center">
  <a href="https://www.youtube.com/watch?v=gWR23YgJ_aQ">
    <img src="https://img.youtube.com/vi/gWR23YgJ_aQ/0.jpg" alt="Assista ao vídeo no YouTube" width="560" />
  </a>
</p>

📺 [Clique aqui para assistir ao vídeo](https://www.youtube.com/watch?v=gWR23YgJ_aQ)

---

## 👨‍💻 Integrantes

- **Felipe Avelino Pedaes**  
- **Gabriel Resende Spirlandelli**  
- **Henrique Almeida Florentino**  
- **Luiz Felipe Vieira Soares**

---

## 🔗 Acesso ao Projeto

* **🎨 FIGMA:** [Protótipo da Interface](https://www.figma.com/design/BZOrhXmiYHgesIZf1Ex3Pw/PetDex.?node-id=0-1&t=8nuIhASiCYaiae4f-1)
* **🐍 API de Análise (FastAPI - Python):** [http://172.206.27.122:8083/docs](http://172.206.27.122:8083/docs)
* **☕ API Principal (Java - Spring Boot):** [http://172.206.27.122:8080/swagger](http://172.206.27.122:8080/swagger)
* **📱 Aplicativo Mobile (APK Android):** [Baixar petdex.apk](./mobile/petdex.apk)

### **🔑 Credenciais de Teste**

Para testar a plataforma, utilize as seguintes credenciais:

```json
{
  "email": "henriquealmeidaflorentino@gmail.com",
  "senha": "senha123"
}
```

---

## 📖 Sobre o Projeto

O **PetDex** é uma solução **IoT + Mobile + IA** desenvolvida para o **monitoramento em tempo real da saúde e segurança de cães e gatos**.

A plataforma combina uma **coleira inteligente** equipada com sensores de batimentos cardíacos, movimentação e localização GPS com um **aplicativo móvel multiplataforma**, permitindo que o tutor acompanhe o bem-estar do animal 24h por dia.

<p align="center">
  <img src="./docs/img/petdex-coleira-1.jpg" alt="Coleira PetDex" width="100%" />
</p>

<p align="center">
  <img src="./docs/img/petdex-coleira-2.jpg" alt="Coleira PetDex - 2" width="49%" />
  <img src="./docs/img/petdex-coleira-3.jpg" alt="Coleira PetDex - 3" width="49%" />
</p>

O sistema coleta dados em tempo real e envia para o backend em nuvem, que processa e analisa essas informações com **inteligência artificial** para detectar alterações fisiológicas, prevenir doenças e notificar o tutor em caso de risco ou fuga.

A solução visa **prevenção, segurança e cuidado contínuo**, fortalecendo o vínculo entre humanos e seus pets.

---

## 📱 Nossa Plataforma

O **aplicativo PetDex**, desenvolvido em **Flutter**, entrega uma experiência completa e intuitiva para acompanhar a rotina do animal.

### **Principais Funcionalidades**

<p align="center">
  <img src="./docs/img/tela1.gif" alt="Tela Inicial do App" width="250px" />
</p>
<p align="center">
  <em><b>Tela Inicial (Figura 9a):</b> mostra a última localização e o batimento cardíaco mais recente do pet, além de um gráfico com as médias das últimas horas.</em>
</p>

---

<p align="center">
  <img src="./docs/img/tela2.gif" alt="Tela de Saúde" width="250px" />
</p>
<p align="center">
  <em><b>Tela de Saúde (Figura 9b):</b> exibe a média de batimentos diários, por data e análises estatísticas referente ao último batimento registrado.</em>
</p>

---

<p align="center">
  <img src="./docs/img/tela3.gif" alt="Tela de Checkup" width="250px" />
</p>
<p align="center">
  <em><b>Tela Checkup Inteligente (Figura 9c):</b> o tutor responde sintomas observados, e a IA da PetDex sugere possíveis condições com base nos dados coletados mas sem emitir diagnósticos, apenas orientações preventivas.</em>
</p>

---

<p align="center">
  <img src="./docs/img/tela4.gif" alt="Tela de Localização" width="250px" />
</p>
<p align="center">
  <em><b>Tela de Localização (Figura 9d):</b> mostra o mapa em tempo real e permite configurar uma <b>área segura</b>. O app envia alertas automáticos caso o pet saia ou retorne ao perímetro.</em>
</p>

---

## 📥 Baixe o Aplicativo Agora!

**Quer testar o PetDex no seu celular Android?**

Você pode baixar o aplicativo pronto para instalação sem precisar compilar o código:

<p align="center">
  <a href="./mobile/petdex.apk" download>
    <img src="https://img.shields.io/badge/Download-PetDex.apk-green?style=for-the-badge&logo=android" alt="Download APK" />
  </a>
</p>

### **📲 Como Instalar:**

1. **Baixe o arquivo APK** clicando no botão acima ou [neste link](./mobile/petdex.apk)
2. **Transfira para seu Android** (se baixou no computador)
3. **Abra o arquivo APK** no dispositivo
4. **Permita a instalação** de fontes desconhecidas (se solicitado nas configurações)
5. **Instale e abra** o aplicativo
6. **Faça login** com as [credenciais de teste](#-credenciais-de-teste) fornecidas acima

**Observação:** O aplicativo já está configurado para se conectar ao servidor Azure em produção.

---

## 📊 Análises Avançadas

A **API analítica (Python/FastAPI)** fornece endpoints que processam e interpretam os dados recebidos da coleira, incluindo:

- Estatísticas descritivas (média, moda, mediana, desvio padrão)
- Correlações entre movimento e batimentos cardíacos
- Previsões de batimentos futuros via **modelo de regressão linear**
- Status geral de saúde e alertas de anomalias

Esses resultados alimentam os dashboards do aplicativo, oferecendo uma visão clara e personalizada do comportamento e condição do pet.

---

## 🧠 Arquitetura da Solução

A PetDex foi desenvolvida com uma **arquitetura modular e distribuída**, dividida em três pilares:

### **1️⃣ Hardware (IoT) – Coleira Inteligente**

* **Microcontrolador:** ESP32 S3 Zero (Wi-Fi e Bluetooth)
* **Sensores:**
  - GY-MAX30102 → Batimentos cardíacos e oxigenação do sangue  
  - MPU6050 → Movimento e postura  
  - NEO-6M → Localização GPS  
* **Prototipagem:** Case em **impressão 3D (PLA)**, leve e ergonômico
* **Testes práticos:** realizados com o cão **Uno**, confirmando conforto e adaptação

---

### **2️⃣ Backend e Infraestrutura**

* **API Principal:** Java 21 + Spring Boot
  - Padrão **Domain-Driven Design (DDD)**
  - Persistência com **MongoDB** (séries temporais)
  - Documentação com **Swagger/OpenAPI**
  - Autenticação via **JWT (JSON Web Tokens)**

* **API Analítica:** Python 3.11 + FastAPI
  - Processamento estatístico e aprendizado de máquina
  - Bibliotecas: Pandas, NumPy, SciPy, Scikit-learn
  - Modelo de classificação **CART (Árvore de Decisão)** em formato PMML
  - Execução assíncrona com **Uvicorn**

* **Hospedagem:** Servidor Azure
  - Sistema Operacional: **Ubuntu**
  - Tipo de Máquina: **Standard B1ms**
  - APIs acessíveis via IP público

---

### **3️⃣ Aplicativo Mobile**

* **Framework:** Flutter  
* **Recursos:**  
  - Monitoramento em tempo real  
  - Dashboards de saúde  
  - Checkup inteligente com IA  
  - Notificações e alertas de fuga  
  - Mapa interativo (Google Maps API)

---

## 🔐 Sistema de Autenticação JWT

A PetDex implementa um sistema robusto de autenticação baseado em **JWT (JSON Web Tokens)** para garantir a segurança das comunicações entre os componentes da plataforma.

### **Como Funciona**

1. **Login do Usuário:** O usuário realiza login através do aplicativo mobile, enviando suas credenciais para a API Java
2. **Geração do Token:** A API Java valida as credenciais e gera um token JWT assinado
3. **Propagação do Token:** O token é armazenado no aplicativo e enviado em todas as requisições subsequentes
4. **Fluxo de Autenticação:** Cliente → API Python → API Java
   - O aplicativo mobile envia o token JWT para a API Python
   - A API Python valida e propaga o token para a API Java
   - A API Java valida o token e processa a requisição

### **Configuração**

Ambas as APIs (Java e Python) compartilham a mesma chave secreta JWT (`JWT_SECRET`) configurada nos arquivos `.env`, garantindo que os tokens possam ser validados em toda a infraestrutura.

---

## 🧠 Modelo de Inteligência Artificial

A PetDex utiliza um modelo de **classificação de espécies** treinado com técnicas de aprendizado de máquina para identificar se um animal é um cão ou gato com base em características físicas.

### **O Desafio: Generalista vs. Especialista**

Durante o desenvolvimento, enfrentamos uma questão estratégica: treinar um modelo **generalista** capaz de classificar 8 espécies diferentes de animais presentes no dataset, ou um modelo **especialista** focado apenas em cães e gatos?

### **Processo de Desenvolvimento**

1. **Treinamento de Múltiplos Modelos:** Foram treinados **12 modelos classificadores diferentes**, incluindo:
   - SVM (Support Vector Machine)
   - Logistic Regression
   - Árvores de Decisão (CART)
   - Random Forest
   - E outros algoritmos do Scikit-learn

2. **Exportação Universal:** Todos os modelos foram exportados para o formato **PMML (Predictive Model Markup Language)**, um padrão universal compatível com a API Python e diversas outras plataformas

### **Validação e Seleção do Modelo**

- **Cross-Validation:** Realizamos análise rigorosa com validação cruzada para avaliar a performance de cada modelo
- **Análise Visual:** Gráficos Boxplot foram gerados para comparar a distribuição de acurácia entre os modelos
- **Teste Final:** Simulação de uso real com **20 casos reais de cães e gatos**

### **O Vencedor: CART Especialista**

O modelo **CART (Classification and Regression Trees)** treinado **APENAS com dados de cães e gatos** atingiu **100% de acerto** no teste final, superando todos os modelos generalistas.

O arquivo `modelo_CART.pmml` foi escolhido como o **"cérebro" oficial da PetDex** e está integrado à API Python, sendo utilizado pelo aplicativo Flutter para realizar classificações em tempo real.

---

## 🧩 Tecnologias Utilizadas

| Camada | Tecnologias |
|:-------|:-------------|
| **Hardware (IoT)** | ESP32 S3 Zero, GY-MAX30102, MPU6050, NEO-6M, Impressão 3D (PLA) |
| **Backend** | Java + Spring Boot, MongoDB, Swagger, JWT, FastAPI (Python), Scikit-learn, PMML |
| **Frontend** | Flutter, API Google Maps |
| **Infraestrutura** | Azure (Ubuntu, Standard B1ms), arquitetura de microsserviços |

---

## 🧪 Resultados

- Integração completa entre **coleira, backend e app**
- Transmissão e análise de dados em tempo real
- Teste físico com pet real validou **ergonomia e conforto**
- Modelo preditivo funcional de frequência cardíaca
- Base pronta para futuras versões com **IA classificadora** e **telemedicina veterinária**

---

> Projeto desenvolvido como parte das atividades acadêmicas da **FATEC** – Faculdade de Tecnologia.  
> Orientado pelos princípios de inovação, prevenção e bem-estar animal 🐕💙

