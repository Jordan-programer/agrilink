package com.backend.agrilink.dto;

import com.backend.agrilink.model.Categorias;
import com.backend.agrilink.model.NivelFrescura;
import com.backend.agrilink.model.ProvinceList;
import com.backend.agrilink.model.UnidadeProduto;

import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.Data;

@Data
public class CreateListingDTO {

    private String productName; // usado se for novo produto
    private Long productId;     // usado se produto já existir

    private Boolean newProduct;

    @Enumerated(EnumType.STRING)
    private Categorias categoriaId;

    private String agricultorId;

    private Double preco;
    private Integer quantidade;

    @Enumerated(EnumType.STRING)
    private UnidadeProduto unidade;

    @Enumerated(EnumType.STRING)
    private ProvinceList provincia;

    private String descricao;

    @Enumerated(EnumType.STRING)
    private NivelFrescura nivelFrescura;
}
