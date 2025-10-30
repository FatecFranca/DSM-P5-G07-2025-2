package com.petdex.api.domain.contracts.dto.movimento;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.Date;

@Schema(
        name = "Requisição Movimento",
        description = "Dados necessários para registrar um novo movimento no sistema",
        example = "{\"data\": \"2024-01-20T14:30:00.000+00:00\", \"acelerometroX\": 0.5, \"acelerometroY\": 0.3, \"acelerometroZ\": 9.8, \"giroscopioX\": 0.1, \"giroscopioY\": 0.2, \"giroscopioZ\": 0.05, \"animal\": \"507f1f77bcf86cd799439011\", \"coleira\": \"507f1f77bcf86cd799439011\"}"
)
public class MovimentoReqDTO {

    @Schema(description = "Data e hora em que foi realizada a coleta do movimento", example = "2024-01-20T14:30:00.000+00:00", requiredMode = Schema.RequiredMode.REQUIRED)
    private Date data;

    @Schema(description = "Valor de aceleração no eixo X no momento da coleta em m/s²", example = "0.5", requiredMode = Schema.RequiredMode.REQUIRED)
    private Double acelerometroX;

    @Schema(description = "Valor de aceleração no eixo Y no momento da coleta em m/s²", example = "0.3", requiredMode = Schema.RequiredMode.REQUIRED)
    private Double acelerometroY;

    @Schema(description = "Valor de aceleração no eixo Z no momento da coleta em m/s²", example = "9.8", requiredMode = Schema.RequiredMode.REQUIRED)
    private Double acelerometroZ;

    @Schema(description = "Valor da rotação do giroscópio no eixo X no momento da coleta em graus/s", example = "0.1", requiredMode = Schema.RequiredMode.REQUIRED)
    private Double giroscopioX;

    @Schema(description = "Valor da rotação do giroscópio no eixo Y no momento da coleta em graus/s", example = "0.2", requiredMode = Schema.RequiredMode.REQUIRED)
    private Double giroscopioY;

    @Schema(description = "Valor da rotação do giroscópio no eixo Z no momento da coleta em graus/s", example = "0.05", requiredMode = Schema.RequiredMode.REQUIRED)
    private Double giroscopioZ;

    @Schema(description = "ID do animal que teve o movimento coletado", example = "507f1f77bcf86cd799439011", requiredMode = Schema.RequiredMode.REQUIRED)
    private String animal;

    @Schema(description = "ID da coleira que realizou a coleta do movimento do animal", example = "507f1f77bcf86cd799439011", requiredMode = Schema.RequiredMode.REQUIRED)
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
