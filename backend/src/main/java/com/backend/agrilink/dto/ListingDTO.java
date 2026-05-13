package com.backend.agrilink.dto;

import lombok.Data;
import java.util.UUID;

@Data
public class ListingDTO {
    private Long id;
    private UUID agricultorId;
    private Long productId;
    private Integer quantidade;
    private Double preco;
    private String provincia;
    private String status;
}
