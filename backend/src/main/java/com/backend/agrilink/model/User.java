package com.backend.agrilink.model;

import java.time.LocalDate;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Data
@Table(name = "usuarios")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    private String nome;
    private String telefone;
    private String email;
    private String senha;

    @Enumerated(EnumType.STRING)
    private TipoUsuario tipo;

    @Enumerated(EnumType.STRING)
    private ProvinceList provincia;
    private LocalDate data_cadastro;
    private String plano;

}
