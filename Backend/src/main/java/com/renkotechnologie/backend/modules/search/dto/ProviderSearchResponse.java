package com.renkotechnologie.backend.modules.search.dto;

import com.renkotechnologie.backend.modules.auth.entity.User;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

/** Profil d'un prestataire tel qu'expose par la recherche : uniquement des donnees publiques. */
@Getter
@Builder
@AllArgsConstructor
public class ProviderSearchResponse {

    private String id;
    private String nom;
    private String prenom;
    private String specialite;
    private String quartier;
    private String photoUrl;
    private String about;
    private boolean certifie;
    private boolean disponible;
    private long missionsRealisees;

    public static ProviderSearchResponse fromEntity(User user, long missionsRealisees) {
        return ProviderSearchResponse.builder()
                .id(String.valueOf(user.getId()))
                .nom(user.getNom())
                .prenom(user.getPrenom())
                .specialite(user.getSpecialite())
                .quartier(user.getQuartier())
                .photoUrl(user.getPhotoUrl())
                .about(user.getAbout())
                .certifie(user.isCertifie())
                .disponible(user.isDisponible())
                .missionsRealisees(missionsRealisees)
                .build();
    }
}
