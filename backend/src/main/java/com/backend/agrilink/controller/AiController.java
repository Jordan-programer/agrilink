package com.backend.agrilink.controller;

import com.backend.agrilink.service.AiService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/ai")
@RequiredArgsConstructor
@CrossOrigin("*")
public class AiController {

    private final AiService aiService;

    // RIA02
    @GetMapping("/recommend-price")
    public ResponseEntity<Map<String, Object>> recommendPrice(
            @RequestParam String product,
            @RequestParam(required = false, defaultValue = "Luanda") String province) {
        
        return ResponseEntity.ok(aiService.recommendPrice(product, province));
    }

    // RIA04
    @GetMapping("/optimize-routes")
    public ResponseEntity<Map<String, Object>> optimizeRoutes(
            @RequestParam(required = false, defaultValue = "Luanda") String province) {
        
        return ResponseEntity.ok(aiService.optimizeRoutes(province));
    }

    // RIA06
    @PostMapping("/chat")
    public ResponseEntity<Map<String, Object>> chat(@RequestBody Map<String, String> payload) {
        String message = payload.getOrDefault("message", "");
        return ResponseEntity.ok(aiService.chat(message));
    }
}
