package com.backend.agrilink.dto;

import com.backend.agrilink.model.Categorias;
import com.backend.agrilink.model.NivelFrescura;
import com.backend.agrilink.model.ProvinceList;
import com.backend.agrilink.model.UnidadeProduto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ProductResponseDTO {
    private Long id;
    private String productName; // usado se for novo produto
    private Long productId;     // usado se produto já existir

    private Boolean newProduct;
    private Categorias categoriaId;
    private String imageUrl;

    private String agricultorId;
    private String farmerName;

    private Double preco;
    private Integer quantidade;
    private UnidadeProduto unidade;
    private ProvinceList provincia;

    private String descricao;
    private NivelFrescura nivelFrescura;
}
