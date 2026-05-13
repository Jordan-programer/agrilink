package com.backend.agrilink.controller;

import com.backend.agrilink.model.Payment;
import com.backend.agrilink.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/payments")
@RequiredArgsConstructor
@CrossOrigin("*")
public class PaymentController {

    private final PaymentService service;

    @PostMapping
    public ResponseEntity<Payment> create(@RequestBody Payment payment) {
        return ResponseEntity.ok(service.processPayment(payment));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Payment> get(@PathVariable Long id) {
        return ResponseEntity.ok(service.findById(id));
    }
}