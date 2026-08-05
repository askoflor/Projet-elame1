package com.renkotechnologie.backend.modules.availability.entity;

import com.renkotechnologie.backend.modules.auth.entity.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Exception ponctuelle a la disponibilite par defaut d'un prestataire pour
 * une date donnee. En l'absence d'override pour une date, le prestataire
 * est considere disponible (comportement par defaut).
 */
@Entity
@Table(name = "availability_overrides", uniqueConstraints = @UniqueConstraint(columnNames = {"provider_id", "date"}))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AvailabilityOverride {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "provider_id", nullable = false)
    private User provider;

    @Column(name = "date", nullable = false)
    private LocalDate date;

    @Column(nullable = false)
    private boolean disponible;
}
