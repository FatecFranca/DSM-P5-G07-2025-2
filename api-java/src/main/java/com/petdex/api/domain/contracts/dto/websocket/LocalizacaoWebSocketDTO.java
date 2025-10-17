package com.petdex.api.domain.contracts.dto.websocket;

import java.util.Date;

/**
 * DTO para mensagens WebSocket de atualização de localização
 */
public class LocalizacaoWebSocketDTO {
    
    private String messageType = "location_update";
    private String animalId;
    private String coleiraId;
    private Double latitude;
    private Double longitude;
    private Date timestamp;
    private Boolean isOutsideSafeZone;
    private Double distanciaDoPerimetro; // Distância em metros do perímetro da área segura

    public LocalizacaoWebSocketDTO() {
    }

    public LocalizacaoWebSocketDTO(String animalId, String coleiraId, Double latitude, Double longitude, 
                                   Date timestamp, Boolean isOutsideSafeZone, Double distanciaDoPerimetro) {
        this.animalId = animalId;
        this.coleiraId = coleiraId;
        this.latitude = latitude;
        this.longitude = longitude;
        this.timestamp = timestamp;
        this.isOutsideSafeZone = isOutsideSafeZone;
        this.distanciaDoPerimetro = distanciaDoPerimetro;
    }

    public String getMessageType() {
        return messageType;
    }

    public void setMessageType(String messageType) {
        this.messageType = messageType;
    }

    public String getAnimalId() {
        return animalId;
    }

    public void setAnimalId(String animalId) {
        this.animalId = animalId;
    }

    public String getColeiraId() {
        return coleiraId;
    }

    public void setColeiraId(String coleiraId) {
        this.coleiraId = coleiraId;
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

    public Date getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(Date timestamp) {
        this.timestamp = timestamp;
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

