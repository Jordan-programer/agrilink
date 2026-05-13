package com.backend.agrilink.dto;

import lombok.Data;
import java.util.UUID;

@Data
public class PaymentDTO {

    private Long id;
    private Long pedidoId;
    private String metodo;
    private String status;
    private Double valor;
    private UUID referencia;
}
