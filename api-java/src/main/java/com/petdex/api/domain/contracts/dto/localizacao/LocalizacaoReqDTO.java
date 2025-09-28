package com.petdex.api.domain.contracts.dto.localizacao;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.Date;

@Schema(name = "Requisição Localização", description = "Informações contidas nas requisições da API envolvendo a Localização")
public class LocalizacaoReqDTO {

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
