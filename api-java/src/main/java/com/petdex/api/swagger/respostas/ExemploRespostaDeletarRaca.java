package com.petdex.api.swagger.respostas;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(
        name = "Exemplo Resposta Deletar Raça",
        description = "Mensagem de confirmação de exclusão de raça"
)
public class ExemploRespostaDeletarRaca {

    @Schema(description = "Mensagem de confirmação da exclusão", example = "Raça deletada com sucesso!")
    private String mensagem;

    public ExemploRespostaDeletarRaca() {
    }

    public ExemploRespostaDeletarRaca(String mensagem) {
        this.mensagem = mensagem;
    }

    public String getMensagem() {
        return mensagem;
    }

    public void setMensagem(String mensagem) {
        this.mensagem = mensagem;
    }
}

