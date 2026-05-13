package com.backend.agrilink.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.backend.agrilink.model.Listing;
import com.backend.agrilink.model.StatusProduto;
import com.backend.agrilink.repository.ListingRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ListingService {

    private final ListingRepository repository;

    public Listing save(Listing listing) {
        listing.setStatusProduto(StatusProduto.ATIVO);
        return repository.save(listing);
    }

    public List<Listing> findAll() {
        return repository.findAll();
    }

    public List<Listing> findByProvincia(String provincia) {
        return repository.findByProvincia(provincia);
    }
}