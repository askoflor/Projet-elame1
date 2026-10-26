package com.renkotechnologie.backend.modules.search.dto;

import com.renkotechnologie.backend.modules.auth.dto.UserSummary;
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

    public static ProviderSearchResponse fromSummary(UserSummary user, long missionsRealisees) {
        return ProviderSearchResponse.builder()
                .id(String.valueOf(user.id()))
                .nom(user.nom())
                .prenom(user.prenom())
                .specialite(user.specialite())
                .quartier(user.quartier())
                .photoUrl(user.photoUrl())
                .about(user.about())
                .certifie(user.certifie())
                .disponible(user.disponible())
                .missionsRealisees(missionsRealisees)
                .build();
    }
}
