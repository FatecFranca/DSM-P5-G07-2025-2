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
* **🐍 API de Análise (FastAPI - Python):** [https://api-python-petdex.onrender.com/docs](https://api-python-petdex.onrender.com/docs)
* **☕ API Principal (Java - Spring Boot):** [https://api-java-petdex.onrender.com/swagger-ui/index.html](https://api-java-petdex.onrender.com/swagger-ui/index.html)

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

* **API Analítica:** Python 3.11 + FastAPI  
  - Processamento estatístico e aprendizado de máquina  
  - Bibliotecas: Pandas, NumPy, SciPy, Scikit-learn  
  - Execução assíncrona com **Uvicorn**

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

## 🧩 Tecnologias Utilizadas

| Camada | Tecnologias |
|:-------|:-------------|
| **Hardware (IoT)** | ESP32 S3 Zero, GY-MAX30102, MPU6050, NEO-6M, Impressão 3D (PLA) |
| **Backend** | Java + Spring Boot, MongoDB, Swagger, FastAPI (Python), Scikit-learn |
| **Frontend** | Flutter, API Google Maps |
| **Infraestrutura** | Hospedagem em nuvem (Render), arquitetura de microsserviços |

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

