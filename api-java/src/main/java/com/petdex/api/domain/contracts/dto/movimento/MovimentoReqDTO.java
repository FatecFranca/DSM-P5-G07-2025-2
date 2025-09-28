package com.petdex.api.domain.contracts.dto.movimento;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.Date;

@Schema(name = "Requisição Movimento", description = "Informações contidas nas requisições da API envolvendo a Localização")
public class MovimentoReqDTO {

    @Schema(description = "Data/Hora que foi feito a coleta do movimento", example = "")
    private Date data;

    @Schema(description = "Valor de aceleração no eixo X no momento da coleta", example = "")
    private Double acelerometroX;

    @Schema(description = "Valor de aceleração no eixo Y no momento da coleta", example = "")
    private Double acelerometroY;

    @Schema(description = "Valor de aceleração no eixo Z no momento da coleta", example = "")
    private Double acelerometroZ;

    @Schema(description = "Valor da posição do giroscópio no eixo X no momento da coleta", example = "")
    private Double giroscopioX;

    @Schema(description = "Valor da posição do giroscópio no eixo Y no momento da coleta", example = "")
    private Double giroscopioY;

    @Schema(description = "Valor da posição do giroscópio no eixo Z no momento da coleta", example = "")
    private Double giroscopioZ;

    @Schema(description = "ID do Animal que foi feito a coleta do movimento", example = "")
    private String animal;

    @Schema(description = "ID da coleira que fez a coleta do movimento do animal", example = "")
    private String coleira;

    public MovimentoReqDTO() {
    }

    public MovimentoReqDTO(Date data, Double acelerometroX, Double acelerometroY, Double acelerometroZ, Double giroscopioX, Double giroscopioY, Double giroscopioZ, String animal, String coleira) {
        this.data = data;
        this.acelerometroX = acelerometroX;
        this.acelerometroY = acelerometroY;
        this.acelerometroZ = acelerometroZ;
        this.giroscopioX = giroscopioX;
        this.giroscopioY = giroscopioY;
        this.giroscopioZ = giroscopioZ;
        this.animal = animal;
        this.coleira = coleira;
    }

    public Date getData() {
        return data;
    }

    public void setData(Date data) {
        this.data = data;
    }

    public Double getAcelerometroX() {
        return acelerometroX;
    }

    public void setAcelerometroX(Double acelerometroX) {
        this.acelerometroX = acelerometroX;
    }

    public Double getAcelerometroY() {
        return acelerometroY;
    }

    public void setAcelerometroY(Double acelerometroY) {
        this.acelerometroY = acelerometroY;
    }

    public Double getAcelerometroZ() {
        return acelerometroZ;
    }

    public void setAcelerometroZ(Double acelerometroZ) {
        this.acelerometroZ = acelerometroZ;
    }

    public Double getGiroscopioX() {
        return giroscopioX;
    }

    public void setGiroscopioX(Double giroscopioX) {
        this.giroscopioX = giroscopioX;
    }

    public Double getGiroscopioY() {
        return giroscopioY;
    }

    public void setGiroscopioY(Double giroscopioY) {
        this.giroscopioY = giroscopioY;
    }

    public Double getGiroscopioZ() {
        return giroscopioZ;
    }

    public void setGiroscopioZ(Double giroscopioZ) {
        this.giroscopioZ = giroscopioZ;
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
