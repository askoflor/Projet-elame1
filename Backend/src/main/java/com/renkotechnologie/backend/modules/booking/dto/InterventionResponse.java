package com.renkotechnologie.backend.modules.booking.dto;

import com.renkotechnologie.backend.modules.booking.entity.Intervention;
import com.renkotechnologie.backend.modules.booking.entity.InterventionPhoto;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@AllArgsConstructor
public class InterventionResponse {

    private String reference;
    private String clientNom;
    private String clientPhone;
    private String providerName;
    private String service;
    private String titre;
    private String description;
    private LocalDate date;
    private List<Integer> heures;
    private String urgence;
    private String adresse;
    private Double montant;
    private String notePrestataire;
    private String statut;
    private String completionDescription;
    private List<String> completionPhotos;
    private LocalDateTime creeLe;

    public static InterventionResponse fromEntity(
            Intervention i, List<InterventionPhoto> photos, String clientNom, String clientPhone) {
        return InterventionResponse.builder()
                .reference(i.getReference())
                .clientNom(clientNom)
                .clientPhone(clientPhone)
                .providerName(i.getProviderName())
                .service(i.getService())
                .titre(i.getTitre())
                .description(i.getDescription())
                .date(i.getDate())
                // copie immediate : force l'initialisation de la collection
                // (lazy-loaded) tant que la session Hibernate est encore active
                // (open-in-view etant desactive, elle ne le sera plus a la serialisation JSON).
                .heures(List.copyOf(i.getHeures()))
                .urgence(i.getUrgence())
                .adresse(i.getAdresse())
                .montant(i.getMontant())
                .notePrestataire(i.getNotePrestataire())
                .statut(i.getStatut().name())
                .completionDescription(i.getCompletionDescription())
                .completionPhotos(photos.stream().map(InterventionPhoto::getImageData).toList())
                .creeLe(i.getCreeLe())
                .build();
    }
}
