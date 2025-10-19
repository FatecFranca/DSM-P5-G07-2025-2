package com.petdex.api.infrastructure.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Configuração do OpenAPI/Swagger para documentação da API
 * Inclui configuração de autenticação JWT Bearer Token
 */
@Configuration
public class OpenApiConfig {

    private static final String SECURITY_SCHEME_NAME = "Bearer Authentication";

    /**
     * Configura o OpenAPI com informações da API e esquema de segurança JWT
     */
    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("PetDex API")
                        .version("1.0.0")
                        .description("API RESTful para gerenciamento de coleira inteligente para pets. " +
                                "Esta API permite o cadastro de usuários, animais e o monitoramento em tempo real " +
                                "de localização, batimentos cardíacos e movimentação dos pets.")
                        .contact(new Contact()
                                .name("Equipe PetDex")
                                .email("contato@petdex.com")
                                .url("https://github.com/petdex"))
                        .license(new License()
                                .name("MIT License")
                                .url("https://opensource.org/licenses/MIT")))
                .addSecurityItem(new SecurityRequirement()
                        .addList(SECURITY_SCHEME_NAME))
                .components(new Components()
                        .addSecuritySchemes(SECURITY_SCHEME_NAME, new SecurityScheme()
                                .name(SECURITY_SCHEME_NAME)
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .description("Insira o token JWT obtido no endpoint de login. " +
                                        "Formato: Bearer {token}")));
    }
}

