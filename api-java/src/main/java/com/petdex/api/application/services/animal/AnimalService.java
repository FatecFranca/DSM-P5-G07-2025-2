package com.petdex.api.application.services.animal;

import com.petdex.api.domain.collections.Animal;
import com.petdex.api.domain.collections.Especie;
import com.petdex.api.domain.collections.Raca;
import com.petdex.api.domain.contracts.dto.PageDTO;
import com.petdex.api.domain.contracts.dto.animal.AnimalReqDTO;
import com.petdex.api.domain.contracts.dto.animal.AnimalResDTO;
import com.petdex.api.infrastructure.mongodb.AnimalRepository;
import com.petdex.api.infrastructure.mongodb.EspecieRepository;
import com.petdex.api.infrastructure.mongodb.RacaRepository;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AnimalService implements IAnimalService{

    @Autowired
    ModelMapper mapper;

    @Autowired
    AnimalRepository animalRepository;

    @Autowired
    EspecieRepository especieRepository;

    @Autowired
    RacaRepository racaRepository;

    @Override
    public AnimalResDTO findById(String id) {
        Animal animal = animalRepository.findById(id).orElseThrow(() -> new RuntimeException("Não foi possível encontrar um animal com o ID " + id));

        Raca raca = racaRepository.findById(animal.getRaca()).orElseThrow(() -> new RuntimeException("Não foi possível encontrar a raça do animal: " + animal.getRaca()));

        Especie especie = especieRepository.findById(raca.getEspecie()).orElseThrow(()-> new RuntimeException("Não foi possível encontrar a especie do animal: " + raca.getEspecie()));

        AnimalResDTO animalResDTO = mapper.map(animal, AnimalResDTO.class);

        animalResDTO.setEspecieNome(especie.getNome());
        animalResDTO.setRacaNome(raca.getNome());


        return animalResDTO;
    }

    @Override
    public Page<AnimalResDTO> findAll(PageDTO pageDTO) {
        pageDTO.sortByName();
        Page<Animal> animaisPage = animalRepository.findAll(pageDTO.mapPage());

        List<AnimalResDTO> dtoList = animaisPage.getContent().stream().map(animal -> {
            AnimalResDTO dto = mapper.map(animal, AnimalResDTO.class);


            Raca raca = racaRepository.findById(animal.getRaca())
                    .orElseThrow(() -> new RuntimeException("Não foi possível encontrar a raça do animal: " + animal.getRaca()));


            Especie especie = especieRepository.findById(raca.getEspecie())
                    .orElseThrow(() -> new RuntimeException("Não foi possível encontrar a espécie do animal: " + raca.getEspecie()));

            dto.setRacaNome(raca.getNome());
            dto.setEspecieNome(especie.getNome());

            return dto;
        }).toList();

        return new PageImpl<>(dtoList, pageDTO.mapPage(), animaisPage.getTotalElements());
    }
    @Override
    public AnimalResDTO create(AnimalReqDTO animalReqDTO) {
        return mapper.map(animalRepository.save(mapper.map(animalReqDTO, Animal.class)), AnimalResDTO.class);
    }

    @Override
    public AnimalResDTO update(String id, AnimalReqDTO animalReqDTO) {

        Animal animalUpdate = animalRepository.findById(id).orElseThrow(() -> new RuntimeException("Não foi possível achar o animal com o ID: " + id));

        if(animalReqDTO.getNome() != null) animalUpdate.setNome(animalReqDTO.getNome());
        if(animalReqDTO.getCastrado() != null) animalUpdate.setCastrado(animalReqDTO.getCastrado());
        if(animalReqDTO.getPeso() != null) animalUpdate.setPeso(animalReqDTO.getPeso());
        if(animalReqDTO.getRaca() != null) animalUpdate.setRaca(animalReqDTO.getRaca());
        if(animalReqDTO.getDataNascimento() != null) animalUpdate.setDataNascimento(animalReqDTO.getDataNascimento());
        if(animalReqDTO.getSexo() != null) animalUpdate.setSexo(animalReqDTO.getSexo());

        return mapper.map(animalRepository.save(animalUpdate), AnimalResDTO.class);
    }

    @Override
    public void delete(String id) {
        animalRepository.deleteById(id);
    }
}
