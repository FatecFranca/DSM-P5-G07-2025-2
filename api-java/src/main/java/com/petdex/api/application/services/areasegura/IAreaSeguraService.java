package com.petdex.api.application.services.areasegura;

import com.petdex.api.domain.contracts.dto.areasegura.AreaSeguraReqDTO;
import com.petdex.api.domain.contracts.dto.areasegura.AreaSeguraResDTO;

import java.util.Optional;

/**
 * Interface de serviço para operações relacionadas a áreas seguras
 */
public interface IAreaSeguraService {
    
    /**
     * Cria ou atualiza uma área segura para um animal
     * @param areaSeguraReq Dados da área segura
     * @return DTO com os dados da área segura criada/atualizada
     */
    AreaSeguraResDTO createOrUpdate(AreaSeguraReqDTO areaSeguraReq);
    
    /**
     * Busca a área segura de um animal pelo ID do animal
     * @param animalId ID do animal
     * @return Optional contendo o DTO da área segura se existir
     */
    Optional<AreaSeguraResDTO> findByAnimalId(String animalId);
    
    /**
     * Busca uma área segura pelo ID
     * @param id ID da área segura
     * @return DTO da área segura
     */
    AreaSeguraResDTO findById(String id);
    
    /**
     * Deleta a área segura de um animal
     * @param animalId ID do animal
     */
    void deleteByAnimalId(String animalId);
    
    /**
     * Calcula a distância em metros entre dois pontos geográficos usando a fórmula de Haversine
     * @param lat1 Latitude do ponto 1
     * @param lon1 Longitude do ponto 1
     * @param lat2 Latitude do ponto 2
     * @param lon2 Longitude do ponto 2
     * @return Distância em metros
     */
    double calcularDistanciaEmMetros(double lat1, double lon1, double lat2, double lon2);
    
    /**
     * Verifica se uma localização está fora da área segura de um animal
     * @param animalId ID do animal
     * @param latitude Latitude da localização atual
     * @param longitude Longitude da localização atual
     * @return true se estiver fora da área segura, false se estiver dentro ou se não houver área segura configurada
     */
    boolean isForaDaAreaSegura(String animalId, double latitude, double longitude);
}

