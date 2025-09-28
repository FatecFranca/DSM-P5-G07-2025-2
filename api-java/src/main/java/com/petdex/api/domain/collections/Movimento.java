package com.petdex.api.domain.collections;

import jakarta.validation.constraints.NotBlank;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Date;

@Document(collection = "movimentos")
public class Movimento {
    @Id
    private String id;

    @NotBlank(message = "Data não pode ser nulo ou vazio")
    private Date data;

    @NotBlank(message = "acelerometroX não pode ser nulo ou vazio")
    private Double acelerometroX;

    @NotBlank(message = "acelerometroY não pode ser nulo ou vazio")
    private Double acelerometroY;

    @NotBlank(message = "acelerometroZ não pode ser nulo ou vazio")
    private Double acelerometroZ;

    @NotBlank(message = "giroscopioX não pode ser nulo ou vazio")
    private Double giroscopioX;

    @NotBlank(message = "giroscopioY não pode ser nulo ou vazio")
    private Double giroscopioY;

    @NotBlank(message = "giroscopioZ não pode ser nulo ou vazio")
    private Double giroscopioZ;

    @NotBlank(message = "animalId não pode ser nulo ou vazio")
    private String animal;

    @NotBlank(message = "coleiraId não pode ser nulo ou vazio")
    private String coleira;


    public Movimento() {
    }

    public Movimento(Date data, Double acelerometroX, Double acelerometroY, Double acelerometroZ, Double giroscopioX, Double giroscopioY, Double giroscopioZ, String animal, String coleira) {
        this.data = data;
        this.acelerometroX = acelerometroX;
        this.acelerometroY = acelerometroY;
        this.acelerometroZ = acelerometroZ;
        this.giroscopioX = giroscopioX;
        this.giroscopioY = giroscopioY;
        this.giroscopioZ = giroscopioZ;
        this.animal = animal;
        this.coleira = coleira;
    }

    public Movimento(String id, Date data, Double acelerometroX, Double acelerometroY, Double acelerometroZ, Double giroscopioX, Double giroscopioY, Double giroscopioZ, String animal, String coleira) {
        this.id = id;
        this.data = data;
        this.acelerometroX = acelerometroX;
        this.acelerometroY = acelerometroY;
        this.acelerometroZ = acelerometroZ;
        this.giroscopioX = giroscopioX;
        this.giroscopioY = giroscopioY;
        this.giroscopioZ = giroscopioZ;
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

    public Double getAcelerometroX() {
        return acelerometroX;
    }

    public void setAcelerometroX(Double acelerometroX) {
        this.acelerometroX = acelerometroX;
    }

    public Double getAcelerometroY() {
        return acelerometroY;
    }

    public void setAcelerometroY(Double acelerometroY) {
        this.acelerometroY = acelerometroY;
    }

    public Double getAcelerometroZ() {
        return acelerometroZ;
    }

    public void setAcelerometroZ(Double acelerometroZ) {
        this.acelerometroZ = acelerometroZ;
    }

    public Double getGiroscopioX() {
        return giroscopioX;
    }

    public void setGiroscopioX(Double giroscopioX) {
        this.giroscopioX = giroscopioX;
    }

    public Double getGiroscopioY() {
        return giroscopioY;
    }

    public void setGiroscopioY(Double giroscopioY) {
        this.giroscopioY = giroscopioY;
    }

    public Double getGiroscopioZ() {
        return giroscopioZ;
    }

    public void setGiroscopioZ(Double giroscopioZ) {
        this.giroscopioZ = giroscopioZ;
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
