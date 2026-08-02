package com.renkotechnologie.backend.modules.search.service;

import com.renkotechnologie.backend.modules.search.dto.ProviderSearchResponse;
import java.util.List;

public interface SearchService {

    /**
     * Recherche des prestataires. {@code callerEmail} est l'email de
     * l'utilisateur connecte s'il y en a un (peut etre {@code null} pour un
     * visiteur non authentifie) ; si cet utilisateur est lui-meme un
     * prestataire, il est exclu de ses propres resultats de recherche.
     */
    List<ProviderSearchResponse> rechercher(String callerEmail, String specialite, String quartier, Boolean disponibleUniquement);
}
