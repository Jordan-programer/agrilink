package com.backend.agrilink.dto;

import lombok.Data;

@Data
public class OrderItemDTO {
    private Long produtoId;
    private Integer quantidade;
    private Double preco;
}