package com.petdex.api.swagger.respostas;

import com.petdex.api.domain.contracts.dto.usuario.UsuarioResDTO;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

@Schema(
        name = "Exemplo Resposta Paginada de Usuários",
        description = "Exemplo de resposta paginada contendo uma lista de usuários"
)
public class ExemploRespostaPageUsuario {

    @Schema(description = "Lista de usuários retornados na página atual", example = "[{\"id\": \"507f1f77bcf86cd799439011\", \"nome\": \"João Silva\", \"cpf\": \"12345678900\", \"whatsApp\": \"11987654321\", \"email\": \"usuario@petdex.com\"}]")
    private List<UsuarioResDTO> content;

    @Schema(description = "Número da página atual (começa em 0)", example = "0")
    private Integer number;

    @Schema(description = "Quantidade de elementos por página", example = "10")
    private Integer size;

    @Schema(description = "Número total de elementos encontrados", example = "50")
    private Long totalElements;

    @Schema(description = "Número total de páginas disponíveis", example = "5")
    private Integer totalPages;

    @Schema(description = "Indica se é a primeira página", example = "true")
    private Boolean first;

    @Schema(description = "Indica se é a última página", example = "false")
    private Boolean last;

    @Schema(description = "Indica se existe uma próxima página", example = "true")
    private Boolean hasNext;

    @Schema(description = "Indica se existe uma página anterior", example = "false")
    private Boolean hasPrevious;

    @Schema(description = "Indica se a página está vazia", example = "false")
    private Boolean empty;

    public ExemploRespostaPageUsuario() {
    }

    public List<UsuarioResDTO> getContent() {
        return content;
    }

    public void setContent(List<UsuarioResDTO> content) {
        this.content = content;
    }

    public Integer getNumber() {
        return number;
    }

    public void setNumber(Integer number) {
        this.number = number;
    }

    public Integer getSize() {
        return size;
    }

    public void setSize(Integer size) {
        this.size = size;
    }

    public Long getTotalElements() {
        return totalElements;
    }

    public void setTotalElements(Long totalElements) {
        this.totalElements = totalElements;
    }

    public Integer getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(Integer totalPages) {
        this.totalPages = totalPages;
    }

    public Boolean getFirst() {
        return first;
    }

    public void setFirst(Boolean first) {
        this.first = first;
    }

    public Boolean getLast() {
        return last;
    }

    public void setLast(Boolean last) {
        this.last = last;
    }

    public Boolean getHasNext() {
        return hasNext;
    }

    public void setHasNext(Boolean hasNext) {
        this.hasNext = hasNext;
    }

    public Boolean getHasPrevious() {
        return hasPrevious;
    }

    public void setHasPrevious(Boolean hasPrevious) {
        this.hasPrevious = hasPrevious;
    }

    public Boolean getEmpty() {
        return empty;
    }

    public void setEmpty(Boolean empty) {
        this.empty = empty;
    }
}

