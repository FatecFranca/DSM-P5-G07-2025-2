package com.petdex.api.domain.contracts.dto.coleira;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(
        name = "Requisição Coleira",
        description = "Dados necessários para criar ou atualizar uma coleira no sistema",
        example = "{\"descricao\": \"Coleira GPS Azul\", \"animal\": \"507f1f77bcf86cd799439011\"}"
)
public class ColeiraReqDTO {

    @Schema(description = "Descrição ou identificação da coleira", example = "Coleira GPS Azul", requiredMode = Schema.RequiredMode.REQUIRED)
    private String descricao;

    @Schema(description = "ID do animal ao qual a coleira está associada", example = "507f1f77bcf86cd799439011", requiredMode = Schema.RequiredMode.REQUIRED)
    private String animal;


    public ColeiraReqDTO() {
    }

    public ColeiraReqDTO(String descricao, String animal) {
        this.descricao = descricao;
        this.animal = animal;
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
