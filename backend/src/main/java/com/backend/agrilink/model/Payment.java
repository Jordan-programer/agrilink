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
@Table(name = "pagamentos")
@Data
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long pedidoId;

    @Enumerated(EnumType.STRING)
    private MetodoPagamento metodo;

    @Enumerated(EnumType.STRING)
    private StatusPagamento pagamento;

    private Double valor;

    private UUID referencia;


}