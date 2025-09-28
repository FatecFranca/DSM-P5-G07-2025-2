package com.petdex.api.domain.collections;

import jakarta.validation.constraints.NotBlank;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "especies")
public class Especie {
    @Id
    private String id;
    @NotBlank(message = "Nome não pode ser nulo ou vazio")
    private String nome;

    public Especie() {
    }

    public Especie(String nome) {
        this.nome = nome;
    }

    public Especie(String id, String nome) {
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
