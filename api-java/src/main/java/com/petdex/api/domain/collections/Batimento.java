package com.petdex.api.domain.collections;


import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.PositiveOrZero;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Date;

@Document(collection = "batimentos")
public class Batimento {
    @Id
    private String id;

    @NotBlank(message = "Data não pode ser nulo ou vazio")
    private Date data;

    @PositiveOrZero(message = "Frequência deve ser um número positivo")
    @NotBlank(message = "Frequência Média não pode ser nulo ou vazio")
    private Integer frequenciaMedia;

    @NotBlank(message = "animalId não pode ser nulo ou vazio")
    private String animal;

    @NotBlank(message = "coleiraId não pode ser nulo ou vazio")
    private String coleira;

    public Batimento() {
    }

    public Batimento(Date data, Integer frequenciaMedia, String animal, String coleira) {
        this.data = data;
        this.frequenciaMedia = frequenciaMedia;
        this.animal = animal;
        this.coleira = coleira;
    }

    public Batimento(String id, Date data, Integer frequenciaMedia, String animal, String coleira) {
        this.id = id;
        this.data = data;
        this.frequenciaMedia = frequenciaMedia;
        this.animal = animal;
        this.coleira = coleira;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public Date getData() {
        return data;
    }

    public void setData(Date data) {
        this.data = data;
    }

    public Integer getFrequenciaMedia() {
        return frequenciaMedia;
    }

    public void setFrequenciaMedia(Integer frequenciaMedia) {
        this.frequenciaMedia = frequenciaMedia;
    }

    public String getAnimal() {
        return animal;
    }

    public void setAnimal(String animal) {
        this.animal = animal;
    }

    public String getColeira() {
        return coleira;
    }

    public void setColeira(String coleira) {
        this.coleira = coleira;
    }
}
