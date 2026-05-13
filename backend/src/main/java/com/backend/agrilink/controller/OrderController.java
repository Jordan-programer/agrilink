package com.backend.agrilink.controller;

import com.backend.agrilink.dto.OrderRequest;
import com.backend.agrilink.model.Order;
import com.backend.agrilink.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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
}