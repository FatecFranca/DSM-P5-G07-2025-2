package com.petdex.api.domain.contracts.dto.especie;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(
        name = "Resposta Espécie",
        description = "Informações de uma espécie retornadas pela API",
        example = "{\"id\": \"507f1f77bcf86cd799439011\", \"nome\": \"Cachorro\"}"
)
public class EspecieResDTO {

    @Schema(description = "Código único identificador da espécie", example = "507f1f77bcf86cd799439011")
    private String id;

    @Schema(description = "Nome da espécie", example = "Cachorro")
    private String nome;

    public EspecieResDTO() {
    }

    public EspecieResDTO(String nome) {
        this.nome = nome;
    }

    public EspecieResDTO(String id, String nome) {
        this.id = id;
        this.nome = nome;
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
}
