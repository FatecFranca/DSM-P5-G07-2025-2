package com.petdex.api.domain.contracts.dto.raca;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(
        name = "Resposta Raça",
        description = "Informações de uma raça retornadas pela API",
        example = "{\"id\": \"507f1f77bcf86cd799439011\", \"nome\": \"Labrador\", \"especieNome\": \"Cachorro\"}"
)
public class RacaResDTO {

    @Schema(description = "Código único identificador da raça", example = "507f1f77bcf86cd799439011")
    private String id;

    @Schema(description = "Nome da raça", example = "Labrador")
    private String nome;

    @Schema(description = "ID da espécie à qual a raça pertence", example = "507f1f77bcf86cd799439011")
    private String especie;

    public RacaResDTO() {
    }

    public RacaResDTO(String nome, String especie) {
        this.nome = nome;
        this.especie = especie;
    }

    public RacaResDTO(String id, String nome, String especie) {
        this.especie = especie;
        this.nome = nome;
        this.id = id;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getespecie() {
        return especie;
    }

    public void setespecie(String especie) {
        this.especie = especie;
    }
}
