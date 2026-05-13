package com.backend.agrilink.dto;

import lombok.Data;
import java.util.UUID;

@Data
public class UserDTO {
    private UUID id;
    private String nome;
    private String telefone;
    private String tipo;
    private String provincia;
}