package com.petdex.api.domain.contracts.dto.localizacao;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.Date;

@Schema(
        name = "Resposta Localização",
        description = "Informações de uma localização retornadas pela API",
        example = "{\"id\": \"507f1f77bcf86cd799439011\", \"data\": \"2024-01-20T14:30:00.000+00:00\", \"latitude\": -23.550520, \"longitude\": -46.633308, \"animal\": \"507f1f77bcf86cd799439011\", \"coleira\": \"507f1f77bcf86cd799439011\", \"isOutsideSafeZone\": false, \"distanciaDoPerimetro\": -50.0}"
)
public class LocalizacaoResDTO {

    @Schema(description = "Código único identificador da localização", example = "507f1f77bcf86cd799439011")
    private String id;

    @Schema(description = "Data e hora em que foi realizada a coleta da localização", example = "2024-01-20T14:30:00.000+00:00")
    private Date data;

    @Schema(description = "Latitude da posição geográfica onde o animal se encontra no momento da coleta", example = "-23.550520")
    private Double latitude;

    @Schema(description = "Longitude da posição geográfica onde o animal se encontra no momento da coleta", example = "-46.633308")
    private Double longitude;

    @Schema(description = "ID do animal que teve a localização coletada", example = "507f1f77bcf86cd799439011")
    private String animal;

    @Schema(description = "ID da coleira que realizou a coleta da localização do animal", example = "507f1f77bcf86cd799439011")
    private String coleira;

    @Schema(description = "Indica se o animal está fora da área segura configurada", example = "false")
    private Boolean isOutsideSafeZone;

    @Schema(description = "Distância em metros do perímetro da área segura. Valor positivo indica que o animal está fora da área segura, valor negativo indica que está dentro", example = "-50.0")
    private Double distanciaDoPerimetro;

    public LocalizacaoResDTO() {
    }

    public LocalizacaoResDTO(String id, Date data, Double latitude, Double longitude, String animal, String coleira) {
        this.id = id;
        this.data = data;
        this.latitude = latitude;
        this.longitude = longitude;
        this.animal = animal;
        this.coleira = coleira;
    }

    public LocalizacaoResDTO(String id, Date data, Double latitude, Double longitude, String animal, String coleira,
                             Boolean isOutsideSafeZone, Double distanciaDoPerimetro) {
        this.id = id;
        this.data = data;
        this.latitude = latitude;
        this.longitude = longitude;
        this.animal = animal;
        this.coleira = coleira;
        this.isOutsideSafeZone = isOutsideSafeZone;
        this.distanciaDoPerimetro = distanciaDoPerimetro;
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

    public Boolean getIsOutsideSafeZone() {
        return isOutsideSafeZone;
    }

    public void setIsOutsideSafeZone(Boolean isOutsideSafeZone) {
        this.isOutsideSafeZone = isOutsideSafeZone;
    }

    public Double getDistanciaDoPerimetro() {
        return distanciaDoPerimetro;
    }

    public void setDistanciaDoPerimetro(Double distanciaDoPerimetro) {
        this.distanciaDoPerimetro = distanciaDoPerimetro;
    }
}
