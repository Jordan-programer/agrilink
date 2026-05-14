package com.backend.agrilink.service;

import org.springframework.stereotype.Service;

import com.backend.agrilink.model.Payment;
import com.backend.agrilink.model.StatusPagamento;
import com.backend.agrilink.repository.PaymentRepository;

import lombok.RequiredArgsConstructor;

import java.time.LocalDate;

import com.backend.agrilink.model.Notification;
import com.backend.agrilink.model.Order;
import com.backend.agrilink.model.StatusPedido;
import com.backend.agrilink.repository.NotificationRepository;
import com.backend.agrilink.repository.OrderRepository;

@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository repository;
    private final OrderRepository orderRepository;
    private final NotificationRepository notificationRepository;

    public Payment processPayment(Payment payment) {
        // simulação de pagamento
        payment.setPagamento(StatusPagamento.PAGO);
        Payment savedPayment = repository.save(payment);

        // Update order status
        Order order = orderRepository.findById(payment.getPedidoId()).orElse(null);
        if (order != null) {
            order.setStatus(StatusPedido.APROVADO);
            orderRepository.save(order);

            // Notify buyer
            Notification buyerNotification = new Notification();
            buyerNotification.setUsuarioId(order.getCompradorId());
            buyerNotification.setMensagem("O pagamento do seu pedido #" + order.getId() + " foi confirmado.");
            buyerNotification.setDataEnvio(LocalDate.now());
            buyerNotification.setLida(false);
            notificationRepository.save(buyerNotification);

            // Notify seller
            if (order.getAgricultorId() != null) {
                Notification sellerNotification = new Notification();
                sellerNotification.setUsuarioId(order.getAgricultorId());
                sellerNotification.setMensagem("Nova venda realizada! O pedido #" + order.getId() + " foi pago. Prepare a mercadoria.");
                sellerNotification.setDataEnvio(LocalDate.now());
                sellerNotification.setLida(false);
                notificationRepository.save(sellerNotification);
            }
        }

        return savedPayment;
    }

    public Payment findById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Pagamento não encontrado"));
    }
}