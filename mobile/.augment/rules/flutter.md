# Contexto do Projeto  
O **PetDex** é um aplicativo mobile desenvolvido em **Flutter** que exibe informações coletadas por uma coleira inteligente, incluindo batimentos cardíacos e localização do animal em tempo real.

Você será responsável por auxiliar na criação e manutenção dos componentes da pasta **`/mobile`**, que contém todo o código Flutter do aplicativo.

---

## 🎯 Escopo de Atuação  
- Você **deve atuar exclusivamente dentro da pasta `/mobile`**.  
- Nenhum arquivo fora dessa pasta deve ser criado, alterado ou referenciado.  

---

## 🧭 Diretrizes Gerais  

### Idioma  
- Todas as respostas devem ser **em português**.  
- Os **nomes de classes, componentes, variáveis e arquivos** devem ser escritos **em inglês**, seguindo as boas práticas do Flutter.

### Criação de Código  
- **Proibido gerar qualquer documentação em formato Markdown** (README, blocos explicativos etc.).  
- **Proibido incluir comentários dentro dos códigos**.  
- O foco deve ser em **código limpo, modular e reutilizável**.

### Estilo e Identidade Visual  
- Você deve respeitar e **manter a hierarquia visual e o esquema de cores já existente no projeto**.  
- A fonte padrão de todo o aplicativo deve ser **Poppins (Google Fonts)**.  
- Os novos componentes devem ser **visualmente consistentes** com o design atual.

### Modularização  
- Cada novo componente deve ser criado **pensando em reuso** em diferentes partes do app.  
- A estrutura deve seguir uma **arquitetura organizada e escalável**, conforme o padrão de pastas já implementado.

---

## ⚙️ Interações com a API  

Antes de desenvolver qualquer integração com a API, Você **deve solicitar obrigatoriamente ao usuário**:  
1. A **URL base** da API.  
2. O(s) **endpoint(s)** e o **método HTTP** de cada requisição.  
3. Um **exemplo dos dados retornados** (JSON de resposta).  

Com essas informações, você deve:  
- Criar **uma classe `service` específica** para cada tipo de requisição (ex: `PetService`, `HealthService`, `LocationService`, etc.).  
- Garantir que **dados sensíveis** (como URLs, tokens, chaves de API, métodos de criptografia e configurações de banco de dados) sejam armazenados em **variáveis de ambiente**.  
- Criar um arquivo **`.env.example`** com exemplos de uso.  
- O arquivo real de ambiente **não deve ser enviado ao repositório remoto**.

---

## 🚫 Restrições  
- **Não criar arquivos de teste automatizado.**  
- **Não gerar documentação técnica Markdown durante o processo.**  
- **Não modificar variáveis de ambiente reais.**  
- **Não incluir comentários em código.**

---

## 🧩 Pós-criação de Componentes  
Após criar qualquer componente,  deve explicar diretamente no chat:  
- O **nome do componente criado**.  
- As **funcionalidades** implementadas.  
- **Como utilizá-lo** dentro do projeto.  

Essa explicação deve ser curta, objetiva e sem incluir blocos de código adicionais ou comentários.

---

## 🔁 Resumo Rápido do Comportamento Esperado  

| Categoria | Diretriz |
|------------|-----------|
| Escopo | Atuar apenas dentro de `/mobile` |
| Linguagem | Português para respostas, Inglês para código |
| Comentários | Não permitidos |
| Documentação | Não gerar arquivos Markdown |
| Estilo | Fonte Poppins, respeitar cores e hierarquia do app |
| Estrutura | Modular e reutil