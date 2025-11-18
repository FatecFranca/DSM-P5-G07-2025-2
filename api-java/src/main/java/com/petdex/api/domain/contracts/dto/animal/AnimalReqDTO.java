package com.petdex.api.domain.contracts.dto.animal;

import io.swagger.v3.oas.annotations.media.Schema;
import org.springframework.web.multipart.MultipartFile;

import java.util.Date;

@Schema(
        name = "Requisição Animal",
        description = "Dados necessários para criar ou atualizar um animal no sistema",
        example = "{\"nome\": \"Rex\", \"dataNascimento\": \"2020-01-15\", \"sexo\": \"Macho\", \"peso\": 25.5, \"castrado\": true, \"usuario\": \"507f1f77bcf86cd799439011\", \"raca\": \"507f1f77bcf86cd799439011\"}"
)
public class AnimalReqDTO {

    @Schema(description = "Nome do animal", example = "Rex", requiredMode = Schema.RequiredMode.REQUIRED)
    private String nome;

    @Schema(description = "Data de nascimento do animal", example = "2020-01-15", requiredMode = Schema.RequiredMode.REQUIRED)
    private Date dataNascimento;

    @Schema(description = "Sexo do animal", example = "Macho", requiredMode = Schema.RequiredMode.REQUIRED)
    private String sexo;

    @Schema(description = "Peso do animal em quilogramas", example = "25.5", requiredMode = Schema.RequiredMode.REQUIRED)
    private Float peso;

    @Schema(description = "Indica se o animal é castrado", example = "true", requiredMode = Schema.RequiredMode.REQUIRED)
    private Boolean castrado;

    @Schema(description = "ID do usuário responsável pelo animal", example = "507f1f77bcf86cd799439011", requiredMode = Schema.RequiredMode.REQUIRED)
    private String usuario;

    @Schema(description = "ID da raça do animal", example = "507f1f77bcf86cd799439011", requiredMode = Schema.RequiredMode.REQUIRED)
    private String raca;

    public AnimalReqDTO() {
    }

    public AnimalReqDTO(String nome, Date dataNascimento, String sexo, Float peso, Boolean castrado, String usuario, String raca) {
        this.nome = nome;
        this.dataNascimento = dataNascimento;
        this.sexo = sexo;
        this.peso = peso;
        this.castrado = castrado;
        this.usuario = usuario;
        this.raca = raca;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public Date getDataNascimento() {
        return dataNascimento;
    }

    public void setDataNascimento(Date dataNascimento) {
        this.dataNascimento = dataNascimento;
    }

    public String getSexo() {
        return sexo;
    }

    public void setSexo(String sexo) {
        this.sexo = sexo;
    }

    public Float getPeso() {
        return peso;
    }

    public void setPeso(Float peso) {
        this.peso = peso;
    }

    public Boolean getCastrado() {
        return castrado;
    }

    public void setCastrado(Boolean castrado) {
        this.castrado = castrado;
    }

    public String getUsuario() {
        return usuario;
    }

    public void setUsuario(String usuario) {
        this.usuario = usuario;
    }

    public String getRaca() {
        return raca;
    }

    public void setRaca(String string) {
        this.raca = string;
    }
}
