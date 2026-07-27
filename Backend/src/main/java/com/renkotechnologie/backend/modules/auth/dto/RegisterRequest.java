package com.renkotechnologie.backend.modules.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RegisterRequest {

    @NotBlank
    private String nom;

    @NotBlank
    private String prenom;

    @NotBlank
    @Email
    private String email;

    @NotBlank
    @Size(min = 6, message = "Le mot de passe doit contenir au moins 6 caracteres")
    private String password;

    @NotBlank
    @Pattern(regexp = "CLIENT|PRESTATAIRE", message = "Le role doit etre CLIENT ou PRESTATAIRE")
    private String role;

    @NotBlank
    private String telephone;

    /** Metier declare, uniquement requis pour un prestataire. */
    private String specialite;

    private LocalDate dateNaissance;
}
