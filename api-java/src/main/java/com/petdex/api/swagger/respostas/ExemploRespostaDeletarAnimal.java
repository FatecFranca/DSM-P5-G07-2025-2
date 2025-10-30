package com.petdex.api.swagger.respostas;

import io.swagger.v3.oas.annotations.media.Schema;

/**
 * Classe de exemplo para resposta de exclusão de animal
 */
@Schema(
        name = "Exemplo Resposta Deletar Animal",
        description = "Exemplo de resposta ao deletar um animal",
        example = "Animal deletado"
)
public class ExemploRespostaDeletarAnimal {

    @Schema(description = "Mensagem de confirmação da exclusão do animal", example = "Animal deletado")
    private String mensagem;

    public ExemploRespostaDeletarAnimal() {
    }

    public ExemploRespostaDeletarAnimal(String mensagem) {
        this.mensagem = mensagem;
    }

    public String getMensagem() {
        return mensagem;
    }

    public void setMensagem(String mensagem) {
        this.mensagem = mensagem;
    }
}

