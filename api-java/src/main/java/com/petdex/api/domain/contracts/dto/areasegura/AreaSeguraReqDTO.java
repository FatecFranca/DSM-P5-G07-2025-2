package com.petdex.api.domain.contracts.dto.areasegura;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

/**
 * DTO para requisições de criação/atualização de área segura
 */
@Schema(
        name = "Requisição Área Segura",
        description = "Dados necessários para criar ou atualizar uma área segura de um animal",
        example = "{\"animal\": \"507f1f77bcf86cd799439011\", \"latitude\": -23.550520, \"longitude\": -46.633308, \"raio\": 500.0}"
)
public class AreaSeguraReqDTO {

    @Schema(description = "ID do animal que terá a área segura configurada", example = "507f1f77bcf86cd799439011", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank(message = "ID do animal não pode ser nulo ou vazio")
    private String animal;

    @Schema(description = "Latitude do ponto central da área segura", example = "-23.550520", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull(message = "Latitude não pode ser nula")
    private Double latitude;

    @Schema(description = "Longitude do ponto central da área segura", example = "-46.633308", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull(message = "Longitude não pode ser nula")
    private Double longitude;

    @Schema(description = "Raio da área segura em metros. Deve ser um valor positivo maior que zero", example = "500.0", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull(message = "Raio não pode ser nulo")
    @Positive(message = "Raio deve ser um número positivo maior que zero")
    private Double raio;

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

