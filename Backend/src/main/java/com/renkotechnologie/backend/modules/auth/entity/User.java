package com.renkotechnologie.backend.modules.auth.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nom;

    @Column(nullable = false)
    private String prenom;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String telephone;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;

    /** Metier declare a l'inscription, uniquement pour un prestataire. */
    private String specialite;

    private LocalDate dateNaissance;

    private String quartier;

    /** Photo de profil encodee en base64 (data URI), stockee directement en base. */
    @Column(name = "photo_url", columnDefinition = "LONGTEXT")
    private String photoUrl;

    @Column(name = "email_verified", nullable = false)
    @Builder.Default
    private boolean emailVerified = false;

    /**
     * Bascule manuellement par un administrateur (via la base de donnees) une
     * fois le profil du prestataire verifie. Conditionne l'affichage du badge
     * "Certifie" sur son profil public. columnDefinition force un DEFAULT SQL
     * pour que l'ajout de cette colonne sur une table users deja peuplee ne
     * casse pas les lignes existantes (evite un NOT NULL sans defaut).
     */
    @Column(nullable = false, columnDefinition = "boolean default false")
    @Builder.Default
    private boolean certifie = false;

    /** Presentation courte affichee sur le profil public (prestataire). */
    @Column(columnDefinition = "TEXT")
    private String about;

    /**
     * Disponibilite affichee sur le profil et utilisee comme filtre de
     * recherche. columnDefinition avec DEFAULT pour ne pas casser les lignes
     * existantes lors de l'ajout de cette colonne (meme raison que
     * {@link #certifie}).
     */
    @Column(nullable = false, columnDefinition = "boolean default true")
    @Builder.Default
    private boolean disponible = true;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // ---- UserDetails ----

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + role.name()));
    }

    @Override
    public String getPassword() {
        return passwordHash;
    }

    @Override
    public String getUsername() {
        return email;
    }
}
