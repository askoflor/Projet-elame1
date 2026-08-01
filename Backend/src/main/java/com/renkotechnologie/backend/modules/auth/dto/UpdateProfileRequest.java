package com.renkotechnologie.backend.modules.auth.dto;

import lombok.Getter;
import lombok.Setter;

/** Champs modifiables par l'utilisateur lui-meme depuis son profil. */
@Getter
@Setter
public class UpdateProfileRequest {

    private String nom;

    private String prenom;

    private String telephone;

    private String quartier;

    /** Photo de profil encodee en base64 (data URI). Null = ne pas modifier. */
    private String photoUrl;
}
