package com.petdex.api.domain.contracts.dto.websocket;

import java.util.Date;

/**
 * DTO para mensagens WebSocket de atualização de batimento cardíaco
 */
public class BatimentoWebSocketDTO {
    
    private String messageType = "heartrate_update";
    private String animalId;
    private String coleiraId;
    private Integer frequenciaMedia;
    private Date timestamp;

    public BatimentoWebSocketDTO() {
    }

    public BatimentoWebSocketDTO(String animalId, String coleiraId, Integer frequenciaMedia, Date timestamp) {
        this.animalId = animalId;
        this.coleiraId = coleiraId;
        this.frequenciaMedia = frequenciaMedia;
        this.timestamp = timestamp;
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

    public Integer getFrequenciaMedia() {
        return frequenciaMedia;
    }

    public void setFrequenciaMedia(Integer frequenciaMedia) {
        this.frequenciaMedia = frequenciaMedia;
    }

    public Date getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(Date timestamp) {
        this.timestamp = timestamp;
    }
}

