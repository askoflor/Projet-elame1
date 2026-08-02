package com.renkotechnologie.backend.modules.search.service.impl;

import com.renkotechnologie.backend.modules.auth.entity.Role;
import com.renkotechnologie.backend.modules.auth.entity.User;
import com.renkotechnologie.backend.modules.auth.repository.UserRepository;
import com.renkotechnologie.backend.modules.booking.entity.InterventionStatus;
import com.renkotechnologie.backend.modules.booking.repository.InterventionRepository;
import com.renkotechnologie.backend.modules.search.dto.ProviderSearchResponse;
import com.renkotechnologie.backend.modules.search.service.SearchService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class SearchServiceImpl implements SearchService {

    private final UserRepository userRepository;
    private final InterventionRepository interventionRepository;

    @Override
    public List<ProviderSearchResponse> rechercher(
            String callerEmail, String specialite, String quartier, Boolean disponibleUniquement) {
        Long callerId = callerEmail == null
                ? null
                : userRepository.findByEmail(callerEmail).map(User::getId).orElse(null);

        return userRepository.findByRole(Role.PRESTATAIRE).stream()
                .filter(u -> callerId == null || !u.getId().equals(callerId))
                .filter(u -> specialite == null || specialite.isBlank() || specialite.equalsIgnoreCase(u.getSpecialite()))
                .filter(u -> quartier == null || quartier.isBlank() || quartier.equalsIgnoreCase(u.getQuartier()))
                .filter(u -> disponibleUniquement == null || !disponibleUniquement || u.isDisponible())
                .map(u -> ProviderSearchResponse.fromEntity(u, missionsRealisees(u)))
                .toList();
    }

    private long missionsRealisees(User provider) {
        String displayName = (provider.getPrenom() + " " + provider.getNom()).trim();
        return interventionRepository.countByProviderNameAndStatut(displayName, InterventionStatus.TERMINEE);
    }
}
