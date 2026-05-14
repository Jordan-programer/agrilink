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
    private final org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;

    public User save(User user) {
        return repository.save(user);
    }

    public User findById(UUID id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));
    }

    public User updateUser(UUID id, User userDetails) {
        User user = findById(id);

        if (userDetails.getNome() != null && !userDetails.getNome().trim().isEmpty()) {
            user.setNome(userDetails.getNome());
        }
        if (userDetails.getTelefone() != null && !userDetails.getTelefone().trim().isEmpty()) {
            user.setTelefone(userDetails.getTelefone());
        }
        if (userDetails.getEmail() != null) {
            user.setEmail(userDetails.getEmail());
        }
        if (userDetails.getProvincia() != null) {
            user.setProvincia(userDetails.getProvincia());
        }
        if (userDetails.getSenha() != null && !userDetails.getSenha().trim().isEmpty()) {
            user.setSenha(passwordEncoder.encode(userDetails.getSenha()));
        }

        return repository.save(user);
    }

    public User upgradeToPremium(UUID id) {
        User user = findById(id);
        user.setPlano("PREMIUM");
        return repository.save(user);
    }
}