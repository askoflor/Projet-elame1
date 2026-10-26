package com.renkotechnologie.backend.modules.auth.service;

import com.renkotechnologie.backend.modules.auth.dto.UserSummary;
import java.util.List;

/**
 * Point d'acces en lecture seule aux comptes utilisateurs, destine aux autres
 * modules (availability, booking, search) : ils ne doivent plus dependre
 * directement de {@code auth.entity.User} ni de {@code auth.repository.UserRepository}.
 */
public interface UserDirectoryService {

    UserSummary getByEmail(String email);

    UserSummary getById(Long id);

    List<UserSummary> getProviders();

    UserSummary getProviderByDisplayName(String displayName);
}
