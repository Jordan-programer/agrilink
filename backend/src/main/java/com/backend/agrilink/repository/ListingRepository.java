package com.backend.agrilink.repository;

import com.backend.agrilink.model.Listing;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ListingRepository extends JpaRepository<Listing, Long> {
    List<Listing> findByProvincia(String provincia);
}