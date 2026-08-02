package com.renkotechnologie.backend.modules.booking.entity;

import com.renkotechnologie.backend.modules.auth.entity.User;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

/**
 * Demande d'intervention creee par un client aupres d'un prestataire.
 *
 * <p>Le prestataire est conserve sous forme de nom affiche ({@code providerName})
 * plutot qu'en relation vers {@link User} : le repertoire de recherche des
 * prestataires (module search) reste pour l'instant base sur des donnees de
 * demonstration non liees aux comptes reellement inscrits, donc toutes les
 * interventions ne correspondent pas necessairement a un compte prestataire
 * existant. Le client, lui, est toujours l'utilisateur authentifie qui cree
 * la demande.</p>
 */
@Entity
@Table(name = "interventions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Intervention {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String reference;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id", nullable = false)
    private User client;

    @Column(name = "provider_name", nullable = false)
    private String providerName;

    @Column(nullable = false)
    private String service;

    @Column(nullable = false)
    private String titre;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false)
    private LocalDate date;

    @ElementCollection
    @CollectionTable(name = "intervention_heures", joinColumns = @JoinColumn(name = "intervention_id"))
    @Column(name = "heure")
    @Builder.Default
    private List<Integer> heures = new ArrayList<>();

    @Column(nullable = false)
    private String urgence;

    @Column(nullable = false)
    private String adresse;

    private Double montant;

    @Column(name = "note_prestataire", columnDefinition = "TEXT")
    private String notePrestataire;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private InterventionStatus statut = InterventionStatus.ATTENTE;

    @Column(name = "completion_description", columnDefinition = "TEXT")
    private String completionDescription;

    @CreationTimestamp
    @Column(name = "cree_le", updatable = false)
    private LocalDateTime creeLe;
}
