package com.petdex.api.view;

import com.petdex.api.application.services.areasegura.IAreaSeguraService;
import com.petdex.api.domain.contracts.dto.areasegura.AreaSeguraReqDTO;
import com.petdex.api.domain.contracts.dto.areasegura.AreaSeguraResDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
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
                         "A área segura é definida por um ponto central (latitude/longitude) e um raio em metros. " +
                         "Se já existir uma área segura para o animal, ela será atualizada com os novos valores.",
            tags = {"Área Segura"},
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "Dados da área segura a ser criada ou atualizada",
                    required = true,
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = AreaSeguraReqDTO.class)
                    )
            )
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "201",
                    description = "Área segura criada ou atualizada com sucesso",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = AreaSeguraResDTO.class)
                    )
            )
    })
    @PostMapping
    public ResponseEntity<AreaSeguraResDTO> createOrUpdate(@Valid @RequestBody AreaSeguraReqDTO areaSeguraReq) {
        AreaSeguraResDTO areaSegura = areaSeguraService.createOrUpdate(areaSeguraReq);
        return new ResponseEntity<>(areaSegura, HttpStatus.CREATED);
    }

    @Operation(
            summary = "Consultar área segura pelo ID",
            description = "Retorna os detalhes de uma área segura específica através do seu identificador único",
            tags = {"Área Segura"},
            parameters = {
                    @Parameter(
                            name = "id",
                            description = "ID da área segura que se deseja consultar",
                            required = true,
                            example = "507f1f77bcf86cd799439011"
                    )
            }
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Área segura encontrada com sucesso",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = AreaSeguraResDTO.class)
                    )
            )
    })
    @GetMapping("/{id}")
    public ResponseEntity<AreaSeguraResDTO> findById(@PathVariable String id) {
        AreaSeguraResDTO areaSegura = areaSeguraService.findById(id);
        if (areaSegura == null) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        return new ResponseEntity<>(areaSegura, HttpStatus.OK);
    }

    @Operation(
            summary = "Consultar área segura de um animal",
            description = "Retorna a área segura configurada para um animal específico através do ID do animal",
            tags = {"Área Segura"},
            parameters = {
                    @Parameter(
                            name = "animalId",
                            description = "ID do animal que se deseja consultar a área segura",
                            required = true,
                            example = "507f1f77bcf86cd799439011"
                    )
            }
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Área segura encontrada com sucesso",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = AreaSeguraResDTO.class)
                    )
            )
    })
    @GetMapping("/animal/{animalId}")
    public ResponseEntity<AreaSeguraResDTO> findByAnimalId(@PathVariable String animalId) {
        Optional<AreaSeguraResDTO> areaSegura = areaSeguraService.findByAnimalId(animalId);
        return areaSegura
                .map(area -> new ResponseEntity<>(area, HttpStatus.OK))
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @Operation(
            summary = "Deletar área segura de um animal",
            description = "Remove a área segura configurada para um animal específico através do ID do animal",
            tags = {"Área Segura"},
            parameters = {
                    @Parameter(
                            name = "animalId",
                            description = "ID do animal que terá a área segura removida",
                            required = true,
                            example = "507f1f77bcf86cd799439011"
                    )
            }
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "204",
                    description = "Área segura deletada com sucesso"
            )
    })
    @DeleteMapping("/animal/{animalId}")
    public ResponseEntity<Void> deleteByAnimalId(@PathVariable String animalId) {
        areaSeguraService.deleteByAnimalId(animalId);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}

