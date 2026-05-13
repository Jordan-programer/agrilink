package com.backend.agrilink.model;

import java.time.LocalDate;
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
@Table(name = "transportes")
@Data
public class Transport {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private UUID transportadorId;

    @Enumerated(EnumType.STRING)
    private StatusTransporte transporte;

    private LocalDate dataPartida;
    
    private String origem;

    private String destino;

    private LocalDate dataChegada;

}
