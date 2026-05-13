package com.backend.agrilink.service;

import com.backend.agrilink.model.User;
import com.backend.agrilink.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository repository;

    public User save(User user) {
        return repository.save(user);
    }

    public User findById(UUID id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
    }
}