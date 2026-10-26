package com.renkotechnologie.backend.modules.booking.service.impl;

import com.renkotechnologie.backend.common.exception.ResourceNotFoundException;
import com.renkotechnologie.backend.modules.auth.dto.UserSummary;
import com.renkotechnologie.backend.modules.auth.service.UserDirectoryService;
import com.renkotechnologie.backend.modules.booking.dto.ChiffrageRequest;
import com.renkotechnologie.backend.modules.booking.dto.CompletionRequest;
import com.renkotechnologie.backend.modules.booking.dto.InterventionCreateRequest;
import com.renkotechnologie.backend.modules.booking.dto.InterventionResponse;
import com.renkotechnologie.backend.modules.booking.dto.ProviderScheduleEntry;
import com.renkotechnologie.backend.modules.booking.entity.Intervention;
import com.renkotechnologie.backend.modules.booking.entity.InterventionPhoto;
import com.renkotechnologie.backend.modules.booking.entity.InterventionStatus;
import com.renkotechnologie.backend.modules.booking.repository.InterventionPhotoRepository;
import com.renkotechnologie.backend.modules.booking.repository.InterventionRepository;
import com.renkotechnologie.backend.modules.booking.service.InterventionService;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class InterventionServiceImpl implements InterventionService {

    private final InterventionRepository interventionRepository;
    private final InterventionPhotoRepository photoRepository;
    private final UserDirectoryService userDirectoryService;

    @Override
    @Transactional
    public InterventionResponse creer(String clientEmail, InterventionCreateRequest request) {
        UserSummary client = userDirectoryService.getByEmail(clientEmail);
        Intervention intervention = Intervention.builder()
                .reference(genererReference())
                .clientId(client.id())
                .providerName(request.getProviderName())
                .service(request.getService())
                .titre(request.getTitre())
                .description(request.getDescription() == null ? "" : request.getDescription())
                .date(request.getDate())
                .heures(request.getHeures())
                .urgence(request.getUrgence())
                .adresse(request.getAdresse())
                .statut(InterventionStatus.ATTENTE)
                .build();
        interventionRepository.save(intervention);
        return InterventionResponse.fromEntity(intervention, List.of(), client.displayName(), client.telephone());
    }

    @Override
    @Transactional(readOnly = true)
    public List<InterventionResponse> mesReservationsClient(String email) {
        UserSummary user = userDirectoryService.getByEmail(email);
        return interventionRepository.findByClientIdOrderByCreeLeDesc(user.id()).stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<InterventionResponse> mesMissionsPrestataire(String email) {
        UserSummary user = userDirectoryService.getByEmail(email);
        return interventionRepository.findByProviderNameOrderByCreeLeDesc(user.displayName()).stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<ProviderScheduleEntry> planningPrestataire(String providerName) {
        return interventionRepository.findByProviderNameAndStatutNot(providerName, InterventionStatus.ANNULEE).stream()
                .map(ProviderScheduleEntry::fromEntity)
                .toList();
    }

    @Override
    @Transactional
    public InterventionResponse chiffrer(String prestataireEmail, String reference, ChiffrageRequest request) {
        Intervention intervention = findOwnedByPrestataire(prestataireEmail, reference);
        intervention.setMontant(request.getMontant());
        if (request.getDateConfirmee() != null) {
            intervention.setDate(request.getDateConfirmee());
        }
        if (request.getNote() != null && !request.getNote().isBlank()) {
            intervention.setNotePrestataire(request.getNote());
        }
        intervention.setStatut(InterventionStatus.ENCOURS);
        interventionRepository.save(intervention);
        return toResponse(intervention);
    }

    @Override
    @Transactional
    public InterventionResponse terminer(String prestataireEmail, String reference, CompletionRequest request) {
        Intervention intervention = findOwnedByPrestataire(prestataireEmail, reference);
        if (intervention.getStatut() == InterventionStatus.TERMINEE) {
            throw new ResourceNotFoundException("Cette intervention est deja terminee");
        }
        intervention.setCompletionDescription(request.getDescription());
        intervention.setStatut(InterventionStatus.TERMINEE);
        interventionRepository.save(intervention);

        List<InterventionPhoto> photos = request.getPhotos().stream()
                .map(data -> InterventionPhoto.builder().intervention(intervention).imageData(data).build())
                .toList();
        photoRepository.saveAll(photos);

        return toResponse(intervention, photos);
    }

    @Override
    @Transactional
    public InterventionResponse annuler(String prestataireEmail, String reference) {
        Intervention intervention = findOwnedByPrestataire(prestataireEmail, reference);
        intervention.setStatut(InterventionStatus.ANNULEE);
        interventionRepository.save(intervention);
        return toResponse(intervention);
    }

    @Override
    public long compterMissionsTerminees(String providerName) {
        return interventionRepository.countByProviderNameAndStatut(providerName, InterventionStatus.TERMINEE);
    }

    private Intervention findOwnedByPrestataire(String prestataireEmail, String reference) {
        UserSummary prestataire = userDirectoryService.getByEmail(prestataireEmail);
        Intervention intervention = interventionRepository.findByReference(reference)
                .orElseThrow(() -> new ResourceNotFoundException("Intervention introuvable"));
        if (!intervention.getProviderName().equals(prestataire.displayName())) {
            throw new ResourceNotFoundException("Intervention introuvable");
        }
        return intervention;
    }

    private InterventionResponse toResponse(Intervention intervention) {
        List<InterventionPhoto> photos = photoRepository.findByInterventionIdOrderByCreatedAtAsc(intervention.getId());
        return toResponse(intervention, photos);
    }

    private InterventionResponse toResponse(Intervention intervention, List<InterventionPhoto> photos) {
        UserSummary client = userDirectoryService.getById(intervention.getClientId());
        return InterventionResponse.fromEntity(intervention, photos, client.displayName(), client.telephone());
    }

    private String genererReference() {
        return "INT-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}
