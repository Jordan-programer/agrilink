package com.backend.agrilink.dto;

import lombok.Data;
import java.util.List;
import java.util.UUID;

@Data
public class OrderRequest {

    private UUID compradorId;

    private List<OrderItemDTO> items;
}
