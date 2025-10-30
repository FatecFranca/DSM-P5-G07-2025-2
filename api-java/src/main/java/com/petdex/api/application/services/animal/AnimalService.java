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
import org.bson.types.ObjectId;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

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
    @Autowired
    private IAnimalService iAnimalService;

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
    public AnimalResDTO create(AnimalReqDTO animalDTO) throws IOException {

        Animal animal = mapper.map(animalDTO, Animal.class);

        return mapper.map(animalRepository.save(animal), AnimalResDTO.class);
    }

    @Override
    public AnimalResDTO update(String id, AnimalReqDTO animalDTO) throws IOException {

        Animal animalUpdate = animalRepository.findById(id).orElseThrow(() -> new RuntimeException("Não foi possível achar o animal com o ID: " + id));

        if(animalDTO.getNome() != null) animalUpdate.setNome(animalDTO.getNome());
        if(animalDTO.getCastrado() != null) animalUpdate.setCastrado(animalDTO.getCastrado());
        if(animalDTO.getPeso() != null) animalUpdate.setPeso(animalDTO.getPeso());
        if(animalDTO.getRaca() != null) animalUpdate.setRaca(animalDTO.getRaca());
        if(animalDTO.getDataNascimento() != null) animalUpdate.setDataNascimento(animalDTO.getDataNascimento());
        if(animalDTO.getSexo() != null) animalUpdate.setSexo(animalDTO.getSexo());


        return mapper.map(animalRepository.save(animalUpdate), AnimalResDTO.class);
    }

    @Override
    public void delete(String id) {
        animalRepository.deleteById(id);
    }

    @Override
    public Optional<AnimalResDTO> findByUsuarioId(String usuarioId) {
        // Converte String para ObjectId
        ObjectId usuarioObjectId = new ObjectId(usuarioId);
        Optional<Animal> animalOpt = animalRepository.findByUsuario(usuarioObjectId);

        return animalOpt.map(animal -> {
            Raca raca = racaRepository.findById(animal.getRaca())
                    .orElseThrow(() -> new RuntimeException("Não foi possível encontrar a raça do animal: " + animal.getRaca()));

            Especie especie = especieRepository.findById(raca.getEspecie())
                    .orElseThrow(() -> new RuntimeException("Não foi possível encontrar a espécie do animal: " + raca.getEspecie()));

            AnimalResDTO animalResDTO = mapper.map(animal, AnimalResDTO.class);
            animalResDTO.setEspecieNome(especie.getNome());
            animalResDTO.setRacaNome(raca.getNome());

            return animalResDTO;
        });
    }

    @Override
    public String saveImage (String id, MultipartFile file) throws IOException {

        Animal animal = animalRepository.findById(id).orElseThrow(() -> new RuntimeException("Não foi possível achar o animal com o ID: " + id));

        // Verifica se existe uma imagem antiga e a exclui
        String oldImageUrl = animal.getUrlImagem();
        if (oldImageUrl != null && !oldImageUrl.isEmpty()) {
            // Extrai o nome do arquivo da URL antiga
            String oldFileName = oldImageUrl.substring(oldImageUrl.lastIndexOf("/") + 1);
            Path oldFilePath = Paths.get("/uploads/animais/").resolve(oldFileName);

            // Exclui o arquivo antigo se ele existir
            if (Files.exists(oldFilePath)) {
                Files.delete(oldFilePath);
            }
        }

        String fileName = UUID.randomUUID() + "_" + file.getOriginalFilename();
        Path uploadPath = Paths.get("/uploads/animais/");
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }
        Path filePath = uploadPath.resolve(fileName);
        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
        String imageUrl = "/uploads/animais/" + fileName;

        animal.setUrlImagem(imageUrl);
        animalRepository.save(animal);

        return imageUrl;
    }

}
