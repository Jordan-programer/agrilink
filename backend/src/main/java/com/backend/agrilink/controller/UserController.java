package com.backend.agrilink.controller;

import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.backend.agrilink.model.User;
import com.backend.agrilink.service.UserService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
@CrossOrigin("*")
public class UserController {
    
    private final UserService userService;

    @PutMapping("/{id}")
    public ResponseEntity<User> updateUser(@PathVariable UUID id, @RequestBody User userDetails) {
        User updatedUser = userService.updateUser(id, userDetails);
        // Não retornar a senha por segurança
        updatedUser.setSenha(null);
        return ResponseEntity.ok(updatedUser);
    }

    @PostMapping("/{id}/upgrade")
    public ResponseEntity<User> upgradeToPremium(@PathVariable UUID id) {
        User upgradedUser = userService.upgradeToPremium(id);
        upgradedUser.setSenha(null);
        return ResponseEntity.ok(upgradedUser);
    }
}
