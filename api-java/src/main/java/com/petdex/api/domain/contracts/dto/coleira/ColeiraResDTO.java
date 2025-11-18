package com.petdex.api.domain.contracts.dto.coleira;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(
        name = "Resposta Coleira",
        description = "Informações detalhadas de uma coleira retornadas pela API",
        example = "{\"id\": \"507f1f77bcf86cd799439011\", \"descricao\": \"Coleira GPS Azul\", \"animal\": \"507f1f77bcf86cd799439011\"}"
)
public class ColeiraResDTO {

    @Schema(description = "Código único identificador da coleira", example = "507f1f77bcf86cd799439011")
    private String id;

    @Schema(description = "Descrição ou identificação da coleira", example = "Coleira GPS Azul")
    private String descricao;

    @Schema(description = "ID do animal ao qual a coleira está associada", example = "507f1f77bcf86cd799439011")
    private String animal;


    public ColeiraResDTO() {
    }

    public ColeiraResDTO(String descricao, String animal) {
        this.descricao = descricao;
        this.animal = animal;
    }

    public ColeiraResDTO(String id, String descricao, String animal) {
        this.id = id;
        this.descricao = descricao;
        this.animal = animal;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public String getAnimal() {
        return animal;
    }

    public void setAnimal(String animal) {
        this.animal = animal;
    }
}
