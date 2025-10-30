package com.petdex.api.swagger.respostas;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(
        name = "Exemplo Resposta Deletar Espécie",
        description = "Mensagem de confirmação de exclusão de espécie"
)
public class ExemploRespostaDeletarEspecie {

    @Schema(description = "Mensagem de confirmação da exclusão", example = "Especie deletada com sucesso")
    private String mensagem;

    public ExemploRespostaDeletarEspecie() {
    }

    public ExemploRespostaDeletarEspecie(String mensagem) {
        this.mensagem = mensagem;
    }

    public String getMensagem() {
        return mensagem;
    }

    public void setMensagem(String mensagem) {
        this.mensagem = mensagem;
    }
}

