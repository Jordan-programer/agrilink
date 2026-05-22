package com.backend.agrilink.controller;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.backend.agrilink.dto.CreateListingDTO;
import com.backend.agrilink.dto.ProductResponseDTO;
import com.backend.agrilink.model.Listing;
import com.backend.agrilink.model.Product;
import com.backend.agrilink.model.StatusProduto;
import com.backend.agrilink.model.User;
import com.backend.agrilink.repository.ListingRepository;
import com.backend.agrilink.repository.ProductRepository;
import com.backend.agrilink.repository.UserRepository;
import com.backend.agrilink.service.ListingService;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/listings")
@RequiredArgsConstructor
public class ListingController {

    private final ListingService service;
    private final ListingRepository listingRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;

    @PostMapping
    @Transactional
    public ResponseEntity<Listing> create(@RequestBody CreateListingDTO dto) {
        Product product;
        if (Boolean.TRUE.equals(dto.getNewProduct())) {
            product = new Product();
            product.setNome(dto.getProductName());
            product.setCategoriaId(dto.getCategoriaId());
            product = productRepository.save(product);
        } else {
            product = productRepository.findById(dto.getProductId())
                    .orElseThrow(() -> new RuntimeException("Produto não encontrado"));
        }

        Listing listing = new Listing();
        listing.setProductId(product.getId());
        listing.setAgricultorId(UUID.fromString(dto.getAgricultorId()));
        listing.setPreco(dto.getPreco());
        listing.setQuantidade(dto.getQuantidade());
        listing.setUnidade(dto.getUnidade());
        listing.setProvincia(dto.getProvincia());
        listing.setDescricao(dto.getDescricao());
        listing.setNivelFrescura(dto.getNivelFrescura());
        listing.setStatusProduto(StatusProduto.ATIVO);

        return ResponseEntity.ok(service.save(listing));
    }

    @GetMapping
    public ResponseEntity<List<Listing>> getAll() {
        return ResponseEntity.ok(service.findAll());
    }

    @GetMapping("/products")
    public ResponseEntity<List<ProductResponseDTO>> getAllProducts(
            @org.springframework.web.bind.annotation.RequestParam(required = false) String role,
            @org.springframework.web.bind.annotation.RequestParam(required = false) String userId) {
        
        List<Listing> listings;
        if ("AGRICULTOR".equalsIgnoreCase(role) && userId != null && !userId.isEmpty()) {
            listings = listingRepository.findByAgricultorId(UUID.fromString(userId));
        } else {
            listings = listingRepository.findAll();
        }

        List<Long> productIds = listings.stream().map(Listing::getProductId).distinct().toList();
        List<UUID> farmerIds = listings.stream().map(Listing::getAgricultorId).distinct().toList();

        Map<Long, Product> productMap = productRepository.findAllById(productIds).stream()
                .collect(Collectors.toMap(Product::getId, p -> p));

        Map<UUID, User> farmerMap = userRepository.findAllById(farmerIds).stream()
                .collect(Collectors.toMap(User::getId, u -> u));

        List<ProductResponseDTO> response = listings.stream()
                .filter(listing -> productMap.containsKey(listing.getProductId()) && farmerMap.containsKey(listing.getAgricultorId()))
                .map(listing -> mapToResponseDTO(listing, productMap, farmerMap))
                .toList();

        return ResponseEntity.ok(response);
    }

    // MÉTODO PRIVADO (FORA DO GETMAPPING)
    private ProductResponseDTO mapToResponseDTO(Listing listing, Map<Long, Product> productMap, Map<UUID, User> farmerMap) {
        Product prod = productMap.get(listing.getProductId());
        User farmer = farmerMap.get(listing.getAgricultorId());

        String productName = prod != null ? prod.getNome() : "Produto Desconhecido";
        com.backend.agrilink.model.CategoryList catId = prod != null ? prod.getCategoriaId() : null;
        String imageUrl = prod != null ? prod.getImageUrl() : null;
        String farmerName = farmer != null ? farmer.getNome() : "Agricultor Desconhecido";

        return ProductResponseDTO.builder()
                .id(listing.getId())
                .productName(productName)
                .productId(listing.getProductId())
                .newProduct(false)
                .categoriaId(catId)
                .imageUrl(imageUrl)
                .agricultorId(listing.getAgricultorId().toString())
                .farmerName(farmerName)
                .preco(listing.getPreco())
                .quantidade(listing.getQuantidade())
                .unidade(listing.getUnidade())
                .provincia(listing.getProvincia())
                .descricao(listing.getDescricao())
                .nivelFrescura(listing.getNivelFrescura())
                .build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<Listing> update(@PathVariable Long id, @RequestBody Listing listing) {
        return ResponseEntity.ok(service.updateListing(id, listing));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.deleteListing(id);
        return ResponseEntity.ok().build();
    }
}
