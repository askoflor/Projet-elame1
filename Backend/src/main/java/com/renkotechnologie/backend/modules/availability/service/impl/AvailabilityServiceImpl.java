package com.renkotechnologie.backend.modules.availability.service.impl;

import com.renkotechnologie.backend.modules.auth.dto.UserSummary;
import com.renkotechnologie.backend.modules.auth.service.UserDirectoryService;
import com.renkotechnologie.backend.modules.availability.dto.AvailabilityOverrideResponse;
import com.renkotechnologie.backend.modules.availability.entity.AvailabilityOverride;
import com.renkotechnologie.backend.modules.availability.repository.AvailabilityOverrideRepository;
import com.renkotechnologie.backend.modules.availability.service.AvailabilityService;
import java.time.LocalDate;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AvailabilityServiceImpl implements AvailabilityService {

    private final AvailabilityOverrideRepository overrideRepository;
    private final UserDirectoryService userDirectoryService;

    @Override
    public List<AvailabilityOverrideResponse> mesDisponibilites(String email) {
        UserSummary user = userDirectoryService.getByEmail(email);
        return toResponses(overrideRepository.findByProviderIdOrderByDateAsc(user.id()));
    }

    @Override
    public List<AvailabilityOverrideResponse> disponibilitesPrestataire(String providerName) {
        UserSummary provider = userDirectoryService.getProviderByDisplayName(providerName);
        return toResponses(overrideRepository.findByProviderIdOrderByDateAsc(provider.id()));
    }

    @Override
    @Transactional
    public List<AvailabilityOverrideResponse> basculerDate(String email, LocalDate date) {
        UserSummary user = userDirectoryService.getByEmail(email);
        var existing = overrideRepository.findByProviderIdAndDate(user.id(), date);
        if (existing.isPresent()) {
            AvailabilityOverride override = existing.get();
            override.setDisponible(!override.isDisponible());
            overrideRepository.save(override);
        } else {
            // Aucune exception enregistree = disponible par defaut ; le premier
            // basculement passe donc la date en indisponible.
            overrideRepository.save(AvailabilityOverride.builder().providerId(user.id()).date(date).disponible(false).build());
        }
        return mesDisponibilites(email);
    }

    @Override
    @Transactional
    public List<AvailabilityOverrideResponse> definirPeriode(String email, LocalDate debut, LocalDate fin, boolean disponible) {
        UserSummary user = userDirectoryService.getByEmail(email);
        for (LocalDate d = debut; !d.isAfter(fin); d = d.plusDays(1)) {
            var existing = overrideRepository.findByProviderIdAndDate(user.id(), d);
            if (existing.isPresent()) {
                existing.get().setDisponible(disponible);
                overrideRepository.save(existing.get());
            } else {
                overrideRepository.save(AvailabilityOverride.builder().providerId(user.id()).date(d).disponible(disponible).build());
            }
        }
        return mesDisponibilites(email);
    }

    @Override
    public boolean estDisponibleLe(Long providerId, LocalDate date) {
        return overrideRepository.findByProviderIdAndDate(providerId, date)
                .map(AvailabilityOverride::isDisponible)
                .orElse(true);
    }

    private List<AvailabilityOverrideResponse> toResponses(List<AvailabilityOverride> overrides) {
        return overrides.stream().map(AvailabilityOverrideResponse::fromEntity).toList();
    }
}
