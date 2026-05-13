package com.backend.agrilink.model;

import java.time.LocalDate;
import java.util.UUID;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Table(name = "notificacoes")
@Data
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private UUID usuarioId;

    private String mensagem;

    private boolean lida;

    private LocalDate dataEnvio;


    /**
     * @return Long return the id
     */
    public Long getId() {
        return id;
    }

    /**
     * @param id the id to set
     */
    public void setId(Long id) {
        this.id = id;
    }

    /**
     * @return UUID return the usuarioId
     */
    public UUID getUsuarioId() {
        return usuarioId;
    }

    /**
     * @param usuarioId the usuarioId to set
     */
    public void setUsuarioId(UUID usuarioId) {
        this.usuarioId = usuarioId;
    }

    /**
     * @return String return the mensagem
     */
    public String getMensagem() {
        return mensagem;
    }

    /**
     * @param mensagem the mensagem to set
     */
    public void setMensagem(String mensagem) {
        this.mensagem = mensagem;
    }

    /**
     * @return boolean return the lida
     */
    public boolean isLida() {
        return lida;
    }

    /**
     * @param lida the lida to set
     */
    public void setLida(boolean lida) {
        this.lida = lida;
    }

    /**
     * @return LocalDate return the dataEnvio
     */
    public LocalDate getDataEnvio() {
        return dataEnvio;
    }

    /**
     * @param dataEnvio the dataEnvio to set
     */
    public void setDataEnvio(LocalDate dataEnvio) {
        this.dataEnvio = dataEnvio;
    }

}