package com.renkotechnologie.backend.modules.availability.service.impl;

import com.renkotechnologie.backend.modules.auth.entity.Role;
import com.renkotechnologie.backend.modules.auth.entity.User;
import com.renkotechnologie.backend.modules.auth.exception.ResourceNotFoundException;
import com.renkotechnologie.backend.modules.auth.repository.UserRepository;
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
    private final UserRepository userRepository;

    @Override
    public List<AvailabilityOverrideResponse> mesDisponibilites(String email) {
        User user = findUserByEmail(email);
        return toResponses(overrideRepository.findByProviderIdOrderByDateAsc(user.getId()));
    }

    @Override
    public List<AvailabilityOverrideResponse> disponibilitesPrestataire(String providerName) {
        User provider = userRepository.findByRole(Role.PRESTATAIRE).stream()
                .filter(u -> displayName(u).equals(providerName))
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException("Prestataire introuvable"));
        return toResponses(overrideRepository.findByProviderIdOrderByDateAsc(provider.getId()));
    }

    @Override
    @Transactional
    public List<AvailabilityOverrideResponse> basculerDate(String email, LocalDate date) {
        User user = findUserByEmail(email);
        var existing = overrideRepository.findByProviderIdAndDate(user.getId(), date);
        if (existing.isPresent()) {
            AvailabilityOverride override = existing.get();
            override.setDisponible(!override.isDisponible());
            overrideRepository.save(override);
        } else {
            // Aucune exception enregistree = disponible par defaut ; le premier
            // basculement passe donc la date en indisponible.
            overrideRepository.save(AvailabilityOverride.builder().provider(user).date(date).disponible(false).build());
        }
        return mesDisponibilites(email);
    }

    @Override
    @Transactional
    public List<AvailabilityOverrideResponse> definirPeriode(String email, LocalDate debut, LocalDate fin, boolean disponible) {
        User user = findUserByEmail(email);
        for (LocalDate d = debut; !d.isAfter(fin); d = d.plusDays(1)) {
            var existing = overrideRepository.findByProviderIdAndDate(user.getId(), d);
            if (existing.isPresent()) {
                existing.get().setDisponible(disponible);
                overrideRepository.save(existing.get());
            } else {
                overrideRepository.save(AvailabilityOverride.builder().provider(user).date(d).disponible(disponible).build());
            }
        }
        return mesDisponibilites(email);
    }

    private List<AvailabilityOverrideResponse> toResponses(List<AvailabilityOverride> overrides) {
        return overrides.stream().map(AvailabilityOverrideResponse::fromEntity).toList();
    }

    private String displayName(User user) {
        return (user.getPrenom() + " " + user.getNom()).trim();
    }

    private User findUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur introuvable"));
    }
}
