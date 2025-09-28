package com.petdex.api.application.services;

import com.petdex.api.domain.collections.Animal;
import com.petdex.api.domain.collections.Coleira;
import com.petdex.api.infrastructure.mongodb.AnimalRepository;
import com.petdex.api.infrastructure.mongodb.ColeiraRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class ValidationService {

    @Autowired
    AnimalRepository animalRepository;

    @Autowired
    ColeiraRepository coleiraRepository;

    public Boolean existAnimal(String animalId) {

        if (animalId == null || animalId.isEmpty()) {
            return false;
        }

        Optional<Animal> animal = animalRepository.findById(animalId);
        return animal.isPresent();
    }

    public Boolean existColeira(String coleiraId) {

        if (coleiraId == null || coleiraId.isEmpty()) {
            return false;
        }

        Optional<Coleira> coleira = coleiraRepository.findById(coleiraId);
        return coleira.isPresent();
    }
}
