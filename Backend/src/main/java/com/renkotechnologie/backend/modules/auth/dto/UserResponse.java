package com.renkotechnologie.backend.modules.auth.dto;

import com.renkotechnologie.backend.modules.auth.entity.User;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@AllArgsConstructor
public class UserResponse {

    private String id;
    private String email;
    private String nom;
    private String prenom;
    private String role;
    private String telephone;
    private String specialite;
    private LocalDate dateNaissance;
    private boolean emailVerified;

    public static UserResponse fromEntity(User user) {
        return UserResponse.builder()
                .id(String.valueOf(user.getId()))
                .email(user.getEmail())
                .nom(user.getNom())
                .prenom(user.getPrenom())
                .role(user.getRole().name())
                .telephone(user.getTelephone())
                .specialite(user.getSpecialite())
                .dateNaissance(user.getDateNaissance())
                .emailVerified(user.isEmailVerified())
                .build();
    }
}
