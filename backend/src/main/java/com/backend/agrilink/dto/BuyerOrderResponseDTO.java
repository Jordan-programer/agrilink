package com.backend.agrilink.dto;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BuyerOrderResponseDTO {
    private String id;
    private String productName;
    private String sellerName;
    private String sellerProvince;
    private Double totalAoa;
    private Integer quantity;
    private String unit;
    private String status;
    private String deliveryDate;
    private String placedAt;
    private String category;
    private List<OrderItemResponseDTO> items;
    private String comprovativoBase64;
}
