package com.backend.agrilink.controller;

import com.backend.agrilink.model.Transport;
import com.backend.agrilink.service.TransportService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/transports")
@RequiredArgsConstructor
@CrossOrigin("*")
public class TransportController {

    private final TransportService service;

    @PostMapping
    public ResponseEntity<Transport> create(@RequestBody Transport transport) {
        return ResponseEntity.ok(service.save(transport));
    }

    @GetMapping
    public ResponseEntity<List<Transport>> getAll() {
        return ResponseEntity.ok(service.findAll());
    }
}