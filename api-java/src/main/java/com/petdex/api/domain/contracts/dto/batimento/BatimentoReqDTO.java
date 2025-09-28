package com.petdex.api.domain.contracts.dto.batimento;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.Date;

@Schema(name = "Requisição Batimento", description = "Informações contidas nas requisições da API envolvendo os batimentos cardíacos")
public class BatimentoReqDTO {

    @Schema(description = "Data/Hora que foi coletado o batimento cardíaco", example = "", requiredMode = Schema.RequiredMode.REQUIRED)
    private Date data;

    @Schema(description = "Frequência média que foi coletada do animal", example = "60", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer frequenciaMedia;

    @Schema(description = "ID do Animal que foi coletado o batimento cardíaco", example = "60", requiredMode = Schema.RequiredMode.REQUIRED)
    private String animal;

    @Schema(description = "ID da coleira que fez a coleta do batimento cardíaco", example = "60", requiredMode = Schema.RequiredMode.REQUIRED)
    private String coleira;

    public BatimentoReqDTO() {
    }

    public BatimentoReqDTO(Date data, Integer frequenciaMedia, String animal, String coleira) {
        this.data = data;
        this.frequenciaMedia = frequenciaMedia;
        this.animal = animal;
        this.coleira = coleira;
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
