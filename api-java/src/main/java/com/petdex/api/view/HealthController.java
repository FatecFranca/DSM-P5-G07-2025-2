package com.petdex.api.view;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Tag(name = "Health", description = "Endpoints de verificação de saúde e informações da API")
public class HealthController {

    @Operation(
            summary = "Verificar saúde da API",
            description = "Endpoint para verificar se a API está online e funcionando corretamente"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "API está online e funcionando",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = String.class)))
    })
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return new ResponseEntity<>("API Java online!", HttpStatus.OK);
    }

    @Operation(
            summary = "Página inicial da API",
            description = "Retorna uma mensagem de boas-vindas e link para a documentação Swagger"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Mensagem de boas-vindas retornada com sucesso",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = String.class)))
    })
    @GetMapping(value = {"", "/"})
    public ResponseEntity<String> api() {
        return new ResponseEntity<>("Seja bem-vindo a API do PetDex! Para acessar a documentação acesse a rota <a href=\"/swagger\">/swagger</a>", HttpStatus.OK);
    }
}
