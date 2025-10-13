package com.petdex.api.domain.contracts.dto.areasegura;

import java.util.Date;

/**
 * DTO para respostas de área segura
 */
public class AreaSeguraResDTO {

    private String id;
    private String animal;
    private Double latitude;
    private Double longitude;
    private Double raio; // Raio em metros
    private Date dataCriacao;
    private Date dataAtualizacao;

    public AreaSeguraResDTO() {
    }

    public AreaSeguraResDTO(String id, String animal, Double latitude, Double longitude, Double raio, Date dataCriacao, Date dataAtualizacao) {
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

