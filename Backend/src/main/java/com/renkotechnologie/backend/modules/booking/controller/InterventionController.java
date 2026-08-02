package com.renkotechnologie.backend.modules.booking.controller;

import com.renkotechnologie.backend.modules.auth.entity.User;
import com.renkotechnologie.backend.modules.booking.dto.ChiffrageRequest;
import com.renkotechnologie.backend.modules.booking.dto.CompletionRequest;
import com.renkotechnologie.backend.modules.booking.dto.InterventionCreateRequest;
import com.renkotechnologie.backend.modules.booking.dto.InterventionResponse;
import com.renkotechnologie.backend.modules.booking.dto.ProviderScheduleEntry;
import com.renkotechnologie.backend.modules.booking.service.InterventionService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/interventions")
@RequiredArgsConstructor
public class InterventionController {

    private final InterventionService interventionService;

    @PostMapping
    public ResponseEntity<InterventionResponse> creer(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody InterventionCreateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(interventionService.creer(user.getEmail(), request));
    }

    /** Renvoie les interventions du client connecte, ou les missions du prestataire connecte selon le role. */
    @GetMapping("/mine")
    public ResponseEntity<List<InterventionResponse>> mesInterventions(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(interventionService.mesInterventions(user.getEmail()));
    }

    /** Planning public d'un prestataire (creneaux occupes), accessible a tout utilisateur connecte pour reserver. */
    @GetMapping("/planning")
    public ResponseEntity<List<ProviderScheduleEntry>> planning(@RequestParam String providerName) {
        return ResponseEntity.ok(interventionService.planningPrestataire(providerName));
    }

    @PostMapping("/{reference}/chiffrer")
    public ResponseEntity<InterventionResponse> chiffrer(
            @AuthenticationPrincipal User user,
            @PathVariable String reference,
            @Valid @RequestBody ChiffrageRequest request) {
        return ResponseEntity.ok(interventionService.chiffrer(user.getEmail(), reference, request));
    }

    @PostMapping("/{reference}/terminer")
    public ResponseEntity<InterventionResponse> terminer(
            @AuthenticationPrincipal User user,
            @PathVariable String reference,
            @Valid @RequestBody CompletionRequest request) {
        return ResponseEntity.ok(interventionService.terminer(user.getEmail(), reference, request));
    }

    @PostMapping("/{reference}/annuler")
    public ResponseEntity<InterventionResponse> annuler(
            @AuthenticationPrincipal User user,
            @PathVariable String reference) {
        return ResponseEntity.ok(interventionService.annuler(user.getEmail(), reference));
    }
}
