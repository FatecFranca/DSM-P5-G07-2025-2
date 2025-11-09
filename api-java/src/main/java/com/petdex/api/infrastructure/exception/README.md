# Sistema de Tratamento de Exceções

Este pacote contém o sistema de tratamento global de exceções da API PetDex.

## Problema Resolvido

Anteriormente, **todos os erros retornavam HTTP 401 (Unauthorized)**, mesmo quando o usuário estava autenticado corretamente e o problema era no servidor ou nos dados da requisição.

Agora, com o `GlobalExceptionHandler`, cada tipo de erro retorna o código HTTP correto:

- **404 (Not Found)**: Recurso não encontrado
- **400 (Bad Request)**: Dados inválidos na requisição
- **409 (Conflict)**: Conflito de dados (ex: email ou CPF duplicado)
- **500 (Internal Server Error)**: Erro no servidor
- **401 (Unauthorized)**: Apenas para problemas de autenticação JWT
- **403 (Forbidden)**: Apenas para problemas de permissão

## Exceções Customizadas

### ResourceNotFoundException
Use quando um recurso não for encontrado no banco de dados.

**Retorna**: HTTP 404 (Not Found)

**Exemplo de uso**:
```java
Animal animal = animalRepository.findById(id)
    .orElseThrow(() -> new ResourceNotFoundException("Animal", "ID", id));
```

### BadRequestException
Use quando os dados da requisição forem inválidos.

**Retorna**: HTTP 400 (Bad Request)

**Exemplo de uso**:
```java
if (email == null || email.isEmpty()) {
    throw new BadRequestException("O email é obrigatório");
}
```

### ConflictException
Use quando houver conflito de dados (ex: email ou CPF duplicado).

**Retorna**: HTTP 409 (Conflict)

**Exemplo de uso**:
```java
Optional<Usuario> usuarioExistente = usuarioRepository.findByEmail(email);
if (usuarioExistente.isPresent()) {
    throw new ConflictException("Usuário", "email", email);
}
```

## Como Usar em Outros Services

### Antes (ERRADO - retornava 401):
```java
Animal animal = animalRepository.findById(id)
    .orElseThrow(() -> new RuntimeException("Animal não encontrado"));
```

### Depois (CORRETO - retorna 404):
```java
import com.petdex.api.infrastructure.exception.ResourceNotFoundException;

Animal animal = animalRepository.findById(id)
    .orElseThrow(() -> new ResourceNotFoundException("Animal", "ID", id));
```

## Exceções Tratadas Automaticamente

O `GlobalExceptionHandler` também trata automaticamente:

- **MethodArgumentNotValidException**: Erros de validação `@Valid` → HTTP 400
- **IllegalArgumentException**: Argumentos inválidos → HTTP 400
- **IOException**: Erros de I/O (arquivos, etc.) → HTTP 500
- **MaxUploadSizeExceededException**: Arquivo muito grande → HTTP 413
- **Exception**: Qualquer outra exceção não tratada → HTTP 500

## Estrutura da Resposta de Erro

Todas as respostas de erro seguem o mesmo formato JSON:

```json
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 404,
  "error": "Recurso Não Encontrado",
  "message": "Animal não encontrado(a) com ID: '123'",
  "path": "/animais/123"
}
```

## Recomendações

1. **Use ResourceNotFoundException** para recursos não encontrados
2. **Use BadRequestException** para validações de negócio
3. **Use ConflictException** para conflitos de dados (email/CPF duplicado)
4. **Deixe RuntimeException** apenas para erros inesperados (será tratado como 500)
5. **Nunca use RuntimeException** para recursos não encontrados (isso causava o bug do 401)

