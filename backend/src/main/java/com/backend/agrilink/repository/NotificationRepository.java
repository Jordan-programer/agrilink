package com.backend.agrilink.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.backend.agrilink.model.Notification;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
   List<Notification> findByUsuarioId(UUID usuarioId);
}