package com.petdex.api.domain.collections;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Date;

/**
 * Entidade que representa uma área segura para um animal.
 * A área segura é definida por um ponto central (latitude/longitude) e um raio em metros.
 */
@Document(collection = "areas_seguras")
public class AreaSegura {
    
    @Id
    private String id;

    @NotBlank(message = "ID do animal não pode ser nulo ou vazio")
    private String animal;

    @NotNull(message = "Latitude não pode ser nula")
    private Double latitude;

    @NotNull(message = "Longitude não pode ser nula")
    private Double longitude;

    @NotNull(message = "Raio não pode ser nulo")
    @Positive(message = "Raio deve ser um número positivo maior que zero")
    private Double raio; // Raio em metros

    private Date dataCriacao;

    private Date dataAtualizacao;

    public AreaSegura() {
        this.dataCriacao = new Date();
        this.dataAtualizacao = new Date();
    }

    public AreaSegura(String animal, Double latitude, Double longitude, Double raio) {
        this.animal = animal;
        this.latitude = latitude;
        this.longitude = longitude;
        this.raio = raio;
        this.dataCriacao = new Date();
        this.dataAtualizacao = new Date();
    }

    public AreaSegura(String id, String animal, Double latitude, Double longitude, Double raio, Date dataCriacao, Date dataAtualizacao) {
        this.id = id;
        this.animal = animal;
        this.latitude = latitude;
        this.longitude = longitude;
        this.raio = raio;
        this.dataCriacao = dataCriacao;
        this.dataAtualizacao = dataAtualizacao;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getAnimal() {
        return animal;
    }

    public void setAnimal(String animal) {
        this.animal = animal;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public Double getRaio() {
        return raio;
    }

    public void setRaio(Double raio) {
        this.raio = raio;
    }

    public Date getDataCriacao() {
        return dataCriacao;
    }

    public void setDataCriacao(Date dataCriacao) {
        this.dataCriacao = dataCriacao;
    }

    public Date getDataAtualizacao() {
        return dataAtualizacao;
    }

    public void setDataAtualizacao(Date dataAtualizacao) {
        this.dataAtualizacao = dataAtualizacao;
    }
}

