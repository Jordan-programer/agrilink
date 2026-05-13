package com.backend.agrilink.service;

import org.springframework.stereotype.Service;

import com.backend.agrilink.model.Payment;
import com.backend.agrilink.model.StatusPagamento;
import com.backend.agrilink.repository.PaymentRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository repository;

    public Payment processPayment(Payment payment) {

        // simulação de pagamento
        payment.setPagamento(StatusPagamento.PAGO);

        return repository.save(payment);
    }

    public Payment findById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Pagamento não encontrado"));
    }
}