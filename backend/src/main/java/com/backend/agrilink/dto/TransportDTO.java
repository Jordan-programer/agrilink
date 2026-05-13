package com.backend.agrilink.dto;

import lombok.Data;

import java.time.LocalDate;
import java.util.UUID;

@Data
public class TransportDTO {

    private Long id;
    private UUID transportadorId;
    private String origem;
    private String destino;
    private String status;
    private LocalDate dataPartida;
    private LocalDate dataChegada;
}