package com.backend.agrilink.dto;
import lombok.Data;

@Data
public class LoginRequest {

    private String telefone;
    private String senha;
}