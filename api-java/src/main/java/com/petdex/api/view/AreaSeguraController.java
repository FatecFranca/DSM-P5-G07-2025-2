package com.petdex.api.view;

import com.petdex.api.application.services.areasegura.IAreaSeguraService;
import com.petdex.api.domain.contracts.dto.areasegura.AreaSeguraReqDTO;
import com.petdex.api.domain.contracts.dto.areasegura.AreaSeguraResDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

/**
 * Controller REST para gerenciamento de áreas seguras dos animais
 */
@RestController
@RequestMapping("/areas-seguras")
@Tag(name = "Área Segura", description = "Operações de gestão de áreas seguras dos animais")
public class AreaSeguraController {

    @Autowired
    private IAreaSeguraService areaSeguraService;

    @Operation(
            summary = "Criar ou atualizar área segura de um animal",
            description = "Cria uma nova área segura ou atualiza a existente para um animal. " +
                         "A área segura é definida por um ponto central (latitude/longitude) e um raio em metros."
    )
    @PostMapping
    public ResponseEntity<AreaSeguraResDTO> createOrUpdate(@Valid @RequestBody AreaSeguraReqDTO areaSeguraReq) {
        AreaSeguraResDTO areaSegura = areaSeguraService.createOrUpdate(areaSeguraReq);
        return new ResponseEntity<>(areaSegura, HttpStatus.CREATED);
    }

    @Operation(
            summary = "Buscar área segura pelo ID",
            parameters = {
                    @Parameter(name = "id", description = "ID da área segura", required = true)
            }
    )
    @GetMapping("/{id}")
    public ResponseEntity<AreaSeguraResDTO> findById(@PathVariable String id) {
        AreaSeguraResDTO areaSegura = areaSeguraService.findById(id);
        if (areaSegura == null) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        return new ResponseEntity<>(areaSegura, HttpStatus.OK);
    }

    @Operation(
            summary = "Buscar área segura de um animal",
            parameters = {
                    @Parameter(name = "animalId", description = "ID do animal", required = true)
            }
    )
    @GetMapping("/animal/{animalId}")
    public ResponseEntity<AreaSeguraResDTO> findByAnimalId(@PathVariable String animalId) {
        Optional<AreaSeguraResDTO> areaSegura = areaSeguraService.findByAnimalId(animalId);
        return areaSegura
                .map(area -> new ResponseEntity<>(area, HttpStatus.OK))
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @Operation(
            summary = "Deletar área segura de um animal",
            parameters = {
                    @Parameter(name = "animalId", description = "ID do animal", required = true)
            }
    )
    @DeleteMapping("/animal/{animalId}")
    public ResponseEntity<Void> deleteByAnimalId(@PathVariable String animalId) {
        areaSeguraService.deleteByAnimalId(animalId);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}

