package com.petdex.api.domain.collections;

import jakarta.validation.constraints.NotBlank;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "coleiras")
public class Coleira {
    @Id
    private String id;
    @NotBlank(message = "Descrição não pode ser nulo ou vazio")
    private String descricao;
    @NotBlank(message = "animal não pode ser nulo ou vazio")
    private String animal;

    public Coleira() {
    }

    public Coleira(String descricao, String animal) {
        this.descricao = descricao;
        this.animal = animal;
    }

    public Coleira(String id, String descricao, String animal) {
        this.id = id;
        this.descricao = descricao;
        this.animal = animal;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public String getAnimal() {
        return animal;
    }

    public void setAnimal(String animal) {
        this.animal = animal;
    }
}
