package com.petdex.api.domain.contracts.dto.areasegura;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

/**
 * DTO para requisições de criação/atualização de área segura
 */
public class AreaSeguraReqDTO {

    @NotBlank(message = "ID do animal não pode ser nulo ou vazio")
    private String animal;

    @NotNull(message = "Latitude não pode ser nula")
    private Double latitude;

    @NotNull(message = "Longitude não pode ser nula")
    private Double longitude;

    @NotNull(message = "Raio não pode ser nulo")
    @Positive(message = "Raio deve ser um número positivo maior que zero")
    private Double raio; // Raio em metros

    public AreaSeguraReqDTO() {
    }

    public AreaSeguraReqDTO(String animal, Double latitude, Double longitude, Double raio) {
        this.animal = animal;
        this.latitude = latitude;
        this.longitude = longitude;
        this.raio = raio;
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
}

