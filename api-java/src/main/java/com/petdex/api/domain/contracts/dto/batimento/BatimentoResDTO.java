package com.petdex.api.domain.contracts.dto.batimento;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.Date;

@Schema(
        name = "Resposta Batimento",
        description = "Informações detalhadas de um batimento cardíaco retornadas pela API",
        example = "{\"id\": \"507f1f77bcf86cd799439011\", \"data\": \"2024-01-20T14:30:00.000+00:00\", \"frequenciaMedia\": 75, \"animal\": \"507f1f77bcf86cd799439011\", \"coleira\": \"507f1f77bcf86cd799439011\"}"
)
public class BatimentoResDTO {

    @Schema(description = "Código único identificador do batimento cardíaco", example = "507f1f77bcf86cd799439011")
    private String id;

    @Schema(description = "Data e hora em que foi coletado o batimento cardíaco", example = "2024-01-20T14:30:00.000+00:00")
    private Date data;

    @Schema(description = "Frequência cardíaca média coletada do animal em batimentos por minuto (BPM)", example = "75")
    private Integer frequenciaMedia;

    @Schema(description = "ID do animal que teve o batimento cardíaco coletado", example = "507f1f77bcf86cd799439011")
    private String animal;

    @Schema(description = "ID da coleira que realizou a coleta do batimento cardíaco", example = "507f1f77bcf86cd799439011")
    private String coleira;

    public BatimentoResDTO() {
    }

    public BatimentoResDTO(String id, Date data, Integer frequenciaMedia, String animal, String coleira) {
        this.id = id;
        this.data = data;
        this.frequenciaMedia = frequenciaMedia;
        this.animal = animal;
        this.coleira = coleira;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getColeira() {
        return coleira;
    }

    public void setColeira(String coleira) {
        this.coleira = coleira;
    }

    public String getAnimal() {
        return animal;
    }

    public void setAnimal(String animal) {
        this.animal = animal;
    }

    public Integer getFrequenciaMedia() {
        return frequenciaMedia;
    }

    public void setFrequenciaMedia(Integer frequenciaMedia) {
        this.frequenciaMedia = frequenciaMedia;
    }

    public Date getData() {
        return data;
    }

    public void setData(Date data) {
        this.data = data;
    }
}
