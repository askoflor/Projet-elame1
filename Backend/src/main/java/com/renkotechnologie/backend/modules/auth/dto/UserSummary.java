package com.renkotechnologie.backend.modules.auth.dto;

/**
 * Vue en lecture seule d'un utilisateur, exposee aux autres modules a la
 * place de l'entite JPA {@link com.renkotechnologie.backend.modules.auth.entity.User}.
 */
public record UserSummary(
        Long id,
        String nom,
        String prenom,
        String email,
        String telephone,
        String specialite,
        String quartier,
        String photoUrl,
        String about,
        boolean certifie,
        boolean disponible) {

    public String displayName() {
        return (prenom + " " + nom).trim();
    }
}
