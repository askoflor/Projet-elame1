package com.renkotechnologie.backend.modules.search.service.impl;

import com.renkotechnologie.backend.modules.auth.dto.UserSummary;
import com.renkotechnologie.backend.modules.auth.service.UserDirectoryService;
import com.renkotechnologie.backend.modules.availability.service.AvailabilityService;
import com.renkotechnologie.backend.modules.booking.service.InterventionService;
import com.renkotechnologie.backend.modules.search.dto.ProviderSearchResponse;
import com.renkotechnologie.backend.modules.search.service.SearchService;
import java.time.LocalDate;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class SearchServiceImpl implements SearchService {

    private final UserDirectoryService userDirectoryService;
    private final InterventionService interventionService;
    private final AvailabilityService availabilityService;

    @Override
    public List<ProviderSearchResponse> rechercher(
            String callerEmail, String specialite, String quartier, Boolean disponibleUniquement, LocalDate date) {
        Long callerId = callerEmail == null ? null : userDirectoryService.getByEmail(callerEmail).id();

        return userDirectoryService.getProviders().stream()
                .filter(u -> callerId == null || !u.id().equals(callerId))
                .filter(u -> specialite == null || specialite.isBlank() || specialite.equalsIgnoreCase(u.specialite()))
                .filter(u -> quartier == null || quartier.isBlank() || quartier.equalsIgnoreCase(u.quartier()))
                .filter(u -> disponibleUniquement == null || !disponibleUniquement || u.disponible())
                .filter(u -> date == null || availabilityService.estDisponibleLe(u.id(), date))
                .map(u -> ProviderSearchResponse.fromSummary(u, missionsRealisees(u)))
                .toList();
    }

    private long missionsRealisees(UserSummary provider) {
        return interventionService.compterMissionsTerminees(provider.displayName());
    }
}
