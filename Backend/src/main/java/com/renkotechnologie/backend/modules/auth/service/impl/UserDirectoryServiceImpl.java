package com.renkotechnologie.backend.modules.auth.service.impl;

import com.renkotechnologie.backend.common.exception.ResourceNotFoundException;
import com.renkotechnologie.backend.modules.auth.dto.UserSummary;
import com.renkotechnologie.backend.modules.auth.entity.Role;
import com.renkotechnologie.backend.modules.auth.entity.User;
import com.renkotechnologie.backend.modules.auth.repository.UserRepository;
import com.renkotechnologie.backend.modules.auth.service.UserDirectoryService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserDirectoryServiceImpl implements UserDirectoryService {

    private final UserRepository userRepository;

    @Override
    public UserSummary getByEmail(String email) {
        return userRepository.findByEmail(email)
                .map(this::toSummary)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur introuvable"));
    }

    @Override
    public UserSummary getById(Long id) {
        return userRepository.findById(id)
                .map(this::toSummary)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur introuvable"));
    }

    @Override
    public List<UserSummary> getProviders() {
        return userRepository.findByRole(Role.PRESTATAIRE).stream()
                .map(this::toSummary)
                .toList();
    }

    @Override
    public UserSummary getProviderByDisplayName(String displayName) {
        return userRepository.findByRole(Role.PRESTATAIRE).stream()
                .map(this::toSummary)
                .filter(u -> u.displayName().equals(displayName))
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException("Prestataire introuvable"));
    }

    private UserSummary toSummary(User user) {
        return new UserSummary(
                user.getId(),
                user.getNom(),
                user.getPrenom(),
                user.getEmail(),
                user.getTelephone(),
                user.getSpecialite(),
                user.getQuartier(),
                user.getPhotoUrl(),
                user.getAbout(),
                user.isCertifie(),
                user.isDisponible());
    }
}
