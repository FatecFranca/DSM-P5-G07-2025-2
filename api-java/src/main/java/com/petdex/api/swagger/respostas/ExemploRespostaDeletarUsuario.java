package com.petdex.api.swagger.respostas;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(
        name = "Exemplo Resposta Deletar Usuário",
        description = "Mensagem de confirmação de exclusão de usuário"
)
public class ExemploRespostaDeletarUsuario {

    @Schema(description = "Mensagem de confirmação da exclusão", example = "Usuário deletado com sucesso")
    private String mensagem;

    public ExemploRespostaDeletarUsuario() {
    }

    public ExemploRespostaDeletarUsuario(String mensagem) {
        this.mensagem = mensagem;
    }

    public String getMensagem() {
        return mensagem;
    }

    public void setMensagem(String mensagem) {
        this.mensagem = mensagem;
    }
}

