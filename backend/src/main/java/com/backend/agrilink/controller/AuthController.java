package com.backend.agrilink.controller;

import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping; // Importação necessária
import org.springframework.web.bind.annotation.RestController;

import com.backend.agrilink.dto.LoginRequest;
import com.backend.agrilink.dto.LoginResponse;
import com.backend.agrilink.model.User;
import com.backend.agrilink.repository.UserRepository;
import com.backend.agrilink.security.JwtService;
import com.backend.agrilink.service.UserService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@CrossOrigin("*")
public class AuthController {

    private final UserService userService;
    private final UserRepository userRepository;
    private final JwtService jwtService;
    
    // 1. Injetando o codificador de senhas
    private final PasswordEncoder passwordEncoder; 

    @PostMapping("/register")
    public ResponseEntity<User> register(@RequestBody User user) {
        // 2. Criptografa a senha antes de enviar para o serviço/banco de dados
        user.setSenha(passwordEncoder.encode(user.getSenha()));
        
        return ResponseEntity.ok(userService.save(user));
    }

    @GetMapping("/user/{id}")
    public ResponseEntity<User> getUser(@PathVariable UUID id) {
        return ResponseEntity.ok(userService.findById(id));
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest request) {

        User user = userRepository.findByTelefone(request.getTelefone())
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        // 3. Verifica se a senha em texto plano bate com o Hash salvo no banco
        if (!passwordEncoder.matches(request.getSenha(), user.getSenha())) {
            throw new RuntimeException("Senha inválida");
        }

        String token = jwtService.generateToken(user.getTelefone(), user.getTipo().toString());

        LoginResponse response = LoginResponse.builder()
                .token(token)
                .id(user.getId().toString())
                .nome(user.getNome())
                .telefone(user.getTelefone())
                .tipo(user.getTipo())
                .provincia(user.getProvincia())
                .build();

        return ResponseEntity.ok(response);
    }
}