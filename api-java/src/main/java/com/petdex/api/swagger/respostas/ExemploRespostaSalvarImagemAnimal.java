package com.petdex.api.swagger.respostas;

import io.swagger.v3.oas.annotations.media.Schema;

/**
 * Classe de exemplo para resposta de salvamento de imagem do animal
 */
@Schema(
        name = "Exemplo Resposta Salvar Imagem Animal",
        description = "Exemplo de resposta ao salvar uma imagem de um animal",
        example = "/uploads/animais/123e4567-e89b-12d3-a456-426614174000_foto_pet.jpg"
)
public class ExemploRespostaSalvarImagemAnimal {

    @Schema(description = "URL da imagem salva no servidor", example = "/uploads/animais/123e4567-e89b-12d3-a456-426614174000_foto_pet.jpg")
    private String urlImagem;

    public ExemploRespostaSalvarImagemAnimal() {
    }

    public ExemploRespostaSalvarImagemAnimal(String urlImagem) {
        this.urlImagem = urlImagem;
    }

    public String getUrlImagem() {
        return urlImagem;
    }

    public void setUrlImagem(String urlImagem) {
        this.urlImagem = urlImagem;
    }
}

