package com.renkotechnologie.backend.modules.search.service;

import com.renkotechnologie.backend.modules.search.dto.ProviderSearchResponse;
import java.time.LocalDate;
import java.util.List;

public interface SearchService {

    /**
     * Recherche des prestataires. {@code callerEmail} est l'email de
     * l'utilisateur connecte s'il y en a un (peut etre {@code null} pour un
     * visiteur non authentifie) ; si cet utilisateur est lui-meme un
     * prestataire, il est exclu de ses propres resultats de recherche.
     * Si {@code date} est fourni, seuls les prestataires disponibles ce
     * jour-la (selon leurs overrides de disponibilite) sont retournes.
     */
    List<ProviderSearchResponse> rechercher(
            String callerEmail, String specialite, String quartier, Boolean disponibleUniquement, LocalDate date);
}
