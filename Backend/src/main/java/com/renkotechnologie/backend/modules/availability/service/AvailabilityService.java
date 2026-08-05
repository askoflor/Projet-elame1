package com.renkotechnologie.backend.modules.availability.service;

import com.renkotechnologie.backend.modules.availability.dto.AvailabilityOverrideResponse;
import java.time.LocalDate;
import java.util.List;

public interface AvailabilityService {

    /** Exceptions de disponibilite du prestataire connecte. */
    List<AvailabilityOverrideResponse> mesDisponibilites(String email);

    /** Exceptions de disponibilite d'un prestataire, publiques (consultees par un client qui reserve). */
    List<AvailabilityOverrideResponse> disponibilitesPrestataire(String providerName);

    List<AvailabilityOverrideResponse> basculerDate(String email, LocalDate date);

    List<AvailabilityOverrideResponse> definirPeriode(String email, LocalDate debut, LocalDate fin, boolean disponible);
}
