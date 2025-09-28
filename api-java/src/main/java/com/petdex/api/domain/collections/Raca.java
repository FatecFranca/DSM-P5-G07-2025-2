package com.petdex.api.domain.collections;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "racas")
public class Raca {

    @Id
    private String id;
    private String nome;
    private String especie;

    public Raca() {
    }

    public Raca(String nome, String especie) {
        this.nome = nome;
        this.especie = especie;
    }

    public Raca(String id, String nome, String especie) {
        this.id = id;
        this.nome = nome;
        this.especie = especie;
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

    public String getEspecie() {
        return especie;
    }

    public void setEspecie(String especie) {
        this.especie = especie;
    }
}
