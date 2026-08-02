package com.renkotechnologie.backend.modules.booking.service.impl;

import com.renkotechnologie.backend.modules.auth.entity.Role;
import com.renkotechnologie.backend.modules.auth.entity.User;
import com.renkotechnologie.backend.modules.auth.exception.ResourceNotFoundException;
import com.renkotechnologie.backend.modules.auth.repository.UserRepository;
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
    private final UserRepository userRepository;

    @Override
    @Transactional
    public InterventionResponse creer(String clientEmail, InterventionCreateRequest request) {
        User client = findUserByEmail(clientEmail);
        Intervention intervention = Intervention.builder()
                .reference(genererReference())
                .client(client)
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
        return InterventionResponse.fromEntity(intervention, List.of());
    }

    @Override
    public List<InterventionResponse> mesInterventions(String email) {
        User user = findUserByEmail(email);
        List<Intervention> interventions = user.getRole() == Role.PRESTATAIRE
                ? interventionRepository.findByProviderNameOrderByCreeLeDesc(displayName(user))
                : interventionRepository.findByClientIdOrderByCreeLeDesc(user.getId());
        return interventions.stream().map(this::toResponse).toList();
    }

    @Override
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

        return InterventionResponse.fromEntity(intervention, photos);
    }

    @Override
    @Transactional
    public InterventionResponse annuler(String prestataireEmail, String reference) {
        Intervention intervention = findOwnedByPrestataire(prestataireEmail, reference);
        intervention.setStatut(InterventionStatus.ANNULEE);
        interventionRepository.save(intervention);
        return toResponse(intervention);
    }

    private Intervention findOwnedByPrestataire(String prestataireEmail, String reference) {
        User prestataire = findUserByEmail(prestataireEmail);
        Intervention intervention = interventionRepository.findByReference(reference)
                .orElseThrow(() -> new ResourceNotFoundException("Intervention introuvable"));
        if (!intervention.getProviderName().equals(displayName(prestataire))) {
            throw new ResourceNotFoundException("Intervention introuvable");
        }
        return intervention;
    }

    private InterventionResponse toResponse(Intervention intervention) {
        List<InterventionPhoto> photos = photoRepository.findByInterventionIdOrderByCreatedAtAsc(intervention.getId());
        return InterventionResponse.fromEntity(intervention, photos);
    }

    private String displayName(User user) {
        return (user.getPrenom() + " " + user.getNom()).trim();
    }

    private String genererReference() {
        return "INT-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    private User findUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur introuvable"));
    }
}
