package com.petdex.api.domain.contracts.dto.localizacao;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.Date;

@Schema(
        name = "Requisição Localização",
        description = "Dados necessários para registrar uma nova localização no sistema",
        example = "{\"data\": \"2024-01-20T14:30:00.000+00:00\", \"latitude\": -23.550520, \"longitude\": -46.633308, \"animal\": \"507f1f77bcf86cd799439011\", \"coleira\": \"507f1f77bcf86cd799439011\"}"
)
public class LocalizacaoReqDTO {

    @Schema(description = "Data e hora em que foi realizada a coleta da localização", example = "2024-01-20T14:30:00.000+00:00", requiredMode = Schema.RequiredMode.REQUIRED)
    private Date data;

    @Schema(description = "Latitude da posição geográfica onde o animal se encontra no momento da coleta", example = "-23.550520", requiredMode = Schema.RequiredMode.REQUIRED)
    private Double latitude;

    @Schema(description = "Longitude da posição geográfica onde o animal se encontra no momento da coleta", example = "-46.633308", requiredMode = Schema.RequiredMode.REQUIRED)
    private Double longitude;

    @Schema(description = "ID do animal que teve a localização coletada", example = "507f1f77bcf86cd799439011", requiredMode = Schema.RequiredMode.REQUIRED)
    private String animal;

    @Schema(description = "ID da coleira que realizou a coleta da localização do animal", example = "507f1f77bcf86cd799439011", requiredMode = Schema.RequiredMode.REQUIRED)
    private String coleira;

    public LocalizacaoReqDTO() {
    }

    public LocalizacaoReqDTO(Date data, Double latitude, Double longitude, String animal, String coleira) {
        this.data = data;
        this.latitude = latitude;
        this.longitude = longitude;
        this.animal = animal;
        this.coleira = coleira;
    }

    public Date getData() {
        return data;
    }

    public void setData(Date data) {
        this.data = data;
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
