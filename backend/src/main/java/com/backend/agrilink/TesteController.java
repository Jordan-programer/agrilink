package com.backend.agrilink;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TesteController {

    @GetMapping("/")
    public String home() {
        return "Servidor AgriLink está online e ligado ao Supabase!";
    }
}
