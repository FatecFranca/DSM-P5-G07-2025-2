package com.petdex.api.domain.collections;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Positive;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Date;

@Document(collection = "animais")
public class Animal {
    @Id
    private String id;

    @NotBlank(message = "Nome não pode ser nulo ou vazio")
    private String nome;
    @NotBlank(message = "Data de nascimento não pode ser nulo ou vazio")
    private Date dataNascimento;
    @Pattern(regexp = "M|F", message = "O sexo deve ser M (MACHO) ou F (FÊMEA)")
    @NotBlank(message = "Sexo não pode ser nulo ou vazio")
    private String sexo;
    @NotBlank(message = "Peso não pode ser nulo ou vazio")
    @Positive(message = "Peso deve ser um número positivo e maior que zero")
    private Float peso;
    @NotBlank(message = "Castrado não pode ser nulo ou vazio")
    private Boolean castrado;
    @NotBlank(message = "usuarioId não pode ser nulo ou vazio")
    private String usuario;
    @NotBlank(message = "racaId não pode ser nulo ou vazio")
    private String raca;


    public Animal() {
    }

    public Animal(String id, String nome, Date dataNascimento, String sexo, Float peso, Boolean castrado, String usuario, String raca) {
        this.id = id;
        this.nome = nome;
        this.dataNascimento = dataNascimento;
        this.sexo = sexo;
        this.peso = peso;
        this.castrado = castrado;
        this.usuario = usuario;
        this.raca = raca;
    }

    public Animal(String nome, Date dataNascimento, String sexo, Float peso, Boolean castrado, String usuario, String raca) {
        this.nome = nome;
        this.dataNascimento = dataNascimento;
        this.sexo = sexo;
        this.peso = peso;
        this.castrado = castrado;
        this.usuario = usuario;
        this.raca = raca;
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
