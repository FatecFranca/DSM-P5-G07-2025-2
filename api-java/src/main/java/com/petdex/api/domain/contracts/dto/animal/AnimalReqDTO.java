package com.petdex.api.domain.contracts.dto.animal;

import java.util.Date;

public class AnimalReqDTO {

    private String nome;
    private Date dataNascimento;
    private String sexo;
    private Float peso;
    private Boolean castrado;
    private String usuario;
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
