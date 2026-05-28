package com.backend.agrilink.model;

import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Table(name = "produtos")
@Data
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nome;

    @Enumerated(EnumType.STRING)
    private Categorias categoriaId;
    
    @org.hibernate.annotations.JdbcTypeCode(java.sql.Types.VARCHAR)
    @jakarta.persistence.Column(name = "image_data", columnDefinition = "TEXT")
    private String imageUrl;
}