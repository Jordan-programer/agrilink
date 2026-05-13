package com.backend.agrilink.dto;

import com.backend.agrilink.model.ProvinceList;
import com.backend.agrilink.model.TipoUsuario;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class LoginResponse {

    private String token;

    private String id;
    private String nome;
    private String telefone;
    private TipoUsuario tipo;
    private ProvinceList provincia;
}