package com.petdex.api.application.services.areasegura;

import com.petdex.api.domain.collections.AreaSegura;
import com.petdex.api.domain.contracts.dto.areasegura.AreaSeguraReqDTO;
import com.petdex.api.domain.contracts.dto.areasegura.AreaSeguraResDTO;
import com.petdex.api.infrastructure.mongodb.AreaSeguraRepository;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.Optional;

/**
 * Serviço para gerenciamento de áreas seguras e cálculo de distâncias geográficas
 */
@Service
public class AreaSeguraService implements IAreaSeguraService {

    @Autowired
    private AreaSeguraRepository areaSeguraRepository;

    @Autowired
    private ModelMapper mapper;

    // Raio da Terra em metros (usado na fórmula de Haversine)
    private static final double RAIO_TERRA_METROS = 6371000.0;

    @Override
    public AreaSeguraResDTO createOrUpdate(AreaSeguraReqDTO areaSeguraReq) {
        // Verifica se já existe uma área segura para este animal
        Optional<AreaSegura> areaExistente = areaSeguraRepository.findByAnimal(areaSeguraReq.getAnimal());
        
        AreaSegura areaSegura;
        if (areaExistente.isPresent()) {
            // Atualiza a área existente
            areaSegura = areaExistente.get();
            areaSegura.setLatitude(areaSeguraReq.getLatitude());
            areaSegura.setLongitude(areaSeguraReq.getLongitude());
            areaSegura.setRaio(areaSeguraReq.getRaio());
            areaSegura.setDataAtualizacao(new Date());
        } else {
            // Cria uma nova área segura
            areaSegura = mapper.map(areaSeguraReq, AreaSegura.class);
        }
        
        AreaSegura areaSalva = areaSeguraRepository.save(areaSegura);
        return mapper.map(areaSalva, AreaSeguraResDTO.class);
    }

    @Override
    public Optional<AreaSeguraResDTO> findByAnimalId(String animalId) {
        Optional<AreaSegura> areaSegura = areaSeguraRepository.findByAnimal(animalId);
        return areaSegura.map(area -> mapper.map(area, AreaSeguraResDTO.class));
    }

    @Override
    public AreaSeguraResDTO findById(String id) {
        Optional<AreaSegura> areaSegura = areaSeguraRepository.findById(id);
        return areaSegura.map(area -> mapper.map(area, AreaSeguraResDTO.class)).orElse(null);
    }

    @Override
    public void deleteByAnimalId(String animalId) {
        areaSeguraRepository.deleteByAnimal(animalId);
    }

    /**
     * Calcula a distância entre dois pontos geográficos usando a fórmula de Haversine.
     * A fórmula de Haversine determina a distância do grande círculo entre dois pontos
     * em uma esfera a partir de suas latitudes e longitudes.
     * 
     * @param lat1 Latitude do ponto 1 em graus
     * @param lon1 Longitude do ponto 1 em graus
     * @param lat2 Latitude do ponto 2 em graus
     * @param lon2 Longitude do ponto 2 em graus
     * @return Distância em metros
     */
    @Override
    public double calcularDistanciaEmMetros(double lat1, double lon1, double lat2, double lon2) {
        // Converte graus para radianos
        double lat1Rad = Math.toRadians(lat1);
        double lon1Rad = Math.toRadians(lon1);
        double lat2Rad = Math.toRadians(lat2);
        double lon2Rad = Math.toRadians(lon2);

        // Diferenças
        double deltaLat = lat2Rad - lat1Rad;
        double deltaLon = lon2Rad - lon1Rad;

        // Fórmula de Haversine
        double a = Math.sin(deltaLat / 2) * Math.sin(deltaLat / 2) +
                   Math.cos(lat1Rad) * Math.cos(lat2Rad) *
                   Math.sin(deltaLon / 2) * Math.sin(deltaLon / 2);
        
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        // Distância em metros
        return RAIO_TERRA_METROS * c;
    }

    @Override
    public boolean isForaDaAreaSegura(String animalId, double latitude, double longitude) {
        Optional<AreaSegura> areaSeguraOpt = areaSeguraRepository.findByAnimal(animalId);
        
        // Se não houver área segura configurada, considera que está dentro (não gera alerta)
        if (areaSeguraOpt.isEmpty()) {
            return false;
        }
        
        AreaSegura areaSegura = areaSeguraOpt.get();
        
        // Calcula a distância entre a localização atual e o centro da área segura
        double distancia = calcularDistanciaEmMetros(
            areaSegura.getLatitude(),
            areaSegura.getLongitude(),
            latitude,
            longitude
        );
        
        // Retorna true se a distância for maior que o raio (está fora da área segura)
        return distancia > areaSegura.getRaio();
    }
}

