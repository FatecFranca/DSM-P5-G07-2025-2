package com.petdex.api.domain.contracts.dto.raca;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(
        name = "Requisição Raça",
        description = "Dados necessários para criar ou atualizar uma raça no sistema",
        example = "{\"nome\": \"Labrador\", \"especie\": \"507f1f77bcf86cd799439011\"}"
)
public class RacaReqDTO {

    @Schema(description = "Nome da raça", example = "Labrador", requiredMode = Schema.RequiredMode.REQUIRED)
    private String nome;

    @Schema(description = "ID da espécie à qual a raça pertence", example = "507f1f77bcf86cd799439011", requiredMode = Schema.RequiredMode.REQUIRED)
    private String especie;

    public RacaReqDTO() {
    }

    public RacaReqDTO(String nome, String especie) {
        this.nome = nome;
        this.especie = especie;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getEspecie() {
        return especie;
    }

    public void setEspecie(String especie) {
        this.especie = especie;
    }
}
