package com.backend.agrilink.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.backend.agrilink.model.StatusTransporte;
import com.backend.agrilink.model.Transport;
import com.backend.agrilink.repository.TransportRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class TransportService {

    private final TransportRepository repository;

    public Transport save(Transport transport) {
        transport.setTransporte(StatusTransporte.EM_TRANSITO);
        return repository.save(transport);
    }

    public List<Transport> findAll() {
        return repository.findAll();
    }
}
