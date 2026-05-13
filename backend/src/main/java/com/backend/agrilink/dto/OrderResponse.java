package com.backend.agrilink.dto;

import lombok.Data;
import java.util.List;

@Data
public class OrderResponse {

    private Long id;
    private String status;
    private Double total;

    private List<OrderItemDTO> items;
}
