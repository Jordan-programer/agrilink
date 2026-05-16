package com.backend.agrilink.model;

import java.time.LocalDateTime;
import java.util.UUID;

import org.hibernate.annotations.CreationTimestamp;

import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Table(name = "pedidos")
@Data
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private UUID compradorId;

    private UUID agricultorId;

    private Double total;
    private Double comissaoPlataforma;

    @Enumerated(EnumType.STRING)
    private StatusPedido status;

    @CreationTimestamp
    private LocalDateTime createdAt;

    private LocalDateTime deliveryDate;

    private UUID transportadorId;

    @Enumerated(EnumType.STRING)
    private StatusTransporte statusTransporte;

    @Enumerated(EnumType.STRING)
    private PaymentStatus paymentStatus = PaymentStatus.PENDENTE;

    @jakarta.persistence.Lob
    @jakarta.persistence.Column(columnDefinition = "LONGTEXT")
    private String comprovativoBase64;
}