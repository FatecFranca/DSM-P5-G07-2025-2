package com.petdex.api.domain.contracts.dto.especie;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(
        name = "Requisição Espécie",
        description = "Dados necessários para criar ou atualizar uma espécie no sistema",
        example = "{\"nome\": \"Cachorro\"}"
)
public class EspecieReqDTO {

    @Schema(description = "Nome da espécie", example = "Cachorro", requiredMode = Schema.RequiredMode.REQUIRED)
    private String nome;

    public EspecieReqDTO() {
    }

    public EspecieReqDTO(String nome) {
        this.nome = nome;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }
}
