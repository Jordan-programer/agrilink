package com.backend.agrilink.controller;

import com.backend.agrilink.model.Notification;
import com.backend.agrilink.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
@CrossOrigin("*")
public class NotificationController {

    private final NotificationService service;

    @GetMapping("/{userId}")
    public ResponseEntity<List<Notification>> getByUser(@PathVariable UUID userId) {
        return ResponseEntity.ok(service.findByUser(userId));
    }
}