package com.backend.agrilink.repository;

import com.backend.agrilink.model.OrderItem;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {
    List<OrderItem> findByPedidoId(Long pedidoId);
}