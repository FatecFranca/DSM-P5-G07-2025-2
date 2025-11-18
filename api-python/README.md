<p align="center">
  <img src="../docs/img/capa-python.svg" alt="Capa do Projeto" width="100%" />
</p>

# 🧮 API em Python — O Cérebro Analítico da PetDex

Bem-vindo à API de Análise de Dados da PetDex! Desenvolvida com **Python** e **FastAPI**, esta API é o coração analítico do nosso ecossistema. Ela é responsável por **transformar os dados brutos coletados pela coleira em insights acionáveis**, que são exibidos de forma clara e intuitiva no aplicativo mobile, capacitando os donos a cuidarem melhor da saúde de seus pets.

---

## ⚙️ Tecnologias Utilizadas

* **Python 3.11**
* **FastAPI** (Framework web moderno e assíncrono)
* **Pandas** (Análise e manipulação de dados)
* **NumPy** (Cálculos numéricos e estatísticos)
* **SciPy** (Cálculos científicos, como a distribuição normal)
* **Scikit-learn** (Modelos de Regressão Linear e Classificação)
* **PyPMML** (Carregamento e execução de modelos PMML)
* **httpx** (Cliente HTTP assíncrono para comunicação com a API Java)
* **Uvicorn** (Servidor ASGI)
* **Azure** (Plataforma de hospedagem da API)

---

## 🧠 Objetivo da API

Esta API **não coleta dados diretamente da coleira**. Seu papel estratégico é **consumir os dados já armazenados na API principal (Java)** e aplicar uma camada de inteligência sobre eles. Ela executa desde cálculos estatísticos básicos até modelos de regressão complexos, fornecendo as análises que tornam o aplicativo PetDex uma ferramenta poderosa para o monitoramento da saúde animal.

---

## 🔬 Conectando a Ciência de Dados à Saúde do Seu Pet

O verdadeiro poder desta API está em como suas funcionalidades se traduzem em recursos visuais e práticos para o usuário. Cada cálculo tem um propósito: dar ao dono do pet a tranquilidade e as informações necessárias para tomar decisões importantes.

### **Previsão de Batimentos: A Regressão Linear em Ação**
A funcionalidade de **previsão de batimentos**, exibida no aplicativo, é alimentada diretamente pelo nosso modelo de regressão linear. A análise demonstrou uma **forte correlação entre a frequência cardíaca e os dados de movimento do animal**, capturados pelo acelerômetro nos três eixos (X, Y, Z). O modelo aprende esse padrão e se torna capaz de **prever a frequência cardíaca esperada com base na atividade física atual do animal**, ajudando a distinguir um aumento de batimentos normal (durante uma brincadeira) de uma anomalia.

<p align="center">
  <img src="../docs/img/mobile/mobile-previsao-batimento.gif" alt="Previsão de Batimento Cardíaco no App" width="250px" />
</p>
<p align="center">
  <em>No aplicativo, essa análise se traduz na tela de "Previsão", onde o usuário vê a projeção dos batimentos com base na atividade do pet.</em>
</p>

### **Probabilidade e Cuidado Proativo: Mais Poder para o Dono**
Calcular a **probabilidade de um determinado batimento cardíaco ocorrer** é uma das ferramentas mais importantes que oferecemos. Utilizando a distribuição normal dos dados históricos do pet, o aplicativo consegue informar ao dono se uma medição atual está dentro do esperado ou se é um valor estatisticamente raro. Ao identificar um padrão com baixa probabilidade, o dono é alertado, o que pode **antecipar uma visita ao veterinário e, em casos extremos, salvar a vida do animal**.

<p align="center">
  <img src="../docs/img/mobile/mobile-saude-probabilidade.gif" alt="Probabilidade de Batimento no App" width="250px" />
</p>
<p align="center">
  <em>A funcionalidade "Probabilidade de Batimento" permite ao dono verificar se uma medição é um evento comum ou raro para seu animal.</em>
</p>

---

## 📡 Endpoints e sua Aplicação Visual

A API está hospedada em um servidor **Azure** (Ubuntu, Standard B1ms) e pode ser acessada através do link:

🔗 **API Base:** [http://172.206.27.122:8083](http://172.206.27.122:8083)

📘 **Documentação Interativa (Swagger):** [http://172.206.27.122:8083/docs](http://172.206.27.122:8083/docs)

### 🔐 Autenticação JWT

Todos os endpoints (exceto `/health`) requerem autenticação via **JWT (JSON Web Tokens)**.

### **🔑 Credenciais de Teste**

Para obter um token JWT, utilize as seguintes credenciais na API Java:

```json
{
  "email": "henriquealmeidaflorentino@gmail.com",
  "senha": "senha123"
}
```

**Como usar no Swagger:**

1. Obtenha um token JWT da API Java (endpoint `POST /auth/login` em [http://172.206.27.122:8080/swagger](http://172.206.27.122:8080/swagger))
2. Use as credenciais acima para fazer login
3. Copie o token JWT retornado
4. Clique no botão **"Authorize"** (cadeado) no topo do Swagger da API Python
5. Cole o token no campo de texto (apenas o token, sem "Bearer")
6. Clique em **"Authorize"**
7. Todos os seus requests incluirão automaticamente o header `Authorization: Bearer <token>`

Para mais detalhes, consulte:

* 📖 **[SWAGGER_JWT_GUIDE.md](./SWAGGER_JWT_GUIDE.md)** - Guia rápido de autenticação JWT
* 📚 **[SWAGGER_EXAMPLES.md](./SWAGGER_EXAMPLES.md)** - Exemplos práticos de requisições
* 📝 **[SWAGGER_DOCUMENTATION.md](./SWAGGER_DOCUMENTATION.md)** - Documentação técnica completa

Cada endpoint abaixo tem um propósito claro, alimentando uma parte específica da interface do usuário. Por exemplo, os dados estatísticos e as médias diárias são consolidados no dashboard principal de saúde do aplicativo:

<p align="center">
  <img src="../docs/img/mobile/mobile-saude.gif" alt="Dashboard de Saúde no App" width="250px" />
</p>
<p align="center">
  <em>O endpoint <code>/batimentos/estatisticas</code> alimenta este dashboard com os principais insights de saúde.</em>
</p>

| Rota                                                          | Descrição                                                                                                        |
| ------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `/batimentos`                                                 | Retorna todos os batimentos cardíacos coletados.                                                                 |
| `/batimentos/estatisticas`                                    | Fornece as estatísticas gerais que alimentam o dashboard de saúde (média, moda, desvio padrão, etc.).            |
| `/batimentos/media-por-data?inicio=YYYY-MM-DD&fim=YYYY-MM-DD` | Calcula a média de batimentos em um intervalo específico.                                                          |
| `/batimentos/media-ultimos-5-dias`                            | Gera o gráfico principal da tela de saúde, com a média diária dos últimos 5 dias.                                |
| `/batimentos/media-ultimas-5-horas-registradas`               | Gera o gráfico da tela inicial, com a média das últimas 5 horas de coleta.                                       |
| `/batimentos/probabilidade?valor=XX`                          | **Calcula a probabilidade de um batimento ocorrer, ajudando o dono a identificar valores atípicos para seu pet.** |
| `/batimentos/regressao`                                       | **Fornece os dados de correlação e regressão que alimentam a tela de previsão de batimentos do aplicativo.** |
| `/health`                                                     | Verifica se a API está online.                                                                                   |

---

## 🔗 Comunicação entre APIs

A **API Python se conecta diretamente à API Java** usando o cliente HTTP assíncrono `httpx`. Ela faz requisições paginadas para obter todos os dados de **batimentos cardíacos** (`GET /batimentos/animal/{id}`) e **movimentos** (`GET /movimentos/animal/{id}`).

Esses dados são então transformados em `DataFrames` do Pandas, onde são limpos, processados, agrupados e cruzados para as análises avançadas.

---

## 📉 Exemplo de Análise de Regressão

A resposta do endpoint `/batimentos/regressao` alimenta diretamente a funcionalidade de previsão no app, fornecendo coeficientes, correlações e projeções:

```json
{
  "coeficientes": {
    "acelerometroX": 11.356,
    "acelerometroY": -16.507,
    "acelerometroZ": 5.498
  },
  "correlacoes": {
    "acelerometroX": 0.287,
    "acelerometroY": -0.445,
    "acelerometroZ": 0.252
  },
  "r2": 0.314,
  "media_erro_quadratico": 356.84,
  "projecao_5_horas": {
    "2025-06-09T22:35:00-03:00": 66.9,
    "2025-06-09T23:35:00-03:00": 66.9
  }
}
```

---

## 🧠 Modelo de Inteligência Artificial: CART

A API Python é responsável por carregar e executar o **modelo de classificação de espécies** da PetDex, que identifica se um animal é um cão ou gato com base em características físicas.

### **O Modelo Escolhido: CART (Árvore de Decisão)**

Após um rigoroso processo de desenvolvimento e validação, o modelo **CART (Classification and Regression Trees)** foi selecionado como o "cérebro" oficial da PetDex.

### **Processo de Seleção**

1. **Desafio Inicial:** Decidir entre um modelo **generalista** (8 espécies) ou **especialista** (apenas cães e gatos)

2. **Treinamento Extensivo:** Foram treinados **12 modelos classificadores diferentes**, incluindo:
   - SVM (Support Vector Machine)
   - Logistic Regression
   - Árvores de Decisão (CART)
   - Random Forest
   - E outros algoritmos do Scikit-learn

3. **Validação Rigorosa:**
   - Análise com **Cross-Validation** para avaliar a performance
   - Gráficos **Boxplot** para comparar a distribuição de acurácia
   - Teste final com **20 casos reais de cães e gatos**

4. **Resultado:** O modelo CART treinado **APENAS com cães e gatos** atingiu **100% de acerto** no teste final

### **Formato PMML: Portabilidade Universal**

Todos os modelos foram exportados para o formato **PMML (Predictive Model Markup Language)**, um padrão universal que permite:

- Compatibilidade com múltiplas plataformas e linguagens
- Independência do framework de treinamento (Scikit-learn)
- Fácil integração com a API Python via biblioteca PyPMML
- Portabilidade para outros sistemas futuros

O arquivo `modelo_CART.pmml` está localizado na raiz do projeto da API Python e é carregado automaticamente na inicialização da aplicação.

### **Integração com o Aplicativo**

O aplicativo Flutter consome os endpoints da API Python que utilizam o modelo CART para realizar classificações em tempo real, permitindo que os usuários identifiquem a espécie de seus pets de forma rápida e precisa.

---

## 📁 Como Executar Localmente

```bash
# Clone o repositório principal
git clone https://github.com/FatecFranca/DSM-P4-G07-2025-1.git

# Navegue até o diretório da API Python
cd DSM-P4-G07-2025-1/api-python

# Crie e ative um ambiente virtual
python -m venv .venv
source .venv/bin/activate  # ou .venv\Scripts\activate no Windows

# Configure o arquivo .env (copie do .env.example e ajuste as variáveis)
cp .env.example .env

# Instale as dependências
pip install -r requirements.txt

# Execute o servidor de desenvolvimento
uvicorn app.main:app --reload
```

A API estará disponível em `http://localhost:8000` e a documentação Swagger em `http://localhost:8000/docs`.

---

## 🚀 Infraestrutura de Hospedagem

A API está hospedada em um servidor **Microsoft Azure** com as seguintes especificações:

- **Sistema Operacional:** Ubuntu
- **Tipo de Máquina:** Standard B1ms
- **IP Público:** 172.206.27.122
- **Porta:** 8083

Esta infraestrutura garante alta disponibilidade e performance para o processamento analítico e execução do modelo de IA em tempo real.

---

## ✅ Status

🟢 **Em produção** — a API está em funcionamento e integrada com o ecossistema PetDex.