package com.backend.agrilink.repository;

import com.backend.agrilink.model.Order;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.backend.agrilink.model.StatusTransporte;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    Optional<Order> findById(Long id);
    List<Order> findByCompradorId(UUID compradorId);
    List<Order> findByStatusTransporte(StatusTransporte status);
    List<Order> findByTransportadorId(UUID transportadorId);
}