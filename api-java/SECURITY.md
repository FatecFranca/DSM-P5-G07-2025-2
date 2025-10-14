# 🔐 Documentação de Segurança - PetDex API

Este documento descreve as funcionalidades de segurança e autenticação implementadas na API PetDex.

---

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Criptografia de Senhas](#criptografia-de-senhas)
- [Autenticação JWT](#autenticação-jwt)
- [Configuração de Variáveis de Ambiente](#configuração-de-variáveis-de-ambiente)
- [Endpoints de Autenticação](#endpoints-de-autenticação)
- [Exemplos de Uso](#exemplos-de-uso)

---

## 🔍 Visão Geral

A API PetDex implementa as seguintes funcionalidades de segurança:

1. **Criptografia de Senhas com BCrypt**: Todas as senhas são criptografadas antes de serem armazenadas no banco de dados
2. **Autenticação JWT**: Sistema de autenticação baseado em tokens JWT (JSON Web Token)
3. **Proteção de Dados Sensíveis**: Senhas nunca são expostas nas respostas da API

---

## 🔒 Criptografia de Senhas

### Como Funciona

- Utiliza o algoritmo **BCrypt** para hash de senhas
- A força do algoritmo (número de rounds) é configurável via variável de ambiente
- As senhas são automaticamente criptografadas nos seguintes cenários:
  - Criação de novo usuário (`POST /usuarios`)
  - Atualização de senha (`PUT /usuarios/{id}`)

### Serviço Responsável

**`PasswordService`** - Localizado em `com.petdex.api.application.services.security`

Métodos principais:
- `hashPassword(String rawPassword)`: Criptografa uma senha em texto plano
- `validatePassword(String rawPassword, String hashedPassword)`: Valida se uma senha corresponde ao hash armazenado

---

## 🎫 Autenticação JWT

### Como Funciona

1. O usuário faz login com email e senha
2. A API valida as credenciais
3. Se válidas, a API gera um token JWT
4. O token é retornado junto com informações do usuário e ID do animal vinculado
5. O token deve ser incluído nas requisições futuras (implementação futura de middleware)

### Estrutura do Token JWT

O token contém as seguintes informações (claims):
- `userId`: ID do usuário
- `email`: Email do usuário
- `iat`: Data de emissão do token
- `exp`: Data de expiração do token

### Tempo de Expiração

- Padrão: **24 horas** (86400000 milissegundos)
- Configurável via variável de ambiente `jwt.expiration`

### Serviço Responsável

**`JwtService`** - Localizado em `com.petdex.api.application.services.security`

Métodos principais:
- `generateToken(String userId, String email)`: Gera um novo token JWT
- `validateToken(String token)`: Valida se um token é válido
- `extractUserId(String token)`: Extrai o ID do usuário do token
- `extractEmail(String token)`: Extrai o email do token

---

## ⚙️ Configuração de Variáveis de Ambiente

### Variáveis Necessárias

Configure as seguintes variáveis de ambiente antes de executar a aplicação:

#### 1. JWT_SECRET
- **Descrição**: Chave secreta para assinar os tokens JWT
- **Obrigatório**: Sim (em produção)
- **Valor Padrão**: `petdex-secret-key-change-in-production`
- **Recomendação**: Use uma string forte em produção (será convertida para 256 bits via SHA-256)
- **Nota**: A chave é automaticamente processada com SHA-256 para garantir o tamanho adequado

```bash
export JWT_SECRET="sua-chave-secreta-super-segura-aqui"
```

#### 2. BCRYPT_SALT
- **Descrição**: Força do algoritmo BCrypt (número de rounds)
- **Obrigatório**: Não
- **Valor Padrão**: `10`
- **Valores Recomendados**: Entre 10 e 12 (quanto maior, mais seguro, mas mais lento)

```bash
export BCRYPT_SALT=12
```

### Exemplo de Configuração Completa

```bash
# Banco de dados
export DATABASE_URI="mongodb://localhost:27017/petdex"

# Segurança
export JWT_SECRET="minha-chave-jwt-super-secreta-2024"
export BCRYPT_SALT=12
```

### Configuração no Docker/Render

Se estiver usando Docker ou Render, adicione as variáveis de ambiente no arquivo de configuração:

**Docker Compose:**
```yaml
environment:
  - DATABASE_URI=mongodb://mongo:27017/petdex
  - JWT_SECRET=sua-chave-secreta
  - BCRYPT_SALT=12
```

**Render:**
Adicione as variáveis no painel de configuração do serviço.

---

## 🌐 Endpoints de Autenticação

### POST /auth/login

Realiza o login do usuário e retorna um token JWT.

**Request:**
```json
{
  "email": "usuario@example.com",
  "senha": "senha123"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "animalId": "507f1f77bcf86cd799439011",
  "userId": "507f191e810c19729de860ea",
  "nome": "João Silva",
  "email": "usuario@example.com"
}
```

**Response (401 Unauthorized):**
Retornado quando as credenciais são inválidas.

---

## 💡 Exemplos de Uso

### 1. Criar um Novo Usuário

```bash
curl -X POST http://localhost:8080/usuarios \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "João Silva",
    "cpf": "123.456.789-00",
    "whatsApp": "(11) 98765-4321",
    "email": "joao@example.com",
    "senha": "senha123"
  }'
```

**Nota**: A senha será automaticamente criptografada antes de ser armazenada.

### 2. Fazer Login

```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "joao@example.com",
    "senha": "senha123"
  }'
```

**Resposta:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NWE...",
  "animalId": "65a1b2c3d4e5f6g7h8i9j0k1",
  "userId": "65a1b2c3d4e5f6g7h8i9j0k2",
  "nome": "João Silva",
  "email": "joao@example.com"
}
```

### 3. Usar o Token JWT (Implementação Futura)

Em requisições futuras, inclua o token no header:

```bash
curl -X GET http://localhost:8080/usuarios/me \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

---

## 🔐 Boas Práticas de Segurança

### Para Desenvolvimento

1. Use valores padrão para facilitar o desenvolvimento local
2. Nunca commite valores reais de `JWT_SECRET` no código

### Para Produção

1. **SEMPRE** configure `JWT_SECRET` com um valor forte e único
2. Use um valor de `BCRYPT_SALT` entre 10 e 12
3. Mantenha as variáveis de ambiente seguras e nunca as exponha publicamente
4. Considere usar um serviço de gerenciamento de secrets (AWS Secrets Manager, Azure Key Vault, etc.)
5. Implemente HTTPS para todas as comunicações
6. Configure rate limiting para prevenir ataques de força bruta

---

## 🛡️ Segurança Adicional

### Proteção de Dados

- **Senhas**: Nunca são retornadas nas respostas da API (removidas do `UsuarioResDTO`)
- **Tokens**: Têm tempo de expiração configurável
- **BCrypt**: Usa salt automático para cada senha

### Próximos Passos Recomendados

1. Implementar middleware de autenticação JWT para proteger endpoints
2. Adicionar refresh tokens para renovação de sessão
3. Implementar rate limiting
4. Adicionar logs de auditoria para tentativas de login
5. Implementar recuperação de senha via email
6. Adicionar autenticação de dois fatores (2FA)

---

## 📚 Referências

- [BCrypt](https://en.wikipedia.org/wiki/Bcrypt)
- [JWT (JSON Web Tokens)](https://jwt.io/)
- [Spring Security](https://spring.io/projects/spring-security)
- [OWASP Password Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)

---

## 📞 Suporte

Para dúvidas ou problemas relacionados à segurança, entre em contato com a equipe de desenvolvimento.

