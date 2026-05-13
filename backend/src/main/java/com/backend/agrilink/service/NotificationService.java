package com.backend.agrilink.service;

import com.backend.agrilink.model.Notification;
import com.backend.agrilink.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository repository;

    public List<Notification> findByUser(UUID userId) {
        return repository.findByUsuarioId(userId);
    }

    public Notification send(Notification notification) {
        return repository.save(notification);
    }
}