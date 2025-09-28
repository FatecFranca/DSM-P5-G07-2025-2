package com.petdex.api.domain.contracts.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

public class PageDTO {
    @Schema(description = "Página da requisição", example = "0")
    private int page = 0;
    @Schema(description = "Quantidade de elementos por página", example = "10")
    private int size = 10;
    @Schema(description = "Atributo pelo qual as respostas serão ordenadas")
    private String sortBy;
    @Schema(description = "Direção da ordem (ASC ou DESC)")
    private String direction;

    public PageDTO() {
    }

    public PageDTO(int page, int size) {
        this.page = page;
        this.size = size;
    }

    public PageDTO(int page, int size, String sortBy, String direction) {
        this.size = size;
        this.page = page;
        this.sortBy = sortBy;
        this.direction = direction;
    }

    public void setPage(int page) {
        this.page = page;
    }

    public void setSize(int size) {
        this.size = size;
    }

    public void setSortBy(String sortBy) {
        this.sortBy = sortBy;
    }

    public void setDirection(String direction) {
        this.direction = direction;
    }

    public Integer getSize() {
        return size;
    }

    public Integer getPage() {
        return page;
    }

    public String getSortBy() {
        return sortBy;
    }

    public String getDirection() {
        return direction;
    }


    public Pageable mapPage() {

        if(this.sortBy != null) {
            Sort sort = direction.equalsIgnoreCase("asc") ?
                    Sort.by(this.sortBy).ascending() :
                    Sort.by(this.sortBy).descending();
            return  PageRequest.of(this.page, this.size, sort);
        }

        return PageRequest.of(this.page, this.size);
    }

    public void sortByNewest() {
        if(this.getSortBy() != null) {
           if (this.getSortBy().isEmpty()) {
               this.setSortBy("data");
           }
        } else {
            this.setSortBy("data");
        }

        if(this.getDirection() != null) {
            if (this.getDirection().isEmpty()) {
                this.setDirection("desc");
            }
        } else {
            this.setDirection("desc");
        }
    }
     public void sortByName() {
        if(this.getSortBy() != null) {
           if (this.getSortBy().isEmpty()) {
               this.setSortBy("nome");
           }
        } else {
            this.setSortBy("nome");
        }

        if(this.getDirection() != null) {
            if (this.getDirection().isEmpty()) {
                this.setDirection("asc");
            }
        } else {
            this.setDirection("asc");
        }
    }


}
