package com.renkotechnologie.backend.modules.booking.service;

import com.renkotechnologie.backend.modules.booking.dto.ChiffrageRequest;
import com.renkotechnologie.backend.modules.booking.dto.CompletionRequest;
import com.renkotechnologie.backend.modules.booking.dto.InterventionCreateRequest;
import com.renkotechnologie.backend.modules.booking.dto.InterventionResponse;
import com.renkotechnologie.backend.modules.booking.dto.ProviderScheduleEntry;
import java.util.List;

public interface InterventionService {

    InterventionResponse creer(String clientEmail, InterventionCreateRequest request);

    /**
     * Reservations faites par l'utilisateur en tant que client. Un
     * prestataire peut lui aussi reserver un service aupres d'un autre
     * prestataire ; cette liste reflete alors ses propres commandes, quel
     * que soit son role.
     */
    List<InterventionResponse> mesReservationsClient(String email);

    /** Missions assignees a l'utilisateur en tant que prestataire (vide si ce n'est pas un prestataire enregistre). */
    List<InterventionResponse> mesMissionsPrestataire(String email);

    List<ProviderScheduleEntry> planningPrestataire(String providerName);

    InterventionResponse chiffrer(String prestataireEmail, String reference, ChiffrageRequest request);

    InterventionResponse terminer(String prestataireEmail, String reference, CompletionRequest request);

    InterventionResponse annuler(String prestataireEmail, String reference);
}
