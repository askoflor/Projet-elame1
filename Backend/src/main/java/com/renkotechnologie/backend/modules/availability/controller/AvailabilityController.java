package com.renkotechnologie.backend.modules.availability.controller;

import com.renkotechnologie.backend.modules.auth.entity.User;
import com.renkotechnologie.backend.modules.availability.dto.AvailabilityOverrideResponse;
import com.renkotechnologie.backend.modules.availability.dto.SetRangeRequest;
import com.renkotechnologie.backend.modules.availability.dto.ToggleDateRequest;
import com.renkotechnologie.backend.modules.availability.service.AvailabilityService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/availability")
@RequiredArgsConstructor
public class AvailabilityController {

    private final AvailabilityService availabilityService;

    @GetMapping("/me")
    public ResponseEntity<List<AvailabilityOverrideResponse>> mesDisponibilites(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(availabilityService.mesDisponibilites(user.getEmail()));
    }

    /** Disponibilites publiques d'un prestataire, consultees par un client pour reserver un creneau. */
    @GetMapping
    public ResponseEntity<List<AvailabilityOverrideResponse>> disponibilitesPrestataire(@RequestParam String providerName) {
        return ResponseEntity.ok(availabilityService.disponibilitesPrestataire(providerName));
    }

    @PostMapping("/toggle")
    public ResponseEntity<List<AvailabilityOverrideResponse>> basculerDate(
            @AuthenticationPrincipal User user, @Valid @RequestBody ToggleDateRequest request) {
        return ResponseEntity.ok(availabilityService.basculerDate(user.getEmail(), request.getDate()));
    }

    @PostMapping("/range")
    public ResponseEntity<List<AvailabilityOverrideResponse>> definirPeriode(
            @AuthenticationPrincipal User user, @Valid @RequestBody SetRangeRequest request) {
        return ResponseEntity.ok(availabilityService.definirPeriode(
                user.getEmail(), request.getDateDebut(), request.getDateFin(), request.getDisponible()));
    }
}
