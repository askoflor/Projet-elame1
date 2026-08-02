package com.renkotechnologie.backend.modules.booking.repository;

import com.renkotechnologie.backend.modules.booking.entity.Intervention;
import com.renkotechnologie.backend.modules.booking.entity.InterventionStatus;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InterventionRepository extends JpaRepository<Intervention, Long> {

    Optional<Intervention> findByReference(String reference);

    List<Intervention> findByClientIdOrderByCreeLeDesc(Long clientId);

    List<Intervention> findByProviderNameOrderByCreeLeDesc(String providerName);

    /** Planning "public" d'un prestataire : sert a griser les creneaux deja pris pour tout client qui consulte son calendrier. */
    List<Intervention> findByProviderNameAndStatutNot(String providerName, InterventionStatus excludedStatut);
}
