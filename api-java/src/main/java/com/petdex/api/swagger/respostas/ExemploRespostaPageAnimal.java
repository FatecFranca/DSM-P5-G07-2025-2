package com.petdex.api.swagger.respostas;

import com.petdex.api.domain.contracts.dto.animal.AnimalResDTO;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

/**
 * Classe de exemplo para resposta paginada de animais
 */
@Schema(
        name = "Exemplo Resposta Paginada de Animais",
        description = "Exemplo de resposta paginada contendo uma lista de animais"
)
public class ExemploRespostaPageAnimal {

    @Schema(description = "Lista de animais retornados na página atual")
    private List<AnimalResDTO> content;

    @Schema(description = "Número da página atual", example = "0")
    private int number;

    @Schema(description = "Quantidade de elementos por página", example = "10")
    private int size;

    @Schema(description = "Número total de elementos em todas as páginas", example = "50")
    private long totalElements;

    @Schema(description = "Número total de páginas", example = "5")
    private int totalPages;

    @Schema(description = "Indica se é a primeira página", example = "true")
    private boolean first;

    @Schema(description = "Indica se é a última página", example = "false")
    private boolean last;

    @Schema(description = "Indica se há uma próxima página", example = "true")
    private boolean hasNext;

    @Schema(description = "Indica se há uma página anterior", example = "false")
    private boolean hasPrevious;

    @Schema(description = "Indica se a página está vazia", example = "false")
    private boolean empty;

    public ExemploRespostaPageAnimal() {
    }

    public ExemploRespostaPageAnimal(List<AnimalResDTO> content, int number, int size, long totalElements, int totalPages, boolean first, boolean last, boolean hasNext, boolean hasPrevious, boolean empty) {
        this.content = content;
        this.number = number;
        this.size = size;
        this.totalElements = totalElements;
        this.totalPages = totalPages;
        this.first = first;
        this.last = last;
        this.hasNext = hasNext;
        this.hasPrevious = hasPrevious;
        this.empty = empty;
    }

    public List<AnimalResDTO> getContent() {
        return content;
    }

    public void setContent(List<AnimalResDTO> content) {
        this.content = content;
    }

    public int getNumber() {
        return number;
    }

    public void setNumber(int number) {
        this.number = number;
    }

    public int getSize() {
        return size;
    }

    public void setSize(int size) {
        this.size = size;
    }

    public long getTotalElements() {
        return totalElements;
    }

    public void setTotalElements(long totalElements) {
        this.totalElements = totalElements;
    }

    public int getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(int totalPages) {
        this.totalPages = totalPages;
    }

    public boolean isFirst() {
        return first;
    }

    public void setFirst(boolean first) {
        this.first = first;
    }

    public boolean isLast() {
        return last;
    }

    public void setLast(boolean last) {
        this.last = last;
    }

    public boolean isHasNext() {
        return hasNext;
    }

    public void setHasNext(boolean hasNext) {
        this.hasNext = hasNext;
    }

    public boolean isHasPrevious() {
        return hasPrevious;
    }

    public void setHasPrevious(boolean hasPrevious) {
        this.hasPrevious = hasPrevious;
    }

    public boolean isEmpty() {
        return empty;
    }

    public void setEmpty(boolean empty) {
        this.empty = empty;
    }
}

