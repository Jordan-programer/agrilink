package com.backend.agrilink.repository;

import com.backend.agrilink.model.Order;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    Optional<Order> findById(Long id);
}