package com.petdex.api.swagger.respostas;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(
        name = "Exemplo Resposta Deletar Coleira",
        description = "Mensagem de confirmação de exclusão de coleira"
)
public class ExemploRespostaDeletarColeira {

    @Schema(description = "Mensagem de confirmação da exclusão", example = "Deletado com sucesso")
    private String mensagem;

    public ExemploRespostaDeletarColeira() {
    }

    public ExemploRespostaDeletarColeira(String mensagem) {
        this.mensagem = mensagem;
    }

    public String getMensagem() {
        return mensagem;
    }

    public void setMensagem(String mensagem) {
        this.mensagem = mensagem;
    }
}

