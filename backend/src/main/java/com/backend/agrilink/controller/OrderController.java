package com.backend.agrilink.controller;

import com.backend.agrilink.dto.OrderRequest;
import com.backend.agrilink.model.Order;
import com.backend.agrilink.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/orders")
@RequiredArgsConstructor
@CrossOrigin("*")
public class OrderController {

    private final OrderService service;

    @PostMapping
    public ResponseEntity<Order> createOrder(@RequestBody OrderRequest request) {
        return ResponseEntity.ok(service.createOrder(request));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Order> getOrder(@PathVariable Long id) {
        return ResponseEntity.ok(service.findById(id));
    }

    @GetMapping("/comprador/{compradorId}")
    public ResponseEntity<List<com.backend.agrilink.dto.BuyerOrderResponseDTO>> getOrdersByComprador(@PathVariable java.util.UUID compradorId) {
        return ResponseEntity.ok(service.getOrdersByComprador(compradorId));
    }

    @PostMapping("/{id}/cancel")
    public ResponseEntity<Order> cancelOrder(@PathVariable Long id) {
        return ResponseEntity.ok(service.cancelOrder(id));
    }

    @GetMapping("/transport/available")
    public ResponseEntity<List<com.backend.agrilink.dto.TransportOrderResponseDTO>> getAvailableTransports() {
        return ResponseEntity.ok(service.getAvailableTransports());
    }

    @GetMapping("/transport/transporter/{transportadorId}")
    public ResponseEntity<List<com.backend.agrilink.dto.TransportOrderResponseDTO>> getTransporterOrders(@PathVariable java.util.UUID transportadorId) {
        return ResponseEntity.ok(service.getTransporterOrders(transportadorId));
    }

    @PutMapping("/{id}/transport/accept/{transportadorId}")
    public ResponseEntity<Order> acceptTransport(@PathVariable Long id, @PathVariable java.util.UUID transportadorId) {
        return ResponseEntity.ok(service.acceptTransport(id, transportadorId));
    }
}