<p align="center">
  <img src="../docs/img/capa-java.svg" alt="Capa do Projeto" width="100%" />
</p>

# 🧠 API em Java — Coleira Inteligente

Esta é a API RESTful desenvolvida com **Java** e **Spring Boot**, responsável por receber os dados enviados pela coleira inteligente, realizar o cadastro de usuários e animais no banco de dados, e transmitir atualizações em tempo real via **WebSocket** para o aplicativo mobile.

---

## ⚙️ Tecnologias Utilizadas

- **Java 21**
- **Spring Boot**
- **MongoDB** (Banco de dados NoSQL)
- **JWT (JSON Web Tokens)** (Autenticação e Segurança)
- **WebSocket + STOMP** (Comunicação em Tempo Real)
- **SockJS** (Fallback para navegadores sem suporte WebSocket)
- **Swagger/OpenAPI** (Documentação)
- **Azure** (Hospedagem da API)

---

## 📐 Arquitetura

A API foi desenvolvida seguindo o padrão **DDD (Domain-Driven Design)**, escolhido pela facilidade de organizar as regras de negócio e manter o código desacoplado e escalável.

A estrutura do projeto é composta por:

- **Entidades (Domain):** Representam os modelos principais do sistema.
- **DTOs (Data Transfer Objects):** Utilizados para garantir a segurança do sistema, evitando o acesso direto às entidades e controlando os dados expostos pela API.
- **Controllers:** Responsáveis por receber as requisições HTTP e direcioná-las para os serviços.
- **Services:** Contêm as regras de negócio e a lógica de processamento dos dados.
- **Repositories:** Camada responsável pela persistência e acesso ao banco de dados (MongoDB).
- **WebSocket Services:** Gerenciam a comunicação em tempo real, enviando notificações instantâneas para os clientes conectados.
- **Security Interceptors:** Validam autenticação JWT tanto em requisições HTTP quanto em conexões WebSocket.

---

## 📡 Endpoints

A API está hospedada em um servidor **Azure** (Ubuntu, Standard B1ms) e pode ser acessada através do link:

🔗 **API Base:** [http://172.206.27.122:8080](http://172.206.27.122:8080)

A documentação interativa da API, feita com Swagger (OpenAPI), está disponível em:

📘 **Swagger UI:** [http://172.206.27.122:8080/swagger](http://172.206.27.122:8080/swagger)

### **🔑 Credenciais de Teste**

Para testar os endpoints protegidos, utilize as seguintes credenciais:

```json
{
  "email": "henriquealmeidaflorentino@gmail.com",
  "senha": "senha123"
}
```

**Como testar no Swagger:**

1. Acesse o endpoint de login (`POST /auth/login`)
2. Use as credenciais acima no corpo da requisição
3. Copie o token JWT retornado
4. Clique no botão **"Authorize"** (cadeado) no topo da página
5. Cole o token e clique em **"Authorize"**
6. Agora você pode testar todos os endpoints protegidos

---

## 🔐 Sistema de Autenticação JWT

A API implementa autenticação baseada em **JWT (JSON Web Tokens)** para garantir a segurança das comunicações.

### **Como Funciona**

1. **Login:** O usuário envia suas credenciais (email e senha) para o endpoint de autenticação
2. **Geração do Token:** A API valida as credenciais no banco de dados e gera um token JWT assinado
3. **Uso do Token:** O token deve ser incluído no header `Authorization: Bearer <token>` em todas as requisições protegidas
4. **Validação:** A API valida o token em cada requisição, verificando sua assinatura e expiração

### **Fluxo de Tokens**

A arquitetura da PetDex implementa um fluxo de autenticação em cascata:

```
Cliente (Mobile) → API Python → API Java
```

- O aplicativo mobile obtém o token JWT através do login na API Java
- Quando o mobile faz requisições para a API Python, envia o token JWT
- A API Python valida e propaga o token para a API Java
- A API Java valida o token e processa a requisição

Isso garante que a autenticação seja mantida em toda a cadeia de comunicação, sem necessidade de múltiplos logins.

### **Configuração**

A chave secreta JWT (`JWT_SECRET`) deve ser configurada no arquivo `.env` (veja `.env.example` para referência). **É fundamental que a mesma chave seja utilizada tanto na API Java quanto na API Python** para que os tokens possam ser validados em ambos os serviços.

---

## 🔌 Comunicação em Tempo Real via WebSocket

A API implementa **WebSocket com protocolo STOMP** para permitir comunicação bidirecional em tempo real entre a coleira inteligente, o servidor e o aplicativo mobile.

### **Como Funciona**

O WebSocket permite que o aplicativo mobile receba atualizações instantâneas sem precisar fazer polling (requisições repetidas). Quando a coleira envia novos dados para a API, estes são automaticamente transmitidos para todos os clientes conectados.

### **Endpoint de Conexão**

🔗 **WebSocket Endpoint:** `ws://172.206.27.122:8080/ws-petdex`

**Para desenvolvimento local:** `ws://localhost:8080/ws-petdex`

### **Autenticação WebSocket**

A conexão WebSocket também requer autenticação JWT. O token pode ser enviado de duas formas:

1. **Via Header Authorization:**
   ```
   Authorization: Bearer <seu_token_jwt>
   ```

2. **Via Query Parameter:**
   ```
   ws://172.206.27.122:8080/ws-petdex?token=<seu_token_jwt>
   ```

### **Tópicos de Inscrição**

Após conectar, o cliente deve se inscrever em tópicos específicos para receber atualizações:

| Tópico | Descrição | Dados Transmitidos |
|:-------|:----------|:-------------------|
| `/topic/animal/{animalId}` | Recebe todas as atualizações de um animal específico | Localização e batimentos cardíacos |

**Exemplo de inscrição:**
```javascript
stompClient.subscribe('/topic/animal/68194120636f719fcd5ee5fd', function(message) {
    const data = JSON.parse(message.body);
    console.log('Atualização recebida:', data);
});
```

### **Tipos de Mensagens**

A API envia dois tipos de mensagens via WebSocket:

#### **1. Atualização de Localização (`location_update`)**

```json
{
  "messageType": "location_update",
  "animalId": "68194120636f719fcd5ee5fd",
  "coleiraId": "coleira-001",
  "latitude": -23.5505,
  "longitude": -46.6333,
  "timestamp": "2025-01-18T14:30:00Z",
  "isOutsideSafeZone": false,
  "distanciaDoPerimetro": 15.5
}
```

**Campos:**
- `messageType`: Tipo da mensagem (sempre `location_update`)
- `animalId`: ID do animal
- `coleiraId`: ID da coleira
- `latitude`: Latitude da localização atual
- `longitude`: Longitude da localização atual
- `timestamp`: Data e hora da medição
- `isOutsideSafeZone`: Indica se o pet está fora da área segura
- `distanciaDoPerimetro`: Distância em metros do perímetro da área segura

#### **2. Atualização de Batimento Cardíaco (`heartrate_update`)**

```json
{
  "messageType": "heartrate_update",
  "animalId": "68194120636f719fcd5ee5fd",
  "coleiraId": "coleira-001",
  "frequenciaMedia": 85,
  "timestamp": "2025-01-18T14:30:00Z"
}
```

**Campos:**
- `messageType`: Tipo da mensagem (sempre `heartrate_update`)
- `animalId`: ID do animal
- `coleiraId`: ID da coleira
- `frequenciaMedia`: Frequência cardíaca média em BPM (batimentos por minuto)
- `timestamp`: Data e hora da medição

### **Tecnologias Utilizadas**

- **STOMP (Simple Text Oriented Messaging Protocol):** Protocolo de mensagens sobre WebSocket
- **SockJS:** Biblioteca de fallback para navegadores que não suportam WebSocket nativo
- **Spring WebSocket:** Implementação do Spring Framework para WebSocket
- **Message Broker em Memória:** Gerenciamento de mensagens e tópicos

### **Cliente de Teste**

A API inclui um **cliente HTML de teste** localizado em `cliente-teste-websocket.html` na raiz do projeto. Este cliente permite:

- Conectar ao WebSocket
- Inscrever-se em tópicos de animais específicos
- Visualizar mensagens em tempo real
- Testar a conexão e autenticação

**Como usar:**

1. Abra o arquivo `cliente-teste-websocket.html` em um navegador
2. Configure a URL do servidor (padrão: `http://localhost:8080/ws-petdex`)
3. Insira o ID do animal que deseja monitorar
4. Clique em "Conectar"
5. Observe as atualizações em tempo real

### **Integração com o Aplicativo Mobile**

O aplicativo Flutter se conecta automaticamente ao WebSocket quando o usuário faz login e:

- Recebe atualizações de localização em tempo real no mapa
- Atualiza os batimentos cardíacos instantaneamente
- Envia notificações quando o pet sai da área segura
- Mantém os dados sincronizados sem necessidade de refresh manual

---

## 🧩 Banco de Dados

Utilizamos o **MongoDB** como banco de dados pela sua alta disponibilidade, flexibilidade na estrutura de dados e facilidade de escalabilidade. Como se trata de um projeto com dados variáveis (ex.: batimentos cardíacos, localização, movimentação), um banco NoSQL foi a melhor escolha.

---

## 🚀 Infraestrutura de Hospedagem

A API está hospedada em um servidor **Microsoft Azure** com as seguintes especificações:

- **Sistema Operacional:** Ubuntu
- **Tipo de Máquina:** Standard B1ms
- **IP Público:** 172.206.27.122
- **Porta:** 8080

Esta infraestrutura garante alta disponibilidade e performance para o processamento dos dados da coleira inteligente em tempo real.

---

## 📁 Como Executar Localmente

```bash
# Clone o repositório
git clone https://github.com/FatecFranca/DSM-P4-G07-2025-1.git

# Navegue até o diretório da API Java
cd DSM-P4-G07-2025-1/api-java

# Configure o arquivo .env (copie do .env.example e ajuste as variáveis)
cp .env.example .env

# Execute com Maven
./mvnw spring-boot:run
```

A API estará disponível em `http://localhost:8080` e a documentação Swagger em `http://localhost:8080/swagger`.

---

Se você quiser testar a API ou contribuir com o projeto, fique à vontade para clonar o repositório e entrar em contato conosco!
