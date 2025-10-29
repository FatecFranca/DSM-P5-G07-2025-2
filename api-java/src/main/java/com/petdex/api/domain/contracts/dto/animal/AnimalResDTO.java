package com.petdex.api.domain.contracts.dto.animal;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.Date;

@Schema(
        name = "Resposta Animal",
        description = "Informações detalhadas de um animal retornadas pela API",
        example = "{\"id\": \"507f1f77bcf86cd799439011\", \"nome\": \"Rex\", \"dataNascimento\": \"2020-01-15\", \"sexo\": \"Macho\", \"peso\": 25.5, \"castrado\": true, \"usuario\": \"507f1f77bcf86cd799439011\", \"racaNome\": \"Labrador\", \"especieNome\": \"Cachorro\"}"
)
public class AnimalResDTO {

    @Schema(description = "Código único identificador do animal", example = "507f1f77bcf86cd799439011")
    private String id;

    @Schema(description = "Nome do animal", example = "Rex")
    private String nome;

    @Schema(description = "Data de nascimento do animal", example = "2020-01-15")
    private Date dataNascimento;

    @Schema(description = "Sexo do animal", example = "Macho")
    private String sexo;

    @Schema(description = "Peso do animal em quilogramas", example = "25.5")
    private Float peso;

    @Schema(description = "Indica se o animal é castrado", example = "true")
    private Boolean castrado;

    @Schema(description = "ID do usuário responsável pelo animal", example = "507f1f77bcf86cd799439011")
    private String usuario;

    @Schema(description = "Nome da raça do animal", example = "Labrador")
    private String racaNome;

    @Schema(description = "Nome da espécie do animal", example = "Cachorro")
    private String especieNome;

    @Schema(description = "Url da imagem do pet", example = "/uploads/animal/imagem-do-pet.png")
    private String urlImagem;

    public AnimalResDTO() {
    }

    public AnimalResDTO(String nome, Date dataNascimento, String sexo, Float peso, Boolean castrado, String usuario, String racaNome, String especieNome) {
        this.nome = nome;
        this.dataNascimento = dataNascimento;
        this.sexo = sexo;
        this.peso = peso;
        this.castrado = castrado;
        this.usuario = usuario;
        this.racaNome = racaNome;
    }

    public AnimalResDTO(String id, String nome, Date dataNascimento, String sexo, Float peso, Boolean castrado, String usuario, String racaNome, String especieNome) {
        this.id = id;
        this.nome = nome;
        this.dataNascimento = dataNascimento;
        this.sexo = sexo;
        this.peso = peso;
        this.castrado = castrado;
        this.usuario = usuario;
        this.racaNome = racaNome;
    }

    public AnimalResDTO(String id, String nome, Date dataNascimento, String sexo, Float peso, Boolean castrado, String usuario, String racaNome, String especieNome,String urlImagem) {
        this.id = id;
        this.nome = nome;
        this.dataNascimento = dataNascimento;
        this.sexo = sexo;
        this.peso = peso;
        this.castrado = castrado;
        this.usuario = usuario;
        this.racaNome = racaNome;
        this.urlImagem = urlImagem;
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

    public String getEspecieNome() {
        return especieNome;
    }

    public void setEspecieNome(String especieNome) {
        this.especieNome = especieNome;
    }

    public void setUsuario(String usuario) {
        this.usuario = usuario;
    }

    public String getRacaNome() {
        return racaNome;
    }

    public void setRacaNome(String string) {
        this.racaNome = string;
    }

    public String getUrlImagem() {
        return urlImagem;
    }

    public void setUrlImagem(String urlImagem) {
        this.urlImagem = urlImagem;
    }
}
