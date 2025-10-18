package com.petdex.api.infrastructure.config;

import com.petdex.api.infrastructure.security.JwtAccessDeniedHandler;
import com.petdex.api.infrastructure.security.JwtAuthenticationEntryPoint;
import com.petdex.api.infrastructure.security.JwtAuthenticationFilter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Configuração de segurança do Spring Security
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Autowired
    private JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;

    @Autowired
    private JwtAccessDeniedHandler jwtAccessDeniedHandler;

    /**
     * Configura a cadeia de filtros de segurança
     * Permite acesso público apenas aos endpoints de login, cadastro de usuário (POST) e documentação Swagger
     * Todas as outras rotas requerem autenticação JWT
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

            // Configuração de handlers de erro
            .exceptionHandling(exception -> exception
                .authenticationEntryPoint(jwtAuthenticationEntryPoint)  // 401 - Não autenticado
                .accessDeniedHandler(jwtAccessDeniedHandler)            // 403 - Acesso negado
            )

            .authorizeHttpRequests(auth -> auth
                // Rotas de autenticação (login)
                .requestMatchers("/auth/**").permitAll()

                // Rota de cadastro de usuário (APENAS POST - sem autenticação)
                .requestMatchers(HttpMethod.POST, "/usuarios").permitAll()

                // Rotas do WebSocket (autenticação feita pelo WebSocketAuthInterceptor)
                .requestMatchers("/ws-petdex/**").permitAll()

                // Rotas do Swagger/OpenAPI
                .requestMatchers("/swagger-ui/**").permitAll()
                .requestMatchers("/swagger-ui.html").permitAll()
                .requestMatchers("/v3/api-docs/**").permitAll()
                .requestMatchers("/swagger-resources/**").permitAll()
                .requestMatchers("/webjars/**").permitAll()
                .requestMatchers("/swagger/**").permitAll()

                // Rota de health check e página inicial
                .requestMatchers("/health").permitAll()
                .requestMatchers("/").permitAll()

                // Todas as outras rotas requerem autenticação
                .anyRequest().authenticated()
            )
            // Adiciona o filtro JWT antes do filtro de autenticação padrão
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}

