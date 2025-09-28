package com.petdex.api.domain.contracts.dto.localizacao;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.Date;

@Schema(name = "Resposta Localização", description = "Informações contidas nas respostas da API envolvendo a Localização")
public class LocalizacaoResDTO {

    @Schema(description = "Código único identificador da localização", example = "")
    private String id;

    @Schema(description = "Data/Hora que foi realizado a coleta da localização", example = "")
    private Date data;

    @Schema(description = "Latitude que se encontra o animal no momento da coleta", example = "")
    private Double latitude;

    @Schema(description = "Longitude que se encontra o animal no momento da coleta", example = "")
    private Double longitude;

    @Schema(description = "ID do Animal que foi feito a coleta da localização", example = "")
    private String animal;

    @Schema(description = "ID da coleira que fez a coleta da localização do animal", example = "")
    private String coleira;

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
}
