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

    public Listing findById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Listing não encontrada"));
    }

    public Listing updateListing(Long id, Listing details) {
        Listing listing = findById(id);
        listing.setPreco(details.getPreco());
        listing.setQuantidade(details.getQuantidade());
        listing.setUnidade(details.getUnidade());
        listing.setProvincia(details.getProvincia());
        listing.setDescricao(details.getDescricao());
        listing.setNivelFrescura(details.getNivelFrescura());
        if (details.getStatusProduto() != null) {
            listing.setStatusProduto(details.getStatusProduto());
        }
        return repository.save(listing);
    }

    public void deleteListing(Long id) {
        repository.deleteById(id);
    }
}