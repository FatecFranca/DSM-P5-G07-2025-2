# 🔌 Guia Completo de WebSocket - PetDex

## 📚 Índice
1. [O que é WebSocket?](#o-que-é-websocket)
2. [Como Funciona o WebSocket?](#como-funciona-o-websocket)
3. [WebSocket vs HTTP Tradicional](#websocket-vs-http-tradicional)
4. [Arquitetura do WebSocket no PetDex](#arquitetura-do-websocket-no-petdex)
5. [Implementação Backend (Spring Boot)](#implementação-backend-spring-boot)
6. [Implementação Frontend (JavaScript)](#implementação-frontend-javascript)
7. [Autenticação JWT no WebSocket](#autenticação-jwt-no-websocket)
8. [Exemplos Práticos](#exemplos-práticos)
9. [Troubleshooting](#troubleshooting)

---

## 🌐 O que é WebSocket?

**WebSocket** é um protocolo de comunicação que permite **comunicação bidirecional em tempo real** entre cliente e servidor através de uma **única conexão persistente**.

### Características Principais:
- ✅ **Comunicação Full-Duplex**: Cliente e servidor podem enviar mensagens simultaneamente
- ✅ **Conexão Persistente**: Uma única conexão TCP permanece aberta
- ✅ **Baixa Latência**: Ideal para aplicações em tempo real
- ✅ **Menor Overhead**: Após o handshake inicial, não há headers HTTP repetidos
- ✅ **Push do Servidor**: Servidor pode enviar dados sem solicitação do cliente

---

## ⚙️ Como Funciona o WebSocket?

### 1️⃣ Handshake Inicial (HTTP Upgrade)
```
Cliente → Servidor: HTTP GET /ws-petdex
Upgrade: websocket
Connection: Upgrade
```

```
Servidor → Cliente: HTTP 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
```

### 2️⃣ Conexão WebSocket Estabelecida
Após o handshake, a conexão HTTP é "atualizada" para WebSocket e permanece aberta.

### 3️⃣ Troca de Mensagens Bidirecional
```
Cliente ←→ Servidor: Mensagens em tempo real
```

### 4️⃣ Encerramento da Conexão
Qualquer lado pode fechar a conexão enviando um frame de fechamento.

---

## 🆚 WebSocket vs HTTP Tradicional

| Aspecto | HTTP Tradicional | WebSocket |
|---------|------------------|-----------|
| **Conexão** | Nova conexão para cada requisição | Conexão persistente |
| **Direção** | Cliente → Servidor (request/response) | Bidirecional (full-duplex) |
| **Overhead** | Headers HTTP em cada requisição | Handshake inicial apenas |
| **Latência** | Alta (nova conexão cada vez) | Baixa (conexão mantida) |
| **Push do Servidor** | Não (precisa polling) | Sim (nativo) |
| **Uso de Recursos** | Alto (muitas conexões) | Baixo (uma conexão) |

### Exemplo Comparativo:

**HTTP Polling (Ineficiente):**
```javascript
// Cliente precisa ficar perguntando ao servidor
setInterval(() => {
  fetch('/api/localizacao/123')
    .then(res => res.json())
    .then(data => console.log(data));
}, 1000); // A cada 1 segundo
```

**WebSocket (Eficiente):**
```javascript
// Servidor envia automaticamente quando há atualização
stompClient.subscribe('/topic/animal/123', (message) => {
  console.log('Nova localização:', JSON.parse(message.body));
});
```

---

## 🏗️ Arquitetura do WebSocket no PetDex

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENTE (Frontend)                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  SockJS + STOMP Client                               │   │
│  │  - Conecta ao endpoint /ws-petdex                    │   │
│  │  - Envia token JWT no header                         │   │
│  │  - Inscreve-se em tópicos: /topic/animal/{id}        │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↕ WebSocket
┌─────────────────────────────────────────────────────────────┐
│                    SERVIDOR (Spring Boot)                    │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  1. SecurityConfig                                   │   │
│  │     - Permite acesso ao /ws-petdex/**                │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  2. WebSocketConfig                                  │   │
│  │     - Configura endpoint STOMP                       │   │
│  │     - Habilita SockJS fallback                       │   │
│  │     - Registra WebSocketAuthInterceptor              │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  3. WebSocketAuthInterceptor                         │   │
│  │     - Valida token JWT no CONNECT                    │   │
│  │     - Autentica usuário                              │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  4. WebSocketNotificationService                     │   │
│  │     - Envia notificações para tópicos                │   │
│  │     - /topic/animal/{id} → LocalizacaoWebSocketDTO   │   │
│  │     - /topic/animal/{id} → BatimentoWebSocketDTO     │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  5. Services (LocalizacaoService, BatimentoService)  │   │
│  │     - Chamam WebSocketNotificationService            │   │
│  │     - Enviam notificações quando há atualizações     │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Fluxo de Dados:

```
1. Coleira envia localização → POST /localizacoes
2. LocalizacaoService salva no MongoDB
3. LocalizacaoService chama WebSocketNotificationService
4. WebSocketNotificationService envia para /topic/animal/{id}
5. Todos os clientes inscritos recebem a atualização em tempo real
```

---

## 🔧 Implementação Backend (Spring Boot)

### 1. Dependências (pom.xml)

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-websocket</artifactId>
</dependency>
```

### 2. Configuração do WebSocket

```java
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Autowired
    private WebSocketAuthInterceptor webSocketAuthInterceptor;

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        // Habilita broker em memória para tópicos
        config.enableSimpleBroker("/topic");
        
        // Prefixo para mensagens destinadas a @MessageMapping
        config.setApplicationDestinationPrefixes("/app");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws-petdex")
                .setAllowedOriginPatterns("*")
                .withSockJS(); // Fallback para navegadores antigos
    }

    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        // Adiciona interceptor de autenticação JWT
        registration.interceptors(webSocketAuthInterceptor);
    }
}
```

### 3. Configuração de Segurança

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                // Permite acesso ao WebSocket (autenticação feita pelo interceptor)
                .requestMatchers("/ws-petdex/**").permitAll()
                
                // Outras rotas...
                .anyRequest().authenticated()
            );
        
        return http.build();
    }
}
```

### 4. Interceptor de Autenticação JWT

```java
@Component
public class WebSocketAuthInterceptor implements ChannelInterceptor {

    @Autowired
    private JwtService jwtService;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        if (accessor != null && StompCommand.CONNECT.equals(accessor.getCommand())) {
            String token = extractToken(accessor);

            if (token != null && jwtService.validateToken(token)) {
                String userId = jwtService.extractUserId(token);
                
                UsernamePasswordAuthenticationToken authToken = 
                    new UsernamePasswordAuthenticationToken(userId, null, new ArrayList<>());
                
                SecurityContextHolder.getContext().setAuthentication(authToken);
                accessor.setUser(authToken);
            }
        }

        return message;
    }

    private String extractToken(StompHeaderAccessor accessor) {
        // Extrai do header Authorization: Bearer <token>
        List<String> authHeaders = accessor.getNativeHeader("Authorization");
        if (authHeaders != null && !authHeaders.isEmpty()) {
            String authHeader = authHeaders.get(0);
            if (authHeader.startsWith("Bearer ")) {
                return authHeader.substring(7);
            }
        }
        
        // Ou do query parameter ?token=<token>
        List<String> tokenParams = accessor.getNativeHeader("token");
        if (tokenParams != null && !tokenParams.isEmpty()) {
            return tokenParams.get(0);
        }
        
        return null;
    }
}
```

### 5. Serviço de Notificação WebSocket

```java
@Service
public class WebSocketNotificationService {

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    public void enviarNotificacaoLocalizacao(String animalId, LocalizacaoWebSocketDTO dto) {
        String topico = "/topic/animal/" + animalId;
        messagingTemplate.convertAndSend(topico, dto);
    }

    public void enviarNotificacaoBatimento(String animalId, BatimentoWebSocketDTO dto) {
        String topico = "/topic/animal/" + animalId;
        messagingTemplate.convertAndSend(topico, dto);
    }
}
```

### 6. DTOs para WebSocket

```java
public class LocalizacaoWebSocketDTO {
    private String messageType = "location_update";
    private String animalId;
    private String coleiraId;
    private Double latitude;
    private Double longitude;
    private Date timestamp;
    private Boolean isOutsideSafeZone;
    private Double distanciaDoPerimetro;
    
    // Getters e Setters...
}
```

```java
public class BatimentoWebSocketDTO {
    private String messageType = "heartrate_update";
    private String animalId;
    private String coleiraId;
    private Integer frequenciaMedia;
    private Date timestamp;
    
    // Getters e Setters...
}
```

### 7. Uso nos Services

```java
@Service
public class LocalizacaoService {

    @Autowired
    private WebSocketNotificationService webSocketNotificationService;

    public LocalizacaoResDTO create(LocalizacaoReqDTO dto) {
        // Salva a localização no banco
        Localizacao localizacao = localizacaoRepository.save(novaLocalizacao);
        
        // Envia notificação WebSocket
        LocalizacaoWebSocketDTO wsDto = new LocalizacaoWebSocketDTO(
            localizacao.getAnimalId(),
            localizacao.getColeiraId(),
            localizacao.getLatitude(),
            localizacao.getLongitude(),
            localizacao.getTimestamp(),
            isOutsideSafeZone,
            distancia
        );
        
        webSocketNotificationService.enviarNotificacaoLocalizacao(
            localizacao.getAnimalId(), 
            wsDto
        );
        
        return localizacaoResDTO;
    }
}
```

---

## 💻 Implementação Frontend (JavaScript)

### 1. Instalação das Bibliotecas

```bash
npm install sockjs-client stompjs
```

Ou via CDN:
```html
<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
```

### 2. Conexão Básica

```javascript
// Criar conexão SockJS
const socket = new SockJS('http://localhost:8080/ws-petdex');

// Criar cliente STOMP
const stompClient = Stomp.over(socket);

// Obter token JWT (do localStorage, por exemplo)
const token = localStorage.getItem('authToken');

// Conectar ao WebSocket
stompClient.connect(
  { Authorization: `Bearer ${token}` }, // Headers com JWT
  (frame) => {
    console.log('✅ Conectado ao WebSocket:', frame);
    
    // Após conectar, inscrever-se em tópicos
    inscreveEmTopicos();
  },
  (error) => {
    console.error('❌ Erro na conexão WebSocket:', error);
  }
);
```

### 3. Inscrição em Tópicos

```javascript
function inscreveEmTopicos() {
  const animalId = '507f1f77bcf86cd799439011'; // ID do animal
  
  // Inscrever-se no tópico de localização
  stompClient.subscribe(`/topic/animal/${animalId}`, (message) => {
    const data = JSON.parse(message.body);
    
    if (data.messageType === 'location_update') {
      atualizarLocalizacaoNoMapa(data);
    } else if (data.messageType === 'heartrate_update') {
      atualizarBatimentoCardiacoNaTela(data);
    }
  });
}
```

### 4. Tratamento de Mensagens

```javascript
function atualizarLocalizacaoNoMapa(data) {
  console.log('📍 Nova localização recebida:', data);
  
  // Atualizar marcador no mapa
  const marker = {
    lat: data.latitude,
    lng: data.longitude
  };
  
  // Verificar se está fora da área segura
  if (data.isOutsideSafeZone) {
    alert(`⚠️ ALERTA: ${data.animalId} está fora da área segura!`);
    mostrarNotificacao('Perigo', `Animal a ${data.distanciaDoPerimetro}m da área segura`);
  }
  
  // Atualizar UI
  atualizarMapa(marker);
}

function atualizarBatimentoCardiacoNaTela(data) {
  console.log('❤️ Novo batimento recebido:', data);
  
  document.getElementById('frequencia-cardiaca').textContent = 
    `${data.frequenciaMedia} BPM`;
}
```

### 5. Desconexão

```javascript
function desconectar() {
  if (stompClient !== null) {
    stompClient.disconnect(() => {
      console.log('🔌 Desconectado do WebSocket');
    });
  }
}

// Desconectar quando a página for fechada
window.addEventListener('beforeunload', desconectar);
```


