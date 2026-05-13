package com.backend.agrilink.service;

import org.springframework.stereotype.Service;

import com.backend.agrilink.dto.OrderItemDTO;
import com.backend.agrilink.dto.OrderRequest;
import com.backend.agrilink.model.Order;
import com.backend.agrilink.model.OrderItem;
import com.backend.agrilink.model.StatusPedido;
import com.backend.agrilink.repository.OrderItemRepository;
import com.backend.agrilink.repository.OrderRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final OrderItemRepository itemRepository;

    public Order createOrder(OrderRequest request) {

        Order order = new Order();
        order.setCompradorId(request.getCompradorId());
        order.setStatus(StatusPedido.PENDENTE);
        order.setTotal(0.0);

        Order savedOrder = orderRepository.save(order);

        double total = 0;

        for (OrderItemDTO itemDto : request.getItems()) {
        OrderItem item = new OrderItem();
        
        item.setPedidoId(savedOrder.getId());
        item.setProdutoId(itemDto.getProdutoId());
        item.setQuantidade(itemDto.getQuantidade());
        item.setPreco(itemDto.getPreco());

        itemRepository.save(item);

        total += itemDto.getPreco() * itemDto.getQuantidade();
    }

    savedOrder.setTotal(total);
    return orderRepository.save(savedOrder);

    }

    public Order findById(Long id) {
    return orderRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Pedido não encontrado com o ID: " + id));
}

}