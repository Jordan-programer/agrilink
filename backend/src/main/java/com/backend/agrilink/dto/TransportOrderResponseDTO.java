package com.backend.agrilink.dto;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransportOrderResponseDTO {
    private String id;
    private Long numericId;
    private String productName;
    private String farmerName;
    private String pickupProvince;
    private String buyerName;
    private String dropoffProvince;
    private Integer totalWeight;
    private Double transportPayout;
    private String statusTransporte;
    private String placedAt;
}
