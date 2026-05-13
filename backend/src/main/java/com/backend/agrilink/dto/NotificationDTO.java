package com.backend.agrilink.dto;

import lombok.Data;
import java.util.UUID;

@Data
public class NotificationDTO {

    private Long id;
    private UUID usuarioId;
    private String mensagem;
    private Boolean lida;
}
