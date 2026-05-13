package com.backend.agrilink.model;

import java.util.UUID;

import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Table(name = "listing")
@Data
public class Listing {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private UUID agricultorId;

    private Long productId;

    private Integer quantidade;

    private Double preco;

    @Enumerated(EnumType.STRING)
    private ProvinceList provincia;

    @Enumerated(EnumType.STRING)
    private StatusProduto statusProduto;

    private String descricao;

     @Enumerated(EnumType.STRING)
    private UnidadeProduto unidade;

    @Enumerated(EnumType.STRING)
    private NivelFrescura nivelFrescura;
     

}