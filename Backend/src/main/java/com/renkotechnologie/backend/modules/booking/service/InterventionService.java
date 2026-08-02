package com.renkotechnologie.backend.modules.booking.service;

import com.renkotechnologie.backend.modules.booking.dto.ChiffrageRequest;
import com.renkotechnologie.backend.modules.booking.dto.CompletionRequest;
import com.renkotechnologie.backend.modules.booking.dto.InterventionCreateRequest;
import com.renkotechnologie.backend.modules.booking.dto.InterventionResponse;
import com.renkotechnologie.backend.modules.booking.dto.ProviderScheduleEntry;
import java.util.List;

public interface InterventionService {

    InterventionResponse creer(String clientEmail, InterventionCreateRequest request);

    List<InterventionResponse> mesInterventions(String email);

    List<ProviderScheduleEntry> planningPrestataire(String providerName);

    InterventionResponse chiffrer(String prestataireEmail, String reference, ChiffrageRequest request);

    InterventionResponse terminer(String prestataireEmail, String reference, CompletionRequest request);

    InterventionResponse annuler(String prestataireEmail, String reference);
}
