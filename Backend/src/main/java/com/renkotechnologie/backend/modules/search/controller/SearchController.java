package com.renkotechnologie.backend.modules.search.controller;

import com.renkotechnologie.backend.modules.auth.entity.User;
import com.renkotechnologie.backend.modules.search.dto.ProviderSearchResponse;
import com.renkotechnologie.backend.modules.search.service.SearchService;
import java.time.LocalDate;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * Recherche de prestataires. Endpoint public (visible aux visiteurs non
 * connectes) : si l'appelant est authentifie et est lui-meme prestataire, il
 * est automatiquement exclu de ses propres resultats.
 */
@RestController
@RequestMapping("/api/v1/search")
@RequiredArgsConstructor
public class SearchController {

    private final SearchService searchService;

    @GetMapping("/providers")
    public ResponseEntity<List<ProviderSearchResponse>> rechercherPrestataires(
            @AuthenticationPrincipal User caller,
            @RequestParam(required = false) String specialite,
            @RequestParam(required = false) String quartier,
            @RequestParam(required = false) Boolean disponible,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        String callerEmail = caller == null ? null : caller.getEmail();
        return ResponseEntity.ok(searchService.rechercher(callerEmail, specialite, quartier, disponible, date));
    }
}
