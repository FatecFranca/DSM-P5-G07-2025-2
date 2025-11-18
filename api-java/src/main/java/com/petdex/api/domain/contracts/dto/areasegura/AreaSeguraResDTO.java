package com.petdex.api.domain.contracts.dto.areasegura;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.Date;

/**
 * DTO para respostas de área segura
 */
@Schema(
        name = "Resposta Área Segura",
        description = "Informações detalhadas de uma área segura retornadas pela API",
        example = "{\"id\": \"507f1f77bcf86cd799439011\", \"animal\": \"507f1f77bcf86cd799439011\", \"latitude\": -23.550520, \"longitude\": -46.633308, \"raio\": 500.0, \"dataCriacao\": \"2024-01-15T10:30:00.000+00:00\", \"dataAtualizacao\": \"2024-01-20T14:45:00.000+00:00\"}"
)
public class AreaSeguraResDTO {

    @Schema(description = "Código único identificador da área segura", example = "507f1f77bcf86cd799439011")
    private String id;

    @Schema(description = "ID do animal associado à área segura", example = "507f1f77bcf86cd799439011")
    private String animal;

    @Schema(description = "Latitude do ponto central da área segura", example = "-23.550520")
    private Double latitude;

    @Schema(description = "Longitude do ponto central da área segura", example = "-46.633308")
    private Double longitude;

    @Schema(description = "Raio da área segura em metros", example = "500.0")
    private Double raio;

    @Schema(description = "Data e hora de criação da área segura", example = "2024-01-15T10:30:00.000+00:00")
    private Date dataCriacao;

    @Schema(description = "Data e hora da última atualização da área segura", example = "2024-01-20T14:45:00.000+00:00")
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

