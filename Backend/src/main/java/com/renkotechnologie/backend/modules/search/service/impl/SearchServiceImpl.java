package com.renkotechnologie.backend.modules.search.service.impl;

import com.renkotechnologie.backend.modules.auth.entity.Role;
import com.renkotechnologie.backend.modules.auth.entity.User;
import com.renkotechnologie.backend.modules.auth.repository.UserRepository;
import com.renkotechnologie.backend.modules.availability.entity.AvailabilityOverride;
import com.renkotechnologie.backend.modules.availability.repository.AvailabilityOverrideRepository;
import com.renkotechnologie.backend.modules.booking.entity.InterventionStatus;
import com.renkotechnologie.backend.modules.booking.repository.InterventionRepository;
import com.renkotechnologie.backend.modules.search.dto.ProviderSearchResponse;
import com.renkotechnologie.backend.modules.search.service.SearchService;
import java.time.LocalDate;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class SearchServiceImpl implements SearchService {

    private final UserRepository userRepository;
    private final InterventionRepository interventionRepository;
    private final AvailabilityOverrideRepository availabilityOverrideRepository;

    @Override
    public List<ProviderSearchResponse> rechercher(
            String callerEmail, String specialite, String quartier, Boolean disponibleUniquement, LocalDate date) {
        Long callerId = callerEmail == null
                ? null
                : userRepository.findByEmail(callerEmail).map(User::getId).orElse(null);

        return userRepository.findByRole(Role.PRESTATAIRE).stream()
                .filter(u -> callerId == null || !u.getId().equals(callerId))
                .filter(u -> specialite == null || specialite.isBlank() || specialite.equalsIgnoreCase(u.getSpecialite()))
                .filter(u -> quartier == null || quartier.isBlank() || quartier.equalsIgnoreCase(u.getQuartier()))
                .filter(u -> disponibleUniquement == null || !disponibleUniquement || u.isDisponible())
                .filter(u -> date == null || isDisponibleLe(u, date))
                .map(u -> ProviderSearchResponse.fromEntity(u, missionsRealisees(u)))
                .toList();
    }

    private boolean isDisponibleLe(User provider, LocalDate date) {
        return availabilityOverrideRepository
                .findByProviderIdAndDate(provider.getId(), date)
                .map(AvailabilityOverride::isDisponible)
                .orElse(true);
    }

    private long missionsRealisees(User provider) {
        String displayName = (provider.getPrenom() + " " + provider.getNom()).trim();
        return interventionRepository.countByProviderNameAndStatut(displayName, InterventionStatus.TERMINEE);
    }
}
